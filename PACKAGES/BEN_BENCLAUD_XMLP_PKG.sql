--------------------------------------------------------
--  DDL for Package BEN_BENCLAUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENCLAUD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENCLAUDS.pls 120.1 2007/12/10 08:26:16 vjaganat noship $ */
	P_CONCURRENT_REQUEST_ID	number;
	P_CONC_REQUEST_ID	number;
	CP_PROCESS_DATE	date;
	CP_BUSINESS_GROUP	varchar2(240);
	CP_CONCURRENT_PROGRAM_NAME	varchar2(240);
	CP_START_DATE	varchar2(12);
	CP_END_DATE	varchar2(30);
	CP_ELAPSED_TIME	varchar2(30);
	CP_PERSONS_SELECTED	number;
	CP_PERSONS_PROCESSED	number;
	CP_START_TIME	varchar2(30);
	CP_END_TIME	varchar2(30);
	CP_PERSONS_UNPROCESSED	number;
	CP_PERSONS_PROCESSED_SUCC	number;
	CP_PERSONS_ERRORED	number;
	CP_STATUS	varchar2(90);
	CP_CLSNNOACTN	number;
	CP_CLSNODEF	number;
	CP_CLSNDEFNOCHG	number;
	CP_CLSNDEFWCHG	number;
	CP_CLSDEFNOCHG	number;
	CP_CLSDEFWCHG	number;
	CP_PERSON	varchar2(246);
	CP_PROGRAM	varchar2(240);
	CP_PLAN	varchar2(240);
	CP_VALIDATE	varchar2(240);
	CP_PERSON_SELECTION_RULE	varchar2(240);
	CP_LOCATION	varchar2(240);
	CP_ASSIGNED_LIFE_EVENT_DATE	varchar2(30);
	CP_LIFE_EVENT_REASON	varchar2(240);
	CP_CLOSE_ACTION_ITEMS_FLAG	varchar2(30);
	CP_CLOSE_MODE	varchar2(20);
	CP_AUDIT_LOG	varchar2(20);
	CP_ACTION_ITEM_EFFECTIVE_DATE	varchar2(30);
	function CF_STANDARD_HEADERFormula return Number  ;
	function CF_PROCESS_INFORMATIONFormula return Number  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function CP_PROCESS_DATE_p return date;
	Function CP_BUSINESS_GROUP_p return varchar2;
	Function CP_CONCURRENT_PROGRAM_NAME_p return varchar2;
	Function CP_START_DATE_p return varchar2;
	Function CP_END_DATE_p return varchar2;
	Function CP_ELAPSED_TIME_p return varchar2;
	Function CP_PERSONS_SELECTED_p return number;
	Function CP_PERSONS_PROCESSED_p return number;
	Function CP_START_TIME_p return varchar2;
	Function CP_END_TIME_p return varchar2;
	Function CP_PERSONS_UNPROCESSED_p return number;
	Function CP_PERSONS_PROCESSED_SUCC_p return number;
	Function CP_PERSONS_ERRORED_p return number;
	Function CP_STATUS_p return varchar2;
	Function CP_CLSNNOACTN_p return number;
	Function CP_CLSNODEF_p return number;
	Function CP_CLSNDEFNOCHG_p return number;
	Function CP_CLSNDEFWCHG_p return number;
	Function CP_CLSDEFNOCHG_p return number;
	Function CP_CLSDEFWCHG_p return number;
	Function CP_PERSON_p return varchar2;
	Function CP_PROGRAM_p return varchar2;
	Function CP_PLAN_p return varchar2;
	Function CP_VALIDATE_p return varchar2;
	Function CP_PERSON_SELECTION_RULE_p return varchar2;
	Function CP_LOCATION_p return varchar2;
	Function CP_ASSIGNED_LIFE_EVENT_DATE_p return varchar2;
	Function CP_LIFE_EVENT_REASON_p return varchar2;
	Function CP_CLOSE_ACTION_ITEMS_FLAG_p return varchar2;
	Function CP_CLOSE_MODE_p return varchar2;
	Function CP_AUDIT_LOG_p return varchar2;
	Function CP_ACTION_ITEM_EFFECTIVE_DATE1 return varchar2;
END BEN_BENCLAUD_XMLP_PKG;

/
