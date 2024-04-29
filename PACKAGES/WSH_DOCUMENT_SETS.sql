--------------------------------------------------------
--  DDL for Package WSH_DOCUMENT_SETS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DOCUMENT_SETS" AUTHID CURRENT_USER as
/* $Header: WSHDSPRS.pls 120.0.12000000.1 2007/01/16 05:45:00 appldev ship $ */


TYPE document_set_rec_type IS RECORD(
  p_report_set_id		NUMBER,
  p_request_id           NUMBER,
  p_customer_id			NUMBER,
  p_item_id			NUMBER,
  p_item_cate_set_id		NUMBER,
  p_item_category_id		NUMBER,
  p_transaction_type_id		NUMBER,
  p_header_id_low		NUMBER,
  p_header_id_high		NUMBER,
  p_salesrep_id			NUMBER,
  p_user_id			NUMBER,
  p_territory_name		VARCHAR2(80),
  p_item_display		VARCHAR2(30),
  p_item_flex_code		VARCHAR2(30),
  p_organization_id		NUMBER,
  p_sort_by			NUMBER,
  p_show_functional_currency	VARCHAR2(20),
  p_ledger_id		NUMBER,  -- LE Uptake
  p_order_date_low		DATE,
  p_order_date_high		DATE,
  p_delivery_date_low		DATE,
  p_delivery_date_high		DATE,
  p_freight_code		VARCHAR2(30),
  p_delivery_id			NUMBER,
  p_delivery_id_high     number,
  p_delivery_id_low      number,
  p_trip_id			NUMBER,
  p_trip_id_high		NUMBER,
  p_trip_id_low		NUMBER,
  p_delivery_leg_id		NUMBER,
  p_bill_of_lading_number	NUMBER,
  p_trip_stop_id		NUMBER,
  p_departure_date_low		DATE,
  p_departure_date_high		DATE,
  p_container_id		NUMBER,
  p_print_cust_item		VARCHAR2(20),
  p_print_mode			VARCHAR2(20),
  p_print_all			VARCHAR2(20),
  p_sort			VARCHAR2(20),
  p_delivery_date_lo		DATE,
  p_delivery_date_hi		DATE,
  p_freight_carrier		VARCHAR2(30),
  p_quantity_precision		VARCHAR2(20),
  p_locator_flex_code		VARCHAR2(20),
  p_warehouse_id		NUMBER,
  pick_slip_num_l		NUMBER,
  pick_slip_num_h		NUMBER,
  p_order_type_id               NUMBER, --Bugfix 3604021
  p_order_num_l			NUMBER,
  p_order_num_h			NUMBER,
  p_order_num_low			NUMBER,
  p_order_num_high			NUMBER,
  --p_move_order_l		NUMBER,
  --p_move_order_h		NUMBER,
  p_move_order_l		VARCHAR2(30),
  p_move_order_h		VARCHAR2(30),
  p_ship_method_code		VARCHAR2(30),
  p_customer_name		VARCHAR2(80),
  p_pick_status			VARCHAR2(20),
  p_detail_date_l		DATE,
  p_detail_date_h		DATE,
  p_exception_name		VARCHAR2(60),
  p_exception_location_id NUMBER,
  p_logging_entity		VARCHAR2(60),
  p_logging_location_id   NUMBER,
  p_location_id			NUMBER,
  p_creation_date_from		DATE,
  p_creation_date_to		DATE,
  p_last_update_date_from	DATE,
  p_last_update_date_to		DATE,
  p_severity			VARCHAR2(10),
  p_status			VARCHAR2(30),
  p_text1			VARCHAR2(240),
  p_text2			VARCHAR2(240),
  p_text3			VARCHAR2(240),
  p_text4			VARCHAR2(240),
  p_currency_code		VARCHAR2(15),
  p_printer_name                VARCHAR2(30),
  bol_error_flag		VARCHAR2(1)
);

TYPE document_set_tab_type IS TABLE OF document_set_rec_type INDEX BY BINARY_INTEGER;

--
-- Name
--   Print_Document_Sets
-- Purpose
--   Execute any Delivery-based Document Set by submitting each document
--   to the transaction manager
-- Arguments
--   many


PROCEDURE print_document_sets(
   p_report_set_id	    IN NUMBER,
   p_organization_id	    IN NUMBER,
   p_trip_ids		    IN WSH_UTIL_CORE.Id_Tab_Type,
   p_stop_ids		    IN WSH_UTIL_CORE.Id_Tab_Type,
   p_delivery_ids	    IN WSH_UTIL_CORE.Id_Tab_Type,
   p_document_param_info    IN WSH_DOCUMENT_SETS.DOCUMENT_SET_TAB_TYPE,
   x_return_status	    IN OUT NOCOPY  VARCHAR2);


END WSH_DOCUMENT_SETS;

 

/
