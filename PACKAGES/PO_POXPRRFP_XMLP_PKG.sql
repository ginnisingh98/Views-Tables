--------------------------------------------------------
--  DDL for Package PO_POXPRRFP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_POXPRRFP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POXPRRFPS.pls 120.1 2007/12/25 11:33:47 krreddy noship $ */
	P_report_type	varchar2(40);
	P_agent_id	varchar2(40);
	P_rfq_num_from	varchar2(40);
	P_rfq_num_to	varchar2(40);
	P_release_num_from	varchar2(40);
	P_release_num_to	varchar2(40);
	P_release_date_from	date;
	P_release_date_to	date;
	P_orderby	varchar2(40);
	P_FLEX_ITEM	varchar2(800);
	P_CONC_REQUEST_ID	number;
	PO_ITEM	varchar2(40);
	PO_HEADER_ID	varchar2(40);
	P_test_flag	varchar2(40);
	P_QTY_PRECISION	number;
	P_QTY_ORDERED	varchar2(40);
	P_user_id	number;
	MLS_FLAG	varchar2(1);
	p_description	varchar2(256);
	p_language_where	varchar2(400);
	temp_col_name	varchar2(40);
	p_uom_col_pol	varchar2(40);
	p_uom_col_pll	varchar2(40);
	p_uom_join_pll	varchar2(200);
	p_uom_join_pol	varchar2(200);
	P_fax_enable	varchar2(1);
	P_fax_num	varchar2(32767);
	P_SINGLE_RFQ_PRINT	number;
	C_address_at_top	varchar2(93);
	function where_clauseFormula return VARCHAR2  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function c_amount_pllformula(pll_quantity_ordered in number, pll_price_override in number) return number  ;
	function g_headersgroupfilter(rfq_num_type in varchar2, poh_rfq_num in varchar2,poh_po_header_id in number,poh_sequence_num in number) return boolean ;
	function c_shiptoformula(pll_ship_address_line1 in varchar2, poh_ship_address_line1 in varchar2, pll_ship_address_line2 in varchar2, poh_ship_address_line2 in varchar2,
	pll_ship_address_line3 in varchar2, poh_ship_address_line3 in varchar2, pll_ship_adr_info in varchar2, poh_ship_adr_info in varchar2, pll_ship_country in varchar2, poh_ship_country in varchar2) return varchar2  ;
	function check_security(poh_rfq_num in varchar2) return boolean  ;
	function round_pol_amt(c_amount_pol in number, c_currency_precision in number) return number  ;
	procedure POPULATE_MLS_LEXICALS  ;
	function mls_installed return boolean  ;
	function c_fax_headerformula(C_first_page in varchar2) return char  ;
	function c_fax_trailerformula(poh_no_of_lines in number, C_last_sum in number, CS_poh_vendor_name in varchar2, CS_poh_rfq_num in varchar2, CS_poh_buyer in varchar2, CS_poh_agent_id in varchar2) return char  ;
	function c_item_descformula(pol_po_item_id in number, pol_item_description in varchar2, C_msi_desc in varchar2, C_msit_desc in varchar2) return char  ;
	function header_noteformula(header_note_datatype_id in number, header_note_media_id in number) return char  ;
	function line_noteformula(line_note_datatype_id in number, line_note_media_id in number) return char  ;
	function item_noteformula(item_note_datatype_id in number, item_note_media_id in number) return char  ;
	Function C_address_at_top_p return varchar2;
END PO_POXPRRFP_XMLP_PKG;


/
