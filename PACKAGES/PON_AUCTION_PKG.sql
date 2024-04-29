--------------------------------------------------------
--  DDL for Package PON_AUCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUCTION_PKG" AUTHID CURRENT_USER as
/* $Header: PONAUCTS.pls 120.21.12010000.9 2014/04/23 05:49:16 gkuncham ship $ */


PROCEDURE START_AUCTION(p_auction_header_id_encrypted   VARCHAR2,	--  1
			p_auction_header_id		NUMBER,		--  2
			p_trading_partner_contact_name  VARCHAR2,	--  3
	   		p_trading_partner_contact_id	NUMBER,		--  4
		        p_trading_partner_name		VARCHAR2,	--  5
	   		p_trading_partner_id		NUMBER,		--  6
	   		p_open_bidding_date		DATE,		--  7
	  		p_close_bidding_date		DATE,		--  8
			p_award_by_date                 DATE,           --  9
			p_reminder_date                 DATE,           -- 10
			p_bid_list_type			VARCHAR2,	-- 11
	   		p_note_to_bidders		VARCHAR2,	-- 12
			p_number_of_items		NUMBER,		-- 13
			p_auction_title			VARCHAR2,	-- 14
                        p_event_id                      NUMBER);   	-- 15



PROCEDURE START_BID(p_bid_id           		NUMBER,		--  1
		    p_auction_header_id		NUMBER,		--  2
		    p_bid_tp_contact_name		VARCHAR2,	--  3
		    p_auction_tp_name	  	VARCHAR2,	--  4
		    p_auction_open_bidding_date	DATE,		--  5
		    p_auction_close_bidding_date	DATE, 		--  6
		    p_visibility_code		VARCHAR2,	--  7
		    p_item_description		VARCHAR2, 	--  8
		    p_old_price			NUMBER,		--  9
		    p_new_price			NUMBER,		-- 10
		    p_auction_title			VARCHAR2,	-- 11
		    p_oex_operation			VARCHAR2,	-- 12
		    p_oex_operation_url		VARCHAR2);	-- 13


PROCEDURE DISQUALIFY_BID(p_auction_header_id_encrypted   VARCHAR2,      --  1
                         p_bid_id           		NUMBER,		--  2
			 p_auction_header_id		NUMBER,		--  3
			 p_bid_tp_contact_name		VARCHAR2,	--  4
			 p_auction_tp_name   	 	VARCHAR2,	--  5
		         p_auction_title		VARCHAR2,	--  6
	   		 p_disqualify_date 	        DATE,		--  7
			 p_disqualify_reason		VARCHAR2	--  8
			);


PROCEDURE RETRACT_BID(p_bid_id           		NUMBER,		--  1
		      p_auction_header_id		NUMBER,		--  2
		      p_bid_tp_contact_name		VARCHAR2,	--  3
		      p_bid_tp_contact_id		NUMBER,		--  4
		      p_auction_tp_contact_name  	VARCHAR2,	--  5
		      p_auction_tp_contact_id	NUMBER,			--  6
		      p_auction_open_bidding_date	DATE,		--  7
		      p_auction_close_bidding_date	DATE, 		--  8
		      p_oex_operation_url		VARCHAR2);	-- 9



PROCEDURE AWARD_BID(p_bid_id           		   NUMBER,	--  1
		    p_auction_header_id		   NUMBER,	--  2
		    p_bid_tp_contact_name	   VARCHAR2,	--  3
		    p_auction_tp_name       	   VARCHAR2,	--  4
		    p_auction_title		   VARCHAR2,	--  5
		    p_auction_header_id_encrypted  VARCHAR2    --  6
		   );



PROCEDURE UNREGISTERED_BIDDERS(itemtype		in varchar2,
			       itemkey		in varchar2,
			       actid         	in number,
			       uncmode		in varchar2,
			       resultout     	out NOCOPY varchar2);

PROCEDURE REGISTERED_BIDDER(itemtype		in varchar2,
 		            itemkey		in varchar2,
                            actid         	in number,
                            uncmode		in varchar2,
                            resultout     	out NOCOPY varchar2);

PROCEDURE BIDDERS_LIST(itemtype		in varchar2,
		       itemkey		in varchar2,
                       actid         	in number,
                       uncmode		in varchar2,
                       resultout     	out NOCOPY varchar2);


PROCEDURE CREATE_LOCAL_ROLES(itemtype	IN VARCHAR2,
			     itemkey		IN VARCHAR2,
			     actid           IN NUMBER,
			     uncmode	        IN VARCHAR2,
			     resultout       OUT NOCOPY VARCHAR2);

PROCEDURE POPULATE_ROLE_WITH_INVITEES (itemtype		IN VARCHAR2,
			     	       itemkey		IN VARCHAR2,
			     	       actid           	IN NUMBER,
			     	       uncmode	        IN VARCHAR2,
			     	       resultout       	OUT NOCOPY VARCHAR2);

PROCEDURE REACHED_AUCTION_START_DATE(itemtype	IN VARCHAR2,
				     itemkey		IN VARCHAR2,
				     actid           IN NUMBER,
				     uncmode	        IN VARCHAR2,
				     resultout       OUT NOCOPY VARCHAR2);

PROCEDURE REACHED_AUCTION_END_DATE(itemtype	IN VARCHAR2,
				   itemkey		IN VARCHAR2,
				   actid           IN NUMBER,
				   uncmode	        IN VARCHAR2,
				   resultout       OUT NOCOPY VARCHAR2);


PROCEDURE DOES_BIDDER_LIST_EXIT(itemtype	IN VARCHAR2,
				itemkey	IN VARCHAR2,
				actid         IN NUMBER,
				uncmode	in varchar2,
				resultout     out NOCOPY varchar2);

PROCEDURE NON_BID_LIST_BIDDERS(itemtype		in varchar2,
			       itemkey		in varchar2,
			       actid         	in number,
			       uncmode		in varchar2,
			       resultout     	out NOCOPY varchar2);


PROCEDURE NOTIFY_BIDDER_LIST_START(itemtype	in varchar2,
				   itemkey		in varchar2,
				   actid         	in number,
				   uncmode		in varchar2,
				   resultout     	out NOCOPY varchar2);

