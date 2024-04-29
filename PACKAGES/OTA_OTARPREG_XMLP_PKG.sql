--------------------------------------------------------
--  DDL for Package OTA_OTARPREG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OTARPREG_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OTARPREGS.pls 120.1 2007/12/07 06:00:03 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60) := 'Registration List';
	P_CONC_REQUEST_ID	number;
	P_COURSE_START_DATE	varchar2(32767);
	P_COURSE_END_DATE	varchar2(32767);
	P_TRAINING_CENTER_ID	number;
	P_EVENT_TYPE	varchar2(40);
	P_EVENT_ID	varchar2(40);
	P_Business	varchar2(80);
	p_and	varchar2(1000);
	P_EVENT_NAME	varchar2(80);
	P_TRAINING_CENTER_NAME	varchar2(60);
	CP_venue	varchar2(500);
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_SUBTITLE	varchar2(60);
	C_EVENT_TITLE	varchar2(80);
	CP_current_date	varchar2(20);
	CP_session_date	varchar2(20);
	CP_course_start_date	varchar2(20);
	CP_course_end_date	varchar2(20);
	function BeforeReport return boolean  ;
	FUNCTION AfterPForm
  RETURN BOOLEAN
 ;
	function CF_current_dateFormula
   return Char
 ;
	function cf_venueformula
  (event_id in number) return char
 ;
	function CF_session_dateFormula return Char  ;
	function CF_course_start_dateFormula return Char  ;
	function CF_course_end_dateFormula return Char  ;
	function AfterReport return boolean  ;
	Function CP_venue_p return varchar2;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_EVENT_TITLE_p return varchar2;
	Function CP_current_date_p return varchar2;
	Function CP_session_date_p return varchar2;
	Function CP_course_start_date_p return varchar2;
	Function CP_course_end_date_p return varchar2;
END OTA_OTARPREG_XMLP_PKG;

/
