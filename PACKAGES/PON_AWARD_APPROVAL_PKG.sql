--------------------------------------------------------
--  DDL for Package PON_AWARD_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AWARD_APPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: PONAWAPS.pls 120.1 2006/03/23 03:43:50 ppaulsam noship $ */

-- constants for integrating with the ame_api package
APPLICATION_ID CONSTANT INTEGER := 396;
AWARD_TRANSACTION_TYPE CONSTANT VARCHAR2(30) := 'PON_NEGOTIATION_AWARD';

-- constants used for parsing and formatting approver strings and records
APPROVER_FIELD_DELIMITER VARCHAR2(3);
APPROVER_RECORD_DELIMITER VARCHAR2(3);
INTEGER_DELIMITER CONSTANT VARCHAR2(1) := ':';

-- constants used to represent the ame_util.approverRecord.api_insertion field
API_AUTHORITY_INSERTION CONSTANT NUMBER := -1;
API_INSERTION CONSTANT NUMBER := -2;
OAM_GENERATED CONSTANT NUMBER := -3;

-- constants used to represent the ame_util.approverRecord.authority field
PRE_APPROVER CONSTANT NUMBER := -4;
AUTHORITY_APPROVER CONSTANT NUMBER := -5;
POST_APPROVER CONSTANT NUMBER := -6;

-- constants used to represent the ame_util.approverRecord.approvalStatus field
APPROVE_AND_FORWARD_STATUS CONSTANT NUMBER := -7;
APPROVED_STATUS CONSTANT NUMBER := -8;
CLEAR_EXCEPTIONS_STATUS CONSTANT NUMBER := -9;
EXCEPTION_STATUS CONSTANT NUMBER := -10;
FORWARD_STATUS CONSTANT NUMBER := -11;
NO_RESPONSE_STATUS CONSTANT NUMBER := -12;
NOTIFIED_STATUS CONSTANT NUMBER := -13;
NULL_STATUS CONSTANT NUMBER := -14;
REJECT_STATUS CONSTANT NUMBER := -15;
REPEATED_STATUS CONSTANT NUMBER := -16;
SUPPRESSED_STATUS CONSTANT NUMBER := -17;

PROCEDURE setup_oam_transaction(p_auction_header_id  IN NUMBER,
                                p_transaction_id     IN VARCHAR2,
                                p_user_id            IN NUMBER,
                                p_last_update_date   OUT NOCOPY DATE,
                                p_error_message      OUT NOCOPY VARCHAR2);

PROCEDURE clear_oam_transaction(p_auction_header_id  IN NUMBER,
                                p_user_id            IN NUMBER);

PROCEDURE pre_approval(itemtype   IN VARCHAR2,
                       itemkey    IN VARCHAR2,
                       actid      IN NUMBER,
                       funcmode   IN VARCHAR2,
                       resultout  OUT NOCOPY VARCHAR2);

PROCEDURE post_approval(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2);

PROCEDURE get_next_approver(itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2);

PROCEDURE process_error(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2);

PROCEDURE is_oam_admin_available(itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                                 actid      IN NUMBER,
                                 funcmode   IN VARCHAR2,
                                 resultout  OUT NOCOPY VARCHAR2);

PROCEDURE is_oam_error(itemtype   IN VARCHAR2,
                       itemkey    IN VARCHAR2,
                       actid      IN NUMBER,
                       funcmode   IN VARCHAR2,
                       resultout  OUT NOCOPY VARCHAR2);

PROCEDURE process_approver_response(itemtype   IN VARCHAR2,
                                    itemkey    IN VARCHAR2,
                                    actid      IN NUMBER,
                                    funcmode   IN VARCHAR2,
                                    resultout  OUT NOCOPY VARCHAR2);

PROCEDURE document_approved(itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2);

PROCEDURE document_rejected(itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2);

PROCEDURE add_approver(p_auction_header_id     IN NUMBER,
                       p_transaction_id        IN VARCHAR2,
                       p_approver_string       IN VARCHAR2,
                       p_position              IN NUMBER,
                       p_last_update_date      IN DATE,
                       p_approver_list_string  OUT NOCOPY VARCHAR2,
                       p_error_message         OUT NOCOPY VARCHAR2);

