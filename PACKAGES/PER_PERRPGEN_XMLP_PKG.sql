--------------------------------------------------------
--  DDL for Package PER_PERRPGEN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPGEN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERGENRPS.pls 120.1 2007/12/06 11:26:49 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_Header	varchar2(200);
	P_Footer	varchar2(200);
	P_Title	varchar2(200);
	P_Report_Name	varchar2(100);
	P_Param_1	varchar2(100);
	P_Param_2	varchar2(100);
	P_Param_3	varchar2(100);
	P_Param_4	varchar2(100);
	P_Param_5	varchar2(100);
	P_Param_6	varchar2(100);
	P_Param_7	varchar2(100);
	P_Param_8	varchar2(100);
	P_Param_9	varchar2(100);
	P_Param_10	varchar2(100);
	P_Param_11	varchar2(100);
	P_Param_12	varchar2(100);
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_SUBTITLE	varchar2(60);
	function BeforeReport return boolean  ;
	function BeforePForm return boolean  ;
	function AfterReport return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
END PER_PERRPGEN_XMLP_PKG;

/
