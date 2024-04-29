--------------------------------------------------------
--  DDL for Package PON_BID_DEFAULTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_BID_DEFAULTING_PKG" AUTHID CURRENT_USER AS
--$Header: PONBDDFS.pls 120.6.12010000.3 2012/05/02 11:43:33 nrayi ship $

-- ======================================================================
-- PROCEDURE:	IS_BIDDING_ALLOWED  PUBLIC
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_vensid			IN vendor site to place a bid for
--	p_venscode			IN corresponding vendor site code
--	p_buyer_user		IN determines if surrogate bid
--	p_action_code		IN determines if certain validation should be suppressed
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: Determine if the bidding action specified by action code can
--			be completed at this time.
-- ======================================================================
PROCEDURE is_bidding_allowed
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_venscode			IN pon_bid_headers.vendor_site_code%TYPE,
	p_buyer_user		IN VARCHAR2,
	----------- Supplier Management: Supplier Evaluation -----------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN VARCHAR2,
	----------------------------------------------------------------
	p_action_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
);

-- ======================================================================
-- PROCEDURE:	CREATE_DEFAULTED_BID	PUBLIC
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_source_bid		IN the bid to default from
--	x_bid_number		OUT bid number of draft loaded or created
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: create a new draft on p_auc_header_id, defaulting from
--			p_source_bid
-- ======================================================================
PROCEDURE create_defaulted_draft
(
	p_new_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_source_bid		IN pon_bid_headers.bid_number%TYPE,
	x_bid_number		OUT NOCOPY pon_bid_headers.bid_number%TYPE
);

-- ======================================================================
-- PROCEDURE:	CHECK_AND_LOAD_BID	PUBLIC
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_draft_number		IN non-null if a specific draft is to be loaded
--	p_tpid				IN trading partner id of supplier
--	p_tpcid				IN trading partner contact id of supplier
--	p_tpname			IN trading partner name of supplier
--	p_tpcname			IN trading partner contact name of supplier
--	p_userid			IN userid of bid creator
--	p_venid				IN vendor id
--	p_vensid			IN vendor site to place a bid for
--	p_venscode			IN corresponding vendor site code
--	p_buyer_user		IN determines if surrogate bid
--	p_auctpid			IN trading partner id of buyer if surrogate bid
--	p_auctpcid			IN trading partner contact id of buyer if surrogate bid

--	p_evaluator_id		IN evaluator user id
--	p_eval_flag		IN flag indicating if the response is an evaluation

--	x_bid_number		OUT bid number of draft loaded or created
--	x_rebid_flag		OUT flag determining if rebid or not
--	x_prev_bid_number	OUT source bid number
--	x_amend_bid_def		OUT Y if source bid is on a previous amendment
--	x_round_bid_def		OUT Y if source bid is on a previous round
--	x_prev_bid_disq		OUT Y is source bid was disqualified

--	p_action_code		IN determine if a special action needs to be taken
--	x_return_status		OUT 0 for success, 1 for error
--	x_return_code		OUT returned error code, or SUCCESS
--
--  COMMENT: Determine if the bidding action specified by action code can
--			be completed at this time.
-- ======================================================================
PROCEDURE check_and_load_bid
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE,
	p_draft_number		IN pon_bid_headers.bid_number%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_tpname			IN pon_bid_headers.trading_partner_name%TYPE,
	p_tpcname			IN pon_bid_headers.trading_partner_contact_name%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE,
	p_venid				IN pon_bid_headers.vendor_id%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE,
	p_venscode			IN pon_bid_headers.vendor_site_code%TYPE,
	p_buyer_user		IN VARCHAR2,
	p_auctpid			IN pon_bid_headers.surrog_bid_created_tp_id%TYPE,
	p_auctpcid			IN pon_bid_headers.surrog_bid_created_contact_id%TYPE,

	------------ Supplier Management: Supplier Evaluation ------------
	p_evaluator_id		IN pon_bid_headers.evaluator_id%TYPE,
	p_eval_flag		IN pon_bid_headers.evaluation_flag%TYPE,
	------------------------------------------------------------------

	x_bid_number		OUT NOCOPY pon_bid_headers.bid_number%TYPE,
	x_rebid_flag		OUT NOCOPY VARCHAR2,
	x_prev_bid_number	OUT NOCOPY pon_bid_headers.bid_number%TYPE,
	x_amend_bid_def		OUT NOCOPY VARCHAR2,
	x_round_bid_def		OUT NOCOPY VARCHAR2,
	x_prev_bid_disq		OUT NOCOPY VARCHAR2,
	x_edit_draft		OUT NOCOPY VARCHAR2,

	p_action_code		IN VARCHAR2,
	x_return_status		OUT NOCOPY NUMBER,
	x_return_code		OUT NOCOPY VARCHAR2
);

