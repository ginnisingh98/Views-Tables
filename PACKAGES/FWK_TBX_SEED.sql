--------------------------------------------------------
--  DDL for Package FWK_TBX_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FWK_TBX_SEED" AUTHID CURRENT_USER as
/* $Header: fwktbx_seeds.pls 120.2 2005/12/19 02:09:32 nigoel noship $ */

    procedure insert_lookup_type(p_lookup_type varchar2,
                                 p_display_name varchar2,
                                 p_description varchar2);

    procedure insert_lookup_code(p_lookup_type varchar2,
                                 p_lookup_code varchar2,
                                 p_meaning varchar2,
                                 p_description varchar2,
                                 p_start_date date,
                                 p_end_date date);

    procedure update_lookup_type(p_lookup_type varchar2,
                                 p_display_name varchar2,
                                 p_description varchar2);

    procedure update_lookup_code(p_lookup_type varchar2,
                                 p_lookup_code varchar2,
                                 p_meaning varchar2,
                                 p_description varchar2,
                                 p_start_date date,
                                 p_end_date date);

    procedure delete_lookup_type(p_lookup_type varchar2);

    procedure delete_lookup_code(p_lookup_type varchar2,
                                 p_lookup_code varchar2);

    procedure insert_employee(p_employee_id number,
                              p_title varchar2,
                              p_first_name varchar2,
                              p_middle_names varchar2,
                              p_last_name varchar2,
                              p_email_address varchar2,
                              p_manager_id number,
                              p_position_code varchar2,
                              p_salary number,
                              p_start_date date,
                              p_end_date date);

    procedure insert_address(p_address_id number,
                             p_address_name varchar2,
                             p_address_line_1 varchar2,
                             p_address_line_2 varchar2,
                             p_address_line_3 varchar2,
                             p_description varchar2,
                             p_email_address varchar2,
                             p_country varchar2,
                             p_town_or_city varchar2,
                             p_postal_code varchar2,
                             p_start_date date,
                             p_end_date date,
                             p_telephone_number_1 varchar2,
                             p_telephone_number_2 varchar2,
                             p_telephone_number_3 varchar2);

    procedure insert_supplier(p_supplier_id number,
                              p_name varchar2,
                              p_on_hold_flag varchar2,
                              p_start_date date,
                              p_end_date date);


    procedure insert_supplier_site(p_supplier_site_id number,
                                   p_supplier_id number,
                                   p_site_name varchar2,
                                   p_payment_terms_code varchar2,
                                   p_carrier_code varchar2,
                                   p_purchasing_site_flag varchar2,
                                   p_address_id number,
                                   p_start_date	date,
                                   p_end_date date);


    procedure insert_item(p_item_id number,
                          p_item_description varchar2,
                          p_start_date_active date,
                          p_end_date_active date,
                          p_enabled_flag varchar2,
                          p_summary_flag varchar2,
                          p_segment1 varchar2,
                          p_segment2 varchar2,
                          p_segment3 varchar2,
                          p_segment4 varchar2,
                          p_fwkitem_id number,
                          p_fwkitem_structure_id number);


    procedure insert_po_header(p_header_id number,
                               p_description varchar2,
                               p_status_code varchar2,
                               p_confirm_flag varchar2,
                               p_supplier_id number,
                               p_supplier_site_id number,
                               p_currency_code varchar2,
                               p_buyer_id number,
                               p_payment_terms_code varchar2,
                               p_carrier_code varchar2,
                               p_ship_to_address_id number,
                               p_bill_to_address_id number,
                               p_rate number);


    procedure insert_po_line(p_line_id number,
                             p_header_id number,
                             p_line_number number,
                             p_item_id number,
                             p_item_description varchar2,
                             p_unit_of_measure varchar2,
                             p_quantity number,
                             p_unit_price number);


    procedure insert_po_shipment(p_shipment_id number,
                                 p_line_id number,
                                 p_shipment_number number,
                                 p_need_by_date date,
                                 p_promise_date date,
                                 p_receipt_quantity number,
                                 p_order_quantity number,
                                 p_ship_to_address_id number,
                                 p_receipt_date date);


   procedure insert_item_ccids(p_fwkitem_id number,
                               p_fwkitem_structure_id number,
                               p_summary_flag varchar2,
                               p_enabled_flag varchar2,
                               p_segment1 varchar2,
                               p_segment2 varchar2,
                               p_segment3 varchar2,
                               p_segment4 varchar2,
                               p_segment5 varchar2,
                               p_segment6 varchar2,
                               p_segment7 varchar2,
                               p_segment8 varchar2,
                               p_segment9 varchar2,
                               p_segment10 varchar2);

   procedure insert_project_header(p_project_id number,
                                  p_name varchar2,
                                  p_start_date date,
                                  p_completion_date date,
                                  p_start_from date,
                                  p_end_to date,
                                  p_task_type varchar2,
                                  p_text_right varchar2);

  procedure insert_project_detail(p_project_id number,
                                  p_top_task_id number,
                                  p_task_id number,
                                  p_task_number varchar2,
                                  p_task_name varchar2,
                                  p_start_from date,
                                  p_end_to date,
                                  p_task_type varchar2,
                                  p_text_right varchar2);
end fwk_tbx_seed;

 

/
