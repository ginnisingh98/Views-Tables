--------------------------------------------------------
--  DDL for Package POS_ASN_DETAILS_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ASN_DETAILS_S" AUTHID CURRENT_USER AS
/* $Header: POSASNDS.pls 115.1 1999/11/30 12:19:43 pkm ship   $ */

  l_language    VARCHAR2(5);
  l_script_name VARCHAR2(240);
  l_org_id      NUMBER;
  l_user_id     NUMBER;
  l_session_id  NUMBER;
  l_responsibility_id NUMBER;
  g_flag VARCHAR2(1);
  g_quantity VARCHAR2(38);
  g_unit_of_measure VARCHAR2(25);

  TYPE t_text_table is table of varchar2(240) index by binary_integer;
  g_dummy t_text_table;

  FUNCTION set_session_info RETURN BOOLEAN;
  FUNCTION get_result_value(p_index in number, p_col in number) return varchar2;

  FUNCTION item_halign(l_index in number) RETURN VARCHAR2;
  FUNCTION item_valign(l_index in number) RETURN VARCHAR2;
  FUNCTION item_name(l_index in number) RETURN VARCHAR2;
  FUNCTION item_code(l_index in number) RETURN VARCHAR2;
  FUNCTION item_style(l_index in number) RETURN VARCHAR2;
  FUNCTION item_displayed(l_index in number) RETURN BOOLEAN;
  FUNCTION item_updateable(l_index in number) RETURN BOOLEAN;
  FUNCTION item_sequence(l_index in number) RETURN NUMBER;
  FUNCTION item_maxlength (l_index in number) RETURN VARCHAR2;
  FUNCTION item_size (l_index in number) RETURN VARCHAR2;
  FUNCTION item_lov(l_index in number) RETURN VARCHAR2;

  PROCEDURE show_details(p_asn_line_id VARCHAR2,
                         p_asn_line_split_id VARCHAR2,
                         p_quantity VARCHAR2 DEFAULT NULL,
                         p_unit_of_measure VARCHAR2 DEFAULT NULL);


  PROCEDURE set_asn_ids(p_asn_line_id VARCHAR2, p_asn_line_split_id VARCHAR2);
  PROCEDURE paint_region_title(p_product VARCHAR2,
                               p_title   VARCHAR2);
  PROCEDURE paint_single_record_prompt(p_attribute_index NUMBER);
  PROCEDURE paint_updateable_field(p_attribute_index NUMBER,
                                   p_result_index    NUMBER,
                                   p_current_col     NUMBER);
  PROCEDURE paint_nonupdateable_field(p_attribute_index NUMBER,
                                    p_result_index NUMBER,
                                    p_current_col  NUMBER,
                                    p_colspan      NUMBER DEFAULT NULL);

  PROCEDURE paint_hidden_field(p_attribute_index NUMBER,
                               p_result_index    NUMBER,
                               p_current_col     NUMBER);

  PROCEDURE paint_shipment_details(p_asn_line_id VARCHAR2,
                                   p_asn_line_split_id VARCHAR2,
                                   p_region VARCHAR2);


  PROCEDURE update_details(pos_asn_line_id            IN VARCHAR2 DEFAULT NULL,
                           pos_asn_line_split_id      IN VARCHAR2 DEFAULT NULL,
                           pos_expected_receipt_date  IN VARCHAR2 DEFAULT NULL,
                           pos_packing_slip           IN VARCHAR2 DEFAULT NULL,
                           pos_waybill_airbill_num    IN VARCHAR2 DEFAULT NULL,
                           pos_bill_of_lading         IN VARCHAR2 DEFAULT NULL,
                           pos_barcode_label          IN VARCHAR2 DEFAULT NULL,
                           pos_country_of_origin      IN VARCHAR2 DEFAULT NULL,
                           pos_country_of_origin_code IN VARCHAR2 DEFAULT NULL,
                           pos_vendor_cum_shipped_qty IN VARCHAR2 DEFAULT NULL,
                           pos_num_of_containers      IN VARCHAR2 DEFAULT NULL,
                           pos_container_num          IN VARCHAR2 DEFAULT NULL,
                           pos_vendor_lot_num         IN VARCHAR2 DEFAULT NULL,
                           pos_freight_carrier        IN VARCHAR2 DEFAULT NULL,
                           pos_freight_carrier_code   IN VARCHAR2 DEFAULT NULL,
                           pos_truck_num              IN VARCHAR2 DEFAULT NULL,
                           pos_reason_id              IN VARCHAR2 DEFAULT NULL,
                           pos_reason_name            IN VARCHAR2 DEFAULT NULL,
                           pos_ship_to_organization_id IN VARCHAR2 DEFAULT NULL);


END pos_asn_details_s;

 

/
