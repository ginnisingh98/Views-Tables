--------------------------------------------------------
--  DDL for Package MTL_QP_PRICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_QP_PRICE" AUTHID CURRENT_USER AS
/* $Header: INVVICAS.pls 120.1.12000000.1 2007/01/17 16:34:59 appldev ship $ */


FUNCTION get_transfer_price (
        p_transaction_id 	    IN  NUMBER,
        p_sell_ou_id     	    IN  NUMBER,
        p_ship_ou_id     	    IN  NUMBER,
        p_order_line_id  	    IN  NUMBER DEFAULT NULL,
        p_inventory_item_id 	IN  NUMBER DEFAULT NULL,
        p_organization_id   	IN  NUMBER DEFAULT NULL,
        p_uom_code		        IN  VARCHAR2 DEFAULT NULL,
        p_cto_item_flag		    IN  VARCHAR2 DEFAULT 'N',
        p_incr_code		        IN  NUMBER,
        p_incrcurrency		    IN  VARCHAR2,
        p_request_type_code   IN  VARCHAR2 DEFAULT 'IC',       -- OPM INVCONV umoogala
        p_pricing_event       IN  VARCHAR2 DEFAULT 'ICBATCH',  -- OPM INVCONV umoogala
        x_currency_code  	    OUT NOCOPY VARCHAR2,
        x_tfrPriceCode   	    OUT NOCOPY NUMBER,
        x_return_status  	    OUT NOCOPY VARCHAR2,
        x_msg_count      	    OUT NOCOPY NUMBER,
        x_msg_data       	    OUT NOCOPY VARCHAR2)
         return number;

PROCEDURE G_Hdr_Initialize (
        p_header_id 		  IN NUMBER
      , p_incr_code		    IN NUMBER
      , p_incrcurrency 		IN VARCHAR2
      , x_return_status 	OUT NOCOPY VARCHAR2 );

PROCEDURE G_Line_Initialize (
        p_line_id 		        IN NUMBER
      , l_sell_org_id 		    IN NUMBER
      , l_ship_org_id 		    IN NUMBER
      , l_primary_uom 		    IN VARCHAR2
      , p_inventory_item_id 	IN NUMBER
      , p_cto_item_flag		    IN VARCHAR2
      , p_base_item_id		    IN NUMBER
      , p_request_type_code   IN VARCHAR2 DEFAULT 'IC' -- OPM INVCONV umoogala
      , x_return_status 	    OUT NOCOPY VARCHAR2 );

PROCEDURE copy_Header_to_request(
        p_header_rec           	IN INV_IC_Order_PUB.Header_Rec_Type
      , p_Request_Type_Code    	IN VARCHAR2
      , px_line_index          	IN OUT NOCOPY NUMBER);

PROCEDURE copy_Line_to_request (
        p_Line_rec              IN INV_IC_ORDER_PUB.Line_Rec_Type
      , p_pricing_events        IN VARCHAR2
      , p_request_type_code     IN VARCHAR2
      , px_line_index           IN OUT NOCOPY NUMBER);

PROCEDURE Populate_Temp_Table ( x_return_status OUT NOCOPY VARCHAR2 );

PROCEDURE Populate_Results ( p_line_index NUMBER
                             , x_return_status OUT NOCOPY VARCHAR2 );

PROCEDURE print_debug(p_message in VARCHAR2);

/** Added for J Development for Global Procurement **/
/** This is to populate the Hdr Information for Global Procurement **/

PROCEDURE copy_Proc_Header_to_request(
    p_header_rec             	IN INV_IC_ORDER_PUB.Proc_Header_Rec_Type
  , p_Request_Type_Code      	IN VARCHAR2
  , px_line_index   		IN OUT NOCOPY NUMBER );

PROCEDURE copy_PROC_Line_to_request (
        p_Line_rec 		IN INV_IC_ORDER_PUB.PROC_Line_Rec_Type
      , p_pricing_events 	IN VARCHAR2
      , p_request_type_code 	IN VARCHAR2
      , px_line_index 		IN OUT NOCOPY NUMBER );


PROCEDURE G_PROC_Hdr_Initialize(
	p_header_id 		IN NUMBER
	, p_incr_code		IN NUMBER
	, p_incrcurrency	IN VARCHAR2
	, x_return_status 	OUT NOCOPY VARCHAR2);

/** This is to populate the Line Information for Global Procurement **/
PROCEDURE G_PROC_LINE_INITIALIZE(
	p_line_id	        IN NUMBER
	, p_from_org_id	        IN NUMBER
	, p_to_org_id	        IN NUMBER
	, p_primary_uom         IN VARCHAR2
	, p_inventory_item_id   IN NUMBER
	, p_cto_item_flag	IN VARCHAR2
	, x_return_status       OUT NOCOPY VARCHAR2);

/** Overloaded Function to get the transfer price for global procurement **/
FUNCTION get_transfer_price_ds (
     p_transaction_id 		IN  NUMBER,
     p_sell_ou_id     		IN  NUMBER,
     p_ship_ou_id     		IN  NUMBER,
     p_flow_type		IN  NUMBER,
     p_order_line_id		IN  NUMBER,
     p_inventory_item_id	IN  NUMBER,
     p_organization_id		IN  NUMBER,
     p_uom_code			IN  VARCHAR2,
     p_cto_item_flag		IN  VARCHAR2 DEFAULT 'N',
     p_incr_code		IN  NUMBER,
     p_incrcurrency		IN  VARCHAR2,
     x_currency_code  		OUT NOCOPY VARCHAR2,
     x_tfrPriceCode   		OUT NOCOPY NUMBER,
     x_return_status  		OUT NOCOPY VARCHAR2,
     x_msg_count      		OUT NOCOPY NUMBER,
     x_msg_data       		OUT NOCOPY VARCHAR2)
return number;

end MTL_QP_PRICE;

 

/
