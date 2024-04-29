--------------------------------------------------------
--  DDL for Package PO_POXPRREQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPRREQ_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPRREQS.pls 120.1 2007/12/25 11:28:59 krreddy noship $ */
	P_title	varchar2(50);
	P_FLEX_ITEM	varchar2(800);
	P_FLEX_CAT	varchar2(31000);
	P_CONC_REQUEST_ID	number;
	P_FLEX_ACC	varchar2(31000);
	P_REQ_NUM_FROM	varchar2(40);
	P_REQ_NUM_TO	varchar2(40);
	P_STRUCT_NUM	varchar2(15);
	P_QTY_PRECISION	number;
	P_BASE_CURRENCY	varchar2(40);
	P_CHART_OF_ACCOUNTS_ID	varchar2(40);
	P_ITEM_STRUCT_NUM	varchar2(40);
	P_SINGLE_REQ_PRINT	number;
	PRL_PO_ITEM_ID	varchar2(40);
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function get_p_struct_num return boolean  ;
	function get_chart_of_accounts_id return boolean  ;
	function g_requisitiongroupfilter(req_num_type in varchar2, Requisition in varchar2) return boolean  ;
	function line_notesformula(line_note_datatype_id in number, line_note_media_id in number) return char  ;
	function item_noteformula(item_note_datatype_id in number, item_note_media_id in number) return char  ;
	function header_notesformula(header_note_datatype_id in number, header_note_media_id in number) return char  ;
	function c_amount_precision(GL_CURRENCY in varchar2, C_AMOUNT in number) return number  ;
	function c_total_amount_precision(GL_CURRENCY in varchar2, TOTAL_AMOUNT in number) return number  ;
END PO_POXPRREQ_XMLP_PKG;


/