PROCEDURE NOTIFY_BIDDER_LIST_CANCEL(itemtype	in varchar2,
				    itemkey		in varchar2,
				    actid         	in number,
				    uncmode		in varchar2,
				    resultout     	out NOCOPY varchar2);

PROCEDURE NOTIFY_NON_BIDDER_LIST_CANCEL(itemtype	in varchar2,
					itemkey		in varchar2,
					actid         	in number,
					uncmode		in varchar2,
					resultout     	out NOCOPY varchar2);

PROCEDURE NOTIFY_BIDDER_LIST_END(itemtype	in varchar2,
				 itemkey		in varchar2,
				 actid         	in number,
				 uncmode		in varchar2,
				 resultout     	out NOCOPY varchar2);

PROCEDURE NOTIFY_NON_BIDDER_LIST_END(itemtype	in varchar2,
				     itemkey		in varchar2,
				     actid         	in number,
				     uncmode		in varchar2,
				     resultout     	out NOCOPY varchar2);

PROCEDURE CHECK_AUCTION_BIDDER
          (p_trading_partner_contact_id IN NUMBER,
           p_auction_header_id IN NUMBER,
           x_return_status OUT NOCOPY NUMBER);

PROCEDURE SEALED_BIDS(itemtype	in varchar2,
		      itemkey		in varchar2,
		      actid         	in number,
		      uncmode		in varchar2,
		      resultout     	out NOCOPY varchar2);

PROCEDURE BIDDER_IN_LIST(itemtype	in varchar2,
			 itemkey		in varchar2,
			 actid         	in number,
			 uncmode		in varchar2,
			 resultout     	out NOCOPY varchar2);

PROCEDURE CANCEL_AUCTION(p_auction_header_id	IN NUMBER);

PROCEDURE COMPLETE_AUCTION(p_auction_header_id	IN NUMBER);

-- FPK: CPA Function to check if negotiation has lines or not
FUNCTION NEG_HAS_LINES (p_auction_number IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Oex_Time_Zone return varchar2;
FUNCTION Get_Time_Zone(contact_id number) return varchar2;
FUNCTION Get_Time_Zone(contact_name varchar2) return varchar2;
FUNCTION Get_TimeZone_Description(p_timezone_id varchar2, lang varchar2) return varchar2;

FUNCTION GET_CLOSE_BIDDING_DATE(p_auction_header_id IN NUMBER) RETURN DATE;

FUNCTION TIME_REMAINING_ORDER(p_auction_header_id IN NUMBER) RETURN NUMBER;

FUNCTION TIME_REMAINING_ORDER( p_auction_status      IN VARCHAR2,
                               p_creation_date       IN DATE,
                               p_close_bidding_date  IN DATE,
                               p_is_paused           IN VARCHAR2,
                               p_last_pause_date     IN DATE,
                               p_auction_header_id_orig_round IN NUMBER,
                               p_auction_round_number IN NUMBER,
                               p_amendment_number IN NUMBER) RETURN NUMBER;

FUNCTION TIME_REMAINING(p_auction_header_id IN NUMBER) RETURN VARCHAR2;

FUNCTION TIME_REMAINING(p_auction_header_id IN NUMBER, p_line_number IN NUMBER) RETURN VARCHAR2;

FUNCTION TIME_REMAINING( p_auction_status      IN VARCHAR2,
                         p_open_bidding_date   IN DATE,
                         p_close_bidding_date  IN DATE,
                         p_is_paused           IN VARCHAR2,
                         p_last_pause_date     IN DATE,
                         p_staggered_closing_interval IN NUMBER ) RETURN VARCHAR2;

PROCEDURE AUCTION_OPEN(itemtype	IN VARCHAR2,
		       itemkey		IN VARCHAR2,
		       actid           IN NUMBER,
		       uncmode	        IN VARCHAR2,
		       resultout       OUT NOCOPY VARCHAR2);

PROCEDURE AUCTION_CLOSED(itemtype	IN VARCHAR2,
			 itemkey		IN VARCHAR2,
			 actid           IN NUMBER,
			 uncmode	        IN VARCHAR2,
			 resultout       OUT NOCOPY  VARCHAR2);

Function  getLookupMeaning(lookupType in varchar2,
                          langCode   in varchar2,
                          lookupCode in varchar2) return varchar2;

Function GetPOTotal(p_po_id    IN number) return Number;

Function getNeedByDatesToPrint(auctionID IN number,lineNumber IN number,userDateFormat IN varchar2) return varchar2;

PROCEDURE AUCTION_PO_SEND (
        transaction_code      	IN     VARCHAR2,
        document_id           	IN     NUMBER,
	party_id		IN     NUMBER DEFAULT NULL,
        debug_mode            	IN     PLS_INTEGER DEFAULT 0,
	trigger_id		OUT    NOCOPY 	PLS_INTEGER,
	retcode		        OUT    NOCOPY	PLS_INTEGER,
	errmsg			OUT    NOCOPY	VARCHAR2
);

PROCEDURE SET_NEW_ITEM_KEY(  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out NOCOPY varchar2 );


PROCEDURE EVENT_AUCTION(itemtype		in varchar2,
			itemkey		in varchar2,
			actid         	in number,
			uncmode		in varchar2,
			resultout     	out NOCOPY  varchar2);

PROCEDURE EVENT_AUCTION_ID(itemtype		in varchar2,
			   itemkey		in varchar2,
			   actid         	in number,
			   uncmode		in varchar2,
			   resultout     	out NOCOPY  varchar2);

PROCEDURE EMPTY_CANCEL_REASON(itemtype		in varchar2,
			      itemkey		in varchar2,
			      actid         	in number,
			      uncmode		in varchar2,
			      resultout     	out NOCOPY  varchar2);

PROCEDURE EMPTY_DISQUALIFY_REASON(itemtype		in varchar2,
				  itemkey		in varchar2,
				  actid         	in number,
				  uncmode		in varchar2,
				  resultout     	out NOCOPY  varchar2);

PROCEDURE EMPTY_CLOSECHANGED_REASON(itemtype          in varchar2,
                              itemkey           in varchar2,
                              actid             in number,
                              uncmode           in varchar2,
                              resultout         out NOCOPY  varchar2);

FUNCTION getEventTitle (p_auction_number IN NUMBER) RETURN VARCHAR2;

PROCEDURE NEW_ROUND_BIDDERS_NOT_INVITED(  p_itemtype		in varchar2,
		       			  p_itemkey		in varchar2,
                       			  actid         	in number,
                       			  uncmode		in varchar2,
                       			  resultout     	out NOCOPY  varchar2);


PROCEDURE CLOSEEARLY_AUCTION (p_auction_header_id    IN NUMBER,
                              p_new_close_date       IN DATE,
                              p_closeearly_reason    IN VARCHAR2);

PROCEDURE CLOSECHANGED_AUCTION (p_auction_header_id   IN NUMBER,
                                p_change_type         IN NUMBER,
                                p_new_close_date       IN DATE,
                                p_closechanged_reason   IN VARCHAR2);

PROCEDURE NOTIFY_OTHER_BIDDERS_OF_DISQ(itemtype		in varchar2,
				    	     itemkey		in varchar2,
				    	     actid         	in number,
				    	     uncmode		in varchar2,
				    	     resultout     	out NOCOPY varchar2);

PROCEDURE NOTIFY_BIDDERS_AUC_CHANGED(itemtype		in varchar2,
				     itemkey		in varchar2,
				     actid         	in number,
				     uncmode		in varchar2,
				     action_code         in varchar2);

PROCEDURE NOTIFY_BIDDERS_OF_CANCEL (itemtype		in varchar2,
				    itemkey		in varchar2,
				    actid         	in number,
				    uncmode		in varchar2,
				    resultout     	out NOCOPY varchar2);

PROCEDURE NOTIFY_BIDDERS_OF_CLOSEEARLY (itemtype		in varchar2,
				    itemkey		in varchar2,
				    actid         	in number,
				    uncmode		in varchar2,
				    resultout     	out  NOCOPY varchar2);

PROCEDURE NOTIFY_BIDDERS_OF_CLOSECHANGED (itemtype		in varchar2,
				    itemkey		in varchar2,
				    actid         	in number,
				    uncmode		in varchar2,
				    resultout     	out  nocopy varchar2);

PROCEDURE COMPLETE_PREV_ROUND_WF(p_itemtype            in varchar2,
                         	 p_itemkey             in varchar2,
                             	 actid                 in number,
                             	 uncmode               in varchar2,
                             	 resultout             out NOCOPY  varchar2);

PROCEDURE COMPLETE_PREV_DOC_WF(p_itemtype            in varchar2,
                               p_itemkey             in varchar2,
                               actid                 in number,
                               uncmode               in varchar2,
                               resultout             out NOCOPY  varchar2);

PROCEDURE COMPLETE_PREV_SUPPL_NOTIFS(p_prev_doc_header_id IN NUMBER);

PROCEDURE POPULATE_ROLE_WITH_SUPPLIERS (itemtype         IN VARCHAR2,
                                        itemkey          IN VARCHAR2,
                                        actid            IN NUMBER,
                                        uncmode          IN VARCHAR2,
                                        resultout        OUT NOCOPY VARCHAR2);

FUNCTION getMessage (msg VARCHAR2) RETURN VARCHAR2;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2) RETURN VARCHAR2;

