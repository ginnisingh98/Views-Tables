--------------------------------------------------------
--  DDL for Package OTA_OTARPSIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OTARPSIS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OTARPSISS.pls 120.1 2007/12/07 06:01:07 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	varchar2(30);
	P_REPORT_TITLE	varchar2(60) := 'Learner Sign-In Sheet (by Organization or Company)';
	P_CONC_REQUEST_ID	number;
	P_COURSE_START_DATE	varchar2(32767);
	P_COURSE_END_DATE	varchar2(32767);
	P_TRAINING_CENTER_ID	number;
	P_EVENT_ID	number;
	P_Business	varchar2(80);
	P_OPTIONAL_COLUMN	varchar2(15);
	P_AND	varchar2(2000);
	P_trainer_and	varchar2(1000);
	P_display_pmt_conf	varchar2(1);
	P_booking_id	number;
	P_display_trainer_signature	varchar2(1);
	P_EVENT_NAME	varchar2(80);
	P_TRAINING_CENTER_NAME	varchar2(60);
	CP_venue	varchar2(500);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_EVENT_TITLE	varchar2(80);
	CP_course_start_date	varchar2(20);
	CP_course_end_date	varchar2(20);
	function BeforeReport return boolean  ;
	function CF_OPTIONAL_COLUMNFormula return Char  ;
	FUNCTION AfterPForm
  RETURN BOOLEAN
 ;
	function cf_venueformula
  (event_id in number) return char
 ;
	function CF_course_end_dateFormula return Char  ;
	function CF_course_start_dateFormula return Char  ;
	function cf_event_durationformula(course_end in date, course_start in date) return number  ;
	function cf_sign4formula(CF_event_duration in number) return char  ;
	function cf_sign3formula(CF_event_duration in number) return char  ;
	function cf_sign2formula(CF_event_duration in number) return char  ;
	function cf_sign1formula(CF_event_duration in number) return char  ;
	function CF_BG_NAMEFormula return Char  ;
	function AfterReport return boolean  ;
	Function CP_venue_p return varchar2;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_EVENT_TITLE_p return varchar2;
	Function CP_course_start_date_p return varchar2;
	Function CP_course_end_date_p return varchar2;
END OTA_OTARPSIS_XMLP_PKG;

/
