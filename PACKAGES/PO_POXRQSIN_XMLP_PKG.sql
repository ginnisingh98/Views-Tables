--------------------------------------------------------
--  DDL for Package PO_POXRQSIN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQSIN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQSINS.pls 120.2 2007/12/25 11:59:40 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_REQ_NUMBER_FROM	varchar2(40);
	P_REQ_NUMBER_TO	varchar2(40);
	P_CREATION_DATE_FROM	date;
	P_CREATION_DATE_TO	date;
	P_CREATION_DATE_FROM1	varchar2(10);
	P_CREATION_DATE_TO1	varchar2(10);
	P_REQUESTOR	varchar2(40);
	P_SUBINVENTORY_TO	varchar2(40);
	P_SUBINVENTORY_FROM	varchar2(40);
	P_WHERE_ITEM	varchar2(2000);
	P_STRUCT_NUM	varchar2(15);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_QTY_PRECISION	number;
	P_STATUS	varchar2(40);
	P_orderby	varchar2(13);
	P_status_displayed	varchar2(80);
	P_orderby_displayed	varchar2(80);
	P_OE_STATUS	varchar2(1);
	P_SINGLE_PO_PRINT	number;
	P_REQ_NUM_TYPE	varchar2(32767);
	P_WHERE_QUERY	varchar2(2000);
        FORMAT_MASK     varchar2(50);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function C_backorderedFormula return VARCHAR2  ;
	function C_fromFormula return VARCHAR2  ;
	function C_whereFormula return VARCHAR2  ;
	function C_interface_whereFormula return VARCHAR2  ;
	function C_requiredFormula return VARCHAR2  ;
	function c_ship_amountformula(required in number, unit_price in number) return number  ;
	function C_ship_qtyFormula return VARCHAR2  ;
	function P_WHERE_ITEMValidTrigger return boolean  ;
	function AfterPForm return boolean  ;
END PO_POXRQSIN_XMLP_PKG;


/
