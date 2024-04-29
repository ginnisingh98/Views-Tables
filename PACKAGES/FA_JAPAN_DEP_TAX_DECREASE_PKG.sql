--------------------------------------------------------
--  DDL for Package FA_JAPAN_DEP_TAX_DECREASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_JAPAN_DEP_TAX_DECREASE_PKG" AUTHID CURRENT_USER AS
/* $Header: FADTXDS.pls 120.1.12010000.2 2009/07/19 12:49:35 glchen ship $ */

	P_CONC_REQUEST_ID	number;
	P_STATE	varchar2(40);
	P_YEAR	number;
	P_BOOK	varchar2(15);
	P_REQUEST_ID	number;
	H_IMPERIAL_CODE	varchar2(20);
	H_IMPERIAL_YEAR	number;
	H_STATE_DESC	varchar2(400);
	CURRENCY_CODE	varchar2(20);
	h_loc_flex_struct	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function BetweenPage return boolean  ;
	function state_descformula(sum_state in varchar2) return char  ;
	function state_countformula(sum_state in varchar2) return number  ;
	Function H_IMPERIAL_CODE_p return varchar2;
	Function H_IMPERIAL_YEAR_p return number;
	Function H_STATE_DESC_p return varchar2;
	Function CURRENCY_CODE_p return varchar2;
	Function h_loc_flex_struct_p return number;
END FA_JAPAN_DEP_TAX_DECREASE_PKG;

/
