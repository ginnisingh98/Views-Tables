--------------------------------------------------------
--  DDL for Package POS_ACK_SEARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ACK_SEARCH" AUTHID CURRENT_USER AS
/* $Header: POSASRCS.pls 115.2 2000/08/02 18:23:40 pkm ship    $ */

  g_user_id     NUMBER;
  g_responsibility_id  NUMBER;
TYPE g_text_table is table of varchar2(240) index by binary_integer;
g_dummy_tbl g_text_table;


PROCEDURE SEARCH_PO2(p_resp_id	IN	VARCHAR2 DEFAULT null);
PROCEDURE SEARCH_PO (
		pk1	IN	varchar2 default null,
		pk2	IN	varchar2 default null,
		pk3	IN	varchar2 default null,
		pk4	IN	varchar2 default null,
		pk5	IN	varchar2 default null,
		pk6	IN	varchar2 default null,
		pk7	IN	varchar2 default null,
		pk8	IN	varchar2 default null,
		pk9	IN	varchar2 default null,
		pk10	IN	varchar2 default null,
		c_outputs1	OUT varchar2,
		c_outputs2	OUT varchar2,
		c_outputs3	OUT varchar2,
		c_outputs4	OUT varchar2,
		c_outputs5	OUT varchar2,
		c_outputs6	OUT varchar2,
		c_outputs7	OUT varchar2,
		c_outputs8	OUT varchar2,
		c_outputs9	OUT varchar2,
		c_outputs10	OUT varchar2
	);
PROCEDURE FIXED_FRAME(l_supplier_contact IN number);
PROCEDURE CRITERIA_FRAME(p_advance_flag  IN      VARCHAR2  DEFAULT 'N',
			l_po_number	IN	VARCHAR2  DEFAULT null
			);
PROCEDURE COUNTER_FRAME(
                        p_first     IN  NUMBER DEFAULT 0,
                        p_last      IN  NUMBER DEFAULT 0,
                        p_total     IN  NUMBER DEFAULT 0
                        );

PROCEDURE BLANK_FRAME (
						l_called_from	IN	NUMBER DEFAULT 0,
						l_rows_inserted	IN	NUMBER	DEFAULT 0
					);
PROCEDURE ADD_FRAME (
                    p_total     IN  NUMBER  default 0
                    ) ;
PROCEDURE RESULT_POS
(
    p_advance_flag                  IN  VARCHAR2    DEFAULT 'N',
    pos_ack_sr_acc_status           IN  VARCHAR2    DEFAULT null,
    pos_ack_sr_acc_reqd             IN  VARCHAR2    DEFAULT null,
    pos_ack_sr_acc_reqd_start_date  IN  VARCHAR2    DEFAULT null,
    pos_ack_sr_acc_reqd_end_date    IN  VARCHAR2    DEFAULT null,
    pos_ack_sr_po_number            IN  VARCHAR2    DEFAULT null,
    pos_ack_sr_supplier_site_id     IN  VARCHAR2    DEFAULT null,
    pos_ack_supplier_site           IN  VARCHAR2    DEFAULT null,
	pos_ack_sr_doc_type				IN  VARCHAR2    DEFAULT null,
    pos_ack_sr_row_num              IN  VARCHAR2    DEFAULT null

);

PROCEDURE SHOW_POS(
						pos_ack_sr_row_num IN VARCHAR2 default '0',
						l_rows_inserted		IN NUMBER	default 0
				);

PROCEDURE  Find_Matching_Rows (
                        l_Acceptance_Status       IN VARCHAR2 default null,
                        l_Acceptance_Reqd_Flag    IN VARCHAR2 default null,
                        l_Start_Date              IN VARCHAR2 default null,
                        l_End_Date                IN VARCHAR2 default null,
                        l_PO_Number               IN VARCHAR2 default null,
                        l_Supplier_Site_Id        IN VARCHAR2 default null,
			l_Document_Type_Code           IN VARCHAR2 default null
                     );

PROCEDURE ACKNOWLEDGE_POS (
    pos_ack_row_num         IN  g_text_table default g_dummy_tbl,
    pos_ack_accept          IN  g_text_table default g_dummy_tbl,
    pos_ack_acc_type        IN  g_text_table default g_dummy_tbl,
    pos_ack_comments        IN  g_text_table default g_dummy_tbl,
    --pos_ack_document_type   IN  g_text_table default g_dummy_tbl,
    --pos_ack_currency        IN  g_text_table default g_dummy_tbl,
    --pos_ack_total           IN  g_text_table default g_dummy_tbl,
    --pos_ack_approval_status IN  g_text_table default g_dummy_tbl,
    pos_ack_shipto_loc      IN  g_text_table default g_dummy_tbl,
    pos_ack_carrier         IN  g_text_table default g_dummy_tbl,
    pos_ack_po_header_id    IN  g_text_table default g_dummy_tbl,
    pos_ack_release_id      IN  g_text_table default g_dummy_tbl,
    pos_ack_buyer_id        IN  g_text_table default g_dummy_tbl,
    pos_ack_acc_type_code   IN  g_text_table default g_dummy_tbl
    );

FUNCTION po_num(seg1 in varchar2, po_header_id in number default null) RETURN VARCHAR2;

FUNCTION GET_SUPPLIER_ID (p_user_id IN NUMBER) RETURN NUMBER;
PROCEDURE Paint_Search_Fields (p_advance_flag IN      VARCHAR2,
				l_po_number	IN	VARCHAR2  DEFAULT null
				);
PROCEDURE PAINT_EDIT_POS(l_row_num  NUMBER default 0);
PROCEDURE DISPLAY_LOG;
PROCEDURE CLEAR_LOG;

FUNCTION item_halign(l_index in number) RETURN VARCHAR2;
FUNCTION item_valign(l_index in number) RETURN VARCHAR2;
FUNCTION item_name(l_index in number) RETURN VARCHAR2;
FUNCTION item_code(l_index in number) RETURN VARCHAR2;
FUNCTION item_style(l_index in number) RETURN VARCHAR2;
FUNCTION item_displayed(l_index in number) RETURN BOOLEAN;
FUNCTION item_updateable(l_index in number) RETURN BOOLEAN;
FUNCTION item_reqd(l_index in number) RETURN VARCHAR2;
FUNCTION item_size(l_index in number) RETURN VARCHAR2;
FUNCTION get_option_string(l_index in number)  RETURN VARCHAR2;
FUNCTION get_result_value(p_index in number, p_col in number) return varchar2;
FUNCTION buyer(seg1 in varchar2, po_header_id in number default null) RETURN VARCHAR2;
PROCEDURE veera_debug(p_debug_string in varchar2);
procedure button(src IN varchar2, txt IN varchar2);
procedure button(src1 IN varchar2, txt1 IN varchar2, src2 IN varchar2, txt2 IN varchar2);
END POS_ACK_SEARCH;

 

/
