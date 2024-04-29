--------------------------------------------------------
--  DDL for Package PQH_PQUBGTEN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQUBGTEN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQUBGTENS.pls 120.1 2007/12/21 17:28:57 vjaganat noship $ */
	P_ORG_STRUCTURE_ID	number;
	P_START_ORG_ID	number;
	P_BUSINESS_GROUP_ID	number;
	P_UNIT_OF_MEASURE	varchar2(50);
	P_ENTITY_CODE	varchar2(50);
	P_END_DATE	date;
	P_START_DATE	date;
	P_EFFECTIVE_DATE	date;
        P_EFFECTIVE_DATE_T	VARCHAR2(40);
	P_BATCH_NAME	varchar2(50);
	P_CONC_REQUEST_ID	number;
	CP_No_Data	varchar2(30);
	CP_sysdate	date;
	CP_BG_NAME	varchar2(240);
	CP_UOM	varchar2(80);
	CP_ENTITY_NAME	varchar2(80);
	CP_ORG_STRUCTURE_NAME	varchar2(240);
	CP_START_ORG_NAME	varchar2(240);
	CP_REPORT_TITLE	varchar2(80);
	function BeforeReport return boolean  ;
	function CP_sysdateFormula return Date  ;
	function AfterReport return boolean  ;
	function cf_amount_format_maskformula(uom in varchar2) return char  ;
	function BeforePForm return boolean  ;
	Function CP_No_Data_p return varchar2;
	Function CP_sysdate_p return date;
	Function CP_BG_NAME_p return varchar2;
	Function CP_UOM_p return varchar2;
	Function CP_ENTITY_NAME_p return varchar2;
	Function CP_ORG_STRUCTURE_NAME_p return varchar2;
	Function CP_START_ORG_NAME_p return varchar2;
	Function CP_REPORT_TITLE_p return varchar2;
END PQH_PQUBGTEN_XMLP_PKG;

/
