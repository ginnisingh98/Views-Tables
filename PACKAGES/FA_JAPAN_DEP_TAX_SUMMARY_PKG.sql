--------------------------------------------------------
--  DDL for Package FA_JAPAN_DEP_TAX_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_JAPAN_DEP_TAX_SUMMARY_PKG" AUTHID CURRENT_USER AS
/* $Header: FADTXSS.pls 120.2.12010000.3 2009/10/15 12:05:04 pmadas ship $ */

	P_CONC_REQUEST_ID	number;
	P_REQUEST_ID	varchar2(40);
	P_STATE	varchar2(40);
	P_YEAR	number;
	P_BOOK	varchar2(15);
        -- Bug 8985010
        P_CATEGORY_STRUCTURE_ID       number;
        P_TAX_ASSET_TYPE_SEGMENT      number;
        P_MINOR_CATEGORY_EXISTS_CHECK varchar2(1);
        P_START_TAX_ASSET_TYPE        number;
        P_END_TAX_ASSET_TYPE          number;
        -- End Bug 8985010
	H_IMPERIAL_CODE	varchar2(20);
	H_IMPERIAL_YEAR	number;
	H_TODAY_IMPERIAL_CODE	varchar2(20);
	H_TODAY_IMPERIAL_YEAR	number;
	H_DECISION	varchar2(20);
	H_STATE_DESC	varchar2(400);
	CURRENCY_CODE	varchar2(20);
	H_LOC_FLEX_STRUCT	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_state_descformula(l_state in varchar2) return varchar2  ;
	Function H_IMPERIAL_CODE_p return varchar2;
	Function H_IMPERIAL_YEAR_p return number;
	Function H_TODAY_IMPERIAL_CODE_p return varchar2;
	Function H_TODAY_IMPERIAL_YEAR_p return number;
	Function H_DECISION_p return varchar2;
	Function H_STATE_DESC_p return varchar2;
	Function CURRENCY_CODE_p return varchar2;
	Function H_LOC_FLEX_STRUCT_p return number;

        Function get_fnd_meaning(l_type in varchar2, l_code in varchar2) return varchar2;
        Function get_fa_meaning(l_type in varchar2, l_code in varchar2) return varchar2;
	Function d_decisionformula(l_state in varchar2) return varchar2  ;
	Function NO_DATA_FOUND_p return varchar2;

END FA_JAPAN_DEP_TAX_SUMMARY_PKG;

/
