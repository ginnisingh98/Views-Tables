--------------------------------------------------------
--  DDL for Package HXT_HXT956A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT956A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT956AS.pls 120.0 2007/12/03 10:59:18 amakrish noship $ */
	P_CONC_REQUEST_ID	number;
	function cf_pep_nameformula(pep_id in number) return varchar2  ;
	function cf_pip_nameformula(pip_id in number) return varchar2  ;
	function cf_egt_nameformula(egt_id in number) return varchar2  ;
	function earn_typeformula(arg_ELEMENT_TYPE_ID in number, arg_EFFECTIVE_START_DATE in date, arg_EFFECTIVE_END_DATE in date) return varchar2  ;
	function BeforePForm return boolean  ;
	function BeforeReport return boolean  ;
END HXT_HXT956A_XMLP_PKG;

/
