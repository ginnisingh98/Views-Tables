--------------------------------------------------------
--  DDL for Package PA_PAXRWRVC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWRVC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWRVCS.pls 120.0 2008/01/02 12:15:26 krreddy noship $ */
	P_REVENUE_CATEGORY	varchar2(40);
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	C_Revenue_Category	varchar2(80);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Revenue_Category_p return varchar2;
END PA_PAXRWRVC_XMLP_PKG;

/
