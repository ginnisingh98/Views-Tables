--------------------------------------------------------
--  DDL for Package PO_POXQUAPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXQUAPR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXQUAPRS.pls 120.1 2007/12/25 11:37:30 krreddy noship $ */
	P_VENDOR_FROM	varchar2(240);
	P_VENDOR_TO	varchar2(240);
	P_BUYER	varchar2(240);
	P_CREATION_DATE_FROM	varchar2(40);
	P_CREATION_DATE_TO	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_QTY_PRECISION	number;
	P_GET_PRECISION	varchar2(40);
	P_title	varchar2(50);
	P_WHERE_ITEM	varchar2(2000);
	P_WHERE_CAT	varchar2(2000);
	P_item_from	varchar2(900);
	P_item_to	varchar2(900);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_STRUCT_NUM	varchar2(15);
	P_ITEM_STRUCT_NUM	varchar2(15);
	P_report_type	number;
	P_detail_summary	varchar2(1);
        FORMAT_MASK varchar2(100);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function per_acceptedformula(Received in number, Accepted in number) return number  ;
	function per_rejectedformula(Received in number, Rejected in number) return number  ;
	function per_returnedformula(Received in number, Returned in number) return number  ;
	function c_item_per_acceptedformula(C_item_sum_rec in number, C_item_sum_acc in number) return number  ;
	function c_item_per_rejectedformula(C_item_sum_rec in number, C_item_sum_rej in number) return number  ;
	function c_item_per_returnedformula(C_item_sum_rec in number, C_item_sum_ret in number) return number  ;
	function uninspectedformula(Received in number, Accepted in number, Rejected in number) return number  ;
	function per_uninspectedformula(Received in number, Uninspected in number) return number  ;
	function per_rtv_wout_inspectformula(Received in number, Rtv_wout_inspect in number) return number  ;
	function c_item_per_uninsformula(C_item_sum_rec in number, C_item_sum_unins in number) return number  ;
	function c_item_per_rtv_wout_insformula(C_item_sum_rec in number, C_item_sum_rtv_wout_ins in number) return number  ;
	function quantity_acceptedformula(pll_quantity_accepted in number, conversion_rate in varchar2) return number  ;
	function quantity_rejectedformula(conversion_rate in varchar2, pll_quantity_rejected in number) return number  ;
	function quantity_orderedformula(conversion_rate in varchar2, pll_quantity_ordered in number) return number  ;
	function c_tot_returnedformula(parent_line_location_id in number, Item_id in number) return number  ;
	function c_tot_inspectedformula(parent_line_location_id in number, Item_id in number) return number  ;
	function c_tot_receivedformula(parent_line_location_id in number, Item_id in number) return number  ;
END PO_POXQUAPR_XMLP_PKG;


/
