--------------------------------------------------------
--  DDL for Package ICX_REQ_SPECIAL_ORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_REQ_SPECIAL_ORD" AUTHID CURRENT_USER AS
/* $Header: ICXRQSPS.pls 115.1 99/07/17 03:23:33 porting ship $ */

 TYPE special_order_record IS RECORD (
                              cart_id VARCHAR2(20) := NULL,
                              category_id VARCHAR2(20) := NULL,
                              category_name VARCHAR2(85) := NULL,
                              item_description VARCHAR2(240) := NULL,
                              qty_v VARCHAR2(20) := NULL,
                              unit_of_measurement VARCHAR2(25) := NULL,
                              unit_price VARCHAR2(20) := NULL,
                              suggested_vendor_item_num VARCHAR2(85) := NULL,
                              suggested_vendor_name VARCHAR2(85) := NULL,
                              suggested_vendor_site VARCHAR2(85) := NULL,
                              suggested_vendor_contact VARCHAR2(85) := NULL,
                              suggested_vendor_phone VARCHAR2(85) := NULL,
                              line_attribute_1 VARCHAR2(300) := NULL,
                              line_attribute_2 VARCHAR2(300) := NULL,
                              line_attribute_3 VARCHAR2(300) := NULL,
                              line_attribute_4 VARCHAR2(300) := NULL,
                              line_attribute_5 VARCHAR2(300) := NULL,
                              line_attribute_6 VARCHAR2(300) := NULL,
                              line_attribute_7 VARCHAR2(300) := NULL,
                              line_attribute_8 VARCHAR2(300) := NULL,
                              line_attribute_9 VARCHAR2(300) := NULL,
                              line_attribute_10 VARCHAR2(300) := NULL,
                              line_attribute_11 VARCHAR2(300) := NULL,
                              line_attribute_12 VARCHAR2(300) := NULL,
                              line_attribute_13 VARCHAR2(300) := NULL,
                              line_attribute_14 VARCHAR2(300) := NULL,
                              line_attribute_15 VARCHAR2(300) := NULL,
                              line_type_id VARCHAR2(10) := NULL);

  v_empty_special_order_rec special_order_record;

  PROCEDURE special_order(n_org VARCHAR2,
                          v_special_order_rec IN special_order_record
                            DEFAULT v_empty_special_order_rec,
                          v_error_flag IN VARCHAR2 DEFAULT NULL,
                          v_error_text IN VARCHAR2 DEFAULT NULL,
                          v_rows_inserted IN VARCHAR2 DEFAULT NULL,
                          v_order_total_message IN VARCHAR2 DEFAULT NULL);

  PROCEDURE special_order_display(n_org VARCHAR2,
                          v_special_order_rec IN special_order_record
                            DEFAULT v_empty_special_order_rec,
                          v_error_flag IN VARCHAR2 DEFAULT NULL,
                          v_error_text IN VARCHAR2 DEFAULT NULL,
                          v_rows_inserted IN VARCHAR2 DEFAULT NULL,
                          v_order_total_message IN VARCHAR2 DEFAULT NULL);

  PROCEDURE special_order_buttons;

  PROCEDURE add_item_to_cart (n_org IN VARCHAR2,
                              cartId in VARCHAR2,
                              icx_category_id IN VARCHAR2 DEFAULT NULL,
                              icx_category_name IN VARCHAR2 DEFAULT NULL,
                              icx_item_description IN VARCHAR2 DEFAULT NULL,
                              icx_qty_v IN VARCHAR2 DEFAULT NULL,
                              icx_unit_of_measurement IN VARCHAR2 DEFAULT NULL,
                              icx_unit_price IN VARCHAR2 DEFAULT NULL,
                              icx_suggested_vendor_item_num IN VARCHAR2 DEFAULT NULL,
                              icx_suggested_vendor_name IN VARCHAR2 DEFAULT NULL,
                              icx_suggested_vendor_site IN VARCHAR2 DEFAULT NULL,
                              icx_suggested_vendor_contact IN VARCHAR2 DEFAULT NULL,
                              icx_suggested_vendor_phone IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_1 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_2 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_3 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_4 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_5 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_6 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_7 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_8 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_9 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_10 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_11 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_12 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_13 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_14 IN VARCHAR2 DEFAULT NULL,
                              icx_line_attribute_15 IN VARCHAR2 DEFAULT NULL,
                              icx_line_type_id IN VARCHAR2 DEFAULT NULL,
                              v_category_pop_list IN VARCHAR2 DEFAULT NULL,
                              v_uom_pop_list IN VARCHAR2 DEFAULT NULL);


PROCEDURE  insert_order_to_cart_line (v_special_order_rec
                                       IN special_order_record,
                                      l_order_total_message
                                       OUT VARCHAR2);

-- remove later
procedure chk_vendor_on(v_items_table IN ak_query_pkg.items_table_type,
                        v_on OUT varchar2);

END icx_req_special_ord;

 

/
