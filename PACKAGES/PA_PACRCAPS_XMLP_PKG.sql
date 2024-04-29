--------------------------------------------------------
--  DDL for Package PA_PACRCAPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PACRCAPS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PACRCAPSS.pls 120.0 2008/01/02 10:56:58 krreddy noship $ */
	P_PROJECT_TYPE	varchar2(32767);
	P_PROJECT_ID	number;
	P_PROJECT_ORG	number;
	P_CLASS_CATEGORY	varchar2(30);
	P_CLASS_CODE	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_debug_mode	varchar2(1);
	CP_project_id	number;
	CP_COMPANY_NAME	varchar2(30);
	CP_PROJECT_NUMBER	varchar2(30);
	CP_PROJECT_ORG	varchar2(60);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_FORMAT_MASDFormula return Char  ;
	Function CP_project_id_p return number;
	Function CP_COMPANY_NAME_p return varchar2;
	Function CP_PROJECT_NUMBER_p return varchar2;
	Function CP_PROJECT_ORG_p return varchar2;
END PA_PACRCAPS_XMLP_PKG;

/