-- FUNCTION getMessage (msg VARCHAR2, token VARCHAR2, token_value VARCHAR2) RETURN VARCHAR2;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token VARCHAR2, token_value VARCHAR2) RETURN VARCHAR2;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2, token1_value VARCHAR2,
		     token2 VARCHAR2, token2_value VARCHAR2) RETURN VARCHAR2;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2, token1_value VARCHAR2,
		     token2 VARCHAR2, token2_value VARCHAR2,
		     token3 VARCHAR2, token3_value VARCHAR2) RETURN VARCHAR2;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2, token1_value VARCHAR2,
		     token2 VARCHAR2, token2_value VARCHAR2, token3 VARCHAR2,
		     token3_value VARCHAR2, token4 VARCHAR2, token4_value VARCHAR2) RETURN VARCHAR2;

FUNCTION getMessage (msg VARCHAR2, msg_suffix VARCHAR2, token1 VARCHAR2, token1_value VARCHAR2,
		     token2 VARCHAR2, token2_value VARCHAR2, token3 VARCHAR2,
		     token3_value VARCHAR2, token4 VARCHAR2, token4_value VARCHAR2,
		     token5 VARCHAR2, token5_value VARCHAR2) RETURN VARCHAR2;

FUNCTION GET_MESSAGE_SUFFIX (x_doctype_group_name VARCHAR2) RETURN VARCHAR2;

