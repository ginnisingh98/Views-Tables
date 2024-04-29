--------------------------------------------------------
--  DDL for Package FA_JAPAN_DEP_TAX_ADDITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_JAPAN_DEP_TAX_ADDITION_PKG" AUTHID CURRENT_USER AS
/* $Header: FADTXAS.pls 120.1.12010000.2 2009/07/19 12:48:20 glchen ship $ */

	P_CONC_REQUEST_ID	number;
	P_CLASSIFICATION	varchar2(32767);
	P_DECISION_COST	varchar2(32767);
	P_BOOK	varchar2(15);
	P_STATE	varchar2(150);
	P_YEAR	number;
	P_PAGESIZE	number;
	P_REQUEST_ID	number;
	H_WHERE	varchar2(100) := 'DTI.END_COST >0' ;
	H_DECISION	varchar2(14);
	H_IMPERIAL_CODE	varchar2(32767);
	H_IMPERIAL_YEAR	number;
	H_NO_DATA_FOUND	number;
	H_STATE_DESC	varchar2(400);
	CURRENCY_CODE	varchar2(20);
	H_CURRENCY_WIDTH	number;
	H_CLASSIFICATION	varchar2(20);
	h_loc_flex_struct	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function d_state_descformula0005(sum_state in varchar2) return char  ;
	function d_decisionformula0007(sum_state in varchar2) return char  ;
	function d_state_countformula(sum_state in varchar2) return number  ;
	Function H_WHERE_p return varchar2;
	Function H_DECISION_p return varchar2;
	Function H_IMPERIAL_CODE_p return varchar2;
	Function H_IMPERIAL_YEAR_p return number;
	Function H_NO_DATA_FOUND_p return number;
	Function H_STATE_DESC_p return varchar2;
	Function CURRENCY_CODE_p return varchar2;
	Function H_CURRENCY_WIDTH_p return number;
	Function H_CLASSIFICATION_p return varchar2;
	Function h_loc_flex_struct_p return number;
END FA_JAPAN_DEP_TAX_ADDITION_PKG;

/
