--------------------------------------------------------
--  DDL for Package PA_PAXRWDOH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWDOH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWDOHS.pls 120.0 2008/01/02 11:57:03 krreddy noship $ */
	START_ORG_ID	varchar2(200);
	P_CONC_REQUEST_ID	number;
	P_burden	varchar2(200);
	P_select_column	varchar2(200):='''hieracy_type''';
	P_select_column1	varchar2(200):='pi.org_structure_version_id org_structure_version_id';
	P_structure_id	varchar2(200):='and 1=1';
	P_version_id	varchar2(200):='and 1=1';
	P_where_clause	varchar2(200):='and    p.org_structure_version_id = pi.org_structure_version_id';
	P_where_clause1	varchar2(200):='and  HR2.ORG_INFORMATION_CONTEXT = ''Project Burdening Hierarchy''';
	P_decode_column	varchar2(200):='1';
	P_from_clause	varchar2(200):='per_org_structure_versions  posv,hr_organization_information hr';
	P_hierarchy_type	varchar2(200);
	P_org_hr	varchar2(200):='and 1=1';
	P_parent_org_id	varchar2(200):='pi.exp_start_org_id';
	C_Company_Name_Header	varchar2(40);
	C_Org_Name	varchar2(60);
	C_NO_DATA_FOUND	varchar2(80);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Org_Name_p return varchar2;
	Function C_NO_DATA_FOUND_p return varchar2;
END PA_PAXRWDOH_XMLP_PKG;

/