PROCEDURE delete_approver(p_auction_header_id     IN NUMBER,
                          p_transaction_id        IN VARCHAR2,
                          p_approver_string       IN VARCHAR2,
                          p_last_update_date      IN DATE,
                          p_approver_list_string  OUT NOCOPY VARCHAR2,
                          p_error_message         OUT NOCOPY VARCHAR2);

PROCEDURE change_first_approver(p_auction_header_id     IN NUMBER,
                                p_transaction_id        IN VARCHAR2,
                                p_approver_string       IN VARCHAR2,
                                p_last_update_date      IN DATE,
                                p_approver_list_string  OUT NOCOPY VARCHAR2,
                                p_error_message         OUT NOCOPY VARCHAR2);

PROCEDURE reset_approver_list(p_auction_header_id         IN NUMBER,
                              p_transaction_id            IN VARCHAR2,
                              p_last_update_date          IN DATE,
                              p_approver_list_string      OUT NOCOPY VARCHAR2,
                              p_can_delete_oam_approvers  OUT NOCOPY VARCHAR2,
                              p_error_message             OUT NOCOPY VARCHAR2);

PROCEDURE submit_for_approval(p_auction_header_id           IN NUMBER,
                              p_transaction_id              IN VARCHAR2,
                              p_user_id                     IN NUMBER,
                              p_user_name                   IN VARCHAR2,
                              p_last_update_date            IN DATE,
                              p_note_to_approvers           IN VARCHAR2,
                              p_reject_unawarded_responses  IN VARCHAR2,
                              p_note_to_rejected_suppliers  IN VARCHAR2,
                              p_has_items_flag              IN VARCHAR2,
                              p_has_scoring_teams_flag      IN VARCHAR2,
                              p_scoring_lock_tpc_id         IN NUMBER,
                              p_first_authority_approver_id IN NUMBER,
                              p_error_message               OUT NOCOPY VARCHAR2);

PROCEDURE make_approval_decision(p_auction_header_id  IN NUMBER,
                                 p_user_name          IN VARCHAR2,
                                 p_decision           IN VARCHAR2,
                                 p_note_to_buyer      IN VARCHAR2,
                                 p_error_message      OUT NOCOPY VARCHAR2);

PROCEDURE make_approval_decision(p_auction_header_id    IN NUMBER,
                                 p_user_name            IN VARCHAR2,
                                 p_decision             IN VARCHAR2,
                                 p_note_to_buyer        IN VARCHAR2,
                                 p_forwardee_user_name  IN VARCHAR2,
                                 p_error_message        OUT NOCOPY VARCHAR2);

/***********************************
  DEBUGGING PROCEDURES AND FUNCTIONS
************************************/

PROCEDURE log_string(p_module  IN VARCHAR2,
                     p_string  IN VARCHAR2);

PROCEDURE log_string(p_level          IN NUMBER,
                     p_current_level  IN NUMBER,
                     p_module         IN VARCHAR2,
                     p_string         IN VARCHAR2);

FUNCTION getAMEFieldDelimiter RETURN VARCHAR2;

FUNCTION getAMERecordDelimiter RETURN VARCHAR2;

FUNCTION get_insertion_list_string(p_insertion_list IN ame_util.insertionsTable2) RETURN VARCHAR2;

FUNCTION get_insertion_string(p_approver  IN ame_util.approverRecord2, p_order IN ame_util.insertionRecord2) RETURN VARCHAR2;

FUNCTION get_api_insertion_string(p_api_insertion IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_authority_string(p_authority IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_approval_status_string(p_approval_status IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_order_type_string(p_order_type IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_parameter_string(p_parameter IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE user_approve(p_auction_header_id  IN NUMBER,
                       p_user_name          IN VARCHAR2);

PROCEDURE user_reject(p_auction_header_id  IN NUMBER,
                      p_user_name          IN VARCHAR2);

PROCEDURE user_forward(p_auction_header_id    IN NUMBER,
                       p_user_name            IN VARCHAR2,
                       p_forwardee_user_name  IN VARCHAR2);

PROCEDURE user_approve_and_forward(p_auction_header_id    IN NUMBER,
                                   p_user_name            IN VARCHAR2,
                                   p_forwardee_user_name  IN VARCHAR2);

END PON_AWARD_APPROVAL_PKG;

 

/
