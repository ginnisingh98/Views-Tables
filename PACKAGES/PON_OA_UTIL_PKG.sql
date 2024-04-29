--------------------------------------------------------
--  DDL for Package PON_OA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_OA_UTIL_PKG" AUTHID CURRENT_USER as
/* $Header: PONOAUTS.pls 120.6 2007/05/24 09:20:48 mshujath ship $ */


/*======================================================================
 FUNCTION :  MONITOR    PUBLIC
 PARAMETERS:
  p_doctype_id            IN        document type id
  p_bid_visibility        IN        bid visibility
  p_sealed_auction_status IN        sealed auction status
  p_auctioneer_id         IN        auctioneer trading partner id
  p_viewer_id             IN        viewer trading partner id
  p_startdate             IN        auction start date
  p_has_items             IN        has Items Flag for negotiation

 COMMENT   : check if monitor icon should be active or not
======================================================================*/

FUNCTION MONITOR (p_doctype_id IN NUMBER,
                  p_bid_visibility IN VARCHAR2,
		  p_sealed_auction_status IN VARCHAR2,
                  p_auctioneer_id  IN NUMBER,
                  p_viewer_id IN NUMBER,
                  p_startdate IN DATE DEFAULT NULL,
                  p_has_items IN VARCHAR2) RETURN VARCHAR2;

/*======================================================================
 FUNCTION :  BUYER_MONITOR    PUBLIC
 PARAMETERS:
  p_doctype_id            IN        document type id
  p_bid_visibility        IN        bid visibility
  p_sealed_auction_status IN        sealed auction status
  p_auctioneer_id         IN        auctioneer trading partner id
  p_viewer_id             IN        viewer trading partner id
  p_has_items             IN        has Items Flag for negotiation
  p_doc_type              IN        Type of the negotiation(RFI,RFQ,AUCTION)
  p_auction_status        IN        Status of the auction
  p_view_by_date          IN        Preview date of the auction
  p_open_bidding_date     IN        Open bidding date of the negotiation
  p_auction_header_id	  IN		Auction Header Id
  p_has_scoring_teams_flag  IN		If auction has scoring teams

 COMMENT   : check if monitor icon should be active or not for buyer homepage and search page
======================================================================*/
FUNCTION BUYER_MONITOR (p_doctype_id      IN NUMBER,
                  p_bid_visibility        IN VARCHAR2,
        		  p_sealed_auction_status IN VARCHAR2,
                  p_auctioneer_id         IN NUMBER,
                  p_viewer_id             IN NUMBER,
                  p_has_items             IN VARCHAR2,
                  p_doc_type              IN VARCHAR2,
                  p_auction_status        IN VARCHAR2,
                  p_view_by_date          IN DATE,
                  p_open_bidding_date     IN DATE,
				  p_auction_header_id     IN NUMBER,
				  p_has_scoring_teams_flag IN VARCHAR2) RETURN VARCHAR2;

/*======================================================================
 FUNCTION :  MONITOR_IMAGE    PUBLIC
 PARAMETERS:
  p_doctype_id            IN        document type id
  p_bid_visibility        IN        bid visibility
  p_sealed_auction_status IN        sealed auction status
  p_auctioneer_id         IN        auctioneer trading partner id
  p_viewer_id             IN        viewer trading partner id
  p_startdate             IN        auction start date
  p_has_items             IN        has Items Flag for negotiation


 COMMENT   : return the monitor image name, either 'MonitorActive'
             or 'MonitorInactive'
======================================================================*/

FUNCTION MONITOR_IMAGE (p_doctype_id IN NUMBER,
                  p_bid_visibility IN VARCHAR2,
		  p_sealed_auction_status IN VARCHAR2,
                  p_auctioneer_id  IN NUMBER,
                  p_viewer_id IN NUMBER,
                  p_startdate IN DATE DEFAULT NULL,
                  p_has_items IN VARCHAR2) RETURN VARCHAR2;

