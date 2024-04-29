--------------------------------------------------------
--  DDL for Package PO_POXRVXRV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXRVXRV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXRVXRVS.pls 120.1 2007/12/25 12:24:06 krreddy noship $ */
	P_title	varchar2(50);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ITEM	varchar2(800);
	P_PO_NUM_FROM	varchar2(40);
	P_VENDOR	varchar2(240);
	LP_VENDOR       varchar2(240);
	P_LOCATION	varchar2(40);
	P_PROMISE_DATE_FROM	varchar2(40);
	P_PROMISE_DATE_TO	varchar2(40);
	P_WHERE_CAT	varchar2(2000):='1 = 1';
	P_STRUCT_NUM	varchar2(15);
	LP_STRUCT_NUM   varchar2(15);
	P_category_from	varchar2(900);
	P_category_to	varchar2(900);
	P_FLEX_CAT	varchar2(800);
	P_orderby	varchar2(40);
	P_QTY_PRECISION	number;
	QTY_PRECISION  varchar2(100);
	P_blind_rcv_flag	varchar2(40);
	P_item_from	varchar2(900);
	P_Item_To	varchar2(900);
	P_WHERE_ITEM	varchar2(2000):='1 = 1';
	P_ITEM_STRUCT_NUM	varchar2(15);
	P_REQ_NUM_FROM	varchar2(40);
	P_REQ_NUM_TO	varchar2(40);
	P_PO_NUM_TO	varchar2(40);
	P_org_id	number;
	P_org_displayed	varchar2(60);
	P_where_po_num_to	varchar2(240):='1=1';
	P_where_po_num_from	varchar2(240):='1=1';
	P_where_req_num_to	varchar2(240):='1=1';
	P_where_req_num_from	varchar2(240):='1=1';
	P_where_vendor	varchar2(240):='1=1';
	P_where_no_po_num	varchar2(240):='1=1';
	P_where_no_req_num	varchar2(240):='1=1';
	P_RMA_NUM_FROM	number;
	P_RMA_NUM_TO	number;
	P_where_rma_num_from	varchar2(240):='1=1';
	P_where_rma_num_to	varchar2(240):='1=1';
	P_where_no_rma_num	varchar2(240):='1=1';
	P_CUSTOMER	varchar2(240);
        LP_CUSTOMER	varchar2(240);
	P_where_customer	varchar2(240):='1=1';
	P_PO_ORG	varchar2(500):='AND 1=1';
	P_REQ_ORG	varchar2(500):='AND 1=1';
	P_RMA_ORG	varchar2(500):='AND 1=1';
	P_LOCATION_ID	number;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function orderby_clauseFormula return VARCHAR2  ;
	procedure get_precision  ;
	function get_p_struct_num return boolean  ;
	function AfterPForm return boolean  ;
	function P_STRUCT_NUMValidTrigger return boolean  ;
	function BeforePForm return boolean  ;
	function BetweenPage return boolean  ;
	function P_org_displayedValidTrigger return boolean  ;
	function location_code1formula(location in varchar2, Shipment_type in varchar2, location_id1 in number) return char  ;
	function P_LOCATIONValidTrigger return boolean  ;
END PO_POXRVXRV_XMLP_PKG;


/
