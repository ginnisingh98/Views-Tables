--------------------------------------------------------
--  DDL for Package PA_PAXRWNLR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWNLR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWNLRS.pls 120.0 2008/01/02 12:01:46 krreddy noship $ */
	P_ORGANIZATION_ID	varchar2(40);
	P_EXPENDITURE_TYPE	varchar2(40);
	P_EXPENDITURE_CATEGORY	varchar2(40);
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	C_Org_Name	varchar2(240);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Org_Name_p return varchar2;
END PA_PAXRWNLR_XMLP_PKG;

/