FUNCTION EMPTY_REASON (p_reason IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE  NOTIFY_NEW_INVITEES (p_auction_id NUMBER);    -- 1

PROCEDURE NOTIFY_ADDED_INVITEES( x_itemtype            in varchar2,
                         	 x_itemkey             in varchar2,
                             	 actid               in number,
                             	 uncmode             in varchar2,
                             	 resultout           out NOCOPY  varchar2);


PROCEDURE NOTIFY_BIDDER_LIST_REMINDER(itemtype		in varchar2,
				     itemkey		in varchar2,
				     actid         	in number,
				     uncmode		in varchar2,
				     resultout          out nocopy varchar2);

PROCEDURE CLOSEDATE_EARLIER_REMINDERDATE(  itemtype		in varchar2,
		       itemkey		in varchar2,
                       actid         	in number,
                       uncmode		in varchar2,
					   resultout     	out nocopy varchar2);

PROCEDURE UPDATE_ACK_TO_YES(        itemtype		in varchar2,
				     itemkey		in varchar2,
				     actid         	in number,
				     uncmode		in varchar2,
				    resultout          out nocopy varchar2);

PROCEDURE UPDATE_ACK_TO_NO(        itemtype		in varchar2,
				     itemkey		in varchar2,
				     actid         	in number,
				     uncmode		in varchar2,
				     resultout          out nocopy varchar2);

   PROCEDURE launch_init_notif_proc(itemtype IN VARCHAR2,
				    itemkey  IN VARCHAR2,
				    actid    IN NUMBER,
				    uncmode  IN VARCHAR2,
				    resultout OUT NOCOPY VARCHAR2);

   PROCEDURE launch_init_notif_p_add(itemtype IN VARCHAR2,
				    itemkey  IN VARCHAR2,
				    actid    IN NUMBER,
				    uncmode  IN VARCHAR2,
				     resultout OUT NOCOPY VARCHAR2);

      PROCEDURE launch_added_notif_proc(itemtype IN VARCHAR2,
				    itemkey  IN VARCHAR2,
				    actid    IN NUMBER,
				    uncmode  IN VARCHAR2,
				    resultout OUT NOCOPY VARCHAR2);

   PROCEDURE launch_new_round_notif(itemtype IN VARCHAR2,
				    itemkey  IN VARCHAR2,
				    actid    IN NUMBER,
				    uncmode  IN VARCHAR2,
				    resultout OUT NOCOPY VARCHAR2);

      PROCEDURE launch_new_round_notif_add(itemtype IN VARCHAR2,
				    itemkey  IN VARCHAR2,
				    actid    IN NUMBER,
				    uncmode  IN VARCHAR2,
				    resultout OUT NOCOPY VARCHAR2);

PROCEDURE SET_INVITATION_LIST_FLAG(p_auction_header_id	NUMBER);

procedure retrieve_user_info(param1 varchar2);
function getPhoneNumber(p_user_name varchar2) return varchar2;
function getFaxNumber(p_user_name varchar2) return varchar2;
function getEMail(p_user_name varchar2) return varchar2;

function replaceHtmlChars(html_in varchar2) return varchar2;

/*======================================================================
 PROCEDURE :  DELETE_NEGOTIATION_LINE_REF    PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_negotiation_line_num  in      negotiation line number
  x_org_id                in      organization id
  x_error_code            out     internal code for error

 COMMENT   : delete negotiation line references
======================================================================*/
PROCEDURE DELETE_NEGOTIATION_LINE_REF(x_negotiation_id in number,
                                      x_negotiation_line_num in number,
                                      x_org_id   in number,
                                      x_error_code     out NOCOPY  varchar2);
/*======================================================================
 PROCEDURE :  DELETE_NEGOTIATION_REF    PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_error_code            out     internal code for error

 COMMENT   : delete negotiation references
======================================================================*/
PROCEDURE DELETE_NEGOTIATION_REF(x_negotiation_id in  number,
                                 x_error_code     out NOCOPY  varchar2);
/*======================================================================
 PROCEDURE :  CANCEL_NEGOTIATION_REF   PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_error_code            out     internal code for error

 COMMENT   : cancel negotiation references
======================================================================*/
PROCEDURE CANCEL_NEGOTIATION_REF(x_negotiation_id in number,
                                 x_error_code     out NOCOPY  varchar2);
/*======================================================================
 PROCEDURE :  UPDATE_NEGOTIATION_REF   PUBLIC
 PARAMETERS:
  x_old_negotiation_id   in   old auction header id
  x_old_negotiation_num  in   old auction display number
  x_new_negotiation_id   in   new auction header id
  x_new_negotiation_num  in   new auction display number
  x_error_code           out  internal code for error
  x_error_message        out  error message

 COMMENT   : update negotiation references
======================================================================*/
PROCEDURE UPDATE_NEGOTIATION_REF(
    x_old_negotiation_id   in   number,
    x_old_negotiation_num  in   varchar2,
    x_new_negotiation_id   in   number,
    x_new_negotiation_num  in   varchar2,
    x_error_code           out  NOCOPY  varchar2,
    x_error_message        out  NOCOPY  varchar2);
/*======================================================================
 PROCEDURE :  COPY_BACKING_REQ  PUBLIC
 PARAMETERS:
  x_old_negotiation_id   in   old auction header id
  x_new_negotiation_id   in   new auction header id
  x_error_code           out  internal code for error

 COMMENT   : update negotiation references
======================================================================*/
/*======================================================================
 PROCEDURE :  CANCEL_NEGOTIATION_REF_BY_LINE   PUBLIC
 PARAMETERS:
  x_negotiation_id        in      auction header id
  x_negotiation_line_id   in      line number
  x_error_code            out     internal code for error

 COMMENT   : cancel negotiation references
======================================================================*/
PROCEDURE CANCEL_NEGOTIATION_REF_BY_LINE(x_negotiation_id in number,
                                         x_negotiation_line_id in number,
                                         x_error_code     out NOCOPY  varchar2);

PROCEDURE COPY_BACKING_REQ(x_old_negotiation_id in number,
                           x_new_negotiation_id in number,
                           x_error_code         out NOCOPY  varchar2);

PROCEDURE Check_Unique_Wrapper(X_Segment1 In VARCHAR2,
                               X_rowid IN VARCHAR2,
                               X_Type_lookup_code IN VARCHAR2,
							   X_bid_number IN NUMBER,
                               X_Unique OUT NOCOPY  VARCHAR2);

FUNCTION CHECK_UNIQUE_ORDER_NUMBER (p_auction_id IN NUMBER,
                        	    p_order_number IN VARCHAR2,
								p_bid_number IN NUMBER)
RETURN VARCHAR2;


PROCEDURE ACK_NOTIF_RESPONSE(p_wf_item_key VARCHAR2,
                             p_user_name   VARCHAR2,
                             p_supp_ack    VARCHAR2,
                             p_ack_note    VARCHAR2);

PROCEDURE ACK_NOTIF_RESPONSE(p_wf_item_key VARCHAR2,
                             p_user_name   VARCHAR2,
                             p_supp_ack    VARCHAR2,
                             p_ack_note    VARCHAR2,
                             x_return_status OUT NOCOPY NUMBER);

PROCEDURE GET_TIME_REMAINING(p_auction_header_id IN NUMBER, p_time_remaining OUT NOCOPY FLOAT);

function get_product_install_status ( x_product_name in varchar2) RETURN VARCHAR2;

SessionLanguage VARCHAR2(255);

PROCEDURE SET_SESSION_LANGUAGE(p_language VARCHAR2, p_language_code VARCHAR2);

PROCEDURE UNSET_SESSION_LANGUAGE;

FUNCTION GET_TRANSACTION_TYPE (p_doctype_group_name PON_AUC_DOCTYPES.INTERNAL_NAME%TYPE)
  RETURN PON_AUC_DOCTYPES.TRANSACTION_TYPE%TYPE;

procedure getTriangulationRate(toCurrency varchar2,
                              fromCurrency varchar2,
                              rateDate date,
                              rateType varchar2,
                              rollDays number,
                              rate out nocopy number);

function getClosestRate(fromCurrency varchar2,toCurrency varchar2, conversionDate date, conversionType varchar2, maxRollDays number) return varchar2;

PROCEDURE DELETE_NEGOTIATION_AMENDMENTS (
    x_negotiation_id        in   number,
    x_error_code            out  NOCOPY varchar2);


FUNCTION GET_MOST_RECENT_AMENDMENT(p_auction_header_id IN NUMBER) RETURN NUMBER;

FUNCTION GET_MEMBER_TYPE(p_auction_header_id IN NUMBER,p_user_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE get_default_hdr_pb_settings (p_doctype_id IN NUMBER,
                                       p_tp_id IN NUMBER,
                                       x_price_break_response OUT NOCOPY VARCHAR2);

PROCEDURE get_default_pb_settings (p_auction_header_id IN NUMBER,
                                   x_price_break_type OUT NOCOPY VARCHAR2,
                                   x_price_break_neg_flag OUT NOCOPY VARCHAR2);

FUNCTION getPAOUInstalled (p_orgId IN NUMBER) RETURN VARCHAR2;

FUNCTION getGMSOUInstalled ( p_orgId IN NUMBER) RETURN VARCHAR2;

PROCEDURE  IS_NEGOTIATION_REQ_BACKED(
				       p_auction_header_id   IN        NUMBER,
				       x_req_backed          OUT NOCOPY VARCHAR2) ;

/*=======================================================================+
-- 12.0 Enhancement
-- SEND_TASK_ASSIGN_NOTIF procedure will be responsible to send
-- Notification to the given Collaboration Team Member
-- as requested by Negotiation Creator.
-- Parameter :
--
--           p_auction_header_id IN     NUMBER,
--           p_user_id           IN     NUMBER,
--           x_return_status     OUT NOCOPY VARCHAR2
+=========================================================================*/

PROCEDURE SEND_TASK_ASSIGN_NOTIF (p_auction_header_id IN     NUMBER,
                                  p_user_id           IN     NUMBER,
                                  x_return_status     OUT NOCOPY VARCHAR2);

/*=======================================================================+
-- 12.0 Enhancement
-- SEND_RESP_NOTIF procedure will be responsible for
-- sending notification to the Buyer when a Seller
-- submits a Response.
-- Parameter :
--            p_bid_number               IN NUMBER,
--            x_return_status            OUT NOCOPY VARCHAR2
--
+=========================================================================*/

PROCEDURE SEND_RESP_NOTIF ( p_bid_number               IN NUMBER,
                           x_return_status             OUT NOCOPY VARCHAR2);


/*=========================================================================+
-- 12.0 Enhancement
-- SEND_MSG_SENT_NOTIF procedure will be responsible for
-- sending notification to the Buyer when a Seller sends
-- a message to Buyer or a Buyer sends an internal message
-- to other Collaboration Team Members
-- Parameter :
--          p_toFirstName       IN VARCHAR2
--          p_toLastName        IN VARCHAR2
--          p_toCompanyName     IN VARCHAR2
--          p_toCompanyId       IN NUMBER
--          p_fromFirstName     IN VARCHAR2
--          p_fromLastName      IN VARCHAR2
--          p_fromCompanyName   IN VARCHAR2
--          p_fromCompanyId     IN NUMBER
--          p_creatorCompanyId  IN NUMBER
--          p_userPartyId       IN NUMBER
--          p_entryid           IN NUMBER
--          p_message_type      IN VARCHAR2
--          x_return_status     OUT NOCOPY VARCHAR2
--
+=========================================================================*/

PROCEDURE SEND_MSG_SENT_NOTIF(
          p_toFirstName      IN VARCHAR2,
          p_toLastName       IN VARCHAR2,
          p_toCompanyName    IN VARCHAR2,
          p_toCompanyId      IN NUMBER,
          p_fromFirstName    IN VARCHAR2,
          p_fromLastName     IN VARCHAR2,
          p_fromCompanyName  IN VARCHAR2,
          p_fromCompanyId    IN NUMBER,
          p_creatorCompanyId IN NUMBER,
          p_userPartyId      IN NUMBER,
          p_entryid          IN NUMBER,
          p_message_type     IN VARCHAR2,
          x_return_status    OUT NOCOPY VARCHAR2
        );

/*=========================================================================+
-- 12.0 Enhancement
-- SEND_TASK_COMPL_NOTIF procedure will be responsible
-- for sending notification from the Buyer user to the
-- Negotiation Creator when the former completes a given
-- task for a Collaboration Team Member.
-- Parameter :
--             p_auction_header_id IN NUMBER,
--             p_user_id           IN NUMBER,
--             x_return_status     OUT NOCOPY VARCHAR2)
+=========================================================================*/

PROCEDURE SEND_TASK_COMPL_NOTIF ( p_auction_header_id IN NUMBER,
                                  p_user_id           IN NUMBER,
                                  x_return_status     OUT NOCOPY VARCHAR2);

/*=========================================================================+
--
-- 12.0 Enhancement
-- IS_NOTIF_SUBSCRIBED  is a wrapper over the GET_NOTIF_PREFERENCE
-- of PON_WF_UTL_PKG. It will call the procedure GET_NOTIF_PREFERENCE with
-- appropriate message type and auction header id.
--
-- Parameter :
--             itemtype  IN VARCHAR2
--             itemkey   IN VARCHAR2
--             actid     IN NUMBER
--	       funcmode  IN VARCHAR2
--	       resultout OUT NOCOPY VARCHAR2
--
+=========================================================================*/


PROCEDURE IS_NOTIF_SUBSCRIBED(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out NOCOPY varchar2);

/*=========================================================================+
--
-- 12.0 Enhancement
-- GET_MAPPED_IP_CATEGORY takes in a po category id as a parameter and
-- returns an ip category if mapping exists else returns -2
--
--
-- Parameter :
--             p_po_category_id  IN NUMBER
--
+=========================================================================*/


FUNCTION GET_MAPPED_IP_CATEGORY(p_po_category_id  IN NUMBER) return NUMBER;

/*=========================================================================+
--
-- 12.0 Enhancement
-- GET_MAPPED_PO_CATEGORY takes in an ip category id as a parameter and
-- returns a po category if mapping exists else returns -2
--
--
-- Parameter :
--             p_ip_category_id  IN NUMBER
--
+=========================================================================*/


FUNCTION GET_MAPPED_PO_CATEGORY(p_ip_category_id  IN NUMBER) return NUMBER;



PROCEDURE GET_NEGOTIATION_DETAILS( p_auction_header_id            NUMBER,
                                   p_user_trading_partner_id      NUMBER,
                                   x_time_left                    OUT NOCOPY VARCHAR2,
                                   x_buyer_display                OUT NOCOPY VARCHAR2,
                                   x_carrier                      OUT NOCOPY VARCHAR2,
                                   x_unlocked_by_display          OUT NOCOPY VARCHAR2,
                                   x_unsealed_by_display          OUT NOCOPY VARCHAR2,
                                   x_has_active_company_bid       OUT NOCOPY VARCHAR2,
                                   x_is_multi_site                OUT NOCOPY VARCHAR2,
                                   x_all_site_bid_on              OUT NOCOPY VARCHAR2,
                                   x_is_paused                    OUT NOCOPY VARCHAR2,
                                   x_outcome_display              OUT NOCOPY VARCHAR2,
                                   x_advances_flag                OUT NOCOPY VARCHAR2,
                                   x_retainage_flag               OUT NOCOPY VARCHAR2,
                                   x_payment_rate_rype_enabled    OUT NOCOPY VARCHAR2
                                 );

---------------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Countdown Clock Project (adsahay)
--
--      Start of comments
--      API Name:               SHOW_COUNTDOWN
--      Function:               Given an auction id, returns "Y" if the auction is active or paused and
--                              closing within next 24 hours. Auctions that are in preview mode,
--                              cancelled or amended, or closing in more than 24 hours return "N".
--      Parameters:
--      IN:     p_auction_header_id IN NUMBER           - Auction header id
--      OUT:    x_return_status OUT NOCOPY VARCHAR2     - Return status
--              x_error_code OUT NOCOPY VARCHAR2        - Error code
--              x_error_message OUT NOCOPY VARCHAR2     - Error message
--
--      End of Comments
--      Return : l_show_countdown VARCHAR2
----------------------------------------------------------------------------------------

FUNCTION SHOW_COUNTDOWN(x_result OUT NOCOPY VARCHAR2,
                        x_error_code OUT NOCOPY VARCHAR2,
                        x_error_message OUT NOCOPY VARCHAR2,
                        p_auction_header_id in NUMBER) return VARCHAR2;

-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Countdown Clock Project (adsahay)
--
--      Start of comments
--      API Name:       HAS_DISTINCT_CLOSING_LINES
--      Function:       Given an auction id, Returns 'Y' if the auction has lines
--                      closing in different times, else 'N'. This means that either the auction is
--                      staggered or has "auto extend" feature enabled such that it extends one line
--                      instead of all lines.
--
--      Parameters:
--      IN:     p_auction_header_id IN NUMBER   - The auction header id
--      OUT:    x_return_status OUT NOCOPY VARCHAR2     - Return status
--              x_error_code OUT NOCOPY VARCHAR2        - Error code
--              x_error_message OUT NOCOPY VARCHAR2     - Error message
--
--      End of Comments
--
--      Return : l_flag VARCHAR2
------------------------------------------------------------------------------------

FUNCTION HAS_DISTINCT_CLOSING_DATES(x_result OUT NOCOPY VARCHAR2,
                        x_error_code OUT NOCOPY VARCHAR2,
                        x_error_message OUT NOCOPY VARCHAR2,
                        p_auction_header_id in NUMBER) return VARCHAR2;

-------------------------------------------------------------------------------------
--	R12 Rollup1 Enhancement - Two Part RFQ project (adsahay)
--
--	Two global variables two allow caching of the meanings of TECHNICAL
--	and COMMERCIAL, along with their getters.
--      Three global variables to store supplier attachment category names.
-------------------------------------------------------------------------------------

g_technical_attachment fnd_document_categories.name%TYPE := 'FromSupplierTechnical';
g_commercial_attachment fnd_document_categories.name%TYPE := 'FromSupplierCommercial';
g_supplier_attachment fnd_document_categories.name%TYPE := 'FromSupplier';

-- bug 6374353
-- create temporary table to store language and meanings of TECHNICAL and COMMERCIAL.
type two_part_cache_rec is record(
        language fnd_lookup_values.language%TYPE,
        technical_meaning fnd_lookups.meaning%TYPE,
        commercial_meaning fnd_lookups.meaning%TYPE
);
type g_tp_cache_type is table of two_part_cache_rec index by BINARY_INTEGER;
g_two_part_cache g_tp_cache_type;

-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Two Part RFQ Project (adsahay)
--
--      Start of comments
--      API Name:       GET_TECHNICAL_MEANING
--      Function:       Returns meaning of 'TECHNICAL' from lookups.
--
--      Parameters:
--      IN:
--      OUT:
--
--      End of Comments
--
--      Return : g_technical_meaning VARCHAR2
------------------------------------------------------------------------------------
FUNCTION get_technical_meaning RETURN VARCHAR2;


-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Two Part RFQ Project (adsahay)
--
--      Start of comments
--      API Name:       GET_COMMERCIAL_MEANING
--      Function:       Returns meaning of 'COMMERCIAL' from lookups.
--
--      Parameters:
--      IN:
--      OUT:
--
--      End of Comments
--
--      Return : g_commercial_meaning VARCHAR2
------------------------------------------------------------------------------------
FUNCTION get_commercial_meaning RETURN VARCHAR2;

-----------------------------------------------------------------------------------
--      R12 Rollup1 Enhancement - Two Part RFQ Project (adsahay)
--
--      Start of comments
--      API Name:       NOTIFY_BIDDERS_TECH_COMPLETE
--      Procedure:      Notify bidders that their bids have/have not been short listed
--			in technical evaluation.
--
--      Parameters:
--      IN:    		p_auction_header_id IN NUMBER - The auction header id.
--      OUT:     	x_return_status OUT NOCOPY VARCHAR2     - Return status
--              	x_error_code OUT NOCOPY VARCHAR2        - Error code
--              	x_error_message OUT NOCOPY VARCHAR2     - Error message
--
--      End of Comments
------------------------------------------------------------------------------------
PROCEDURE notify_bidders_tech_complete(x_return_status OUT NOCOPY VARCHAR2,
					x_error_code OUT NOCOPY VARCHAR2 ,
					x_error_message OUT NOCOPY VARCHAR2,
					p_auction_header_id IN NUMBER);

/*======================================================================
 FUNCTION :  GET_AUCTION_STATUS_DISPLAY   PUBLIC
 PARAMETERS:
  p_auction_header_id        in      auction header id
  p_user_trading_partner_id   in     trading partner id of the user
                                     currently running the application
 COMMENT   : Returns the negotiation status that has to be displayed to the user.
            This function will be used in the select lists of various VOs that need
            to query auction status
======================================================================*/
FUNCTION GET_AUCTION_STATUS_DISPLAY(
      p_auction_header_id IN pon_auction_headers_all.AUCTION_HEADER_ID%TYPE,
      p_user_trading_partner_id IN pon_auction_headers_all.TRADING_PARTNER_ID%TYPE) RETURN VARCHAR2;

/*======================================================================
 FUNCTION :  GET_MONITOR_IMAGE_AND_STATUS   PUBLIC
 PARAMETERS:

p_auction_header_id       IN  header id of teh auction
p_doctype_id              IN  the document type id of the negotiation
p_bid_visibility          IN  bid visibility
p_sealed_auction_status   IN  sealed status of the negotiation
p_auctioneer_id           IN  id of the negotiation creator
p_viewer_id               IN  id of the person view the negotiation
p_has_items               IN  flag to indicate the existence of lines
p_doc_type                IN  document type of the negotiation
p_auction_status          IN  the auction status
p_view_by_date            IN
p_open_bidding_date       IN  The date on which bidding starts
p_has_scoring_teams_flag  IN  flag to indicate existence of scoring teams
p_user_trading_partner_id IN  the trading partner id of the user
x_buyer_monitor_image     OUT the image that should be used for monitor auction icons
x_auction_status_display  OUT the auction status for display

COMMENT   : This procedure will be used in the getters of the Monitor Image attributs
            of various VOs. The procedures calls the existing PON_OA_UTIL_PKG.BUYER_MONITOR_IMAGE
            and GET_AUCTION_STATUS_DISPLAY at one go and returns the image and status together to the middle
            tier. this is done to improve the efficiency of the code and avoid multiple jdbc calls,
            one for the image and the other for the auction status.
======================================================================*/
PROCEDURE GET_MONITOR_IMAGE_AND_STATUS(
      p_auction_header_id     IN NUMBER,
      p_doctype_id IN NUMBER,
      p_bid_visibility         IN VARCHAR2,
      p_sealed_auction_status  IN VARCHAR2,
      p_auctioneer_id          IN NUMBER,
      p_viewer_id              IN NUMBER,
      p_has_items              IN VARCHAR2,
      p_doc_type               IN VARCHAR2,
      p_auction_status         IN VARCHAR2,
      p_view_by_date           IN DATE,
      p_open_bidding_date      IN DATE,
      p_has_scoring_teams_flag IN VARCHAR2,
      p_user_trading_partner_id IN NUMBER,
      x_buyer_monitor_image OUT NOCOPY  VARCHAR2,
      x_auction_status_display OUT NOCOPY VARCHAR2);

--========================================================================
-- PROCEDURE : GET_NEGOTIATION_STATUS
-- PARAMETERS:
--             p_auction_status - The auction_status column
--             p_is_paused - is_paused column
--             p_view_by_date - view_by_date column
--             p_open_bidding_date - open_bidding_date column
--             p_close_bidding_date - close_bidding_date column
--             p_award_status - award_status column
--             p_award_approval_status - award_approval_status column
--             p_outcome_status - outcome_status column
--
-- COMMENT   : This procedure will be used in the pon_auction_headers_all_v
--             view to get the value for the negotiation_status
--             column in the view. Prior to the use of this function the
--             same code existed as decodes in the view itself.
--========================================================================
FUNCTION GET_NEGOTIATION_STATUS (
  p_auction_status VARCHAR2,
  p_is_paused VARCHAR2,
  p_view_by_date DATE,
  p_open_bidding_date DATE,
  p_close_bidding_date DATE,
  p_award_status VARCHAR2,
  p_award_approval_status VARCHAR2,
  p_outcome_status VARCHAR2
) RETURN VARCHAR2;

--========================================================================
-- PROCEDURE : GET_SUPPL_NEGOTIATION_STATUS
-- PARAMETERS:
--             p_auction_status - The auction_status column
--             p_is_paused - is_paused column
--             p_view_by_date - view_by_date column
--             p_open_bidding_date - open_bidding_date column
--             p_close_bidding_date - close_bidding_date column
--
-- COMMENT   : This procedure will be used in the pon_auction_headers_all_v
--             view to get the value for the suppl_negotiation_status
--             column in the view. Prior to the use of this function the
--             same code existed as decodes in the view itself.
--========================================================================
FUNCTION GET_SUPPL_NEGOTIATION_STATUS (
  p_auction_status IN VARCHAR2,
  p_is_paused IN VARCHAR2,
  p_view_by_date IN DATE,
  p_open_bidding_date IN DATE,
  p_close_bidding_date IN DATE
) RETURN VARCHAR2;

/*============================================================================================================*
 * PROCEDURE : GET_DEFAULT_TIERS_INDICATOR                                                                    *
 * PARAMETERS:                                                                                                *
 *             p_contract_type - outcome of the negotiation                                                   *
 *             p_price_breaks_enabled - to indicate if price breaks are applicable as per po style            *
 *             p_qty_price_tiers_enabled - to indicate if price tiers are applicable as per neg style         *
 *             p_doctype_id - document type id of the negotiation                                             *
 *             x_price_tiers_indicator - default price tiers indicator value.                                 *
 *                                                                                                            *
 * COMMENT   : This procedure will be used in getting the default  price tier indicator value.                *
 *             It's used in plsql routines where new negotiation created from autocreation and renegotiation. *
 *             The logic is same as AuctionHeadersAllEO.getPriceTiersPoplist. Only difference is that we      *
 *             don't have to return the poplist here. So few conditions where default values is same can be   *
 *             clubbeb together.                                                                              *
 * ===========================================================================================================*/
PROCEDURE GET_DEFAULT_TIERS_INDICATOR (
  p_contract_type                   IN VARCHAR2,
  p_price_breaks_enabled            IN VARCHAR2,
  p_qty_price_tiers_enabled         IN VARCHAR2,
  p_doctype_id                      IN NUMBER,
  x_price_tiers_indicator           OUT NOCOPY VARCHAR2
) ;

------------------------------------------------------------------------------
--Start of Comments
-- Bug Number: 8446265
--Procedure:
--  It returns the tokens replaced FND message to Notification Message Body
--Procedure Usage:
--  It is being used to replace the workflow message Body by FND Message & its tokens
-- Procedures newly introduced:
-- 1. GEN_PON_DSQBID_BODY
-- 2. GEN_PON_ARI_UNINVITED_BODY
-- 3. GEN_AWARD_LINES_BODY
-- 4. GEN_AWARD_NOLINES_BODY
-- 5. GEN_AWARD_EVENT_LINES_BODY
-- 6. GEN_AWARD_EVENT_NOLINES_BODY
-- 7. GEN_AUC_AMEND_BODY
-- 8. GEN_INVITE_REQ_SUPP_RESP_BODY
-- 9. GEN_INVITE_CONT_RESP_BODY
-- 10. GEN_INVITE_ADD_CONT_RESP_BODY
-- 11. GEN_INV_NEWRND_START_BODY
-- 12. GEN_INV_NEWRND_START_AD_BODY
--Parameters:
--  itemtype, itemkey
--IN:
--  itemtype, item key
--OUT:
--  document
--End of Comments
------------------------------------------------------------------------------
--Bug 8446265 modification starts
PROCEDURE GEN_PON_DSQBID_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_PON_ARI_UNINVITED_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_AWARD_LINES_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_AWARD_NOLINES_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_AWARD_EVENT_LINES_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_AWARD_EVENT_NOLINES_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_AUC_AMEND_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_INVITE_REQ_SUPP_RESP_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);


PROCEDURE GEN_INVITE_CONT_RESP_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);



