--------------------------------------------------------
--  DDL for Package PON_AUCTION_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUCTION_HEADERS_PKG" AUTHID CURRENT_USER AS
-- $Header: PONAUCHS.pls 120.7 2007/06/18 10:56:01 ukottama ship $
--===================
-- PROCEDURES
--===================
--========================================================================
-- PROCEDURE : Update_Auction_Info     PUBLIC
-- PARAMETERS:
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Updating auction information
--========================================================================
PROCEDURE update_proxy_bid
( p_auctionHeaderId	IN NUMBER,
  p_bidNumber		IN NUMBER,
  p_oldBidNumber        IN NUMBER,
  p_isSurrogateBid 	IN VARCHAR2,
  p_isAuctionClosed	IN VARCHAR2,
  x_isPriceChanged      OUT NOCOPY VARCHAR2
);

PROCEDURE cancel_all_proxy_bid_lines
( p_auctionHeaderId         IN  NUMBER
, p_tradingPartnerId        IN  NUMBER
, p_tradingPartnerContactId IN  NUMBER
, x_status                  OUT NOCOPY VARCHAR2
);

PROCEDURE cancel_proxy_bid_line
( p_auctionHeaderId         IN  NUMBER
, p_lineNumber              IN  NUMBER
, p_bidNumber               IN  NUMBER
, p_tradingPartnerId        IN  NUMBER
, p_tradingPartnerContactId IN  NUMBER
, x_bidNumber               OUT NOCOPY NUMBER
, x_status                  OUT NOCOPY VARCHAR2
);

PROCEDURE UPDATE_AUCTION_INFO
( p_auctionHeaderId IN NUMBER,
  p_bidNumber IN NUMBER,
  p_vendorSiteId IN NUMBER,
  p_isRebid IN VARCHAR2,
  p_prevBidNumber IN NUMBER,
  p_isSavingDraft IN VARCHAR2,
  p_isSurrogateBid IN VARCHAR2,
  p_loginUserId IN NUMBER,
  x_return_status OUT NOCOPY NUMBER,
  x_return_code OUT NOCOPY VARCHAR2
);



PROCEDURE check_is_bid_valid
 ( p_auctionHeaderId IN NUMBER,
   p_bidNumber IN NUMBER,
   p_vendorSiteId IN NUMBER,
   p_prevBidNumber IN NUMBER,
   p_isRebid IN VARCHAR2,
   p_isSavingDraft IN VARCHAR2,
   p_surrogBidFlag IN VARCHAR2,
   p_publishDate IN DATE,
   x_return_status OUT NOCOPY NUMBER,
   x_return_code OUT NOCOPY VARCHAR2
);

procedure update_rank
(
  p_auctionHeaderId IN NUMBER,
  p_bidNumber       IN NUMBER,
  p_lineNumber      IN NUMBER,
  p_scoring_method  IN VARCHAR2,
  p_auction_type    IN VARCHAR2,
  p_oldRank         IN NUMBER,
  p_price           IN NUMBER,
  p_score           IN NUMBER,
  p_proxy           IN VARCHAR2,
  p_date            IN DATE
);

PROCEDURE update_auction_info_disqualify
( p_auctionHeaderId           IN NUMBER,
  p_bidNumber                   IN NUMBER
-- fph,
--  p_oex_operation	      IN VARCHAR2,
--  p_oex_operation_url	      IN VARCHAR2
);


PROCEDURE get_auc_header_id_orig_round
( p_auctionHeaderId           IN NUMBER,
  p_auctionHeaderIdOrigRound  OUT NOCOPY NUMBER
);


FUNCTION get_bid_break_price(p_bid_number IN NUMBER,
			 p_line_number IN NUMBER,
			 p_ship_to_org IN NUMBER,
			 p_ship_to_loc IN NUMBER,
			 p_quantity IN NUMBER,
			 p_need_by_date IN DATE)
  RETURN NUMBER;


