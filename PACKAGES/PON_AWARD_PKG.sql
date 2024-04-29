--------------------------------------------------------
--  DDL for Package PON_AWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AWARD_PKG" AUTHID CURRENT_USER AS
-- $Header: PONAWRDS.pls 120.10.12010000.2 2015/08/12 08:59:12 irasoolm ship $

g_xml_upload_mode CONSTANT VARCHAR2(3) := 'XML';
g_txt_upload_mode CONSTANT VARCHAR2(3) := 'TXT';

PROCEDURE clean_unawarded_items (p_batch_id  IN NUMBER);

PROCEDURE reject_unawarded_active_bids(p_auction_header_id     IN NUMBER,
                                       p_user_id               IN NUMBER,
                                       p_note_to_rejected      IN VARCHAR2,
									   p_neg_has_lines         IN VARCHAR2);

PROCEDURE complete_award (p_auction_header_id_encrypted IN VARCHAR2,
                          p_auction_header_id           IN NUMBER,
                          p_note_to_rejected            IN VARCHAR2,
                          p_shared_award_decision       IN VARCHAR2,
                          p_user_id                     IN NUMBER,
                          p_create_po_flag              IN VARCHAR2,
                          p_source_reqs_flag            IN VARCHAR2,
                          p_no_bids_flag                IN VARCHAR2,
                          p_has_backing_reqs_flag       IN VARCHAR2,
                          p_outcome_status              IN VARCHAR2,
						  p_has_scoring_teams_flag      IN VARCHAR2,
						  p_scoring_lock_tpc_id         IN NUMBER);

PROCEDURE complete_auction (p_auction_header_id     IN NUMBER );

PROCEDURE award_notification (p_auction_header_id_encrypted IN VARCHAR2,
                              p_auction_header_id           IN NUMBER,
                              p_shared_award_decision       IN VARCHAR2);

PROCEDURE complete_item_disposition  (p_auction_header_id     IN NUMBER,
                                      p_line_number           IN NUMBER,
                                      p_award_quantity        IN NUMBER);

PROCEDURE  award_item_disposition  (p_auction_header_id     IN NUMBER,
                                       p_line_number           IN NUMBER,
                                       p_award_quantity        IN NUMBER);
--
TYPE PON_AWARD_LINES_REC IS RECORD (
	 bid_number       NUMBER,
	 line_number      NUMBER,
	 award_status     VARCHAR2(10),
	 award_quantity   NUMBER,
	 award_date       DATE,
	 note_to_supplier VARCHAR2(4000),
         group_type       pon_auction_item_prices_all.group_type%type,
	 award_shipment_number   NUMBER
);
TYPE t_award_lines IS TABLE OF PON_AWARD_LINES_REC
 INDEX BY BINARY_INTEGER;

-- FPK: CPA
TYPE PON_AWARD_HEADER_REC IS RECORD (
	 bid_number       NUMBER,
	 award_status     PON_BID_HEADERS.AWARD_STATUS%TYPE,
	 award_date       DATE
);

TYPE t_awarded_bid_headers IS TABLE OF PON_AWARD_HEADER_REC
 INDEX BY BINARY_INTEGER;

t_emptytbl t_awarded_bid_headers;

TYPE Number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE Date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE Char25_tbl_type IS TABLE OF VARCHAR2(25) INDEX BY BINARY_INTEGER;
-- end of FPK: CPA

