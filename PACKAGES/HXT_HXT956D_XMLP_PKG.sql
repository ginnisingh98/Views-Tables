--------------------------------------------------------
--  DDL for Package HXT_HXT956D_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT956D_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT956DS.pls 120.0 2007/12/03 11:09:17 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	function bhtformula(ELT_BASE_ID in number, arg_effective_start_date in date, arg_effective_end_date in date) return varchar2  ;
	function premformula(ELT_PREMIUM_ID in number) return varchar2  ;
	function BeforePForm return boolean  ;
	function AfterPForm return boolean  ;
	function BeforeReport return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT956D_XMLP_PKG;

/
