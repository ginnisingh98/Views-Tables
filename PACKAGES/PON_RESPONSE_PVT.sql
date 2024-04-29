--------------------------------------------------------
--  DDL for Package PON_RESPONSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_RESPONSE_PVT" AUTHID CURRENT_USER AS
-- $Header: PONRESPS.pls 120.7.12010000.2 2009/09/15 01:44:05 atjen ship $

FUNCTION get_header_close_bidding_date
         (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE)
         RETURN DATE;

FUNCTION get_line_close_bidding_date
         (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
          p_line_number       IN pon_bid_item_prices.line_number%TYPE,
          p_is_paused         IN pon_auction_headers_all.is_paused%TYPE,
          p_pause_date        IN pon_auction_headers_all.last_pause_date%TYPE)
	     RETURN DATE;

PROCEDURE calculate_group_amounts
          (p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
           p_line_number IN pon_bid_item_prices.line_number%TYPE,
           p_is_supplier IN VARCHAR,
           p_group_amount OUT NOCOPY NUMBER);

PROCEDURE calculate_group_amounts
          (p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
           p_is_supplier IN VARCHAR);

PROCEDURE calculate_group_amounts(p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
                                  p_is_supplier IN VARCHAR,
                                  p_do_all_lines IN VARCHAR,
                                  p_batch_id IN pon_bid_item_prices.batch_id%TYPE);

PROCEDURE calculate_group_amounts_auto
          (p_bid_number IN pon_bid_item_prices.bid_number%TYPE,
           p_is_supplier IN VARCHAR);

PROCEDURE change_bid_by_percentage
          (p_bid_number          IN pon_bid_item_prices.bid_number%TYPE,
           p_power_percentage    IN NUMBER,
		   p_powerbidlosinglines IN VARCHAR2,
		   p_previous_bid_number IN pon_bid_headers.old_bid_number%TYPE);


PROCEDURE recalculate_auc_curr_prices
(
	p_bid_number 	IN pon_bid_item_prices.bid_number%TYPE,
	p_curr_changed	IN VARCHAR2,
	p_batch_id		IN pon_bid_item_prices.batch_id%TYPE
);

PROCEDURE publish(p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
                  p_bid_number IN pon_bid_headers.bid_number%TYPE,
                  p_rebid_flag IN VARCHAR,
                  p_publish_date IN pon_bid_headers.publish_date%TYPE,
                  p_tp_id IN pon_bid_headers.trading_partner_id%TYPE,
                  p_tpc_id IN pon_bid_headers.trading_partner_contact_id%TYPE,
                  p_user_id IN NUMBER,
                  p_batch_id IN NUMBER,
                  p_request_id IN NUMBER,
                  p_hdr_validation_failed IN VARCHAR,
                  x_return_status OUT NOCOPY NUMBER,
                  x_return_code OUT NOCOPY VARCHAR);


PROCEDURE remove_empty_rows
          (p_bid_number IN pon_bid_headers.bid_number%TYPE,
           p_batch_start IN NUMBER,
           p_batch_end IN NUMBER);

PROCEDURE remove_empty_rows_auto
          (p_bid_number IN pon_bid_headers.bid_number%TYPE,
           p_max_line_number IN NUMBER,
           p_batch_size IN NUMBER);

PROCEDURE update_bid_header_fields
    (p_bid_number IN pon_bid_headers.bid_number%TYPE,
     p_publish_date IN pon_bid_headers.publish_date%TYPE,
     p_bid_entry_date IN pon_bid_headers.publish_date%TYPE,
     p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
     p_two_part_flag IN pon_auction_headers_all.two_part_flag%TYPE,
     p_sealed_auction_status IN pon_auction_headers_all.sealed_auction_status%TYPE);

PROCEDURE update_bid_header_fields_auto
    (p_bid_number IN pon_bid_headers.bid_number%TYPE,
     p_publish_date IN pon_bid_headers.publish_date%TYPE,
     p_bid_entry_date IN pon_bid_headers.publish_date%TYPE,
     p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
     p_two_part_flag IN pon_auction_headers_all.two_part_flag%TYPE,
     p_sealed_auction_status IN pon_auction_headers_all.sealed_auction_status%TYPE);

PROCEDURE publish_lines
   (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
    p_bid_number IN pon_bid_headers.bid_number%TYPE,
    p_publish_date IN DATE,
    p_tp_id IN pon_bid_headers.trading_partner_id%TYPE,
    p_auc_tp_id IN pon_auction_headers_all.trading_partner_id%TYPE,
    p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
    p_rebid_flag IN VARCHAR,
    p_batch_start IN NUMBER,
    p_batch_end IN NUMBER);

PROCEDURE publish_lines_auto
   (p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
    p_bid_number IN pon_bid_headers.bid_number%TYPE,
    p_publish_date IN DATE,
    p_tp_id IN pon_bid_headers.trading_partner_id%TYPE,
    p_auc_tp_id IN pon_auction_headers_all.trading_partner_id%TYPE,
    p_surrog_bid_flag IN pon_bid_headers.surrog_bid_flag%TYPE,
    p_rebid_flag IN VARCHAR,
    p_max_line_number IN NUMBER,
    p_batch_size IN NUMBER);


PROCEDURE publish_cp
          (errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY VARCHAR2,
           p_auction_header_id IN NUMBER,
           p_bid_number IN NUMBER,
           p_rebid_flag IN VARCHAR2,
           p_publish_date IN VARCHAR2,
           p_date_mask IN VARCHAR2,
           p_tp_id IN NUMBER,
           p_tpc_id IN NUMBER,
           p_user_type IN VARCHAR2,
           p_user_id IN NUMBER);

PROCEDURE validate_cp
          (errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY VARCHAR2,
           p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
           p_bid_number IN pon_bid_headers.bid_number%TYPE,
           p_user_type IN VARCHAR2,
           p_user_id IN NUMBER);

PROCEDURE get_message_name(p_msg_code IN VARCHAR2,
                           p_auction_header_id IN NUMBER,
                           x_msg_name OUT NOCOPY VARCHAR2);

PROCEDURE get_user_lang_message (p_tpc_id IN NUMBER,
                                 p_message_name IN VARCHAR2,
                                 p_message_token1_name IN VARCHAR2,
                                 p_message_token1_value IN VARCHAR2,
                                 p_message_token2_name IN VARCHAR2,
                                 p_message_token2_value IN VARCHAR2,
                                 x_message_text OUT NOCOPY VARCHAR2);

-- Begin Supplier Management: Supplier Evaluation

-- Procedure to calculate the average evaluation scores for each supplier,
-- and put the scores into each supplier response.

PROCEDURE calculate_avg_eval_scores(p_auction_header_id IN pon_auction_headers_all.auction_header_id%TYPE);

-- End Supplier Management: Supplier Evaluation

END PON_RESPONSE_PVT;

/