--
-- Constants for mode values
g_AWARD_QUOTE          VARCHAR2(20) := 'AWARD_QUOTE';
g_AWARD_MULTIPLE_LINES VARCHAR2(20) := 'AWARD_MULTIPLE_LINES';
g_AWARD_LINE           VARCHAR2(20) := 'AWARD_LINE';
--Awarded by Line on Award Line page(Horizontal Page)
g_AWARD_LINE_H         VARCHAR2(20) := 'AWARD_LINE_H';
g_AWARD_GROUP          VARCHAR2(20) := 'AWARD_GROUP';
g_AWARD_GROUP_H          VARCHAR2(20) := 'AWARD_GROUP_H';
g_AWARD_AUTO_RECOMMEND CONSTANT VARCHAR2(30) := 'AWARD_AUTO_RECOMMEND';
g_AWARD_OPTIMIZATION CONSTANT VARCHAR2(30) := 'AWARD_OPTIMIZATION';
--
g_AWARD_OUTCOME_WIN     CONSTANT VARCHAR2(10) := 'WIN';
g_AWARD_OUTCOME_LOSE    CONSTANT VARCHAR2(10) := 'LOSE';
g_AWARD_OUTCOME_NOAWARD CONSTANT VARCHAR2(10) := 'NA';
g_AWARD_OUTCOME_NOBID   CONSTANT VARCHAR2(10) := 'NB';
--
--
PROCEDURE award_auction
( p_auctioneer_id     IN  NUMBER
, p_auction_header_id IN  NUMBER
, p_last_update_date  IN  DATE
, p_mode              IN  VARCHAR2
, p_line_num          IN  NUMBER
, p_award_table       IN  PON_AWARD_TABLE
, p_note_to_accepted  IN  VARCHAR2
, p_note_to_rejected  IN  VARCHAR2
, p_batch_id          IN  NUMBER
, x_status            OUT NOCOPY VARCHAR2
);
--
PROCEDURE update_bid_item_prices
(
  p_auction_id    IN NUMBER,
  p_award_lines   IN t_award_lines,
  p_auctioneer_id IN NUMBER,
  p_mode          IN VARCHAR2
);
--
/*==========================================================================================================================
 * PROCEDURE : upd_single_bid_item_prices_qt
 * PARAMETERS:  1. p_bid_number - bid number for which the award_price and shipment no to be updated.
 *              2. p_line_number - corresponding line number
 *              3. p_award_status - award status 'AWARDED' or 'REJECTED'
 *              4. p_award_quantity - The quantity awarded
 *              5. p_award_date -- Award Datw
 *              6. p_auctioneer_id - Id of person who is saving award
 *              7. p_award_shipment_number - Quantity awarded falls in the tiers range corresponding to the shipment number
 * COMMENT   : This procedure calculates the award price based on the per unit and fixed amount component and
 *               corresponding to the award shipment number. PON_BID_ITEM_PRICES is updated accordingly
 *==========================================================================================================================*/
PROCEDURE upd_single_bid_item_prices_qt
(
p_bid_number     IN NUMBER,
p_line_number    IN NUMBER,
p_award_status   IN VARCHAR2,
p_award_quantity IN NUMBER,
p_award_date     IN DATE,
p_auctioneer_id  IN NUMBER,
p_award_shipment_number IN NUMBER
);
--
PROCEDURE update_single_bid_item_prices
(
p_bid_number     IN NUMBER,
p_line_number    IN NUMBER,
p_award_status   IN VARCHAR2,
p_award_quantity IN NUMBER,
p_award_date     IN DATE,
p_auctioneer_id  IN NUMBER
);
--
PROCEDURE update_bid_headers
(
  p_auction_id           IN NUMBER,
  p_auctioneer_id        IN NUMBER,
  p_awarded_bid_headers  IN t_awarded_bid_headers DEFAULT t_emptytbl, -- FPK: CPA
  p_neg_has_lines        IN VARCHAR2                                  -- FPK: CPA
 );
