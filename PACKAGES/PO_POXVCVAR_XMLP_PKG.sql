--------------------------------------------------------
--  DDL for Package PO_POXVCVAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXVCVAR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXVCVARS.pls 120.1 2007/12/25 12:38:45 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_INVENTORY_ITEM_ID_FROM	varchar2(40);
	P_INVENTORY_ITEM_ID_TO	varchar2(40);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_FLEX_ITEM	varchar2(800);
	P_WHERE_ITEM	varchar2(2000);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_BASE_CURRENCY	varchar2(40);
	P_ASL_INSTALLED	varchar2(40);
	P_ASSIGNMENT_SET_ID	varchar2(40);
	P_ASSIGNMENT_SET_ID_Qry varchar2(40);
	P_ORGANIZATION_ID	varchar2(40);
	P_ORGANIZATION_CODE	varchar2(32767);
	CP_ORGANIZATION_CODE	varchar2(32767);
	function BeforeReport return boolean  ;
	function P_titleValidTrigger return boolean  ;
	function AfterReport return boolean  ;
	function get_actual(Expenditure_total in number, C_vendor_total in number) return number  ;
	function c_intendedformula(Split in number, Expenditure_Total in number) return number  ;
END PO_POXVCVAR_XMLP_PKG;


/
