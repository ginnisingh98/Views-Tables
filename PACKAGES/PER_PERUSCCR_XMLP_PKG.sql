--------------------------------------------------------
--  DDL for Package PER_PERUSCCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERUSCCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERUSCCRS.pls 120.2 2008/04/02 08:18:25 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_SESSION_DATE1 varchar2(240);
	P_CONC_REQUEST_ID	number;
	P_PARENT_ORGANIZATION_ID	varchar2(40);
	P_ORG_STRUCTURE_VERSION_ID	varchar2(40);
	P_QL_DATE_FROM	date;
	P_QL_DATE_FROM1 varchar2(240);
	P_QL_DATE_TO	date;
	P_QL_DATE_TO1 varchar2(240);
	P_QUALIFYING_EVENT	varchar2(40);
	P_COV_START_FROM	date;
	P_COV_START_FROM1 varchar2(240);
	P_COV_START_TO	date;
	P_COV_START_TO1 varchar2(240);
	P_COV_END_FROM	date;
	P_COV_END_FROM1 varchar2(240);
	P_COVERAGE_END_TO	date;
	P_COV_END_TO1 varchar2(240);
	P_COBRA_STATUS	varchar2(40);
	P_BEN_PLAN_TYPE_ID	number;
	P_BENEFIT_PLAN_TYPE_ID	varchar2(40);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_qualifying_event	varchar2(80);
	C_COBRA_STATUS	varchar2(80);
	C_PARENT_ORGANIZATION_NAME	varchar2(240);
	C_ORG_STRUCTURE_NAME	varchar2(30);
	C_BENEFIT_PLAN_NAME	varchar2(30);
	C_END_OF_TIME	date;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_qualifying_event_p return varchar2;
	Function C_COBRA_STATUS_p return varchar2;
	Function C_PARENT_ORGANIZATION_NAME_p return varchar2;
	Function C_ORG_STRUCTURE_NAME_p return varchar2;
	Function C_BENEFIT_PLAN_NAME_p return varchar2;
	Function C_END_OF_TIME_p return date;
END PER_PERUSCCR_XMLP_PKG;

/
