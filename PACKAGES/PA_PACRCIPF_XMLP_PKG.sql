--------------------------------------------------------
--  DDL for Package PA_PACRCIPF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PACRCIPF_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PACRCIPFS.pls 120.0 2008/01/02 10:58:38 krreddy noship $ */
	P_FROM_PERIOD	varchar2(32767);
	P_PROJECT_TYPE	varchar2(40);
	P_PROJECT_NUMBER	varchar2(40);
	P_PROJECT_ORG	number;
	P_GROUP_BY_CAT	varchar2(1);
	P_conc_request_id	number;
	P_debug_mode	varchar2(1);
	P_CLASS_CATEGORY	varchar2(30);
	P_CLASS_CODE	varchar2(30);
	P_CAP_EVENT_ID	number;
	P_FROM_ACCOUNT	varchar2(1000);
	P_TO_ACCOUNT	varchar2(1000);
	P_TO_PERIOD	varchar2(32767);
	P_COA_ID	number;
	P_PROJECT_ID	number;
	p_ca_set_of_books_id	number;
	p_ca_org_id	number;
	p_mrcsobtype	varchar2(10);
	lp_pa_curr_asset_cost	varchar2(50);
	lp_pa_proj_asset_line	varchar2(50);
	CP_COA_ID	number;
	CP_COMPANY_NAME	varchar2(80);
	CP_MIN_OPEN_DATE	date;
	CP_MAX_CLOSE_DATE	date;
	C_SOB_ID	varchar2(50);
	C_WHERE	varchar2(4000) :=  '''1''=''1''' ;
	CP_1	number;
	CP_PROJ_ORG_NAME	varchar2(80);
	CP_NO_DATA_FOUND	varchar2(80);
	function CF_FORMAT_MASKFormula return Char  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function AfterPForm return boolean  ;
	Function C_WHERE_p return varchar2;
	Function CP_1_p return number;
	Function CP_PROJ_ORG_NAME_p return varchar2;
	Function CP_NO_DATA_FOUND_p return varchar2;
END PA_PACRCIPF_XMLP_PKG;

/
