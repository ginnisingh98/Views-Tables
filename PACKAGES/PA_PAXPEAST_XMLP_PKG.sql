--------------------------------------------------------
--  DDL for Package PA_PAXPEAST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPEAST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPEASTS.pls 120.0 2008/01/02 11:47:01 krreddy noship $ */
	ORGANIZATION_ID	varchar2(40);
	JOB_ID	varchar2(40);
	ORGANIZATION_ID_T	varchar2(40);
	JOB_ID_T	varchar2(40);
	EFFECTIVE_DATE	date;
	EFFECTIVE_DATE_1 varchar2(10);
	JOB_LEVEL	varchar2(40);
	JOB_DISCIPLINE	varchar2(40);
	SORT_BY	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_para_sql	varchar2(2000);
	C_Company_Name_Header	varchar2(40);
	C_Org_Name	varchar2(60);
	C_Job	varchar2(240);
	C_Sort_By_Meaning	varchar2(80);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function BeforePForm return boolean  ;
	function AfterPForm return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
	Function C_Org_Name_p return varchar2;
	Function C_Job_p return varchar2;
	Function C_Sort_By_Meaning_p return varchar2;
END PA_PAXPEAST_XMLP_PKG;

/
