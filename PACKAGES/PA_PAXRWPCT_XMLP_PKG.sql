--------------------------------------------------------
--  DDL for Package PA_PAXRWPCT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWPCT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWPCTS.pls 120.0 2008/01/02 12:08:50 krreddy noship $ */
	P_CONC_REQUEST_ID	number;
	C_company_name_header	varchar2(40);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_company_name_header_p return varchar2;
END PA_PAXRWPCT_XMLP_PKG;

/