-- ======================================================================
-- FUNCTION:	GET_SOURCE_BID_FOR_SPREADSHEET
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--  	p_prev_round_auc_header_id  IN auction header id of prev round negotiation
--	p_tpid			IN trading partner id of supplier
--	p_tpcid			IN trading partner contact id of supplier
--  	p_auc_header_id_orig_amend IN auction header id of original amendment
--	p_amendment_number	IN amendment number
--	p_vensid		IN vendor site to place a bid for
--
--  COMMENT: This function is only used in spreadsheet export case.
--           Determine whether there are any bids existing for the current amendment.
--	     If not, determines whether there are any bids in previous amendment
--           of current round; If still not, check whether there is an active bid
--           from previous round
-- ======================================================================
FUNCTION get_source_bid_for_spreadsheet
(
	p_auc_header_id			IN pon_auction_headers_all.auction_header_id%TYPE,
	p_prev_round_auc_header_id 	IN pon_auction_headers_all.auction_header_id_prev_round%TYPE,
	p_tpid				IN pon_bid_headers.trading_partner_id%TYPE,
	p_tpcid				IN pon_bid_headers.trading_partner_contact_id%TYPE,
	p_auc_header_id_orig_amend 	IN pon_auction_headers_all.auction_header_id_orig_amend%TYPE,
	p_amendment_number		IN pon_auction_headers_all.amendment_number%TYPE,
	p_vensid			IN pon_bid_headers.vendor_site_id%TYPE

) RETURN NUMBER;


--------------------------------------------------------------------------------
--                      can_supplier_create_payments                         --
--------------------------------------------------------------------------------
-- Start of Comments
--
-- API Name: can_supplier_create_payments
--
-- Type    : Private
--
-- Pre-reqs: None
--
-- Function: This API is called by the Response Import Spreadsheet page.
--           It determines if there are any lines in the RFQ that can have payments.
--           If yes, then the "Pay Items" will be one of the option in the Import
--           and Export poplists
--
--
-- Parameters:
--
--              p_auction_header_id       IN      NUMBER
--                   Auction header id - required
--              p_bid_number       IN      NUMBER
--                   Bid Number - required
--              p_po_style_id       IN      NUMBER
--                   PO Style Id - required
--
--
--              x_can_create_payments OUT      VARCHAR2
--                   Returns Y if payments can be created for atleast one of the
--                   line to which supplier has access. Otherwise Returns N
--
--
-- End of Comments
--------------------------------------------------------------------------------
PROCEDURE  can_supplier_create_payments(
				       p_auction_header_id       IN        NUMBER,
				       p_bid_number              IN        NUMBER,
				       x_can_create_payments OUT NOCOPY VARCHAR2) ;


/**
  * This function calculates the total price on a line including the
  * buyer and the supplier price factors in auction currency.
  *
  * This function will be used in view objects to display supplier's
  * previous round price as the start price for this line instead of the
  * auction line start price.
  *
  * This is as per Cendant requirement to enforce upon suppliers to
  * bid lower than their bid on the previous round of the negotiation
  *
  * Currently anticipated usage of this function are on View Bid Page
  * (ViewBidItemsVO), Negotiation Summary page (AuctionItemPricesAllVO)
  * and bid creation page (ResponseAMImpl)
  *
  * p_auction_header_id - current round auction header id
  * p_prev_auc_active_bid_number - bid number on the previous round
  * p_line_number  - current line number
  * p_unit_price - bid line price in auction currency
  * p_quantity - bid quantity for the current line
*/

FUNCTION apply_price_factors(p_auction_header_id	IN NUMBER,
                             p_prev_auc_active_bid_number  IN NUMBER,
                             p_line_number          IN NUMBER,
                             p_unit_price           IN NUMBER,
                             p_quantity             IN NUMBER
                             )
RETURN NUMBER;

FUNCTION is_accepted_terms_cond(p_auction_header_id  IN NUMBER,
                                p_auction_header_id_orig_amend  IN NUMBER,
                                p_trading_partner_id number,
                                p_trading_partner_contact_id number
                             )
RETURN VARCHAR2;

END PON_BID_DEFAULTING_PKG;

/
