--------------------------------------------------------
--  DDL for Package OTA_OTARPBUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OTARPBUD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OTARPBUDS.pls 120.1 2007/12/07 05:59:44 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE	date;
	LP_SESSION_DATE	date;
	P_REPORT_TITLE	varchar2(60);
	P_CONC_REQUEST_ID	number;
	P_TRANSFER_STATUS	varchar2(40);
	P_PRICE	varchar2(40);
	P_RESOURCE_BOOKING_STATUS	varchar2(40);
	P_PAYMENT_STATUS	varchar2(40);
	P_DISPLAY_MODE	varchar2(40);
	P_COURSE_START_DATE	varchar2(32767);
	P_COURSE_END_DATE	varchar2(32767);
	P_DELEGATE_BOOKING_CURRENCY	varchar2(40);
	P_RESOURCE_BOOKING_CURRENCY	varchar2(40);
	P_ACTIVITY_ID	varchar2(40);
	P_ACTIVITY_VERSION_ID	varchar2(40);
	P_EVENT_ID	varchar2(40);
	P_PROGRAM_ID	varchar2(40);
	P_revenue_display_currency	varchar2(4);
	P_delegate_display_currency	varchar2(32767);
	P_Business	varchar2(80);
	CP_rev_curr	number := 0 ;
	CP_cost_curr	number := 0 ;
	CP_Venue	varchar2(500);
	CP_prev_event	number;
	CP_conv	number := 0 ;
	CP_prev_event2	number;
	CP_conv1	number := 0 ;
	C_BUSINESS_GROUP_NAME	varchar2(60);
	C_REPORT_SUBTITLE	varchar2(60);
	C_ACTIVITY_NAME	varchar2(80);
	C_ACTIVITY_VERSION_NAME	varchar2(80);
	C_EVENT_TITLE	varchar2(80);
	C_PROGRAM_NAME	varchar2(80);
	CP_transfer_status	varchar2(80);
	CP_resource_booking_status	varchar2(80);
	function BeforeReport return boolean  ;
	function CF_eff_dateFormula return Date  ;
	function cf_conv_amountformula(event_id in number, currency_code1 in varchar2, money_amount in number, cf_eff_date in date, cf_currency_type in varchar2) return number  ;
	function cf_conv1formula(event_id in number, currency_code3 in varchar2, money_amount2 in number, cf_eff_date in date, cf_currency_type in varchar2) return number  ;
	function cf_currency_typeformula(cf_eff_date in date) return varchar2  ;
	function cf_venueformula
  (event_id in number) return char
 ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
	Function CP_rev_curr_p return number;
	Function CP_cost_curr_p return number;
	Function CP_Venue_p return varchar2;
	Function CP_prev_event_p return number;
	Function CP_conv_p return number;
	Function CP_prev_event2_p return number;
	Function CP_conv1_p return number;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_ACTIVITY_NAME_p return varchar2;
	Function C_ACTIVITY_VERSION_NAME_p return varchar2;
	Function C_EVENT_TITLE_p return varchar2;
	Function C_PROGRAM_NAME_p return varchar2;
	Function CP_transfer_status_p return varchar2;
	Function CP_resource_booking_status_p return varchar2;
END OTA_OTARPBUD_XMLP_PKG;

/
