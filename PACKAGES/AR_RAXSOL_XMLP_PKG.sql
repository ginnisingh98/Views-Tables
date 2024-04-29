--------------------------------------------------------
--  DDL for Package AR_RAXSOL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXSOL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXSOLS.pls 120.0 2007/12/27 14:34:30 abraghun noship $ */
	P_CONC_REQUEST_ID	number;
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(80);
	RP_DATA_FOUND	varchar2(300);
	RP_ID	varchar2(80);
	RP_NONE	varchar2(80);
	RP_SEGMENT	varchar2(80);
	RP_NUMBER	varchar2(80);
	RP_VALUE	varchar2(80);
	RP_YES	varchar2(80);
	RP_AMT	varchar2(80);
	RP_NO	varchar2(80);
	RP_PER	varchar2(80);
	RP_CODE	varchar2(80);
	c_industry_code	varchar2(20);
	c_salesrep_title	varchar2(20);
	c_salescredit_title	varchar2(20);
	c_salester_title	varchar2(20);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function report_nameformula(Company_Name in varchar2) return varchar2  ;
	function C_GET_MEANINGFormula return Number  ;
	--function c_last_invoice_numberformula(auto_trx_numbering in varchar2, batch_source_id in number) return char  ;
	function c_last_invoice_numberformula(auto_trx_numbering in varchar2, batch_source_id_t in number) return char  ;
	function RP_SYSDATEFormula return VARCHAR2  ;
	function c_data_not_foundformula(Name in varchar2) return number  ;
	procedure get_lookup_meaning(p_lookup_type	in VARCHAR2,
			     p_lookup_code	in VARCHAR2,
			     p_lookup_meaning  	in out NOCOPY VARCHAR2)
			     ;
	procedure get_boiler_plates  ;
	function set_display_for_core(p_field_name in VARCHAR2)
         return boolean  ;
	function set_display_for_gov(p_field_name in VARCHAR2)
         return boolean  ;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_ID_p return varchar2;
	Function RP_NONE_p return varchar2;
	Function RP_SEGMENT_p return varchar2;
	Function RP_NUMBER_p return varchar2;
	Function RP_VALUE_p return varchar2;
	Function RP_YES_p return varchar2;
	Function RP_AMT_p return varchar2;
	Function RP_NO_p return varchar2;
	Function RP_PER_p return varchar2;
	Function RP_CODE_p return varchar2;
	Function c_industry_code_p return varchar2;
	Function c_salesrep_title_p return varchar2;
	Function c_salescredit_title_p return varchar2;
	Function c_salester_title_p return varchar2;
END AR_RAXSOL_XMLP_PKG;



/
