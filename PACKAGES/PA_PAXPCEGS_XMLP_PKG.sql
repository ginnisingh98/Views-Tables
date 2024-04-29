--------------------------------------------------------
--  DDL for Package PA_PAXPCEGS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPCEGS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPCEGSS.pls 120.0 2008/01/02 11:40:15 krreddy noship $ */
	p_start_organization_id	number;
	ENDING_DATE	date;
	ENDING_DATE_1   varchar2(25);
	LINKAGE	varchar2(40);
	STATUS	varchar2(40);
	DISPLAY_RELEASED_GROUP	varchar2(40);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_rule_optimizer	varchar2(3);
	C_COMPANY_NAME_HEADER	varchar2(50);
	Start_organization	varchar2(240);
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	FUNCTION get_start_org RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function Start_organization_p return varchar2;
END PA_PAXPCEGS_XMLP_PKG;

/
