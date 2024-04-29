--------------------------------------------------------
--  DDL for Package PO_RCVTXRTR_NEW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_RCVTXRTR_NEW_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RCVTXRTRS.pls 120.3 2007/12/25 13:51:02 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	ITEM_ID	varchar2(40);
	RRP_ORGANIZATION_ID	varchar2(40);
	RRP_TRANSACTION_ID	varchar2(40);
	RRP_SHIPMENT_LINE_ID	varchar2(40);
	RRP_FROM_INTERFACE	varchar2(40);
	P_FLEX_CAT	varchar2(31000);
	P_FLEX_ITEM	varchar2(800);
	P_org_displayed	varchar2(60);
	P_org_id	number;
	P_FLEX_LOCATOR	varchar2(800) := '(MSL.SEGMENT1||''\n''||MSL.SEGMENT2||''\n''||MSL.SEGMENT3||''\n''||MSL.SEGMENT4||''\n''||MSL.SEGMENT5||''\n''||MSL.SEGMENT6||''\n''||MSL.SEGMENT7||''\n''||MSL.SEGMENT8||''\n''||MSL.SEGMENT9||''\n''||MSL.SEGMENT10||
	''\n''||MSL.SEGMENT11||''\n''||MSL.SEGMENT12||''\n''||MSL.SEGMENT13||''\n''||MSL.SEGMENT14||''\n''||MSL.SEGMENT15||''\n''||MSL.SEGMENT16||''\n''||MSL.SEGMENT17||''\n''||MSL.SEGMENT18||''\n''||MSL.SEGMENT19||''\n''||MSL.SEGMENT20)' ;
	P_STRUCT_NUM	number;
	P_STRUCT_NUM1	number;
	P_ITEM_STRUCT_NUM	number;
	P_item_from	varchar2(900);
	P_Item_to	varchar2(900);
	P_category_to	varchar2(900);
	P_category_from	varchar2(900);
	P_vendor_from	varchar2(240);
	P_vendor_to	varchar2(240);
	P_po_num_from	varchar2(40);
	P_po_num_to	varchar2(40);
	P_receipt_num_from	varchar2(40);
	P_receipt_num_to	varchar2(40);
	P_req_num_from	varchar2(40);
	P_ship_num_to	varchar2(40);
	P_req_num_to	varchar2(40);
	P_ship_num_from	varchar2(40);
	P_trx_date_from	date;
	P_trx_date_to	date;
	P_receiver	varchar2(240);
	P_trx_type	varchar2(40);
	P_buyer	varchar2(240);
	P_inc_lot_and_serial	varchar2(1);
	P_exception	varchar2(1);
	P_detail_summary	varchar2(1);
	P_sort_by	varchar2(40);
	P_QTY_PRECISION	number;
	P_WHERE_CAT	varchar2(2400);
	P_WHERE_ITEM	varchar2(2400);
	P_INV_STATUS	varchar2(1);
	P_where_org_id	varchar2(240) := '1=1';
	P_where_receipt_num_from	varchar2(240) := '1=1';
	P_where_receipt_num_to	varchar2(240) := '1=1';
	P_where_receiver	varchar2(240);
	P_where_po_num_to	varchar2(240) := '1=1';
	P_where_vendor_to	varchar2(240) := '1=1';
	P_where_vendor_from	varchar2(240) := '1=1';
	P_where_buyer	varchar2(240) := '1=1';
	P_where_po_num_from	varchar2(240) := '1=1';
	P_where_trx_type	varchar2(240) := '1=1';
	P_where_trx_date_from	varchar2(240) := '1=1';
	P_where_trx_date_to	varchar2(240) := '1=1';
	P_where_ship_num_from	varchar2(240) := '1=1';
	P_where_ship_num_to	varchar2(240) := '1=1';
	P_where_req_num_from	varchar2(240) := '1=1';
	P_where_req_num_to	varchar2(240) := '1=1';
	P_CUSTOMER_FROM	varchar2(240);
	P_CUSTOMER_TO	varchar2(240);
	P_RMA_NUM_FROM	varchar2(40);
	P_RMA_NUM_TO	varchar2(40);
	P_where_customer_from	varchar2(240) := '1=1';
	P_where_customer_to	varchar2(240) :='1=1';
	P_where_rma_num_from	varchar2(240) := '1=1';
	P_where_rma_num_to	varchar2(240) := '1=1';
	function BeforeReport return boolean  ;
	function get_p_struct_num return boolean  ;
	procedure get_precision  ;
	function G_src_and_typeGroupFilter return boolean  ;
	function AfterPForm return boolean  ;
	function AfterReport return boolean  ;
	function rcv_uom_convertformula(PO_UOM in varchar2, UOM in varchar2, ls_item_id in number, PRICE in number) return number  ;
END PO_RCVTXRTR_new_XMLP_PKG;


/
