--------------------------------------------------------
--  DDL for Package HXT_HXT956C_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT956C_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT956CS.pls 120.0 2007/12/03 11:06:50 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	function earn_typeformula(arg_ELEMENT_TYPE_ID in number, arg_EFFECTIVE_START_DATE in date, arg_EFFECTIVE_END_DATE in date) return varchar2  ;
	function BeforePForm return boolean  ;
	function AfterPForm return boolean  ;
	function BeforeReport return boolean  ;
	function BetweenPage return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT956C_XMLP_PKG;

/
