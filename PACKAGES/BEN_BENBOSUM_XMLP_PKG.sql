--------------------------------------------------------
--  DDL for Package BEN_BENBOSUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENBOSUM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENBOSUMS.pls 120.2 2007/12/10 08:25:07 vjaganat noship $ */
	P_CONCURRENT_REQUEST_ID	number;
	P_CONC_REQUEST_ID	number;
	CP_PROCESS_DATE	date;
	CP_VALIDATE	varchar2(240);
	CP_PERSON_SELECTION_RULE	varchar2(240);
	CP_LIFE_EVENT_REASON	varchar2(240);
	CP_ORGANIZATION	varchar2(240);
	CP_LEGAL_ENTITY	varchar2(240);
	CP_TO_OCRD_DT	date;
	CP_START_DATE	varchar2(30);
	CP_END_DATE	varchar2(30);
	CP_ELAPSED_TIME	varchar2(30);
	CP_PERSONS_SELECTED	number;
	CP_PERSONS_PROCESSED	number;
	CP_FROM_OCRD_DT	date;
	CP_END_TIME	varchar2(30);
	CP_START_TIME	varchar2(30);
	CP_LOCATION	varchar2(240);
	CP_PERSONS_ERRORED	number;
	CP_PERSONS_PROCESSED_SUCC	number;
	CP_PERSONS_UNPROCESSED	number;
	CP_LF_EVT_BO	number;
	CP_PERSON_BNFT_GRP	varchar2(240);
	CP_PEOPLE_LF_EVT_BO	number;
	CP_concurrent_program_name	varchar2(240);
	CP_BUSINESS_GROUP	varchar2(240);
	CP_LF_EVT_BO_CLS	number;
	CP_LF_EVT_BO_IP_WE	number;
	CP_LF_EVT_BO_IP_WOE	number;
	CP_RESULTING_STATUS	varchar2(80);
	function CF_STANDARD_HEADERFormula return Number  ;
	function CF_SUMMARY_EVENTFormula return Number  ;
	function CF_1Formula return Number  ;
	function G_benefit_action_idGroupFilter return boolean  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function CP_PROCESS_DATE_p return date;
	Function CP_VALIDATE_p return varchar2;
	Function CP_PERSON_SELECTION_RULE_p return varchar2;
	Function CP_LIFE_EVENT_REASON_p return varchar2;
	Function CP_ORGANIZATION_p return varchar2;
	Function CP_LEGAL_ENTITY_p return varchar2;
	Function CP_TO_OCRD_DT_p return date;
	Function CP_START_DATE_p return varchar2;
	Function CP_END_DATE_p return varchar2;
	Function CP_ELAPSED_TIME_p return varchar2;
	Function CP_PERSONS_SELECTED_p return number;
	Function CP_PERSONS_PROCESSED_p return number;
	Function CP_FROM_OCRD_DT_p return date;
	Function CP_END_TIME_p return varchar2;
	Function CP_START_TIME_p return varchar2;
	Function CP_LOCATION_p return varchar2;
	Function CP_PERSONS_ERRORED_p return number;
	Function CP_PERSONS_PROCESSED_SUCC_p return number;
	Function CP_PERSONS_UNPROCESSED_p return number;
	Function CP_LF_EVT_BO_p return number;
	Function CP_PERSON_BNFT_GRP_p return varchar2;
	Function CP_PEOPLE_LF_EVT_BO_p return number;
	Function CP_concurrent_program_name_p return varchar2;
	Function CP_BUSINESS_GROUP_p return varchar2;
	Function CP_LF_EVT_BO_CLS_p return number;
	Function CP_LF_EVT_BO_IP_WE_p return number;
	Function CP_LF_EVT_BO_IP_WOE_p return number;
	Function CP_RESULTING_STATUS_p return varchar2;
END BEN_BENBOSUM_XMLP_PKG;

/
