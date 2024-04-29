--------------------------------------------------------
--  DDL for Package ICX_POR_ITEM_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_ITEM_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: ICXIULDS.pls 115.9 2004/03/31 21:43:18 vkartik ship $*/

-- Use this for mode in move_data if called from edit rejected line
EDIT_REJECTED_LINE_MODE CONSTANT VARCHAR2(20) := 'EDIT_REJECTED_LINE';
-- Default mode for move_data
LOADER_MODE CONSTANT VARCHAR2(20) := 'LOADER';

-- The flags indicating whether root or local descriptors need to be refreshed
gRootDescRefresh BOOLEAN := FALSE;
gLocalDescRefresh BOOLEAN := FALSE;

PROCEDURE move_data(p_app_name IN VARCHAR2, p_request_id IN NUMBER,
  p_data_type IN VARCHAR2, p_supplier_id IN NUMBER, p_langs IN LANG_ARRAY,
  p_user_id IN NUMBER, p_user_login IN NUMBER, p_batch_size IN NUMBER,
  p_succ_line OUT NOCOPY NUMBER, p_failed_line OUT NOCOPY NUMBER,
  p_max_failed_line IN NUMBER DEFAULT -1,
  p_catalog_name IN VARCHAR2, --Bug#2611529
  p_negotiated_price IN VARCHAR2 --Bug#2611529
  );

PROCEDURE move_unsaved_failed_lines(p_request_id IN NUMBER,
  p_data_type IN VARCHAR2, p_supplier_id IN NUMBER,
  p_user_id IN NUMBER, p_user_login IN NUMBER,
  p_language IN VARCHAR2, p_lines_to_save_count IN NUMBER,
  p_failed_lines_saved_count OUT NOCOPY NUMBER);

PROCEDURE create_price_list(p_price_list_name IN VARCHAR2,
                            p_buyer_id in NUMBER,
                            p_supplier_id IN NUMBER,
                            p_currency IN VARCHAR2,
                            p_begindate IN VARCHAR2,
                            p_enddate IN VARCHAR2,
                            p_user_id IN NUMBER,
                            p_request_id IN NUMBER,
                            p_header_id OUT NOCOPY NUMBER,
                            p_type OUT NOCOPY VARCHAR2);

PROCEDURE update_price_list( p_header_id IN NUMBER,
                            p_begindate IN VARCHAR2,
                            p_enddate IN VARCHAR2,
                            p_user_id IN NUMBER,
                            p_request_id IN NUMBER);

-- moved here by sudsubra
-- from ICXXJVLS.pls

PROCEDURE save_failed_price(p_request_id IN NUMBER,
                            p_line_number IN NUMBER,
                            p_action IN VARCHAR2,
                            p_amount IN VARCHAR2,
                            p_currency IN VARCHAR2,
                            p_uom IN VARCHAR2,
                            p_buyer_name IN VARCHAR2,
                            p_supplier_name IN VARCHAR2,
                            p_supplier_part_num IN VARCHAR2,
                			      p_price_list_name IN VARCHAR2,
			                      p_price_code IN VARCHAR2,
                            p_supplier_comments IN VARCHAR2,
                            p_begin_date IN VARCHAR2,
                            p_end_date IN VARCHAR2,
                            p_supplier_part_auxid IN VARCHAR2, -- Bug#2611529
                            p_supplier_site_code IN VARCHAR2);

PROCEDURE save_failed_price_list(p_request_id IN NUMBER,
			    p_line_number IN NUMBER,
			    p_action IN VARCHAR2,
          p_price_list_name IN VARCHAR2,
			    p_currency IN VARCHAR2,
			    p_buyer_name IN VARCHAR2,
			    p_supplier_name IN VARCHAR2,
			    p_begin_date IN VARCHAR2,
			    p_end_date IN VARCHAR2);

PROCEDURE reject_catalog(p_request_id IN NUMBER,
                           p_line_type IN VARCHAR2,
                           p_descriptor_key IN VARCHAR2,
                           p_descriptor_val IN VARCHAR2,
                           p_error_message IN VARCHAR2
                           );

PROCEDURE save_failed_admin(p_request_id IN NUMBER,
                           p_line_number IN NUMBER,
                           p_buyer IN VARCHAR2,
                           p_contract_ref_num IN VARCHAR2
                           );
PROCEDURE get_contracts_pass_failed( p_request_id IN NUMBER,
                             p_succ_count OUT NOCOPY number,
                             p_failed_count OUT NOCOPY number);
PROCEDURE get_global_supplier_currency( p_request_id IN NUMBER,
                             p_supplier OUT NOCOPY VARCHAR,
                             p_currency OUT NOCOPY VARCHAR);
PROCEDURE validate_contracts(p_request_id in number, p_line_number in number,
              p_buyer in varchar2, p_contract in varchar2,
              p_supplier OUT NOCOPY varchar2, p_currency OUT NOCOPY varchar2,
              p_error_message OUT NOCOPY varchar2) ;
PROCEDURE save_failed_admin_data (p_request_id in number) ;

procedure Debug(p_message in varchar2) ;
FUNCTION can_update(descriptor_key IN VARCHAR2) return boolean;
PROCEDURE handle_category_change (p_action IN VARCHAR2);
PROCEDURE reject_line(p_row_id IN UROWID, p_row_type IN VARCHAR2,
  p_error_message IN VARCHAR2);

END ICX_POR_ITEM_UPLOAD;

 

/
