--------------------------------------------------------
--  DDL for Package PER_PERUSADA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERUSADA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERUSADAS.pls 120.1 2007/12/28 07:38:47 amakrish noship $ */
	P_ORG_STRUCTURE_VERSION_ID	number;
	P_SESSION_DATE1 varchar2(240);
	P_ORG_STRUCTURE_VERSION_ID_1	number;
	P_BUSINESS_GROUP_ID	number;
	P_ORGANIZATION_ID	varchar2(40);
	P_SESSION_DATE	date;
	P_VIEW_JOB_REQS	varchar2(32767);
	P_VIEW_POSITION_REQS	varchar2(32767);
	P_REGISTERED_DISABLED	varchar2(32767);
	P_PERSON	number;
	P_EMPLOYEE_NUMBER	number;
	P_JOB_ID	number;
	P_POSITION_NAME	varchar2(240);
	P_LOCATION	number;
	P_SORT	varchar2(32767);
	P_CONC_REQUEST_ID	number;
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_TYPE	varchar2(30);
	C_ORGANIZATION_HIERARCHY	varchar2(30);
	C_ORGANIZATION	varchar2(60);
	C_DISABILITY_ID_FLEX_NUM	number;
	C_DISABILITY_ACC_ID_FLEX_NUM	number;
/*	C_lex_assign_where	varchar2(20000) := := 'and 1 = 1' ;
	C_lex_assign_order	varchar2(250) := := 'initcap(peo.full_name)' ;*/
	C_lex_assign_where	varchar2(20000) := 'and 1 = 1' ;
	C_lex_assign_order	varchar2(250) := 'initcap(peo.full_name)' ;
	C_full_name	varchar2(240);
	C_employee_number	varchar2(40);
	C_job_name	varchar2(80);
	C_location_code	varchar2(40);
	function BeforeReport return boolean  ;
	function g_1groupfilter(establishment_id1 in number) return boolean  ;
	function G_DisabilitiesGroupFilter return boolean  ;
	function G_2GroupFilter return boolean  ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_TYPE_p return varchar2;
	Function C_ORGANIZATION_HIERARCHY_p return varchar2;
	Function C_ORGANIZATION_p return varchar2;
	Function C_DISABILITY_ID_FLEX_NUM_p return number;
	Function C_DISABILITY_ACC_ID_FLEX_NUM_p return number;
	Function C_lex_assign_where_p return varchar2;
	Function C_lex_assign_order_p return varchar2;
	Function C_full_name_p return varchar2;
	Function C_employee_number_p return varchar2;
	Function C_job_name_p return varchar2;
	Function C_location_code_p return varchar2;
END PER_PERUSADA_XMLP_PKG;

/
