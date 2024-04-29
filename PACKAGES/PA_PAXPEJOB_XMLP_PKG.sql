--------------------------------------------------------
--  DDL for Package PA_PAXPEJOB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPEJOB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPEJOBS.pls 120.0 2008/01/02 11:48:37 krreddy noship $ */
	P_JOB_LEVEL	varchar2(40);
	P_JOB_DISCIPLINE	varchar2(40);
	P_SORT_BY	varchar2(40);
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	C_Sort_By_Name	varchar2(80);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Sort_By_Name_p return varchar2;
END PA_PAXPEJOB_XMLP_PKG;

/
