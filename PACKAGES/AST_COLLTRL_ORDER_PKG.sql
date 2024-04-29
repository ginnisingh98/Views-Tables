--------------------------------------------------------
--  DDL for Package AST_COLLTRL_ORDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_COLLTRL_ORDER_PKG" AUTHID CURRENT_USER as
/* $Header: astclrqs.pls 115.18 2002/12/05 19:57:47 rramacha ship $ */
 -- Start of comments
 -- API name   : open_order
 -- Type       : Private
 -- Pre-reqs   : None.
 -- Function   : initializes the order entry process for the current collateral registration flow

 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0

 -- Extra Parameters
 -- Collaterals are free orders. So there is not price information needed.
 --, p_currency_code              IN VARCHAR2
 --, p_price_list_id              IN NUMBER
 --, p_invoice_party_id           IN NUMBER
 --, p_invoice_party_site_id      IN NUMBER
 -- End of comments

 PROCEDURE open_order (
     p_cust_party_id              IN NUMBER
   , p_cust_account_id            IN NUMBER
   , p_sold_to_contact_id	    IN NUMBER
   , p_inv_party_id               IN NUMBER
   , p_inv_party_site_id          IN NUMBER
   , p_ship_party_site_id         IN NUMBER
   , p_source_code                IN VARCHAR2
   , p_order_type_id              IN NUMBER
   , p_employee_id                IN NUMBER
   , p_campaign_id                IN NUMBER
   , p_quote_header_id            IN NUMBER DEFAULT NULL
 ) ;
 -- Start of comments
 -- API name   : add_order_line
 -- Type       : Private
 -- Pre-reqs   : None.
 -- Function   : adds a new line item to the current order entry process for the current collateral registration flow

 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0

 -- Extra Parameters
 -- Collaterals are free orders. So there is not price information needed.
 --, p_line_list_price    IN NUMBER
 --, p_price_list_id      IN NUMBER DEFAULT NULL
 --, p_price_list_line_id IN NUMBER DEFAULT NULL
 -- End of comments
 PROCEDURE add_order_line (
     p_ship_party_id      IN NUMBER
   , p_ship_party_site_id IN NUMBER
   , p_inventory_item_id  IN NUMBER
   , p_quantity           IN NUMBER
   , p_ship_method_code	 IN VARCHAR2
   , p_uom_code           IN VARCHAR2
   , p_line_category_code IN VARCHAR2
 ) ;

 -- Start of comments
 -- API name   : submit_order
 -- Type       : Private

 -- Pre-reqs   : None.
 -- Function   : submits the current order entry process for the current collateral
 --              registration flow to the Oracle Order Entry module for validation,
 --			  processing and posting

 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0

 -- Extra Parameters
 -- Collaterals are free orders. So there is not price information needed.
 --  p_payment_term_id          IN NUMBER DEFAULT NULL
 --, p_payment_amount           IN NUMBER DEFAULT NULL
 --, p_payment_type             IN VARCHAR2 DEFAULT NULL
 --, p_payment_option           IN VARCHAR2 DEFAULT NULL
 --, p_credit_card_code         IN VARCHAR2 DEFAULT NULL
 --, p_credit_card_holder_name  IN VARCHAR2 DEFAULT NULL
 --, p_payment_ref_number       IN VARCHAR2 DEFAULT NULL
 --, p_credit_card_approval     IN VARCHAR2 DEFAULT NULL
 --, p_credit_card_expiration   IN DATE DEFAULT NULL
 -- End of comments

 PROCEDURE submit_order (
     x_return_status            OUT NOCOPY VARCHAR2
   , x_order_header_rec         OUT NOCOPY ASO_ORDER_INT.Order_Header_rec_type
   , x_order_line_tbl           OUT NOCOPY ASO_ORDER_INT.Order_Line_tbl_type
 ) ;

 -- Start of comments
 -- API name   : start_request
 -- Type       : Private

 -- Pre-reqs   : None.
 -- Function   : Starts a fulfilment request and returns the request id
 --              to the client. This is a wrapper package procedure.
 --

 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0

 PROCEDURE start_request(l_request_id	 OUT NOCOPY NUMBER,
			          l_return_status OUT NOCOPY VARCHAR2,
			          l_msg_count     OUT NOCOPY NUMBER,
			          l_msg_data  	 OUT NOCOPY VARCHAR2);

 -- Start of comments
 -- API name   : xml_request
 -- Type       : Private

 -- Pre-reqs   : None.
 -- Function   : This is a wrapper package procedure to call fulfillment
 --              Get_Content_Xml. This inturn returns the xml generated
 --			  by the fulfillment API using the content id.

 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0

 PROCEDURE xml_request(l_content_id IN  NUMBER,
		       l_request_type     IN  VARCHAR2,
		       l_user_note        IN  VARCHAR2,
		       l_email	           IN  VARCHAR2,
		       l_party_id         IN  NUMBER,
		       l_return_status    OUT NOCOPY VARCHAR2,
		       l_content_xml      OUT NOCOPY VARCHAR2,
		       l_msg_count        OUT NOCOPY NUMBER,
		       l_msg_data         OUT NOCOPY VARCHAR2,
		       l_request_id       IN  NUMBER);

 -- Start of comments
 -- API name   : xml_request
 -- Type       : Private (Overloaded)

 -- Pre-reqs   : None.
 -- Function   : This is a wrapper package procedure to call fulfillment
 --              Get_Content_Xml. This inturn returns the xml generated by
 --			  the fulfillment API using the content id with media type
 --              and fax or printer or email information. This is over loaded.

 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0

 PROCEDURE xml_request(p_content_id IN  NUMBER,
		       p_request_type     IN  VARCHAR2,
		       p_media_type	      IN  VARCHAR2 DEFAULT 'EMAIL',
		       p_user_note	      IN  VARCHAR2,
		       p_email            IN  VARCHAR2,
                 p_fax              IN  VARCHAR2 DEFAULT NULL,
                 p_printer          IN  VARCHAR2 DEFAULT NULL,
		       p_party_id         IN  NUMBER DEFAULT NULL,
		       x_return_status    OUT NOCOPY VARCHAR2,
		       x_content_xml      OUT NOCOPY VARCHAR2,
		       x_msg_count        OUT NOCOPY NUMBER,
		       x_msg_data         OUT NOCOPY VARCHAR2,
		       p_request_id       IN  NUMBER);

 -- Start of comments
 -- API name   : submit_request
 -- Type       : Private

 -- Pre-reqs   : None.
 -- Function   : This is a wrapper package procedure to call fulfillment
 --              submit request. This takes the final xml generated and
 --			  submitts the request to the fulfillment queue and returs
 --			  the status.

 -- Parameters :
 -- Version    : Current version 1.0
 --              Initial version 1.0

PROCEDURE submit_request(l_commit 		   IN  VARCHAR2,
					l_return_status   OUT NOCOPY VARCHAR2,
					l_msg_count 	   OUT NOCOPY NUMBER,
					l_msg_data 	   OUT NOCOPY VARCHAR2,
					l_subject 	   IN  VARCHAR2,
					l_source_code_id  IN  NUMBER,
					l_party_id 	   IN  NUMBER,
					l_user_id 	   IN  NUMBER,
					l_extended_header IN  VARCHAR2,
					l_content_xml	   IN  VARCHAR2,
					l_request_id	   IN  NUMBER);
END ast_colltrl_order_pkg;

 

/