/*======================================================================
 FUNCTION :  BUYER_MONITOR_IMAGE    PUBLIC
 PARAMETERS:
  p_doctype_id            IN        document type id
  p_bid_visibility        IN        bid visibility
  p_sealed_auction_status IN        sealed auction status
  p_auctioneer_id         IN        auctioneer trading partner id
  p_viewer_id             IN        viewer trading partner id
  p_has_items             IN        has Items Flag for negotiation
  p_doc_type              IN        Type of the negotiation(RFI,RFQ,AUCTION)
  p_auction_status        IN        Status of the auction
  p_view_by_date          IN        Preview date of the auction
  p_open_bidding_date     IN        Open bidding date of the negotiation
  p_auction_header_id	  IN		Auction Header Id
  p_has_scoring_teams_flag  IN		If auction has scoring teams

 COMMENT   : return the monitor image name, either 'MonitorActive'
             or 'MonitorInactive'
             In OA 5.6, we use switcher bean to implement monitor column.
             In OA 5.7, we can just use a simple region item.
======================================================================*/
FUNCTION BUYER_MONITOR_IMAGE (p_doctype_id IN NUMBER,
                  p_bid_visibility         IN VARCHAR2,
		          p_sealed_auction_status  IN VARCHAR2,
                  p_auctioneer_id          IN NUMBER,
                  p_viewer_id              IN NUMBER,
                  p_has_items              IN VARCHAR2,
                  p_doc_type               IN VARCHAR2,
                  p_auction_status         IN VARCHAR2,
                  p_view_by_date           IN DATE,
                  p_open_bidding_date      IN DATE,
				  p_auction_header_id     IN NUMBER,
				  p_has_scoring_teams_flag IN VARCHAR2) RETURN VARCHAR2;
/*======================================================================
 FUNCTION :  DICUSSION_URL    PUBLIC
 PARAMETERS:
  p_auction_id            IN        auction header id
  p_viewer_party_id       IN        viewer's trading partner id
  p_app                   IN        app name
  p_subtab_pos            IN        subtab position

 COMMENT   : returns javascript for discussion icon
======================================================================*/

