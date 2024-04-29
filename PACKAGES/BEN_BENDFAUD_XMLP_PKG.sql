--------------------------------------------------------
--  DDL for Package BEN_BENDFAUD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENDFAUD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BENDFAUDS.pls 120.1 2007/12/10 08:30:11 vjaganat noship $ */
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
	CP_VALIDATE	varchar2(20);
	CP_PERSON	varchar2(240);
	CP_PERSON_TYPE	varchar2(240);
	CP_PERSON_SELECTION_RULE	varchar2(20);
	CP_ENROLLMENT_TYPE_CYCLE	varchar2(240);
	CP_ORGANIZATION	varchar2(240);
	CP_LEGAL_ENTITY	varchar2(240);
	CP_AUDIT_LOG	varchar2(20);
	CP_BENEFIT_GROUP	varchar2(240);
	CP_LOCATION	varchar2(240);
	CP_PAYROLL	varchar2(240);
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
	Function CP_VALIDATE_p return varchar2;
	Function CP_PERSON_p return varchar2;
	Function CP_PERSON_TYPE_p return varchar2;
	Function CP_PERSON_SELECTION_RULE_p return varchar2;
	Function CP_ENROLLMENT_TYPE_CYCLE_p return varchar2;
	Function CP_ORGANIZATION_p return varchar2;
	Function CP_LEGAL_ENTITY_p return varchar2;
	Function CP_AUDIT_LOG_p return varchar2;
	Function CP_BENEFIT_GROUP_p return varchar2;
	Function CP_LOCATION_p return varchar2;
	Function CP_PAYROLL_p return varchar2;
END BEN_BENDFAUD_XMLP_PKG;

/
