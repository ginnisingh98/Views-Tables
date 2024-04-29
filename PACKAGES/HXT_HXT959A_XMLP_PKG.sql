--------------------------------------------------------
--  DDL for Package HXT_HXT959A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_HXT959A_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: HXT959AS.pls 120.0 2007/12/03 11:43:38 amakrish noship $ */
	START_DATE	date;
	END_DATE	date;
	P_PAYROLL_ID	number;
	P_CONC_REQUEST_ID	number;
	function cf_tot_varformula(STANDARD_START in number, TIME_IN in date) return varchar2 ;
	function cf_l_vlformula(STANDARD_START in number, TIME_IN in date) return varchar2 ;
	FUNCTION Reset_Hours ( p_in DATE, p_out DATE) RETURN VARCHAR2  ;
	function CF_Payroll_typeFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
END HXT_HXT959A_XMLP_PKG;

/
