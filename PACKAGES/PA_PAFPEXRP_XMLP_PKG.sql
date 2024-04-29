--------------------------------------------------------
--  DDL for Package PA_PAFPEXRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAFPEXRP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPEXRPS.pls 120.0 2008/01/02 10:59:34 krreddy noship $ */
	p_project_id_param	varchar2(100);
	P_PROJECT_ID_parameter number;
	P_ASSIGNMENT_ID_PARAM	varchar2(100);
	P_ORG_ID	number;
	P_ORGANIZATION_ID	number;
	P_START_ORGANIZATION_ID	number;
	P_PROJECT_ID	number;
	P_ASSIGNMENT_ID	number;
	P_ORG_STRUCTURE_VERSION_ID	number;
	P_FCST_START_DATE	date;
	P_FCST_END_DATE	date;
	P_CONC_REQUEST_ID	number;
	function cf_rejection_descriptionformul(rejection_code in varchar2) return char  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	p_start_organization_id_dummy number;
	function p_fcst_start_date_p return date;
	function P_FCST_END_DATE_p return date;
	function p_project_id_parameter_p return number;

END PA_PAFPEXRP_XMLP_PKG;

/
