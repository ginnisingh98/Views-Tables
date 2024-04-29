--------------------------------------------------------
--  DDL for Package PO_POXPRIPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPRIPR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPRIPRS.pls 120.3 2008/01/22 07:44:46 dwkrishn noship $ */
	P_title	varchar2(50);
	P_FLEX_ITEM	varchar2(800);
	P_CONC_REQUEST_ID	number;
	P_FLEX_CAT	varchar2(31000);
	P_PERIOD_FROM	varchar2(40);
	P_PERIOD_TO	varchar2(40);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_qty_precision	varchar2(40);
  QTY_PRECISION varchar2(100);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_CATEGORY_FROM	varchar2(900);
	P_CATEGORY_TO	varchar2(900);
	P_ITEM_FROM	varchar2(900);
	P_ITEM_TO	varchar2(900);
	P_WHERE_CAT	varchar2(2000) := '1=1' ;
	P_WHERE_ITEM	varchar2(2000) := '1=1' ;
	P_STRUCT_NUM	varchar2(15);
	P_STRUCT_NUM1	varchar2(15);
	P_ORDERBY_ITEM	varchar2(298);
	P_ORDERBY_CAT	varchar2(298);
	P_ORDERBY	varchar2(40);
	P_BASE_CURRENCY	varchar2(32767);
	P_ITEM_STRUCT_NUM	varchar2(32767);
	P_orderby_displayed	varchar2(80);
	LP_orderby_displayed	varchar2(80);
	P_ORDERBY_CLAUSE	varchar2(32767) := 'MCA.SEGMENT1';
	LP_orderby_clause	varchar2(32767) := 'MCA.SEGMENT1';
	P_PERIOD_START_DATE	date;
	P_PERIOD_END_DATE	date;
	PERIOD_WHERE	varchar2(1000) := '1=1';
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function ipvformula(Average_Purchase in number, Average_Invoice in number) return number  ;
	procedure get_precision  ;
	function orderby_clauseFormula return VARCHAR2  ;
	function get_p_struct_num return boolean  ;
	function item_average_purchase_roundfor(item_average_purchase in number, c_fnd_precision in number) return number  ;
	function item_average_invoice_roundform(item_average_invoice in number, c_fnd_precision in number) return number  ;
	function AfterPForm return boolean  ;
	function average_purchase_roundformula(AVERAGE_PURCHASE in number, c_fnd_precision in number) return number  ;
	function c_amount_roundformula(C_AMOUNT in number, c_fnd_precision in number) return number  ;
	function average_invoice_roundformula(AVERAGE_INVOICE in number, c_fnd_precision in number) return number  ;
	function c_amount_tot_roundformula(C_AMOUNT_TOT in number, c_fnd_precision in number) return number  ;
	function rateformula(Unit_Of_measure in varchar2, Unit in varchar2, Item_id in number) return number  ;
	function po_primary_qtyformula(PO_Quantity in number, conv_Rate in number) return number  ;
	function ap_primary_qtyformula(AP_Quantity in number, conv_Rate in number) return number  ;
	function average_invoiceformula(Q_Invoiced in number, Total_amount_Invoiced in number) return number  ;
	function average_purchaseformula(C_amount in number, Q_Purchased in number) return number  ;
END PO_POXPRIPR_XMLP_PKG;


/