PROCEDURE GEN_INVITE_ADD_CONT_RESP_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);



PROCEDURE GEN_INV_NEWRND_START_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);



PROCEDURE GEN_INV_NEWRND_START_AD_BODY(p_document_id    IN VARCHAR2,
        			       display_type     IN VARCHAR2,
			               document         IN OUT NOCOPY CLOB,
			               document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GET_DISCUSSION_MESG_BODY
  (
    p_document_id	in	varchar2,
    display_type	in	varchar2,
    document	in out	NOCOPY CLOB,
    document_type	in out	NOCOPY varchar2
  );

--Bug 8446265 modification ends
 -- Added for the bug#8847938 to remove the space as delimitter in user name

 	 procedure string_to_userTable(p_UserList  in VARCHAR2,
 	                                         p_UserTable out NOCOPY WF_DIRECTORY.UserTable);

-- Begin Supplier Management: Bug 9222914
PROCEDURE SYNC_BID_HEADER_ATTACHMENTS(p_auction_header_id IN NUMBER);
-- END Supplier Management: Bug 9222914

-- Begin Supplier Management: Bug 10378806 / 11071755
PROCEDURE GEN_REQ_SUPP_AUC_AMEND_BODY(p_document_id    IN VARCHAR2,
                                      display_type     IN VARCHAR2,
                                      document         IN OUT NOCOPY CLOB,
                                      document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_INV_REQ_SUPP_NEWRND_BODY(p_document_id    IN VARCHAR2,
                                       display_type     IN VARCHAR2,
                                       document         IN OUT NOCOPY CLOB,
                                       document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE IS_SM_ENABLED(itemtype     IN VARCHAR2,
                        itemkey      IN VARCHAR2,
                        actid        IN NUMBER,
                        funcmode     IN VARCHAR2,
                        resultout    OUT NOCOPY VARCHAR2);
-- End Supplier Management: Bug 10378806 / 11071755

-- bug#16690631 for surrogate quote enhancement
PROCEDURE CHECK_NOTIFY_USER_INFO(p_user_name IN VARCHAR2,
                                 p_trading_partner_contact_id IN NUMBER,
                                 x_user_name OUT NOCOPY VARCHAR2);

--bug#18097527 fix
PROCEDURE GEN_AUC_AMEND_BODY_PROSP_SUPP(p_document_id    IN VARCHAR2,
                                      display_type     IN VARCHAR2,
                                      document         IN OUT NOCOPY CLOB,
                                      document_type    IN OUT NOCOPY VARCHAR2);

PROCEDURE GEN_INV_NEWRND_BODY_PROSP_SUPP(p_document_id    IN VARCHAR2,
                                      display_type     IN VARCHAR2,
                                      document         IN OUT NOCOPY CLOB,
                                      document_type    IN OUT NOCOPY VARCHAR2);

END PON_AUCTION_PKG;

/

  GRANT EXECUTE ON "APPS"."PON_AUCTION_PKG" TO "REPORT_TESTER";
  GRANT EXECUTE ON "APPS"."PON_AUCTION_PKG" TO "P1MSTR";
