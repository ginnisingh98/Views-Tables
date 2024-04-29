--------------------------------------------------------
--  DDL for Package PO_POXRQSDD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRQSDD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRQSDDS.pls 120.2 2007/12/25 11:58:08 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_REQ_NUMBER_FROM	varchar2(40);
	P_REQ_NUMBER_TO	varchar2(40);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_REQUESTOR	varchar2(40);
	P_qty_precision	varchar2(40);
    QTY_PRECISION varchar2(100);
     FORMAT_MASK VARCHAR2(100);
	P_ORDERBY	varchar2(40);
	P_OE_STATUS	varchar2(1);
	P_ORDERBY_DISPLAYED	varchar2(80);
	P_SINGLE_PO_PRINT	number;
	P_REQ_NUM_TYPE	varchar2(32767);
	P_WHERE_QUERY	varchar2(2000);
	C_quantity_shipped	number;
	C_Quantity_Variance	number;
	C_Cost_variance	number;
	function BeforeReport return boolean  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function C_shipped_qtyFormula return VARCHAR2  ;
	function C_selling_priceFormula return VARCHAR2  ;
	function C_fromFormula return VARCHAR2  ;
	function C_whereFormula return VARCHAR2  ;
	function c_get_shipped_quantity (Quantity_delivered in number, unit_price in number, Line in number, Req_number in varchar2, p_Order_Source_id in number) return number  ;
	function get_shipped_quantity(orig_line_num in varchar2,orig_header_num varchar2,psp_order_source_id number) return number   ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
	Function C_quantity_shipped_p return number;
	Function C_Quantity_Variance_p return number;
	Function C_Cost_variance_p return number;
END PO_POXRQSDD_XMLP_PKG;


/
