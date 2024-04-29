--------------------------------------------------------
--  DDL for Package OE_PORTAL_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PORTAL_HEADER" AUTHID CURRENT_USER AS
/* $Header: OEXHPORS.pls 120.0 2005/06/01 23:09:19 appldev noship $ */


g_header_rec          OE_ORDER_PUB.Header_Rec_Type;
g_db_header_rec          OE_ORDER_PUB.Header_Rec_Type;


PROCEDURE Default_Header_Attributes
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

, p_sold_to_org_id                IN  NUMBER
, x_agreement_id OUT NOCOPY NUMBER

, x_freight_carrier_code OUT NOCOPY VARCHAR2

, x_freight_terms_code OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY VARCHAR2

, x_invoice_to_org_id OUT NOCOPY NUMBER

, x_order_type_id OUT NOCOPY NUMBER

, x_org_id OUT NOCOPY NUMBER

, x_partial_shipments_allowed OUT NOCOPY VARCHAR2

, x_payment_term_id OUT NOCOPY NUMBER

, x_price_list_id OUT NOCOPY NUMBER

, x_shipment_priority_code OUT NOCOPY VARCHAR2

, x_shipping_method_code OUT NOCOPY VARCHAR2

, x_ship_to_org_id OUT NOCOPY NUMBER

, x_sold_to_org_id OUT NOCOPY NUMBER

, x_tax_exempt_flag OUT NOCOPY VARCHAR2

, x_tax_exempt_number OUT NOCOPY VARCHAR2

, x_tax_point_code OUT NOCOPY VARCHAR2

, x_transactional_curr_code OUT NOCOPY VARCHAR2

, x_payment_type_code OUT NOCOPY VARCHAR2

, x_shipping_instructions OUT NOCOPY VARCHAR2

, x_shipping_method OUT NOCOPY VARCHAR2

, x_freight_terms OUT NOCOPY VARCHAR2

, x_invoice_to_address1 OUT NOCOPY VARCHAR2

, x_invoice_to_address2 OUT NOCOPY VARCHAR2

, x_invoice_to_address3 OUT NOCOPY VARCHAR2

, x_invoice_to_address4 OUT NOCOPY VARCHAR2

, x_payment_term OUT NOCOPY VARCHAR2

, x_shipment_priority OUT NOCOPY varchar2

, x_ship_to_address1 OUT NOCOPY VARCHAR2

, x_ship_to_address2 OUT NOCOPY VARCHAR2

, x_ship_to_address3 OUT NOCOPY VARCHAR2

, x_ship_to_address4 OUT NOCOPY VARCHAR2

, x_sold_to_org OUT NOCOPY VARCHAR2

, x_tax_point OUT NOCOPY VARCHAR2

,x_request_date OUT NOCOPY DATE

, x_tax_exempt OUT NOCOPY VARCHAR2

, x_partial_shipments OUT NOCOPY VARCHAR2

, x_order_type OUT NOCOPY VARCHAR2

, x_customer_number OUT NOCOPY VARCHAR2

);


PROCEDURE Validate_Write_Header
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN NUMBER
, p_db_record                       IN  VARCHAR2
, p_freight_terms_code   IN VARCHAR2
, p_invoice_to_org_id    IN NUMBER
, p_partial_shipments_allowed IN VARCHAR2
, p_shipment_priority_code IN  VARCHAR2
, p_shipping_method_code   IN VARCHAR2
, p_ship_to_org_id        IN NUMBER
, p_tax_exempt_flag      IN VARCHAR2
, p_request_date         IN  VARCHAR2
, p_cust_po_number       IN VARCHAR2
, p_shipping_instructions IN VARCHAR2
, p_sold_to_org_id        IN NUMBER
, x_order_number OUT NOCOPY NUMBER

, x_agreement_id OUT NOCOPY NUMBER

, x_freight_carrier_code OUT NOCOPY VARCHAR2

, x_freight_terms_code OUT NOCOPY VARCHAR2

, x_header_id OUT NOCOPY NUMBER

, x_invoice_to_org_id OUT NOCOPY NUMBER

, x_order_type_id OUT NOCOPY NUMBER

, x_org_id OUT NOCOPY NUMBER

, x_partial_shipments_allowed OUT NOCOPY VARCHAR2

, x_payment_term_id OUT NOCOPY NUMBER

, x_price_list_id OUT NOCOPY NUMBER

, x_shipment_priority_code OUT NOCOPY VARCHAR2

, x_shipping_method_code OUT NOCOPY VARCHAR2

, x_ship_to_org_id OUT NOCOPY NUMBER

, x_sold_to_org_id OUT NOCOPY NUMBER

, x_tax_exempt_flag OUT NOCOPY VARCHAR2

, x_tax_exempt_number OUT NOCOPY VARCHAR2

, x_tax_point_code OUT NOCOPY VARCHAR2

, x_transactional_curr_code OUT NOCOPY VARCHAR2

, x_payment_type_code OUT NOCOPY VARCHAR2

, x_shipping_instructions OUT NOCOPY VARCHAR2

, x_shipping_method OUT NOCOPY VARCHAR2

, x_freight_terms OUT NOCOPY VARCHAR2

, x_invoice_to_address1 OUT NOCOPY VARCHAR2

, x_invoice_to_address2 OUT NOCOPY VARCHAR2

, x_invoice_to_address3 OUT NOCOPY VARCHAR2

, x_invoice_to_address4 OUT NOCOPY VARCHAR2

, x_payment_term OUT NOCOPY VARCHAR2

, x_shipment_priority OUT NOCOPY varchar2

, x_ship_to_address1 OUT NOCOPY VARCHAR2

, x_ship_to_address2 OUT NOCOPY VARCHAR2

, x_ship_to_address3 OUT NOCOPY VARCHAR2

, x_ship_to_address4 OUT NOCOPY VARCHAR2

, x_sold_to_org OUT NOCOPY VARCHAR2

, x_tax_point OUT NOCOPY VARCHAR2

, x_request_date OUT NOCOPY DATE

, x_cust_po_number OUT NOCOPY VARCHAR2

, x_tax_exempt OUT NOCOPY VARCHAR2

, x_partial_shipments OUT NOCOPY VARCHAR2

, x_order_type OUT NOCOPY VARCHAR2

, x_customer_number OUT NOCOPY VARCHAR2

/*, x_cascade_flag OUT NOCOPY VARCHAR2*/

);


PROCEDURE Delete_Row
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
);



PROCEDURE GET_HEADER_TOTALS
( x_return_status OUT NOCOPY VARCHAR2

, x_msg_count OUT NOCOPY NUMBER

, x_msg_data OUT NOCOPY VARCHAR2

,   p_header_id                     IN  NUMBER
, x_line_total OUT NOCOPY NUMBER

, x_tax_total OUT NOCOPY NUMBER

, x_charge_total OUT NOCOPY NUMBER

, x_order_total OUT NOCOPY NUMBER

);


END OE_Portal_Header;

 

/
