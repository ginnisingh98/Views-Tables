--------------------------------------------------------
--  DDL for Package PER_PERRPRMS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPRMS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERRPRMSS.pls 120.1 2007/12/06 11:32:53 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_SESSION_DATE1	varchar2(32767);
	P_CONC_REQUEST_ID	number;
	P_MATCHING_LEVEL	varchar2(1);
	P_JOB_ID	number;
	P_POSITION_ID	number;
	P_PERSON_TYPE	varchar2(32767);
	P_JOB_POSITION	varchar2(30):='JOB_ID';
	--P_SPECIAL_INFO_SEGS	varchar2(32000);
	P_SPECIAL_INFO_SEGS	varchar2(32000) := 'lpad('' '',32000)';
	P_LEGISLATION_CODE	varchar2(32767);
	C_REQ_VAL	varchar2(2000);
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_SUBTITLE	varchar2(60);
	C_JOB_POSITION_ID	number;
	C_JOB_POSITION_NAME	varchar2(240);
	C_PERSON_TYPE_DESC	varchar2(80);
	C_REQUIREMENT_DESC	varchar2(240);
	C_REQUIREMENT_VALUE	varchar2(240);
	C_END_OF_TIME	date;
	function BeforeReport return boolean  ;
	function C_SPECIAL_INFO_SEGSFormula return Number  ;
	function g_people_matchinggroupfilter(c_special_info_count in number, person_id1 in number, C_COUNT_ESSENTIAL in number, C_COUNT_DESIRABLE in number) return boolean  ;
	function c_date_toformula(date_to in date) return varchar2  ;
	function C_REQUIREMENT_HEADINGFormula return VARCHAR2  ;
	function c_essential_decodeformula(essential in varchar2) return varchar2  ;
	function AfterReport return boolean  ;
	Function C_REQ_VAL_p return varchar2;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_JOB_POSITION_ID_p return number;
	Function C_JOB_POSITION_NAME_p return varchar2;
	Function C_PERSON_TYPE_DESC_p return varchar2;
	Function C_REQUIREMENT_DESC_p return varchar2;
	Function C_REQUIREMENT_VALUE_p return varchar2;
	Function C_END_OF_TIME_p return date;
END PER_PERRPRMS_XMLP_PKG;

/