--
PROCEDURE update_single_bid_header
(
  p_bid_number    IN NUMBER,
  p_auctioneer_id IN NUMBER

);
--
PROCEDURE update_auction_item_prices
(
  p_auction_id    IN NUMBER,
  p_line_number   IN NUMBER,
  p_award_date    IN DATE,
  p_auctioneer_id IN NUMBER,
  p_mode          IN VARCHAR2
);
--
PROCEDURE update_single_auction_item
(
  p_auction_id    IN NUMBER,
  p_line_number   IN NUMBER,
  p_auctioneer_id IN NUMBER,
  p_mode          IN pon_auction_item_prices_all.award_mode%type
);
--
--
PROCEDURE update_auction_headers
(
  p_auction_id    IN NUMBER,
  p_mode          IN VARCHAR2,
  p_award_date    IN DATE,
  p_auctioneer_id IN NUMBER,
  p_neg_has_lines IN VARCHAR2 -- FPK: CPA
);
--
--
PROCEDURE update_award_agreement_amount
(
 p_auction_id    IN NUMBER,
 p_auctioneer_id IN NUMBER
);
--
--
PROCEDURE bulk_update_pon_acceptances
( p_auction_header_id IN NUMBER,
  p_line_number 	  IN NUMBER,
  p_note_to_accepted  IN VARCHAR2,
  p_note_to_rejected  IN VARCHAR2,
  p_award_date    	  IN DATE,
  p_auctioneer_id	  IN NUMBER,
  p_mode              IN VARCHAR2
)
;
--
PROCEDURE update_unawarded_acceptances
(
  p_auction_header_id     IN NUMBER,
  p_line_number           IN NUMBER,
  p_note_to_rejected      IN VARCHAR2,
  p_award_date            IN DATE,
  p_auctioneer_id         IN NUMBER
)
;
--
FUNCTION get_award_status(award_outcome IN VARCHAR2 ) RETURN VARCHAR2;
--

PROCEDURE update_notes_for_bid
(
  p_bid_number        IN NUMBER,
  p_note_to_supplier  IN VARCHAR2,
  p_internal_note     IN VARCHAR2,
  p_auctioneer_id     IN NUMBER
);

--
PROCEDURE clear_draft_awards
(
  p_auction_header_id IN NUMBER,
  p_line_number       IN NUMBER,
  p_award_date        IN DATE,
  p_auctioneer_id     IN NUMBER,
  p_neg_has_lines     IN VARCHAR2 -- FPK: CPA
);
--
PROCEDURE clear_awards_recommendation
(
  p_auction_header_id IN NUMBER,
  p_award_date        IN DATE,
  p_auctioneer_id     IN NUMBER
);
--
PROCEDURE save_award_recommendation
(
   p_batch_id         IN  NUMBER,
   p_auctioneer_id    IN  NUMBER,
   p_last_update_date IN  DATE,
   p_mode             IN  VARCHAR2,
   x_status           OUT NOCOPY VARCHAR2
);
--
PROCEDURE accept_award_scenario
(
   p_scenario_id         IN  NUMBER,
   p_auctioneer_id    IN  NUMBER,
   p_last_update_date IN  DATE,
   x_status           OUT NOCOPY VARCHAR2
);
--
PROCEDURE copy_award_scenario
(
  p_scenario_id         IN NUMBER,
  p_user_id	        IN NUMBER,
  p_cost_scenario_flag  IN VARCHAR2,
  x_cost_scenario_id	OUT NOCOPY NUMBER,
  x_status              OUT NOCOPY VARCHAR2
);
--
PROCEDURE save_award_spreadsheet
(
   p_batch_id          IN  NUMBER,
   p_auction_header_id IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_auctioneer_id     IN  NUMBER,
   p_last_update_date  IN  DATE,
   p_batch_enabled     IN  VARCHAR2,
   p_is_xml_upload     IN  VARCHAR2,
   x_status            OUT NOCOPY VARCHAR2
);

PROCEDURE batch_award_spreadsheet
(
   p_auction_header_id IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_auctioneer_id     IN  NUMBER,
   p_last_update_date  IN  DATE,
   x_status            OUT NOCOPY VARCHAR2
);

