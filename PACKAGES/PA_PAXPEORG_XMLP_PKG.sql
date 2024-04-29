--------------------------------------------------------
--  DDL for Package PA_PAXPEORG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPEORG_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPEORGS.pls 120.0 2008/01/02 11:49:18 krreddy noship $ */
	P_TYPE	varchar2(40);
	P_CONC_REQUEST_ID	number;
	C_Company_Name_Header	varchar2(40);
	C_Type_Meaning	varchar2(80);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function BeforePForm return boolean  ;
	function AfterPForm return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Type_Meaning_p return varchar2;
END PA_PAXPEORG_XMLP_PKG;

/
