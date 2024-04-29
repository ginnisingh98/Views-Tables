--------------------------------------------------------
--  DDL for Package PER_PERHDSUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERHDSUM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERHDSUMS.pls 120.1 2007/12/06 11:27:29 amakrish noship $ */
	P_ORGANIZATION_STRUCTURE_ID	number;
	P_REPORT_DATE_FROM	date;
	P_REPORT_DATE_TO	date;
	P_REPORT_DATE_FROM_LP	varchar2(30);
	P_REPORT_DATE_TO_LP	varchar2(30);
	P_TOP_ORGANIZATION_ID	number;
	P_INCLUDE_TOP_ORG	varchar2(40);
	P_BUSINESS_GROUP_ID	number;
	P_ROLL_UP	varchar2(32767);
	P_REPORT_DATE	date;
	P_BUDGET	varchar2(32767);
	P_JOB_CATEGORY	varchar2(32767);
	P_INCLUDE_ASG_TYPE	varchar2(32767);
	P_CONC_REQUEST_ID	number;
	CP_BUSINESS_GROUP_NAME	varchar2(240);
	CP_ORGANIZATION_NAME	varchar2(240);
	CP_TOP_ORG_NAME	varchar2(240);
	CP_ORGANIZATION_HIERARCHY_NAME	varchar2(80);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function CP_BUSINESS_GROUP_NAME_p return varchar2;
	Function CP_ORGANIZATION_NAME_p return varchar2;
	Function CP_TOP_ORG_NAME_p return varchar2;
	Function CP_ORGANIZATION_HIERARCHY_NAM return varchar2;
END PER_PERHDSUM_XMLP_PKG;

/
