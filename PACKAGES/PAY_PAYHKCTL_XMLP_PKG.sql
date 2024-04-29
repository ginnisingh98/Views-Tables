--------------------------------------------------------
--  DDL for Package PAY_PAYHKCTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYHKCTL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYHKCTLS.pls 120.0 2007/12/13 11:58:49 amakrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	LP_BUSINESS_GROUP_ID	number;
	LCF_business_group hr_all_organization_units.name%type;
	P_CONC_REQUEST_ID	number;
	P_ARCHIVE_ACTION_ID	varchar2(40);
	P_ARCHIVE_OR_MAGTAPE	varchar2(32767);
	LP_ARCHIVE_ACTION_ID varchar2(40);
        LP_ARCHIVE_OR_MAGTAPE varchar2(32767);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function CF_business_groupFormula return VARCHAR2  ;
	function cf_balance_calculationformula(ctr in number, X_HK_IR56_A_ASG_LE_YTD in varchar2, X_HK_IR56_B_ASG_LE_YTD in varchar2, X_HK_IR56_C_ASG_LE_YTD in varchar2,
	X_HK_IR56_D_ASG_LE_YTD in varchar2, X_HK_IR56_E_ASG_LE_YTD in varchar2, X_HK_IR56_F_ASG_LE_YTD in varchar2, X_HK_IR56_G_ASG_LE_YTD in varchar2, X_HK_IR56_H_ASG_LE_YTD in varchar2, X_HK_IR56_I_ASG_LE_YTD in varchar2, X_HK_IR56_J_ASG_LE_YTD in varchar2,
	X_HK_IR56_K1_ASG_LE_YTD in varchar2, X_HK_IR56_K2_ASG_LE_YTD in varchar2, X_HK_IR56_K3_ASG_LE_YTD in varchar2, X_HK_IR56_L_ASG_LE_YTD in varchar2) return number  ;
END PAY_PAYHKCTL_XMLP_PKG;

/
