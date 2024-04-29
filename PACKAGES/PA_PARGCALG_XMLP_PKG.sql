--------------------------------------------------------
--  DDL for Package PA_PARGCALG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PARGCALG_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PARGCALGS.pls 120.0 2008/01/02 11:03:18 krreddy noship $ */
	P_coa_id	number;
	P_DEBUG_MODE	varchar2(30);
	P_CONC_REQUEST_ID	number;
	P_min_precision	number;
	p_start_calendar_name	varchar2(50);
	p_end_calendar_name	varchar2(50);
	p_run_mode	varchar2(1);
	CP_company_name	varchar2(60);
	CP_NODATAFOUND	varchar2(80) := 'No Data Found' ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function CF_company_nameFormula return Char  ;
	Function CP_company_name_p return varchar2;
	Function CP_NODATAFOUND_p return varchar2;
END PA_PARGCALG_XMLP_PKG;

/
