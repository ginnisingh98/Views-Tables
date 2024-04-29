--------------------------------------------------------
--  DDL for Package PON_TRANSFORM_BIDDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_TRANSFORM_BIDDING_PKG" AUTHID CURRENT_USER AS
-- $Header: PONTFBDS.pls 120.1 2005/06/17 16:03:08 dgallant noship $
--===================
-- PROCEDURES
--===================

FUNCTION find_user_site
	(p_auction_header_id 	IN pon_bid_headers.auction_header_id%TYPE,
	 p_tpid 				IN pon_bid_headers.trading_partner_id%TYPE,
	 p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE)
	RETURN NUMBER;


FUNCTION check_est_qty_on_all_bid_lines
               (p_auction_header_id IN NUMBER,
                p_bid_number        IN NUMBER) RETURN VARCHAR2;

FUNCTION calculate_supplier_bid_total
             (p_auction_header_id    IN NUMBER,
              p_bid_number           IN NUMBER,
              p_outcome              IN pon_auction_headers_all.contract_type%TYPE,
              p_supplier_view_type   IN pon_auction_headers_all.supplier_view_type%TYPE,
              p_tpid                 IN NUMBER,
              p_site                 IN NUMBER) RETURN NUMBER;

FUNCTION calculate_bid_total
              (p_auction_header_id IN NUMBER,
               p_bid_number        IN NUMBER,
               p_tpid              IN NUMBER,
               p_site              IN NUMBER) RETURN NUMBER;

FUNCTION calculate_price
	(p_auction_header_id 	                IN NUMBER,
	 p_line_number			        IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_tpcid				IN NUMBER,
	 p_site					IN NUMBER,
         p_requested_supplier_id                IN NUMBER)
	RETURN NUMBER;

FUNCTION calculate_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_tpcid				IN NUMBER,
	 p_site					IN NUMBER)
	RETURN NUMBER;

FUNCTION calculate_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_site					IN NUMBER)
	RETURN NUMBER;

FUNCTION untransform_one_price
	(p_auction_header_id 	IN NUMBER,
	 p_line_number			IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity 				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_site_id				IN NUMBER)
	RETURN NUMBER;

FUNCTION untransform_one_price
	(p_auction_header_id 	                IN NUMBER,
	 p_line_number			        IN NUMBER,
	 p_price				IN NUMBER,
	 p_quantity 				IN NUMBER,
	 p_tpid 				IN NUMBER,
	 p_site_id				IN NUMBER,
         p_requested_supplier_id                IN NUMBER)
	RETURN NUMBER;

FUNCTION calculate_quote_amount
	(p_auction_header_id 	IN pon_bid_headers.auction_header_id%TYPE,
 	 p_line_number			IN pon_auction_item_prices_all.line_number%TYPE,
	 p_bid_number			IN pon_bid_headers.bid_number%TYPE,
	 p_supplier_view_type	IN pon_auction_headers_all.supplier_view_type%TYPE,
	 p_buyer_tpid			IN pon_auction_headers_all.trading_partner_id%TYPE,
	 p_tpid 				IN pon_bid_headers.trading_partner_id%TYPE,
	 p_site					IN pon_bid_headers.vendor_site_id%TYPE)
	RETURN NUMBER;

FUNCTION has_pf_values_defined
         (p_auction_header_id    IN NUMBER,
          p_line_number          IN NUMBER,
          p_pf_seq_number        IN NUMBER,
          p_trading_partner_id   IN NUMBER,
          p_vendor_site_id       IN NUMBER) RETURN VARCHAR2;

FUNCTION has_pf_values_defined
         (p_auction_header_id    IN NUMBER,
          p_line_number          IN NUMBER,
          p_pf_seq_number        IN NUMBER,
          p_trading_partner_id   IN NUMBER,
          p_vendor_site_id       IN NUMBER,
          p_requested_supplier_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE GET_DISPLAY_CURRENCY_INFO (p_auction_header_id            IN  NUMBER,
                                     p_trading_partner_id           IN  NUMBER,
                                     p_vendor_site_id               IN  NUMBER,
                                     p_trading_partner_contact_id   IN  NUMBER,
                                     p_is_buyer                     IN  VARCHAR2,
                                     x_currency                     OUT NOCOPY VARCHAR2,
                                     x_rate                         OUT NOCOPY NUMBER,
                                     x_precision                    OUT NOCOPY NUMBER,
                                     x_currency_precision           OUT NOCOPY NUMBER,
                                     x_site_id                      OUT NOCOPY NUMBER,
                                     x_bid_number                   OUT NOCOPY NUMBER,
                                     x_bid_status                   OUT NOCOPY VARCHAR2);


END PON_TRANSFORM_BIDDING_PKG;

 

/
