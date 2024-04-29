--------------------------------------------------------
--  DDL for Package PER_PERRPRAS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPRAS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERRPRASS.pls 120.1 2007/12/06 11:31:52 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_SESSION_DATE1 varchar2(240);
	P_CONC_REQUEST_ID	number;
	P_PERSON_TYPE	varchar2(30);
	P_PEOPLE_GROUP_FLEX_ID	number;
	P_PEOPLE_GROUP_ID	varchar2(240);
	P_JOB_ID	number;
	P_POSITION_ID	number;
	P_PAYROLL_ID	number;
	P_PRIMARY_FLAG	varchar2(1);
	P_ASG_STATUS_TYPE_ID1	number;
	P_ASG_STATUS_TYPE_ID2	number;
	P_ASG_STATUS_TYPE_ID3	number;
	P_ASG_STATUS_TYPE_ID4	number;
	P_LEGISLATION_CODE	varchar2(2);
	P_GRADE_ID	number;
	--P_MATCHING_CRITERIA	varchar2(400);
	P_MATCHING_CRITERIA	varchar2(400) := 'AND 1=1';
	P_STATUS_MATCHING	varchar2(240);
	P_ORGANIZATION_STRUCTURE_ID	number;
	P_ORG_STRUCTURE_VERSION_ID	number;
	P_PARENT_ORGANIZATION_ID	number;
	--P_ORG_MATCHING	varchar2(400);
	P_ORG_MATCHING	varchar2(400) := ' ';
	P_APL_ORDER	varchar2(240);
	P_EMP_ORDER	varchar2(240);
	--P_JOB_MATCHING	varchar2(80);
	P_JOB_MATCHING	varchar2(80) := ' ';
	--P_POSITION_MATCHING	varchar2(80);
	P_POSITION_MATCHING	varchar2(80) := ' ';
	--P_GRADE_MATCHING	varchar2(80);
	P_GRADE_MATCHING	varchar2(80) := ' ';
	--P_PAYROLL_MATCHING	varchar2(80);
	P_PAYROLL_MATCHING	varchar2(80) := ' ';
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_PERSON_TYPE_DESC	varchar2(80);
	C_JOB_DESC	varchar2(240);
	C_POSITION_DESC	varchar2(240);
	C_GRADE_DESC	varchar2(240);
	C_PAYROLL_DESC	varchar2(80);
	C_PRIMARY_FLAG_DESC	varchar2(30);
	C_ASG_STATUS_DESC1	varchar2(100);
	C_ASG_STATUS_DESC2	varchar2(100);
	C_ASG_STATUS_DESC3	varchar2(100);
	C_ASG_STATUS_DESC4	varchar2(100);
	C_ORG_STRUCTURE_DESC	varchar2(80);
	C_ORG_STRUCTURE_VERSION_DESC	number;
	C_VERSION_FROM_DESC	date;
	C_VERSION_TO_DESC	date;
	C_ORGANIZATION_DESC	varchar2(240);
	C_STATUS_LIST	varchar2(500);
	C_SESSION_DATE	date;
	--C_GLOBAL_HIERARCHY	varchar2(80) := := 'Global Organization Hierarchy' ;
	C_GLOBAL_HIERARCHY	varchar2(80) := 'Global Organization Hierarchy' ;
	--added
	p_status_matching_1 varchar2(240);
	function BeforeReport return boolean  ;
	function c_status_start_dateformula(p_assignment_id in number, p_assignment_status_type_id in number) return date  ;
	function c_status_end_dateformula(p_assignment_id in number, p_assignment_status_type_id in number) return date  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_PERSON_TYPE_DESC_p return varchar2;
	Function C_JOB_DESC_p return varchar2;
	Function C_POSITION_DESC_p return varchar2;
	Function C_GRADE_DESC_p return varchar2;
	Function C_PAYROLL_DESC_p return varchar2;
	Function C_PRIMARY_FLAG_DESC_p return varchar2;
	Function C_ASG_STATUS_DESC1_p return varchar2;
	Function C_ASG_STATUS_DESC2_p return varchar2;
	Function C_ASG_STATUS_DESC3_p return varchar2;
	Function C_ASG_STATUS_DESC4_p return varchar2;
	Function C_ORG_STRUCTURE_DESC_p return varchar2;
	Function C_ORG_STRUCTURE_VERSION_DESC_p return number;
	Function C_VERSION_FROM_DESC_p return date;
	Function C_VERSION_TO_DESC_p return date;
	Function C_ORGANIZATION_DESC_p return varchar2;
	Function C_STATUS_LIST_p return varchar2;
	Function C_SESSION_DATE_p return date;
	Function C_GLOBAL_HIERARCHY_p return varchar2;
END PER_PERRPRAS_XMLP_PKG;

/
