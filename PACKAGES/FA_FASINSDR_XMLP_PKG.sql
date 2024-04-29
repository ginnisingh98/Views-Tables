--------------------------------------------------------
--  DDL for Package FA_FASINSDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FASINSDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FASINSDRS.pls 120.0.12010000.1 2008/07/28 13:16:47 appldev ship $ */
	P_CONC_REQUEST_ID	number;
	P_COMPANY_FROM	varchar2(30);
	P_ASSET_BOOK	varchar2(40);
	P_LOCATION_FLEX_FROM	varchar2(240);
	P_COMPANY_TO	varchar2(30);
	P_LOCATION_FLEX_TO	varchar2(240);
	P_ASSET_NUMBER_FROM	varchar2(15);
	P_ASSET_NUMBER_TO	varchar2(15);
	P_CATEGORY_FLEX_FROM	varchar2(40);
	P_CATEGORY_FLEX_TO	varchar2(40);
	C_SET_OF_BOOKS_ID	number;
	c_acct_flex_struct	number;
	c_acct_flex_bal_seg	varchar2(100);
	c_cat_flex_struct	number;
	c_where_cat_flex	varchar2(1000);
	c_cat_flex_seg	varchar2(100);
	C_SOB_NAME	varchar2(40);
	c_book_class	varchar2(20);
	c_book_type_code	varchar2(30);
	c_distribution_source_book	varchar2(20);
	C_currency_code	varchar2(32767);
	c_precision	varchar2(1);
	c_locn_flex_struct	number;
	c_loc_flex_seg	varchar2(100);
	c_where_locn_flex	varchar2(1000);
	c_acct_flex_bal_where	varchar2(1000);
	C_NO_DATA_FOUND	varchar2(2);
	C_TODAYS_DATE	varchar2(25);
	C_WHERE_ASSET_NUMBER	varchar2(100)  := 'Asset' ;
	function AfterReport return boolean  ;
	function BeforeReport return boolean  ;
	function C_1Formula return VARCHAR2  ;
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
	Function c_precision_p return varchar2;
	Function c_locn_flex_struct_p return number;
	Function c_loc_flex_seg_p return varchar2;
	Function c_where_locn_flex_p return varchar2;
	Function c_acct_flex_bal_where_p return varchar2;
	Function C_NO_DATA_FOUND_p return varchar2;
	Function C_TODAYS_DATE_p return varchar2;
	Function C_WHERE_ASSET_NUMBER_p return varchar2;
END FA_FASINSDR_XMLP_PKG;


/
