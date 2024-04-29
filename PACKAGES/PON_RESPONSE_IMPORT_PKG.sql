--------------------------------------------------------
--  DDL for Package PON_RESPONSE_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_RESPONSE_IMPORT_PKG" AUTHID CURRENT_USER AS
--$Header: PONRIMPS.pls 120.6 2007/06/21 18:10:12 jingche ship $

FUNCTION get_message_1_token
(
	p_message			IN VARCHAR2,
	p_token1_name		IN VARCHAR2,
	p_token1_value		IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE process_spreadsheet_data
(
	p_batch_id		IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_request_id		IN pon_bid_headers.request_id%TYPE,
	p_userid		IN pon_interface_errors.created_by%TYPE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_return_code		OUT NOCOPY VARCHAR2
);

PROCEDURE process_xml_spreadsheet_data
(
        p_batch_id              IN pon_bid_item_prices_interface.batch_id%TYPE,
        p_bid_number            IN pon_bid_headers.bid_number%TYPE,
        p_request_id            IN pon_bid_headers.request_id%TYPE,
        p_user_id               IN pon_interface_errors.created_by%TYPE,
        x_return_status         OUT NOCOPY NUMBER,
        x_return_code           OUT NOCOPY VARCHAR2
);

PROCEDURE remove_xml_skipped_lines
(
	p_auc_header_id		IN pon_bid_item_prices_interface.auction_header_id%TYPE,
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_request_id		IN pon_bid_headers.request_id%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_full_qty			IN VARCHAR2,
	p_buyer_user		IN VARCHAR2,
	p_suffix			IN VARCHAR2
) ;

PROCEDURE copy_shipment_interface_to_txn
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_item_prices.last_updated_by%TYPE,
    p_bid_currency_precision IN pon_bid_headers.number_price_decimals%TYPE,
        p_shipment_type               IN pon_bid_shipments.shipment_type%TYPE
);

END PON_RESPONSE_IMPORT_PKG;

/
