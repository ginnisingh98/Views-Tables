--------------------------------------------------------
--  DDL for Package FA_FAS420_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FAS420_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: FAS420S.pls 120.0.12010000.1 2008/07/28 13:14:21 appldev ship $ */
	P_BOOK	varchar2(15);
	P_PERIOD1	varchar2(15);
	P_CONC_REQUEST_ID	number;
	P_PERIOD2	varchar2(15);
	P_MIN_PRECISION	number;
	lp_currency_code	varchar2(15);
	p_ca_org_id	number;
	p_ca_set_of_books_id	number;
	p_mrcsobtype	varchar2(10);
	lp_fa_book_controls	varchar2(50);
	lp_fa_books	varchar2(50);
	lp_fa_deprn_summary	varchar2(50);
	lp_fa_deprn_detail	varchar2(50);
	lp_fa_deprn_periods	varchar2(50);
	lp_fa_adjustments	varchar2(50);
	ACCT_BAL_APROMPT	varchar2(200);
	ACCT_CC_APROMPT	varchar2(200);
	CAT_MAJ_RPROMPT	varchar2(200);
	Period1_POD	date;
	Period1_PCD	date;
	Period1_FY	number;
	Period2_POD	date;
	Period2_PCD	date;
	Period2_FY	number;
	PERIOD_FROM	varchar2(20);
	PERIOD_TO	varchar2(20);
	function Report_NameFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function Period1_PCFormula return Number  ;
	function Period2_PCFormula return Number  ;
	function d_lifeformula(life in number, adj_rate in number, bonus_rate in number, prod in number) return varchar2  ;
	function AfterPForm return boolean  ;
	Function ACCT_BAL_APROMPT_p return varchar2;
	Function ACCT_CC_APROMPT_p return varchar2;
	Function CAT_MAJ_RPROMPT_p return varchar2;
	Function Period1_POD_p return date;
	Function Period1_PCD_p return date;
	Function Period1_FY_p return number;
	Function Period2_POD_p return date;
	Function Period2_PCD_p return date;
	Function Period2_FY_p return number;
	Function PERIOD_FROM_p return varchar2;
	Function PERIOD_TO_p return varchar2;
	--added
	Function LP_CURRENCY_CODE_p return varchar2 ;
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR;
END FA_FAS420_XMLP_PKG;


/
