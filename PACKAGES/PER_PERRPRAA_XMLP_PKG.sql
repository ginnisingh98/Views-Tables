--------------------------------------------------------
--  DDL for Package PER_PERRPRAA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERRPRAA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERRPRAAS.pls 120.1 2007/12/06 11:30:35 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_SESSION_DATE1 varchar2(240);
	P_SESSION_DATE	date;
	P_CONC_REQUEST_ID	number;
	P_ORGANIZATION_ID	number;
	P_PERSON_ID	number;
	P_DATE_FROM	date;
	P_DATE_TO	date;
	P_ABS_TYPE1	varchar2(30);
	P_ABS_TYPE2	varchar2(30);
	P_ABS_TYPE3	varchar2(30);
	P_ABS_TYPE4	varchar2(30);
	P_ABS_TYPE5	varchar2(30);
	P_ABS_TYPE6	varchar2(30);
	P_ABS_TYPE7	varchar2(30);
	P_ABS_TYPE8	varchar2(30);
	P_ABS_TYPE9	varchar2(30);
	P_ABS_TYPE10	varchar2(30);
	--P_ABSENCE_SQL	varchar2(400);
	--P_ABSENCE_ATT_SQL	varchar2(100);
	P_ABSENCE_SQL	varchar2(400) := 'and 1 = 1';
	P_ABSENCE_ATT_SQL	varchar2(100) := 'and 1 = 1';
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_REPORT_SUBTITLE	varchar2(60);
	C_DISPLAY_ABTYPES	varchar2(309);
	C_ORGANIZATION_NAME	varchar2(240);
	C_ABTYPES_ENTERED	varchar2(1);
	C_ABSENCE_TYPES	varchar2(329);
	C_ABS_TYPE_NAME1	varchar2(30);
	C_ABS_TYPE_NAME2	varchar2(30);
	C_ABS_TYPE_NAME3	varchar2(30);
	C_ABS_TYPE_NAME4	varchar2(30);
	C_ABS_TYPE_NAME5	varchar2(30);
	C_ABS_TYPE_NAME6	varchar2(30);
	C_ABS_TYPE_NAME7	varchar2(30);
	C_ABS_TYPE_NAME8	varchar2(30);
	C_ABS_TYPE_NAME9	varchar2(30);
	C_ABS_TYPE_NAME10	varchar2(30);
	C_PERSON_NAME	varchar2(240);
	C_NLS_LANGUAGE	varchar2(66);
	function BeforeReport return boolean  ;
	function c_running_totalformula(summ_person_id in number, p_absence_attendance_type_id in number) return number  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	function BetweenPage return boolean  ;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_REPORT_SUBTITLE_p return varchar2;
	Function C_DISPLAY_ABTYPES_p return varchar2;
	Function C_ORGANIZATION_NAME_p return varchar2;
	Function C_ABTYPES_ENTERED_p return varchar2;
	Function C_ABSENCE_TYPES_p return varchar2;
	Function C_ABS_TYPE_NAME1_p return varchar2;
	Function C_ABS_TYPE_NAME2_p return varchar2;
	Function C_ABS_TYPE_NAME3_p return varchar2;
	Function C_ABS_TYPE_NAME4_p return varchar2;
	Function C_ABS_TYPE_NAME5_p return varchar2;
	Function C_ABS_TYPE_NAME6_p return varchar2;
	Function C_ABS_TYPE_NAME7_p return varchar2;
	Function C_ABS_TYPE_NAME8_p return varchar2;
	Function C_ABS_TYPE_NAME9_p return varchar2;
	Function C_ABS_TYPE_NAME10_p return varchar2;
	Function C_PERSON_NAME_p return varchar2;
	Function C_NLS_LANGUAGE_p return varchar2;
END PER_PERRPRAA_XMLP_PKG;

/
