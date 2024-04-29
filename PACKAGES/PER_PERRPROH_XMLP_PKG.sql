--------------------------------------------------------
--  DDL for Package PER_PERRPROH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPROH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERRPROHS.pls 120.1 2007/12/06 11:33:13 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_SESSION_DATE1 varchar2(240);
	P_CONC_REQUEST_ID	number;
	P_PARENT_ORGANIZATION_ID	number;
	P_ORG_STRUCTURE_VERSION_ID	number;
	P_MANAGER_FLAG	varchar2(30);
	C_type	varchar2(90);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_ORG_HIERARCHY_NAME	varchar2(30);
	C_VERSION	number;
	C_VERSION_START_DATE	date;
	C_VERSION_END_DATE	date;
	C_PARENT_ORG_NAME	varchar2(240);
	C_SESSION_DATE	varchar2(11);
	C_MANAGERS_SHOWN	varchar2(30);
	--C_GLOBAL_HIERARCHY	varchar2(80) := := 'Global Organization Hierarchy' ;
	C_GLOBAL_HIERARCHY	varchar2(80) := 'Global Organization Hierarchy' ;
	function BeforeReport return boolean  ;
	function c_nameformula(organization_id_parent in number) return varchar2  ;
	function c_count_org_subords2formula(organization_id_child in number) return number  ;
	--function c_count_child_orgs1formula(organization_id_parent in number) return number  ;
	function c_count_child_orgs1formula(arg_organization_id_parent in number) return number  ;
	function c_count_managersformula(organization_id_parent in number) return varchar2  ;
	function c_count_managers1formula(organization_id_child in number) return number  ;
	function c_count_org_subordsformula(organization_id_parent in number) return number  ;
	function AfterReport return boolean  ;
	Function C_type_p return varchar2;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_ORG_HIERARCHY_NAME_p return varchar2;
	Function C_VERSION_p return number;
	Function C_VERSION_START_DATE_p return date;
	Function C_VERSION_END_DATE_p return date;
	Function C_PARENT_ORG_NAME_p return varchar2;
	Function C_SESSION_DATE_p return varchar2;
	Function C_MANAGERS_SHOWN_p return varchar2;
	Function C_GLOBAL_HIERARCHY_p return varchar2;
END PER_PERRPROH_XMLP_PKG;

/