--
FUNCTION is_auction_not_updated
(
   p_auction_header_id NUMBER,
   p_last_update_date  DATE
)  RETURN              BOOLEAN;
--
PROCEDURE toggle_shortlisting
( p_user_id    IN NUMBER
, p_bid_number IN NUMBER
, p_event      IN VARCHAR2
);
--
FUNCTION get_award_amount(p_auction_header_id IN NUMBER) RETURN NUMBER;
--
PROCEDURE award_bi_subline (
   p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
   p_bid_number IN pon_bid_headers.bid_number%TYPE,
   p_parent_line_number IN pon_bid_item_prices.line_number%TYPE,
   p_award_status IN pon_bid_item_prices.award_status%TYPE,
   p_award_date IN pon_bid_item_prices.award_date%TYPE,
   p_auctioneer_id pon_bid_item_prices.LAST_UPDATED_BY%TYPE);
--
--
----------------------------------------------------------------
--and sets the award status of parent line by querying up the child lines
----------------------------------------------------------------
PROCEDURE update_bi_group_award (
   p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
   p_bid_number IN pon_bid_headers.bid_number%TYPE,
   p_parent_line_number IN pon_auction_item_prices_all.parent_line_number%TYPE,
   p_award_date IN pon_bid_item_prices.award_date%TYPE,
   p_auctioneer_id IN pon_bid_item_prices.last_updated_by%TYPE);
--
--
PROCEDURE update_ai_group_award (
   p_auction_header_id IN pon_bid_headers.auction_header_id%TYPE,
   p_line_number IN pon_bid_item_prices.line_number%TYPE,
   p_award_date IN pon_bid_item_prices.award_date%TYPE,
   p_auctioneer_id IN pon_bid_item_prices.last_updated_by%TYPE);
--

PROCEDURE get_award_totals(
	p_auction_header_id	in 	number,
	p_award_total		out	nocopy	number,
	p_current_total		out	nocopy	number,
	p_savings_total		out	nocopy	number,
	p_savings_percent	out	nocopy	number);


FUNCTION does_bid_exist
(
   p_scenario_id IN  PON_OPTIMIZE_CONSTRAINTS.SCENARIO_ID%TYPE,
   p_sequence_number IN  PON_OPTIMIZE_CONSTRAINTS.SEQUENCE_NUMBER%TYPE,
   p_bid_number IN  PON_BID_HEADERS.BID_NUMBER%TYPE
)  RETURN VARCHAR2;


FUNCTION has_scored_attribute
(
   p_auction_header_id IN  PON_AUCTION_ATTRIBUTES.AUCTION_HEADER_ID%TYPE,
   p_line_number IN  PON_AUCTION_ATTRIBUTES.LINE_NUMBER%TYPE
)  RETURN              VARCHAR2;


PROCEDURE preprocess_cost_of_constraint
(
  p_scenario_id         	IN NUMBER,
  p_user_id         		IN NUMBER,
  p_cost_constraint_flag	IN VARCHAR2,
  p_constraint_type		IN VARCHAR2,
  p_internal_type		IN VARCHAR2,
  p_line_number			IN NUMBER,
  p_sequence_number		IN NUMBER,
  x_cost_scenario_id		OUT NOCOPY NUMBER,
  x_status              	OUT NOCOPY VARCHAR2
);

PROCEDURE postprocess_cost_of_constraint
(
  p_scenario_id         IN NUMBER,
  p_constraint_type	IN VARCHAR2,
  p_internal_type	IN VARCHAR2,
  p_line_number		IN NUMBER,
  p_sequence_number	IN NUMBER,
  x_status              OUT NOCOPY VARCHAR2
);

PROCEDURE reset_cost_of_constraint
(
  p_scenario_id         IN NUMBER,
  x_status              OUT NOCOPY VARCHAR2
);

FUNCTION GET_SAVING_PERCENT_INCENTIVE (p_scenario_id   IN NUMBER)
       RETURN NUMBER;


FUNCTION getDependentReqLevel
(
p_auction_header_id IN NUMBER,
p_sequence_number IN NUMBER
)
RETURN NUMBER;

END PON_AWARD_PKG;

/
