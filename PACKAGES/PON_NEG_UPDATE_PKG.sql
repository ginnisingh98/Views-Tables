--------------------------------------------------------
--  DDL for Package PON_NEG_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_NEG_UPDATE_PKG" AUTHID CURRENT_USER as
/* $Header: PONUPDTS.pls 120.5 2007/05/25 16:21:40 mshujath ship $ */


PROCEDURE MANUAL_CLOSE (p_auction_header_id IN NUMBER,
                        p_close_now_flag IN VARCHAR2,
                        p_new_close_date IN DATE,
                        p_reason IN VARCHAR2,
                        p_user_id IN NUMBER) ;

PROCEDURE CANCEL_NEGOTIATION (p_auction_header_id IN NUMBER,
                              p_send_note_flag IN VARCHAR2,
                              p_reason IN VARCHAR2,
                              p_user_id IN NUMBER,
                              x_error_code OUT NOCOPY VARCHAR2) ;

PROCEDURE MANUAL_EXTEND (p_auction_header_id IN NUMBER,
                            p_close_date IN DATE,
                            p_new_close_date IN DATE,
                            p_is_autoExtend IN VARCHAR2,
                            p_new_autoextend_num IN NUMBER,
                            p_is_allExtend IN VARCHAR2,
                            p_new_duration IN NUMBER,
                            p_new_extend_type IN VARCHAR2,
                            p_user_id IN NUMBER,
                            p_last_updated_date IN DATE,
                            p_auto_extend_min_trigger IN NUMBER,
                            p_result OUT NOCOPY NUMBER,
                            p_extended_close_bidding_date OUT NOCOPY DATE );

PROCEDURE ACTIVATE_PREV_ROUND_NEG (p_prev_round_auction_header_id IN NUMBER);

PROCEDURE CAN_EDIT_DRAFT_AMEND (p_auction_header_id_prev_doc IN NUMBER,
                                x_error_code OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_TO_NEW_DOCUMENT (p_auction_header_id_curr_doc IN NUMBER,
                                  p_doc_number_curr_doc IN VARCHAR2,
                                  p_auction_header_id_prev_doc IN NUMBER,
                                  p_auction_origination_code IN VARCHAR2,
                                  p_is_new IN VARCHAR2,
                                  p_is_publish IN VARCHAR2,
                                  p_transaction_type IN VARCHAR2,
                                  p_user_id IN NUMBER,
                                  x_error_code OUT NOCOPY VARCHAR2,
                                  x_error_msg OUT NOCOPY VARCHAR2);

PROCEDURE UPDATE_MODIFIED_FIELDS (p_currAuctionHeaderId IN NUMBER,
                                  p_prevAuctionHeaderId IN NUMBER,
                                  p_action IN VARCHAR2);

PROCEDURE UPDATE_CURRENCY_RATES_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                          p_prevAuctionHeaderId IN NUMBER,
                                          p_action IN VARCHAR2);

PROCEDURE UPDATE_NEG_TEAM_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                    p_prevAuctionHeaderId IN NUMBER,
                                    p_action IN VARCHAR2);

PROCEDURE UPDATE_INVITEES_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                    p_prevAuctionHeaderId IN NUMBER,
                                    p_action IN VARCHAR2);

PROCEDURE UPDATE_HDR_ATTR_MODIFIED (p_currAuctionHeaderId IN NUMBER,
                                    p_prevAuctionHeaderId IN NUMBER,
                                    p_action IN VARCHAR2);

PROCEDURE PROPAGATE_BACK_INSERT_INVITEE(p_currAuctionHeaderId IN NUMBER,
                                        p_sequence IN NUMBER);

PROCEDURE PROPAGATE_BACK_UPDATE_INVITEE(p_currAuctionHeaderId IN NUMBER,
                                        p_sequence IN NUMBER);

PROCEDURE PROPAGATE_BACK_INSERT_MEMBER(p_currAuctionHeaderId IN NUMBER,
                                       p_userId IN NUMBER);

PROCEDURE PROPAGATE_BACK_UNLOCK(p_currAuctionHeaderId IN NUMBER,
                                p_userId              IN NUMBER,
                                p_unlock_date         IN DATE,
				p_unlock_type         IN VARCHAR2);

PROCEDURE PROPAGATE_BACK_UNSEAL(p_currAuctionHeaderId IN NUMBER,
                                p_userId              IN NUMBER,
                                p_unseal_date         IN DATE,
				p_unseal_type         IN VARCHAR2);


PROCEDURE PROCESS_PRICE_FACTORS(p_auction_header_id IN NUMBER,
                                p_user_id           IN NUMBER,
                                p_login_id          IN NUMBER);

PROCEDURE MANUAL_CLOSE_LINE (x_result OUT NOCOPY VARCHAR2, --1
  x_error_code OUT NOCOPY VARCHAR2, --2
  x_error_message OUT NOCOPY VARCHAR2, --3
  p_auction_header_id IN NUMBER, --4
  p_line_number IN NUMBER, --5
  p_user_id IN NUMBER, --6
  x_is_auction_closed OUT NOCOPY VARCHAR2); --7

PROCEDURE PROPAGATE_BACK_TECH_EVAL(p_currAuctionHeaderId IN NUMBER,
				   p_tech_eval_status    IN VARCHAR2);

END PON_NEG_UPDATE_PKG;

/
