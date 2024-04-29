--------------------------------------------------------
--  DDL for Package FA_FASINSVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASINSVR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASINSVRS.pls 120.0.12010000.1 2008/07/28 13:16:49 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_COMPANY_FROM	varchar2(30);
	P_ASSET_BOOK	varchar2(40);
	P_LOCATION_FLEX_FROM	varchar2(240);
	P_COMPANY_TO	varchar2(30);
	P_LOCATION_FLEX_TO	varchar2(240);
	P_ASSET_NUMBER_FROM	varchar2(40);
	P_ASSET_NUMBER_TO	varchar2(40);
	P_CATEGORY_FLEX_FROM	varchar2(40);
	P_CATEGORY_FLEX_TO	varchar2(40);
	C_SET_OF_BOOKS_ID	number;
	P_INSURANCE_COMPANY_FROM	varchar2(80);
	P_INSURANCE_COMPANY_TO	varchar2(80);
	P_CAL_METHOD_FROM	varchar2(32767);
	P_CAL_METHOD_TO	varchar2(32767);
	P_YEAR	varchar2(32767);
	P_REPORT_TYPE	varchar2(32767);
	c_acct_flex_struct	number;
	c_acct_flex_bal_seg	varchar2(2000) := 'gcc.segment1' ;
	c_cat_flex_struct	number;
	c_where_cat_flex	varchar2(1000);
	c_cat_flex_seg	varchar2(100) := 'cat.segment1' ;
	C_SOB_NAME	varchar2(40);
	c_book_class	varchar2(20);
	c_book_type_code	varchar2(30);
	c_distribution_source_book	varchar2(30);
	C_currency_code	varchar2(32767);
	c_precision	number;
	c_locn_flex_struct	number;
	c_loc_flex_seg	varchar2(1000) := 'loc.segment1' ;
	c_where_locn_flex	varchar2(1000);
	c_acct_flex_bal_where	varchar2(1000);
	C_NO_DATA_FOUND	varchar2(2);
	C_TODAYS_DATE	varchar2(25);
	c_where_cal_method	varchar2(400):='AND 1=1';
	c_where_ins_company	varchar2(1000):='AND 1=1';
	c_where_asset_number	varchar2(400):='AND 1=1';
	C_WHERE_OLD_INS_DATA	varchar2(1000);
	C_CURRENT_FISCAL_YEAR	varchar2(32767);
	L_count	number;
	CP_insurance_from	varchar2(240);
	CP_insurance_to	varchar2(240);
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function CF_NO_DATA_FOUNDFormula return Number  ;
	Function c_acct_flex_struct_p return number;
	Function c_acct_flex_bal_seg_p return varchar2;
	Function c_cat_flex_struct_p return number;
	Function c_where_cat_flex_p return varchar2;
	Function c_cat_flex_seg_p return varchar2;
	Function C_SOB_NAME_p return varchar2;
	Function c_book_class_p return varchar2;
	Function c_book_type_code_p return varchar2;
	Function c_distribution_source_book_p return varchar2;
	Function C_currency_code_p return varchar2;
	Function c_precision_p return number;
	Function c_locn_flex_struct_p return number;
	Function c_loc_flex_seg_p return varchar2;
	Function c_where_locn_flex_p return varchar2;
	Function c_acct_flex_bal_where_p return varchar2;
	Function C_NO_DATA_FOUND_p return varchar2;
	Function C_TODAYS_DATE_p return varchar2;
	Function c_where_cal_method_p return varchar2;
	Function c_where_ins_company_p return varchar2;
	Function c_where_asset_number_p return varchar2;
	Function C_WHERE_OLD_INS_DATA_p return varchar2;
	Function C_CURRENT_FISCAL_YEAR_p return varchar2;
	Function L_count_p return number;
	Function CP_insurance_from_p return varchar2;
	Function CP_insurance_to_p return varchar2;
END FA_FASINSVR_XMLP_PKG;


/
