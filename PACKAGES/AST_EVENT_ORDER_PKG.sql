--------------------------------------------------------
--  DDL for Package AST_EVENT_ORDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_EVENT_ORDER_PKG" AUTHID CURRENT_USER as
 /* $Header: astevoes.pls 115.6 2002/02/06 12:32:48 pkm ship     $ */

 -- Start of comments
 -- API name   : open_order
 -- Type       : Private
 -- Pre-reqs   : None.
 -- Function   : initializes the order entry process for the current event registration flow
 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0
 -- End of comments
 PROCEDURE open_order (
     p_cust_party_id              IN NUMBER
   , p_cust_account_id            IN NUMBER
   , p_currency_code              IN VARCHAR2
   , p_source_code                IN VARCHAR2 DEFAULT 'ASO'
   , p_order_type_id              IN NUMBER DEFAULT 1000 -- TBD How is it determined, its a FK to OE_TRANSACTION_TYPES_ALL
   , p_price_list_id              IN NUMBER
   , p_employee_id                IN NUMBER
   , p_invoice_party_id           IN NUMBER
   , p_invoice_party_site_id      IN NUMBER
   , p_quote_header_id            IN NUMBER DEFAULT NULL
 ) ;
 -- Start of comments
 -- API name   : add_order_line
 -- Type       : Private
 -- Pre-reqs   : None.
 -- Function   : adds a new line item to the current order entry process for the current event registration flow
 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0
 -- End of comments
 PROCEDURE add_order_line (
     p_ship_party_id      IN NUMBER
   , p_ship_party_site_id IN NUMBER
   , p_inventory_item_id  IN NUMBER
   , p_line_list_price    IN NUMBER
   , p_quantity           IN NUMBER DEFAULT 1
   , p_discount           IN NUMBER DEFAULT NULL
   , p_discount_uom       IN VARCHAR2 DEFAULT NULL
   , p_uom_code           IN VARCHAR2 DEFAULT 'Ea'
   , p_price_list_id      IN NUMBER DEFAULT NULL
   , p_price_list_line_id IN NUMBER DEFAULT NULL
 ) ;
 -- Start of comments
 -- API name   : submit_order
 -- Type       : Private
 -- Pre-reqs   : None.
 -- Function   : submits the current order entry process for the current event registration flow to the
 --              Oracle Order Entry module for validation, processing and posting
 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0
 -- End of comments
 PROCEDURE submit_order (
     p_payment_term_id          IN NUMBER DEFAULT NULL
   , p_payment_amount           IN NUMBER DEFAULT NULL
   , p_payment_type             IN VARCHAR2 DEFAULT NULL
   , p_payment_option           IN VARCHAR2 DEFAULT NULL
   , p_credit_card_code         IN VARCHAR2 DEFAULT NULL
   , p_credit_card_holder_name  IN VARCHAR2 DEFAULT NULL
   , p_payment_ref_number       IN VARCHAR2 DEFAULT NULL
   , p_credit_card_approval     IN VARCHAR2 DEFAULT NULL
   , p_credit_card_expiration   IN DATE DEFAULT NULL
   , p_total_discount           IN NUMBER DEFAULT NULL
   , p_total_discount_uom       IN VARCHAR2 DEFAULT NULL
   , x_return_status            OUT VARCHAR2
   , x_order_header_rec         OUT ASO_ORDER_INT.Order_Header_rec_type
   , x_order_line_tbl           OUT ASO_ORDER_INT.Order_Line_tbl_type
 ) ;
END ast_event_order_pkg;

 

/
