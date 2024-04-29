--------------------------------------------------------
--  DDL for Package BEN_BENERTYP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENERTYP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENERTYPS.pls 120.1 2007/12/10 08:33:31 vjaganat noship $ */
	run_mode varchar2(100);
	P_CONCURRENT_REQUEST_ID	number;
	P_SUBTITLE	varchar2(50);
	P_CONC_REQUEST_ID	number;
	CP_PROCESS_DATE	varchar2(30);
	CP_DERIVABLE_FACTORS	varchar2(240);
	CP_VALIDATE	varchar2(240);
	CP_PERSON	varchar2(270);
	CP_PERSON_TYPE	varchar2(240);
	CP_PROGRAM	varchar2(240);
	CP_BUSINESS_GROUP	varchar2(240);
	CP_PLAN	varchar2(240);
	CP_ENROLLMENT_TYPE_CYCLE	varchar2(800);
	CP_PLANS_NOT_IN_PROGRAMS	varchar2(240);
	CP_JUST_PROGRAMS	varchar2(240);
	CP_COMP_OBJECT_SELECTION_RULE	varchar2(240);
	CP_PERSON_SELECTION_RULE	varchar2(240);
	CP_LIFE_EVENT_REASON	varchar2(240);
	CP_ORGANIZATION	varchar2(240);
	CP_POSTAL_ZIP_RANGE	varchar2(80);
	CP_REPORTING_GROUP	varchar2(240);
	CP_PLAN_TYPE	varchar2(240);
	CP_OPTION	varchar2(240);
	CP_ELIGIBILITY_PROFILE	varchar2(240);
	CP_VARIABLE_RATE_PROFILE	varchar2(270);
	CP_LEGAL_ENTITY	varchar2(240);
	CP_PAYROLL	varchar2(240);
	CP_CONCURRENT_PROGRAM_NAME	varchar2(270);
	CP_MODE	varchar2(90);
	CP_STATUS	varchar2(240);
	CP_START_DATE	varchar2(30);
	CP_END_DATE	varchar2(30);
	CP_START_TIME	varchar2(30);
	CP_END_TIME	varchar2(30);
	CP_ELAPSED_TIME	varchar2(30);
	CP_PERSONS_SELECTED	number;
	CP_PERSONS_PROCESSED	number;
	CP_PERSONS_ERRORED	number;
	CP_PERSONS_UNPROCESSED	number;
	CP_PERSONS_PROCESSED_SUCC	number;
	CD_01	varchar2(80);
	CD_02	varchar2(80);
	CD_03	varchar2(80);
	CD_04	varchar2(80);
	CD_05	varchar2(80);
	CD_06	varchar2(80);
	CD_07	varchar2(80);
	CD_08	varchar2(80);
	CD_09	varchar2(80);
	CD_10	varchar2(80);
	CD_11	varchar2(80);
	CD_12	varchar2(80);
	CD_13	varchar2(80);
	CD_14	varchar2(80);
	CD_15	varchar2(80);
	CD_16	varchar2(80);
	CD_17	varchar2(80);
	CD_18	varchar2(80);
	CD_19	varchar2(80);
	CD_20	varchar2(80);
	CV_01	varchar2(80);
	CV_02	varchar2(80);
	CV_03	varchar2(80);
	CV_04	varchar2(80);
	CV_05	varchar2(80);
	CV_06	varchar2(80);
	CV_07	varchar2(80);
	CV_08	varchar2(80);
	CV_09	varchar2(80);
	CV_10	varchar2(80);
	CV_11	varchar2(80);
	CV_12	varchar2(80);
	CV_13	varchar2(80);
	CV_14	varchar2(80);
	CV_15	varchar2(80);
	CV_16	varchar2(80);
	CV_17	varchar2(80);
	CV_18	varchar2(80);
	CV_19	varchar2(80);
	CV_20	varchar2(80);
	CP_LOCATION	varchar2(80);
	CP_DEBUG_MESSAGE	varchar2(80);
	CP_AUDIT_LOG	varchar2(80);
	CP_BENFT_GROUP	varchar2(80);
	function CF_STANDARD_HEADERFormula return Number ;
	function CF_1Formula return Number  ;
	FUNCTION Get_val (p_cd varchar2) RETURN varchar2  ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	Function CP_PROCESS_DATE_p return varchar2;
	Function CP_DERIVABLE_FACTORS_p return varchar2;
	Function CP_VALIDATE_p return varchar2;
	Function CP_PERSON_p return varchar2;
	Function CP_PERSON_TYPE_p return varchar2;
	Function CP_PROGRAM_p return varchar2;
	Function CP_BUSINESS_GROUP_p return varchar2;
	Function CP_PLAN_p return varchar2;
	Function CP_ENROLLMENT_TYPE_CYCLE_p return varchar2;
	Function CP_PLANS_NOT_IN_PROGRAMS_p return varchar2;
	Function CP_JUST_PROGRAMS_p return varchar2;
	Function CP_COMP_OBJECT_SELECTION_RULE1 return varchar2;
	Function CP_PERSON_SELECTION_RULE_p return varchar2;
	Function CP_LIFE_EVENT_REASON_p return varchar2;
	Function CP_ORGANIZATION_p return varchar2;
	Function CP_POSTAL_ZIP_RANGE_p return varchar2;
	Function CP_REPORTING_GROUP_p return varchar2;
	Function CP_PLAN_TYPE_p return varchar2;
	Function CP_OPTION_p return varchar2;
	Function CP_ELIGIBILITY_PROFILE_p return varchar2;
	Function CP_VARIABLE_RATE_PROFILE_p return varchar2;
	Function CP_LEGAL_ENTITY_p return varchar2;
	Function CP_PAYROLL_p return varchar2;
	Function CP_CONCURRENT_PROGRAM_NAME_p return varchar2;
	Function CP_MODE_p return varchar2;
	Function CP_STATUS_p return varchar2;
	Function CP_START_DATE_p return varchar2;
	Function CP_END_DATE_p return varchar2;
	Function CP_START_TIME_p return varchar2;
	Function CP_END_TIME_p return varchar2;
	Function CP_ELAPSED_TIME_p return varchar2;
	Function CP_PERSONS_SELECTED_p return number;
	Function CP_PERSONS_PROCESSED_p return number;
	Function CP_PERSONS_ERRORED_p return number;
	Function CP_PERSONS_UNPROCESSED_p return number;
	Function CP_PERSONS_PROCESSED_SUCC_p return number;
	Function CD_01_p return varchar2;
	Function CD_02_p return varchar2;
	Function CD_03_p return varchar2;
	Function CD_04_p return varchar2;
	Function CD_05_p return varchar2;
	Function CD_06_p return varchar2;
	Function CD_07_p return varchar2;
	Function CD_08_p return varchar2;
	Function CD_09_p return varchar2;
	Function CD_10_p return varchar2;
	Function CD_11_p return varchar2;
	Function CD_12_p return varchar2;
	Function CD_13_p return varchar2;
	Function CD_14_p return varchar2;
	Function CD_15_p return varchar2;
	Function CD_16_p return varchar2;
	Function CD_17_p return varchar2;
	Function CD_18_p return varchar2;
	Function CD_19_p return varchar2;
	Function CD_20_p return varchar2;
	Function CV_01_p return varchar2;
	Function CV_02_p return varchar2;
	Function CV_03_p return varchar2;
	Function CV_04_p return varchar2;
	Function CV_05_p return varchar2;
	Function CV_06_p return varchar2;
	Function CV_07_p return varchar2;
	Function CV_08_p return varchar2;
	Function CV_09_p return varchar2;
	Function CV_10_p return varchar2;
	Function CV_11_p return varchar2;
	Function CV_12_p return varchar2;
	Function CV_13_p return varchar2;
	Function CV_14_p return varchar2;
	Function CV_15_p return varchar2;
	Function CV_16_p return varchar2;
	Function CV_17_p return varchar2;
	Function CV_18_p return varchar2;
	Function CV_19_p return varchar2;
	Function CV_20_p return varchar2;
	Function CP_LOCATION_p return varchar2;
	Function CP_DEBUG_MESSAGE_p return varchar2;
	Function CP_AUDIT_LOG_p return varchar2;
	Function CP_BENFT_GROUP_p return varchar2;
END BEN_BENERTYP_XMLP_PKG;

/