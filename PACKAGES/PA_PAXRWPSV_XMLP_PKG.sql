--------------------------------------------------------
--  DDL for Package PA_PAXRWPSV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWPSV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWPSVS.pls 120.0 2008/01/02 12:13:53 krreddy noship $ */
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
END PA_PAXRWPSV_XMLP_PKG;

/
