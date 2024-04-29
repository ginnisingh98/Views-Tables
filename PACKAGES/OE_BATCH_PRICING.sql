--------------------------------------------------------
--  DDL for Package OE_BATCH_PRICING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BATCH_PRICING" AUTHID CURRENT_USER AS
/* $Header: OEXBPRIS.pls 120.0.12010000.2 2008/11/13 09:00:07 amallik noship $ */

PROCEDURE PRICE
(
  ERRBUF			OUT NOCOPY	VARCHAR2,
  RETCODE			OUT NOCOPY	VARCHAR2,
  p_preview_mode		IN		VARCHAR2,
  p_pricing_level		IN		VARCHAR2,
  p_dummy			IN		VARCHAR2,
  p_org_id			IN		NUMBER,
  p_order_number_low		IN		NUMBER,
  p_order_number_high		IN		NUMBER,
  p_order_type_id		IN		NUMBER,
  p_line_type_id		IN		NUMBER,
  p_customer_id			IN		NUMBER,
  p_ship_to_org_id		IN		NUMBER,
  p_invoice_to_org_id		IN		NUMBER,
  p_customer_class_code		IN		VARCHAR2,
  p_salesrep_id			IN		NUMBER,
  p_price_list_id		IN		NUMBER,
  p_inventory_item_id		IN		NUMBER,
  p_item_category_id		IN		NUMBER,
  p_ship_from_org_id		IN		NUMBER,
  p_order_date_low		IN		VARCHAR2,
  p_order_date_high		IN		VARCHAR2,
  p_order_creation_date_low	IN		VARCHAR2,
  p_order_creation_date_high	IN		VARCHAR2,
  p_line_creation_date_low	IN		VARCHAR2,
  p_line_creation_date_high	IN		VARCHAR2,
  p_booked_date_low		IN		VARCHAR2,
  p_booked_date_high		IN		VARCHAR2,
  p_pricing_date_low		IN		VARCHAR2,
  p_pricing_date_high		IN		VARCHAR2,
  p_schedule_ship_date_low	IN		VARCHAR2,
  p_schedule_ship_date_high	IN		VARCHAR2,
  p_booked_orders		IN		VARCHAR2,
  p_header_id			IN		NUMBER	DEFAULT NULL,
  p_line_count			IN		NUMBER  DEFAULT NULL,
  p_line_list			IN		VARCHAR2 DEFAULT NULL
);

END OE_BATCH_PRICING;

/