FUNCTION get_bid_break_price_with_pe(p_bid_number IN NUMBER,
			 p_line_number IN NUMBER,
			 p_ship_to_org IN NUMBER,
			 p_ship_to_loc IN NUMBER,
			 p_quantity IN NUMBER,
			 p_need_by_date IN DATE)
  RETURN NUMBER;


FUNCTION GET_FND_USER_ID (p_person_party_id IN NUMBER) RETURN NUMBER;

FUNCTION get_most_recent_bid_number(x_auction_header_id IN NUMBER,
				  x_trading_partner_id IN NUMBER,
				  x_trading_partner_contact_id IN NUMBER)
  RETURN NUMBER;

FUNCTION is_better_proxy_price(x_price1 IN NUMBER,
                               x_bidNumber IN NUMBER,
                               x_proxy1 IN VARCHAR2,
                               x_date1  IN DATE,
                               x_price2 IN NUMBER,
                               x_triggerNumber IN NUMBER,
                               x_date2  IN DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(is_better_proxy_price, WNDS);
--
FUNCTION is_better_proxy_price_by_score(x_price1 IN NUMBER,
                                        x_score1 IN NUMBER,
                                        x_proxy1 IN VARCHAR2,
                                        x_bidNumber IN NUMBER,
                                        x_date1  IN DATE,
                                        x_price2 IN NUMBER,
                                        x_score2 IN NUMBER,
                                        x_triggerNumber IN NUMBER,
                                        x_date2  IN DATE)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(is_better_proxy_price_by_score, WNDS);

FUNCTION apply_price_factors(p_auction_header_id        IN NUMBER,
                             p_line_number              IN NUMBER,
                             p_bid_number               IN NUMBER,
                             p_price                    IN NUMBER,
                             p_bid_quantity             IN NUMBER,
                             p_trading_partner_id       IN NUMBER,
                             p_vendor_site_id           IN NUMBER,
                             p_rate                     IN NUMBER,
                             p_price_precision          IN NUMBER,
                             p_currency_precision       IN NUMBER,
                             p_entity_level             IN VARCHAR2)
RETURN NUMBER;

PROCEDURE recover_prev_amend_draft (
  p_auction_header_id_orig_amend IN NUMBER,
  p_trading_partner_id           IN NUMBER,
  p_trading_partner_contact_id   IN NUMBER,
  p_vendor_site_id               IN NUMBER,
  p_login_user_id                IN NUMBER
);

PROCEDURE set_buyer_bid_total
              (p_auction_header_id   IN NUMBER,
               p_bid_number          IN NUMBER);



FUNCTION new_best_price   (x_auction_type         IN VARCHAR2,
			   x_current_price        IN NUMBER,
		      	   x_current_limit_price  IN NUMBER,
			   x_best_bid_price       IN NUMBER,
		      	   x_best_bid_limit_price IN NUMBER)
RETURN VARCHAR2;

FUNCTION new_best_mas_price( p_auction_type         IN VARCHAR2
                           , p_current_price        IN NUMBER
                           , p_total_weighted_score IN NUMBER
                           , p_current_limit_price  IN NUMBER
                           , p_best_bid_bid_price   IN NUMBER
                           , p_best_bid_score       IN NUMBER
                           , p_best_bid_limit_price IN NUMBER
                           )
RETURN VARCHAR2;

FUNCTION APPLY_PRICE_FACTORS(
							 p_auction_header_id			IN NUMBER,
                             p_prev_auc_active_bid_number  	IN NUMBER,
                             p_line_number           		IN NUMBER,
                             p_contract_type        		IN VARCHAR2,
                             p_supplier_view_type   		IN VARCHAR2,
                             p_pf_type_allowed      		IN VARCHAR2,
                             p_reverse_transform_flag		IN VARCHAR2
                             )
RETURN NUMBER;

PROCEDURE update_auction_info_tech_short (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_msg OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_user_id IN NUMBER
);

END PON_AUCTION_HEADERS_PKG;

/
