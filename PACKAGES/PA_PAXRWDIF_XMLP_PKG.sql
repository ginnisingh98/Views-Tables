--------------------------------------------------------
--  DDL for Package PA_PAXRWDIF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWDIF_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWDIFS.pls 120.1 2008/01/03 11:17:53 krreddy noship $ */
	P_FORMAT	varchar2(40);
	P_GROUP	varchar2(40);
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	C_Format_Name	varchar2(30);
	C_Grouping_Name	varchar2(80);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Format_Name_p return varchar2;
	Function C_Grouping_Name_p return varchar2;
END PA_PAXRWDIF_XMLP_PKG;

/
