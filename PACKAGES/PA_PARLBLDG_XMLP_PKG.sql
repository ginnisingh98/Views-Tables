--------------------------------------------------------
--  DDL for Package PA_PARLBLDG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PARLBLDG_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PARLBLDGS.pls 120.0 2008/01/02 11:04:09 krreddy noship $ */
	P_coa_id	number;
	P_DEBUG_MODE	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_min_precision	number;
	p_start_resource_name	varchar2(100);
	p_end_resource_name	varchar2(100);
	p_start_resource_name_dummy	varchar2(100);
	p_end_resource_name_dummy	varchar2(100);
	p_run_mode	varchar2(1);
	p_resource_id	number;
	START_RESOURCE_NAME	varchar2(40);
	CP_company_name	varchar2(60);
	CP_NODATAFOUND	varchar2(80) := 'No Data Found' ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function CP_company_nameFormula return Char  ;
	Function CP_company_name_p return varchar2;
	Function CP_NODATAFOUND_p return varchar2;
END PA_PARLBLDG_XMLP_PKG;

/
