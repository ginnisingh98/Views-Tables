--------------------------------------------------------
--  DDL for Package PA_PAXRWIMP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXRWIMP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXRWIMPS.pls 120.0 2008/01/02 11:58:25 krreddy noship $ */
	P_costing	varchar2(3);
	P_CONC_REQUEST_ID	number;
	P_DEBUG_MODE	varchar2(3);
	P_RULE_OPTIMIZER	varchar2(3);
	C_Company_Name_Header	varchar2(40);
	FUNCTION  get_company_name    RETURN BOOLEAN  ;
	function BeforeReport return boolean  ;
	function get_meaning (type in VARCHAR2,code in VARCHAR2) return VARCHAR2  ;
	function c_descformula(glpa_type in varchar2) return varchar2  ;
	function cf_overtime_flagformula(overtime_flag in varchar2) return varchar2  ;
	function cf_iflabortoglformula(Iflabortogl in varchar2) return varchar2  ;
	function cf_ifrevtoglformula(Ifrevenuetogl in varchar2) return varchar2  ;
	function cf_ifusgtoglformula(ifusagetogl in varchar2) return varchar2  ;
	function cf_cen_inv_collformula(centralized_invoicing_flag in varchar2) return varchar2  ;
	function cf_ifretnaccformul(Ifretnacc in varchar2) return varchar2  ;
	function cf_mrc_for_fundformula(mrc_for_fund in varchar2) return char  ;
	function cf_reval_mrc_fundformula(reval_mrc_fund in varchar2) return char  ;
	function cf_mrc_for_finplanformula(mrc_for_finplan in varchar2) return char  ;
	function cf_ingainlossformula(ingainloss in varchar2) return char  ;
	function cf_exch_rate_typeformula(exch_rate_type in varchar2) return char  ;
	function  cf_customer_relationformula(cust_acc_rel_code in varchar2) return char  ;
	function cf_credit_memoformula(credit_memo_reason_flag in varchar2) return char  ;
	function AfterReport return boolean  ;
	Function C_Company_Name_Header_p return varchar2;
END PA_PAXRWIMP_XMLP_PKG;

/
