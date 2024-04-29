--------------------------------------------------------
--  DDL for Package PA_PAXRWPRT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWPRT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWPRTS.pls 120.0 2008/01/02 12:12:33 krreddy noship $ */
	P_CONC_REQUEST_ID	number;
	C_Company_name_header	varchar2(40);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_name_header_p return varchar2;
END PA_PAXRWPRT_XMLP_PKG;

/
