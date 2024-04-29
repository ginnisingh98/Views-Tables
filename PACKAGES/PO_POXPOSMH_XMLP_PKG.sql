--------------------------------------------------------
--  DDL for Package PO_POXPOSMH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPOSMH_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPOSMHS.pls 120.1 2007/12/25 11:21:24 krreddy noship $ */
	P_title	varchar2(50);
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(3100);
	P_CONC_REQUEST_ID	number;
	P_BUYER	varchar2(240);
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_INVOICE_DATE_FROM	varchar2(40);
	P_INVOICE_DATE_TO	varchar2(40);
	PRICE_HOLD	varchar2(40);
	QTY_ORD_HOLD	varchar2(40);
	QTY_REC_HOLD	varchar2(40);
	QUALITY_HOLD	varchar2(40);
	ORG_ID	varchar2(40);
	P_PRICE_HOLD	varchar2(40);
	P_QTY_ORD_HOLD	varchar2(40);
	P_QTY_REC_HOLD	varchar2(40);
	P_QUALITY_HOLD	varchar2(40);
	P_QTY_PRECISION	number;
	P_WHERE_CAT	varchar2(2000);
	P_WHERE_ITEM	varchar2(2000);
	P_STRUCT_NUM	varchar2(15);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_ITEM_STRUCT_NUM	varchar2(32767);
        FORMAT_MASK varchar2(100);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function c_report_avg_no_of_daysformula(C_report_tot_days_hold in number, C_report_number_total in number) return number  ;
	function c_total_days_holdingformula(average in number, number_amount_tot in number) return number  ;
	function c_unit_price_round(unit_price in varchar2, parent_currency_precision in number) return number  ;
	function c_invoice_price_round(invoice_price in number, parent_currency_precision in number) return number  ;
END PO_POXPOSMH_XMLP_PKG;


/
