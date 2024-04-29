--------------------------------------------------------
--  DDL for Package OE_PORTAL_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PORTAL_LINE" AUTHID CURRENT_USER AS
/* $Header: OEXLPORS.pls 120.0 2005/06/01 01:50:37 appldev noship $ */



PROCEDURE Validate_Write_Line
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_line_id                       IN   NUMBER
, p_header_id                       IN NUMBER
, p_db_flag                         IN VARCHAR2 DEFAULT 'N'
, p_sold_to_org_id                  IN NUMBER
, p_inventory_item_id               IN NUMBER
, p_ordered_quantity               IN NUMBER
, p_order_quantity_uom             IN VARCHAR2
, p_ship_to_org_id                 IN NUMBER
, p_request_date                   IN VARCHAR2
,   x_discounts                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_charges                       OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_taxes                         OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_line_tax_value                OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_schedule_ship_date            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_schedule_arrival_date         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_schedule_status_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_schedule_action_code          OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address1            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address2            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address3            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_address4            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_location            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_org                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_ship_from_org_id              OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_promise_date                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_unit_selling_price			 OUT NOCOPY /* file.sql.39 change */	NUMBER
,   x_unit_list_price			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_list_percent				 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_selling_percent			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_quantity			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_pricing_quantity_uom		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_calculate_price_flag		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_calculate_price_descr         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_inventory_item_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_customer_item                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_inventory_item                  OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_item_desc                       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ordered_quantity                OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_order_quantity_uom            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_request_date                    OUT NOCOPY /* file.sql.39 change */ DATE
,   x_ordered_item_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list_id				 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_price_list				 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,   x_payment_term_id			 OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_payment_term				 OUT NOCOPY /* file.sql.39 change */ varchar2
,   x_shipment_priority_code		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_shipment_priority			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms_code			 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_freight_terms				 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_lock_control                  OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_line_id                         OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_ship_to_org_id                  OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_ship_to_org                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ship_to_location                     OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ship_to_address1                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ship_to_address2                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ship_to_address3                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_ship_to_address4                OUT NOCOPY /* file.sql.39 change */ VARCHAR2
);

/*
PROCEDURE Schedule_Line (
p_inventory_item_id IN NUMBER ,
p_input_quantity IN NUMBER,
p_customer_id IN NUMBER,
p_customer_site_id IN NUMBER,
p_uom IN VARCHAR2,
p_need_by_date IN VARCHAR2,
x_return_status     OUT NOCOPY  file.sql.39 change  VARCHAR2,
x_msg_data          OUT NOCOPY  file.sql.39 change  VARCHAR2,
x_msg_count          OUT NOCOPY  file.sql.39 change  NUMBER
);
*/
PROCEDURE Delete_Row
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_line_id                     IN  NUMBER
);

END OE_Portal_Line;

 

/
