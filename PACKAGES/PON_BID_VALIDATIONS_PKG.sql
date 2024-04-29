--------------------------------------------------------
--  DDL for Package PON_BID_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_BID_VALIDATIONS_PKG" AUTHID CURRENT_USER AS
--$Header: PONBDVLS.pls 120.3 2007/02/01 00:41:25 mxfang ship $

g_online_mode     CONSTANT VARCHAR2(3) := 'ONL';
g_xml_upload_mode CONSTANT VARCHAR2(3) := 'XML';
g_txt_upload_mode CONSTANT VARCHAR2(3) := 'TXT';

FUNCTION GET_MASK
(     p_precision in NUMBER
) RETURN VARCHAR2;

FUNCTION FORMAT_PRICE
(     p_price in NUMBER,
      p_format_mask in VARCHAR2,
      p_precision IN NUMBER
) RETURN VARCHAR2;

FUNCTION validate_price_precision
(
	p_number			IN NUMBER,
	p_precision			IN NUMBER
) RETURN VARCHAR2;

FUNCTION validate_currency_precision
(
	p_number			IN NUMBER,
	p_precision			IN NUMBER
) RETURN VARCHAR2;

PROCEDURE validate_bid
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
);

PROCEDURE validate_spreadsheet_upload
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_interface_type	IN pon_interface_errors.interface_type%TYPE,
        p_spreadsheet_type      IN VARCHAR2,
	p_userid		IN pon_interface_errors.created_by%TYPE,
	p_batch_id		IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
);

PROCEDURE populate_has_bid_changed_line
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_source_bid		IN pon_bid_item_prices.bid_number%TYPE,
    p_batch_start       IN NUMBER,
    p_batch_end         IN NUMBER,
	p_rebid_flag		IN VARCHAR2,
	p_blanket			IN VARCHAR2,
    p_use_batch_id      IN VARCHAR2
);

FUNCTION GET_VENDOR_SITE_CODE(p_vendor_site_id IN NUMBER) RETURN VARCHAR2;

END PON_BID_VALIDATIONS_PKG;

/
