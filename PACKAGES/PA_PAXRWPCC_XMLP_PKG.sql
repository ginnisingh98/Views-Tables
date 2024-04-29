--------------------------------------------------------
--  DDL for Package PA_PAXRWPCC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWPCC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWPCCS.pls 120.0 2008/01/02 12:04:43 krreddy noship $ */
	P_CLASS_CATEGORY	varchar2(40);
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
END PA_PAXRWPCC_XMLP_PKG;

/
