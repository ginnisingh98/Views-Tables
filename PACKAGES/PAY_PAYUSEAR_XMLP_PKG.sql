--------------------------------------------------------
--  DDL for Package PAY_PAYUSEAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYUSEAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYUSEARS.pls 120.0 2007/12/28 06:45:41 srikrish noship $ */
	P_BUSINESS_GROUP_ID	number;
	P_CONC_REQUEST_ID	number;
	P_PAYROLL_ACTION_ID	number;
	P_CONSOLIDATION_SET_ID	number;
	P_PAYROLL_ID	number;
	P_TIME_PERIOD_ID	number;
	P_TAX_UNIT_ID	number;
	P_ELEMENT_TYPE_ID	number;
	CONSOLIDATION_SET_ID	varchar2(40);
	C_TAX_UNIT_ADDRESS2	varchar2(300);
	C_BUSINESS_GROUP_NAME	varchar2(240);
	C_CONSOLIDATION_SET_NAME	varchar2(60);
	C_TIME_PERIOD_NAME	varchar2(35);
	C_PAYROLL_NAME	varchar2(80);
	C_PAYROLL_ACTION	varchar2(80);
	C_TAX_UNIT	varchar2(240);
	C_PERIOD_START_DATE	date;
	C_PERIOD_END_DATE	date;
	C_ELEMENT_TYPE_NAME	varchar2(80);
	function BeforeReport return boolean  ;
	function tax_unit_addressformula(location_id in number) return varchar2  ;
	function c_valueformula(value in varchar2, uom in varchar2, currency1 in varchar2) return varchar2  ;
	function G_tax_unit_headerGroupFilter return boolean  ;
	function AfterReport return boolean  ;
	Function C_TAX_UNIT_ADDRESS2_p return varchar2;
	Function C_BUSINESS_GROUP_NAME_p return varchar2;
	Function C_CONSOLIDATION_SET_NAME_p return varchar2;
	Function C_TIME_PERIOD_NAME_p return varchar2;
	Function C_PAYROLL_NAME_p return varchar2;
	Function C_PAYROLL_ACTION_p return varchar2;
	Function C_TAX_UNIT_p return varchar2;
	Function C_PERIOD_START_DATE_p return date;
	Function C_PERIOD_END_DATE_p return date;
	Function C_ELEMENT_TYPE_NAME_p return varchar2;
END PAY_PAYUSEAR_XMLP_PKG;

/
