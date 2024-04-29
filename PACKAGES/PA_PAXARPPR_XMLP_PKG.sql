--------------------------------------------------------
--  DDL for Package PA_PAXARPPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXARPPR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXARPPRS.pls 120.1 2008/01/03 11:11:54 krreddy noship $ */

  	PA_PURGE_ERROR_CODE VARCHAR2(10) := '0';
  	PA_PURGE_ERROR_BUFF VARCHAR2(1000) := ' ';
	P_rule_optimizer	varchar2(3);
	P_debug_mode	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_PURGE_BATCH_ID	number;
	P_commit_size	varchar2(32767);
	P_run_purge	varchar2(2);
	C_COMPANY_NAME_HEADER	varchar2(50);
	C_no_data_found	varchar2(80);
	C_dummy_data	number;
	C_batch_name	varchar2(30);
	C_batch_description	varchar2(80);
	C_batch_status	varchar2(30);
	C_Through_date	date;
	C_batch_status_meaning	varchar2(80);
	C_batch_active_closed	varchar2(1);
	C_YES	varchar2(32767);
	C_NO	varchar2(32767);
	C_RUN_PURGE	varchar2(32767);
	C_COMMIT_SIZE	number;
	C_Batch_Purged_Date	date;
	FUNCTION  get_cover_page_values   RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function AfterReport return boolean  ;
	function BetweenPage return boolean  ;
	Function C_COMPANY_NAME_HEADER_p return varchar2;
	Function C_no_data_found_p return varchar2;
	Function C_dummy_data_p return number;
	Function C_batch_name_p return varchar2;
	Function C_batch_description_p return varchar2;
	Function C_batch_status_p return varchar2;
	Function C_Through_date_p return date;
	Function C_batch_status_meaning_p return varchar2;
	Function C_batch_active_closed_p return varchar2;
	Function C_YES_p return varchar2;
	Function C_NO_p return varchar2;
	Function C_RUN_PURGE_p return varchar2;
	Function C_COMMIT_SIZE_p return number;
	Function C_Batch_Purged_Date_p return varchar2;
END PA_PAXARPPR_XMLP_PKG;

/