FUNCTION DISCUSSION_URL (p_auction_id IN NUMBER,
                         p_viewer_party_id IN NUMBER,
                         p_app IN VARCHAR2,
                         p_subtab_pos IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  TIME_REMAINING_CLOSE_DATE   PUBLIC
 PARAMETERS:
  p_startdate            IN        auction start date
  p_enddate              IN        auction end date
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format

 COMMENT   : returns html formatted string of time remaining and close date
======================================================================*/
/*
FUNCTION TIME_REMAINING_CLOSE_DATE(p_startdate IN DATE DEFAULT NULL,
                        p_enddate IN DATE DEFAULT NULL,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2) RETURN VARCHAR2;
*/
/*======================================================================
 FUNCTION :  TIME_REMAINING_CLOSE_DATE_NOTZ   PUBLIC
 PARAMETERS:
  p_startdate            IN        auction start date
  p_enddate              IN        auction end date
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format


 COMMENT   : returns html formatted string of time remaining and close date
             without timezone at end
======================================================================*/
/*
FUNCTION TIME_REMAINING_CLOSE_DATE_NOTZ(p_startdate IN DATE DEFAULT NULL,
                        p_enddate IN DATE DEFAULT NULL,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2) RETURN VARCHAR2;
*/

/*======================================================================
 FUNCTION :  GET_TIMEZONE_DISP   PUBLIC
 PARAMETERS:
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id


 COMMENT   : returns timezone to display
======================================================================*/

FUNCTION GET_TIMEZONE_DISP(p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2) RETURN VARCHAR2;



/*======================================================================
 FUNCTION :  TIME_REMAINING_SLASH_CLOSE   PUBLIC
 PARAMETERS:
  p_startdate            IN        auction start date
  p_enddate              IN        auction end date
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format
  p_days_string		 IN	   translated 'PON_AUCTION_DAYS'
  p_day_string 		 IN 	   translated 'PON_AUCTION_DAY'
  p_hours_string	 IN	   translated 'PON_AUCTION_HOURS'
  p_hour_string		 IN 	   translated 'PON_AUCTION_HOUR'
  p_minutes_string	 IN	   translated 'PON_AUCTION_MINUTES'
  p_minute_string	 IN	   translated 'PON_AUCTION_MINUTE'

 COMMENT   : returns html formatted string of time remaining and close date
======================================================================*/
/*
FUNCTION TIME_REMAINING_SLASH_CLOSE(
			p_startdate IN DATE DEFAULT NULL,
                        p_enddate IN DATE DEFAULT NULL,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2,
			p_days_string IN VARCHAR2,
			p_day_string IN VARCHAR2,
			p_hours_string IN VARCHAR2,
			p_hour_string IN VARCHAR2,
			p_minutes_string IN VARCHAR2,
			p_minute_string IN VARCHAR2) RETURN VARCHAR2;
*/
/*======================================================================
 FUNCTION :  TIME_REMAINING_SLASH_CLOSE   PUBLIC
 PARAMETERS:
  p_startdate            IN        auction start date
  p_enddate              IN        auction end date
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format

 COMMENT   : returns html formatted string of time remaining and close date
======================================================================*/
/*
FUNCTION TIME_REMAINING_SLASH_CLOSE(
			p_startdate IN DATE DEFAULT NULL,
                        p_enddate IN DATE DEFAULT NULL,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2) RETURN VARCHAR2;
*/
/*======================================================================
 FUNCTION :  DISPLAY_DATE_TIME   PUBLIC
 PARAMETERS:
  p_date                 IN        a date value
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format
  p_display_timzezone    IN        whether to display time zone

 COMMENT   : returns date and time converted to client time zone
             assumes the passed in date is in server time zone
======================================================================*/

FUNCTION DISPLAY_DATE_TIME(p_date IN DATE DEFAULT NULL,
                           p_client_timezone_id IN VARCHAR2,
                           p_server_timezone_id IN VARCHAR2,
                           p_date_format IN VARCHAR2,
			   p_display_timezone IN VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2;

/*======================================================================
 FUNCTION :  RESPONSE_VIEWMORENEGS   PUBLIC
 PARAMETERS:
  p_auctioneer_id         IN    auctioneer trading partner id
  p_viewer_tp_id          IN    viewer trading partner id,
  p_query_type            IN    query type
  p_number_of_bids        IN    number of bids
  p_bid_visibility        IN    bid visibility code
  p_sealed_auction_status IN    sealed auction status

 COMMENT   : calculates value for response column in view more negotiations
             page
======================================================================*/

FUNCTION RESPONSE_VIEWMORENEGS (p_auctioneer_id IN NUMBER,
                   p_viewer_tp_id IN  NUMBER,
                   p_query_type IN VARCHAR2,
		   p_number_of_bids IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  RESPONSE_VIEWAUCTIONS   PUBLIC
 PARAMETERS:
  p_auctioneer_id         IN    auctioneer trading partner id
  p_viewer_tp_id          IN    viewer trading partner id,
  p_number_of_bids        IN    number of bids
  p_bid_visibility        IN    bid visibility code
  p_sealed_auction_status IN    sealed auction status

 COMMENT   : calculates value for response column in view auctions page
======================================================================*/

FUNCTION RESPONSE_VIEWAUCTIONS (p_auctioneer_id IN NUMBER,
                   p_viewer_tp_id IN  NUMBER,
		   p_number_of_bids IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  RESPONSE_VIEWACTIVEBIDS   PUBLIC
 PARAMETERS:
  p_auction_id            IN    auction header id
  p_auction_status        IN    auction status
  p_auctioneer_id         IN    auctioneer trading partner id
  p_viewer_tp_id          IN    viewer trading partner id,
  p_viewer_tpc_id         IN    viewer trading partner contact id,
  p_bid_visibility        IN    bid visibility code
  p_sealed_auction_status IN    sealed auction status
  p_bidStatus             IN    bid status
  p_bidder_tpc_id         IN    bidder trading partner contact id

 COMMENT   : calculates value for number of bids column in the ViewActiveBids page
======================================================================*/

FUNCTION RESPONSE_VIEWACTIVEBIDS (p_auction_id IN NUMBER,
                   p_auction_status IN VARCHAR2,
                   p_auctioneer_id IN NUMBER,
                   p_viewer_tp_id IN  NUMBER,
                   p_viewer_tpc_id IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
		   p_sealed_auction_status IN VARCHAR2,
                   p_bidStatus IN VARCHAR2,
                   p_bidder_tpc_id IN NUMBER) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  NUMBIDS_VIEWACTIVEBIDS   PUBLIC
 PARAMETERS:
  p_number_of_bids        IN    number of bids
  p_bid_visibility        IN    bid visibility code
  p_sealed_auction_status IN    sealed auction status

 COMMENT   : calculates value for number of bids column in the ViewActiveBids page
======================================================================*/

FUNCTION NUMBIDS_VIEWACTIVEBIDS (p_number_of_bids IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  TRUNCATE   PUBLIC
 PARAMETERS:
  p_string         IN    input string

 COMMENT   : Truncate a large string to 30 chars appended by ...
======================================================================*/



FUNCTION TRUNCATE (p_string IN VARCHAR2) RETURN VARCHAR2;

/*======================================================================
 FUNCTION :  TRUNCATE   PUBLIC
 PARAMETERS:
  p_string         IN    input string
  p_length         IN    truncation length

 COMMENT   : Truncate a large string appended by ...
======================================================================*/
FUNCTION TRUNCATE (p_string IN VARCHAR2,
                   p_length IN NUMBER) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  TRUNCATE_DISPLAY_STRING   PUBLIC
 PARAMETERS:
  p_string         IN    input string

 COMMENT   : Truncate a large string to 240 chars (default) appended by ...
             This is equivalent to AuctionUtil.truncateDisplayString
======================================================================*/

FUNCTION TRUNCATE_DISPLAY_STRING (p_string IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  HTML_FORMATTED_HR_ADDRESS   PUBLIC
 PARAMETERS:
   p_location_id   IN    location id for the address
   p_language      IN    language
 COMMENT   : Returns aN html formatted address for the given location
======================================================================*/
FUNCTION HTML_FORMATTED_HR_ADDRESS(p_location_id IN NUMBER,
				   p_language IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  HTML_FORMATTED_EMAIL_STRING   PUBLIC
 PARAMETERS:
  p_email1         IN    input string
  p_email2         IN    input string

 COMMENT   : returns html formatted string of up to 2 email address.
             If both emails are specified, they are separated by a slash.
             This is currently used in ViewBiddersList to display
             contact and additional contact emails.
   ======================================================================*/



FUNCTION HTML_FORMATTED_EMAIL_STRING (p_email1 IN VARCHAR2,
                                      p_email2 IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  GET_HTML_FORMATTED_BID_STRING   PUBLIC
 PARAMETERS:
  p_doctype_id            IN    doc type id
  p_auction_header_id     IN    auction id
  p_trading_partner_id    IN    supplier trading partner id
  p_app_name              IN    application name

 COMMENT   : returns html formatted string of all active responses placed by
             a supplier on a negotiation.
             This is currently used in ViewBiddersList to display
             the response column.
======================================================================*/

FUNCTION GET_HTML_FORMATTED_BID_STRING (p_doctype_id  IN NUMBER,
                                        p_auction_header_id IN NUMBER,
                                        p_trading_partner_id IN NUMBER,
                                        p_app_name IN VARCHAR2) RETURN VARCHAR2;


/*======================================================================
 FUNCTION :  RESPONSE_VIEWBIDDERSLIST   PUBLIC
 PARAMETERS:
  p_doc_type_id           IN    doc type id
  p_auction_header_id     IN    auction id
  p_auctioneer_id         IN    auctioneer trading partner id
  p_viewer_tp_id          IN    viewer trading partner id,
  p_trading_partner_id    IN    supplier trading partner id
  p_bid_visibility        IN    bid visibility code
  p_sealed_auction_status IN    sealed auction status

 COMMENT   : calculates value for response column in view invitation list page
======================================================================*/

FUNCTION RESPONSE_VIEWBIDDERSLIST (p_doctype_id  IN NUMBER,
                   p_auction_header_id IN NUMBER,
                   p_auctioneer_id IN NUMBER,
                   p_viewer_tp_id IN  NUMBER,
		   p_trading_partner_id IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2;


TYPE bizrules is TABLE OF pon_auc_doctype_rules.validity_flag%TYPE
     INDEX BY BINARY_INTEGER;

/*======================================================================
FUNCTION :  DISPLAY_DATE   PUBLIC
 PARAMETERS:
  p_date                 IN        a date value
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format
  p_display_timzezone    IN        whether to display time zone

 COMMENT   : returns date converted to client time zone
             assumes the passed in date is in server time zone
======================================================================*/

FUNCTION DISPLAY_DATE(p_date IN DATE DEFAULT NULL,
                           p_client_timezone_id IN VARCHAR2,
                           p_server_timezone_id IN VARCHAR2,
                           p_date_format IN VARCHAR2,
                           p_display_timezone IN VARCHAR2 DEFAULT 'Y') RETURN VARCHAR2;

/*======================================================================
 FUNCTION :  CONVERT_DATE         PUBLIC
 PARAMETERS:
  p_date                 IN        a date value
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id

 COMMENT   : returns date converted to client's time zone
             assumes the passed in date is in server time zone
======================================================================*/

FUNCTION CONVERT_DATE(p_date IN DATE DEFAULT NULL,
                      p_client_timezone_id IN VARCHAR2,
                      p_server_timezone_id IN VARCHAR2) RETURN DATE;

/*======================================================================
 FUNCTION :  GET_ACTIVE_BID_COUNT   PUBLIC
 PARAMETERS:
  p_auction_header_id     IN    auction id
  p_line_number           IN    line number

 COMMENT   : Returns the number of active bids for the given auction's line
             number.
======================================================================*/

FUNCTION GET_ACTIVE_BID_COUNT (p_auction_header_id   IN NUMBER,
                               p_line_number IN NUMBER)
       RETURN NUMBER;

/*======================================================================
 FUNCTION :  TIME_REMAINING_ONLY_NOTZ   PUBLIC
 PARAMETERS:
  p_startdate            IN        auction start date
  p_enddate              IN        auction end date
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format

 COMMENT   : returns the time remaining if the close date is more than
 	     31 days after today; else returns the actual close date
======================================================================*/
/*
FUNCTION TIME_REMAINING_ONLY_NOTZ(p_startdate IN DATE DEFAULT NULL,
                        	  p_enddate IN DATE DEFAULT NULL,
                        	  p_client_timezone_id IN VARCHAR2,
                        	  p_server_timezone_id IN VARCHAR2,
                        	  p_date_format IN VARCHAR2) RETURN VARCHAR2;
*/

FUNCTION BID_NUMBER_SORT (p_auction_id NUMBER,
                   p_auction_status IN VARCHAR2,
                   p_auctioneer_id IN NUMBER,
                   p_viewer_tp_id IN  NUMBER,
                   p_viewer_tpc_id IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
                   p_sealed_auction_status IN VARCHAR2,
                   p_bidStatus IN VARCHAR2,
                   p_bidder_tpc_id IN NUMBER,
                   p_bid_number IN NUMBER) RETURN NUMBER;

/*======================================================================
 PROCEDURE: GET_DATABASE_VERSION    PUBLIC
 PARAMETERS:
  p_version     OUT    A string which represents the internal software version
                       of the database (e.g., 7.1.0.0.0).
  p_compatibility  OUT    The compatibility setting of the database determined
                          by the "compatible" init.ora parameter.

 COMMENT   : Returns the database version and compatibility setting
======================================================================*/
procedure GET_DATABASE_VERSION (p_version   OUT NOCOPY VARCHAR2,
                               p_compatibility OUT NOCOPY VARCHAR2);


/*======================================================================
 PROCEDURE:  CREATE_URL_ATTACHMENT    PUBLIC
   PARAMETERS:
   COMMENT   :  This procedure is used to create url attachments
                during spreadsheet upload
======================================================================*/

PROCEDURE create_url_attachment(
        p_seq_num                 in NUMBER,
        p_category_name             in VARCHAR2,
        p_document_description    in VARCHAR2,
        p_datatype_id             in NUMBER,
        p_url                     in VARCHAR2,
        p_entity_name             in VARCHAR2,
        p_pk1_value               in VARCHAR2,
        p_pk2_value               in VARCHAR2,
        p_pk3_value               in VARCHAR2,
        p_pk4_value               in VARCHAR2,
        p_pk5_value               in VARCHAR2
);

/*=========================================================================+
--
-- 12.0 ECO 4749273 - SEND TO LIST BEHAVIOR CHANGE IN ONLINE DISCUSSION
--
-- GET_TEAM_MEMBER_CNT takes AUCTION_HEADER_ID,DISCUSSION_ID,
-- USER_ID and TRADING_PARTNER_CONTACT_ID as parameters and
--
--
-- Returns number of team members for given negotiation.
--
--
-- Parameter :
--             p_auction_header_id IN NUMBER
--             p_discussion_id IN NUMBER
--             p_user_id IN NUMBER,
--             p_trading_partner_contact_id IN NUMBER
--
+=========================================================================*/

FUNCTION GET_TEAM_MEMBER_CNT(p_auction_header_id IN NUMBER,
                             p_discussion_id IN NUMBER,
                             p_user_id IN NUMBER,
                             p_trading_partner_contact_id IN NUMBER)
        return NUMBER;


/*======================================================================
  FUNCTION  :  APPROVAL_CONDITION    PUBLIC
  PARAMETERS:
    p_user_id         IN     User Id of the Buyer

  COMMENT   : Returns whether the Negotiation requires approval from
    the manager of the buyer if present
======================================================================*/
FUNCTION APPROVAL_CONDITION (p_user_id IN NUMBER) RETURN VARCHAR2;


END PON_OA_UTIL_PKG;

/

  GRANT EXECUTE ON "APPS"."PON_OA_UTIL_PKG" TO "EBSBI";
