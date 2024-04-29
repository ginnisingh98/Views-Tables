--------------------------------------------------------
--  DDL for Package POS_ASN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASN" AUTHID CURRENT_USER AS
/* $Header: POSASNES.pls 115.6 2000/08/02 12:44:48 pkm ship    $ */

  MAX_ERROR_LEN       CONSTANT NUMBER := 32000;

  l_language           VARCHAR2(5);
  l_script_name        VARCHAR2(240);
  l_org_id             NUMBER;
  l_user_id            NUMBER;
  l_session_id         NUMBER;
  l_responsibility_id  NUMBER;
  l_request_id         NUMBER;
  l_header_id          NUMBER;
  l_line_id            NUMBER;
  l_date_format        VARCHAR2(200);
  error_message        VARCHAR2(32000); /* length should be same as MAX_ERROR_LEN */
  sub_state            VARCHAR2(100);
  but1                 VARCHAR2(2000);
  but2		       VARCHAR2(2000);
  but3		       VARCHAR2(2000);

  x_ship_date          VARCHAR2(200);
  x_receipt_date       VARCHAR2(200);
  l_ship_date          DATE;
  l_receipt_date       DATE;
  ship_date_error      BOOLEAN;
  receipt_date_error   BOOLEAN;
  header_error         BOOLEAN;


  cursor c_shipment_err is
            select TO_CHAR(ASND.ASN_LINE_ID) ||
                           DECODE(ASND.ASN_LINE_SPLIT_ID, 0,
                           '', '-' ||
                             TO_CHAR(ASND.ASN_LINE_SPLIT_ID)) error_seq,
                   replace(replace(err.error_message, '
', null), '''', '\''') error_message
            from po_interface_errors err,
                 pos_asn_shop_cart_details asnd
            where err.INTERFACE_HEADER_ID = l_header_id and
                  asnd.HEADER_INTERFACE_ID = err.INTERFACE_HEADER_ID and
                  asnd.INTERFACE_TRANSACTION_ID = err.INTERFACE_LINE_ID;

  cursor c_header_err is
            select replace(replace(err.error_message,'
', null),'''', '\''') error_message
            from po_interface_errors err
            where INTERFACE_HEADER_ID = l_header_id and
                  INTERFACE_LINE_ID is null;


  cursor c_lines is
         select
          l_header_id				HEADER_ID,
          l_request_id 				GROUP_ID,
          decode(pla.vendor_id || pla.vendor_site_id,
                 null, 'SHIP', 'RECEIVE')	TRANSACTION_TYPE,
          sysdate				TRANSACTION_DATE,
          'RUNNING'				PROCESSING_STATUS_CODE,
          'BATCH'				PROCESSING_MODE_CODE,
          'RUNNING'				TRANSACTION_STATUS_CODE,
          decode(pla.vendor_id || pla.vendor_site_id,
                 null, 'SHIP', 'DELIVER') 	AUTO_TRANSACT_CODE,
          'VENDOR'				RECEIPT_SOURCE_CODE,
          'PO'					SOURCE_DOCUMENT_CODE,
          pl.PO_HEADER_ID			PO_HEADER_ID,
          pl.PO_LINE_ID				PO_LINE_ID,
          pl.PO_LINE_LOCATION_ID		PO_LINE_LOCATION_ID,
          pl.QUANTITY_SHIPPED			QUANTITY,
          pl.UNIT_OF_MEASURE			UNIT_OF_MEASURE,
          pl.UOM_CODE				UOM_CODE,
          pl.LAST_UPDATE_DATE			LAST_UPDATE_DATE,
          pl.LAST_UPDATED_BY			LAST_UPDATED_BY,
          pl.LAST_UPDATE_DATE			CREATION_DATE,
          pl.LAST_UPDATED_BY   			CREATED_BY,
          pl.LAST_UPDATE_LOGIN			LAST_UPDATE_LOGIN,
          pl.ITEM_ID				ITEM_ID,
          pl.EXPECTED_RECEIPT_DATE		EXPECTED_RECEIPT_DATE,
          pl.COMMENTS				COMMENTS,
          pl.WAYBILL_AIRBILL_NUM		WAYBILL_AIRBILL_NUM,
          pl.BARCODE_LABEL			BARCODE_LABEL,
          pl.BILL_OF_LADING			BILL_OF_LADING,
          pl.CONTAINER_NUM			CONTAINER_NUM,
          pl.COUNTRY_OF_ORIGIN_CODE		COUNTRY_OF_ORIGIN_CODE,
          pl.VENDOR_CUM_SHIPPED_QTY		VENDOR_CUM_SHIPPED_QTY,
          pl.FREIGHT_CARRIER_CODE		FREIGHT_CARRIER_CODE,
          pl.VENDOR_LOT_NUM			VENDOR_LOT_NUM,
          pl.TRUCK_NUM				TRUCK_NUM,
          pl.NUM_OF_CONTAINERS			NUM_OF_CONTAINERS,
          pl.PACKING_SLIP			PACKING_SLIP,
          pl.REASON_ID				REASON_ID,
          pl.ACTUAL_COST			ACTUAL_COST,
          pl.TRANSFER_COST			TRANSFER_COST,
          pl.TRANSPORTATION_COST		TRANSPORTATION_COST,
          pl.RMA_REFERENCE			RMA_REFERENCE,
          'Y'					VALIDATION_FLAG,
          pl.asn_line_id			ASN_LINE_ID,
          pl.asn_line_split_id			ASN_LINE_SPLIT_ID,
          pl.WIP_ENTITY_ID			WIP_ENTITY_ID,
          pl.WIP_LINE_ID			WIP_LINE_ID,
          pl.WIP_OPERATION_SEQ_NUM		WIP_OPERATION_SEQ_NUM,
          pl.PO_DISTRIBUTION_ID 		PO_DISTRIBUTION_ID,
          POS_QUANTITIES_S.get_invoice_qty(PO_LINE_LOCATION_ID,
                                           UNIT_OF_MEASURE,
                                           ITEM_ID,
                                           QUANTITY_SHIPPED)  QUANTITY_INVOICED
        from pos_asn_shop_cart_details pl,
             pos_asn_shop_cart_headers ph,
             po_location_associations pla
        where pl.session_id = l_session_id and
              ph.session_id = l_session_id and
              pla.location_id(+) = ph.ship_to_location_id;

  cursor c_wip is
        select
         pl.po_distribution_id						p_po_distribution_id,
         pl.quantity_shipped     					p_shipped_qty,
         pl.unit_of_measure            					p_shipped_uom,
         pl.wip_entity_id                                               p_wip_entity_id,
         ph.ship_date          					 	p_shipped_date,
         nvl(pl.expected_receipt_date, ph.expected_receipt_date) 	p_expected_receipt_date,
         nvl(pl.packing_slip, ph.packing_slip)         			p_packing_slip,
         nvl(pl.waybill_airbill_num, ph.waybill_airbill_num)       	p_airbill_waybill,
         nvl(pl.bill_of_lading, ph.bill_of_lading) 			p_bill_of_lading,
         ph.packaging_code        					p_packaging_code,
         nvl(pl.num_of_containers, ph.num_of_containers)     		p_num_of_container,
         ph.gross_weight         					p_gross_weight,
         ph.gross_weight_uom_code 					p_gross_weight_uom,
         ph.net_weight           					p_net_weight,
         ph.net_weight_uom_code  					p_net_weight_uom,
         ph.tar_weight           					p_tar_weight,
         ph.tar_weight_uom_code  					p_tar_weight_uom,
--       null 								p_hazard_class,
--       null 								p_hazard_code,
--       null 								p_hazard_desc,
         ph.special_handling_code 					p_special_handling_code,
         nvl(pl.freight_carrier_code, ph.freight_carrier_code)    	p_freight_carrier,
         ph.freight_terms 						p_freight_carrier_terms,
         ph.carrier_equipment    					p_carrier_equip,
         ph.carrier_method       					p_carrier_method,
         ph.freight_bill_number  					p_freight_bill_num
--       null 								p_receipt_num,
--       null 								p_ussgl_txn_code
        from pos_asn_shop_cart_headers ph,
             pos_asn_shop_cart_details pl
        where ph.session_id = l_session_id and
              pl.session_id = l_session_id and
              exists (select 'ok'
                     from po_location_associations pla
                     where pla.location_id = ph.ship_to_location_id and
                           pla.vendor_id is not null and
                           pla.vendor_site_id is not null);

  cursor c_buyer is
    select poh.agent_id 		buyer_id,
           posh.shipment_num 		shipment_num,
           posh.ship_date 		ship_date,
           nvl(posd.expected_receipt_date, posh.expected_receipt_date)
                                        expected_receipt_date,
           posh.vendor_id		supplier_id,
           pov.vendor_name		supplier
    from  pos_asn_shop_cart_headers posh,
          pos_asn_shop_cart_details posd,
          po_headers_all poh,
          po_vendors pov
    where posh.session_id  = l_session_id and
          posd.session_id  = l_session_id and
          poh.po_header_id = posd.po_header_id and
          pov.vendor_id    = posh.vendor_id;


  TYPE t_text_table is table of varchar2(240) index by binary_integer;
  g_dummy t_text_table;

  FUNCTION set_session_info RETURN BOOLEAN;
  FUNCTION get_result_value(p_index in number, p_col in number) return varchar2;

  FUNCTION item_reqd(l_index in number) RETURN VARCHAR2;
  FUNCTION item_halign(l_index in number) RETURN VARCHAR2;
  FUNCTION item_valign(l_index in number) RETURN VARCHAR2;
  FUNCTION item_name(l_index in number) RETURN VARCHAR2;
  FUNCTION item_code(l_index in number) RETURN VARCHAR2;
  FUNCTION item_style(l_index in number) RETURN VARCHAR2;
  FUNCTION item_displayed(l_index in number) RETURN BOOLEAN;
  FUNCTION item_updateable(l_index in number) RETURN BOOLEAN;
  FUNCTION item_size (l_index in number) RETURN VARCHAR2;
  FUNCTION item_maxlength (l_index in number) RETURN VARCHAR2;
  FUNCTION item_lov(l_index in number) RETURN VARCHAR2;
  FUNCTION item_lov_multi(l_index in number, l_row in number, l_wip_row in number) RETURN VARCHAR2;
  FUNCTION item_wrap(l_index in number) RETURN VARCHAR2;

  PROCEDURE hidden_label(l_index in number);
  PROCEDURE hidden_field(l_index in number,
                         l_res_index in number,
                         l_col in number);

  PROCEDURE single_row_label(l_index in number);
  PROCEDURE multi_row_label (l_index in number);

  PROCEDURE non_updateable(l_index in number,
                           l_res_index in number,
                           l_col in number);
  PROCEDURE updateable(l_index in number,
                     l_res_index in number,
                     l_col in number,
                     l_row in number default null,
                     l_wip_row in number default null);
  PROCEDURE image(l_index in number,
                  href in varchar2);

  PROCEDURE button(src1 IN varchar2,
                   txt1 IN varchar2,
                   src2 IN varchar2,
                   txt2 IN varchar2);

  PROCEDURE buyer_notify;

  PROCEDURE init_page;
  PROCEDURE init_body;
  PROCEDURE close_page;

  PROCEDURE show_edit_page;
  PROCEDURE show_edit_header;
  PROCEDURE show_shipment_help;
  PROCEDURE show_edit_shipments;
  PROCEDURE show_delete_frame;

  PROCEDURE err_htp(msg IN VARCHAR2);
  PROCEDURE show_error_page;
  PROCEDURE show_ok_page;

  PROCEDURE print_edit_header;
  PROCEDURE print_edit_shipments;
  PROCEDURE print_simple_head_err_page;
  PROCEDURE print_error_page;

  PROCEDURE create_rcv_header;
  PROCEDURE create_rcv_transaction;

  PROCEDURE call_wip_api;

  FUNCTION valid_asn RETURN BOOLEAN;
  PROCEDURE submit;

  PROCEDURE update_shipments(pos_quantity_shipped      IN t_text_table DEFAULT g_dummy,
                             pos_select                IN t_text_table DEFAULT g_dummy,
                             pos_unit_of_measure       IN t_text_table DEFAULT g_dummy,
                             pos_comments              IN t_text_table DEFAULT g_dummy,
                             pos_asn_line_id           IN t_text_table DEFAULT g_dummy,
                             pos_asn_line_split_id     IN t_text_table DEFAULT g_dummy,
                             pos_po_line_location_id   IN t_text_table DEFAULT g_dummy,
                             pos_po_distribution_id    IN t_text_table DEFAULT g_dummy,
                             pos_asn_wip_job           IN t_text_table DEFAULT g_dummy,
                             pos_wip_entity_id         IN t_text_table DEFAULT g_dummy,
                             pos_wip_line_id           IN t_text_table DEFAULT g_dummy,
                             pos_wip_operation_seq_num IN t_text_table DEFAULT g_dummy,
                             pos_item_id               IN t_text_table DEFAULT g_dummy,
                             pos_uom_class	       IN t_text_table DEFAULT g_dummy,
                             pos_po_header_id          IN t_text_table DEFAULT g_dummy,
                             pos_submit                IN VARCHAR2 DEFAULT null);

  PROCEDURE update_header( pos_asn_shipment_num       IN VARCHAR2 DEFAULT null,
                           pos_bill_of_lading         IN VARCHAR2 DEFAULT null,
                           pos_waybill_airbill_num    IN VARCHAR2 DEFAULT null,
                           pos_ship_date              IN VARCHAR2 DEFAULT null,
                           pos_expected_receipt_date  IN VARCHAR2 DEFAULT null,
                           pos_num_of_containers      IN VARCHAR2 DEFAULT null,
                           pos_comments               IN VARCHAR2 DEFAULT null,
                           pos_packing_slip           IN VARCHAR2 DEFAULT null,
                           pos_freight_carrier	      IN VARCHAR2 DEFAULT null,
                           pos_freight_carrier_code   IN VARCHAR2 DEFAULT null,
                           pos_freight_term           IN VARCHAR2 DEFAULT null,
                           pos_freight_term_code      IN VARCHAR2 DEFAULT null,
                           pos_freight_bill_num       IN VARCHAR2 DEFAULT null,
                           pos_carrier_method         IN VARCHAR2 DEFAULT null,
                           pos_carrier_equipment      IN VARCHAR2 DEFAULT null,
			   pos_gross_weight           IN VARCHAR2 DEFAULT null,
			   pos_gross_weight_uom       IN VARCHAR2 DEFAULT null,
			   pos_gross_weight_uom_code  IN VARCHAR2 DEFAULT null,
			   pos_net_weight             IN VARCHAR2 DEFAULT null,
			   pos_net_weight_uom         IN VARCHAR2 DEFAULT null,
			   pos_net_weight_uom_code    IN VARCHAR2 DEFAULT null,
			   pos_tar_weight             IN VARCHAR2 DEFAULT null,
			   pos_tar_weight_uom         IN VARCHAR2 DEFAULT null,
			   pos_tar_weight_uom_code    IN VARCHAR2 DEFAULT null,
			   pos_packaging_code         IN VARCHAR2 DEFAULT null,
			   pos_special_handling_code  IN VARCHAR2 DEFAULT null,
                           pos_ship_to_organization_id IN VARCHAR2 DEFAULT null);

END pos_asn;

 

/
