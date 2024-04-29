--------------------------------------------------------
--  DDL for Package PO_POXSERPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXSERPR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXSERPRS.pls 120.1 2007/12/25 12:26:22 krreddy noship $ */
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_BUYER	varchar2(40);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_QTY_PRECISION	number;
	QTY_PRECISION varchar2(30);
	P_GET_PRECISION	varchar2(40);
	P_title	varchar2(52);
	P_WHERE_ITEM	varchar2(2000);
	P_WHERE_CAT	varchar2(2000);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_STRUCT_NUM	varchar2(15);
	P_ITEM_STRUCT_NUM	varchar2(15);
	P_detail_summary	varchar2(1);
	P_DRIVE_OFF_HEADERS	varchar2(40);
	P_DRIVE_OFF_VENDORS	varchar2(40);
	P_VENDOR_QUERY	varchar2(4000);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function locationformula(PO_RECEIVED in number, PO_WRONG_LOCATION in number) return number  ;
	function on_timeformula(PO_ORDERED in number, PO_RECEIVED in number, PO_ON_TIME in number) return number  ;
	function lateformula(PO_ORDERED in number, PO_RECEIVED in number, PO_LATE in number) return number  ;
	function earlyformula(PO_ORDERED in number, PO_RECEIVED in number, PO_EARLY in number) return number  ;
	function varianceformula(PO_RECEIVED in number, PO_DAYS_QTY in number) return number  ;
	function c_per_item_earlyformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_early in number) return number  ;
	function c_per_item_lateformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_late in number) return number  ;
	function c_per_item_on_timeformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_on_time in number) return number  ;
	function c_per_item_locformula(C_item_sum_rec in number, C_item_sum_w_loc in number) return number  ;
	function c_per_item_rejformula(C_item_sum_rec in number, C_item_sum_rej in number) return number  ;
	function c_per_item_varformula(C_item_sum_rec in number, C_item_sum_days_qty in number) return number  ;
	function orderedformula(shipment_conversion_rate in varchar2, pll_quantity_ordered in number) return number  ;
	function rejectedformula(shipment_conversion_rate in varchar2, pll_quantity_rejected in number) return number  ;
	function per_rejectedformula(PO_received in number, PO_rejected in number) return number  ;
	function openformula(Received in number, Ordered in number, cutoff_date in date) return number  ;
	function past_dueformula(Received in number, Ordered in number, cutoff_date in date) return number  ;
	function p_openformula(PO_ORDERED in number, PO_RECEIVED in number, PO_OPEN in number) return number  ;
	function p_past_dueformula(PO_ORDERED in number, PO_RECEIVED in number, PO_PAST_DUE in number) return number  ;
	function c_per_item_openformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_open in number) return number  ;
	function c_per_item_past_dueformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_past_due in number) return number  ;
	function quantity_received_on_timeformu(quantity_received_total in number, quantity_received_early in number, quantity_received_late in number) return number  ;
	function receivedformula(quantity_received_total in number) return number  ;
	function days_total_late_or_earlyformul(days_received_early in number, days_received_late in number) return number  ;
END PO_POXSERPR_XMLP_PKG;


/
