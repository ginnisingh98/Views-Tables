--------------------------------------------------------
--  DDL for Package Body PON_OA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_OA_UTIL_PKG" as
/* $Header: PONOAUTB.pls 120.9.12010000.2 2008/10/30 10:02:21 jianliu ship $ */

g_monitor_rules                bizrules;
g_offer_rules                  bizrules;
g_fetched_doctype_rules        boolean := FALSE;


/*======================================================================
 PROCEDURE :  LOAD_DOCTYPE_RULES    PRIVATE
 PARAMETERS:
      none
 COMMENT   : load doc type rules into package variables
======================================================================*/

PROCEDURE LOAD_DOCTYPE_RULES IS

CURSOR doctypes IS
   SELECT doctype_id
     FROM pon_auc_doctypes;

BEGIN

   IF (not g_fetched_doctype_rules) THEN

      FOR doctype IN doctypes LOOP

         BEGIN
	    select nvl(r.validity_flag,'N')
	      into g_monitor_rules(doctype.doctype_id)
	      from pon_auc_doctype_rules r, pon_auc_bizrules biz
	      where biz.name = 'USE_AUCTION_MONITOR'
	      and r.bizrule_id = biz.bizrule_id
	      and r.doctype_id = doctype.doctype_id;
	 EXCEPTION WHEN NO_DATA_FOUND THEN
	    g_monitor_rules(doctype.doctype_id) := 'N';
	 END;

         BEGIN
	    select decode(nvl(r.fixed_value,'NONE'),'COMMIT','Y','N')
	      into g_offer_rules(doctype.doctype_id)
	      from pon_auc_doctype_rules r, pon_auc_bizrules biz
	      where biz.name = 'AWARD_TYPE'
	      and r.bizrule_id = biz.bizrule_id
	      and r.doctype_id = doctype.doctype_id;
	 EXCEPTION WHEN NO_DATA_FOUND THEN
	    g_offer_rules(doctype.doctype_id) := 'N';
	 END;

      END LOOP;

      g_fetched_doctype_rules := TRUE;

   END IF;

END  LOAD_DOCTYPE_RULES;

/*======================================================================
 FUNCTION :  MONITOR    PUBLIC
 PARAMETERS:
  p_doctype_id            IN        document type id
  p_bid_visibility        IN        bid visibility
  p_sealed_auction_status IN        sealed auction status
  p_auctioneer_id         IN        auctioneer trading partner id
  p_viewer_id             IN        viewer trading partner id
  p_startdate             IN        auction open bidding date
  p_has_items             IN        has Items Flag for negotiation

 COMMENT   : check if monitor icon should be active or not
======================================================================*/

FUNCTION MONITOR (p_doctype_id IN NUMBER,
                  p_bid_visibility IN VARCHAR2,
		  p_sealed_auction_status IN VARCHAR2,
                  p_auctioneer_id  IN NUMBER,
                  p_viewer_id IN NUMBER,
		  p_startdate IN DATE,
                  p_has_items IN VARCHAR2) RETURN VARCHAR2
IS


v_is_auctioneer boolean := FALSE;

BEGIN


   IF (p_auctioneer_id is NULL) THEN
       RETURN  'N';
   END IF;

   IF (p_startdate IS NULL OR p_startdate > SYSDATE) THEN
      RETURN 'N';
   END IF;

   IF (p_auctioneer_id = p_viewer_id) THEN
       v_is_auctioneer := TRUE;
   ELSE
       v_is_auctioneer := FALSE;
   END IF;

   load_doctype_rules;

   IF (g_monitor_rules(p_doctype_id) <> 'Y') THEN
       RETURN  'N';
   END IF;

   -- if negotiation does not have lines, return N
   IF (p_has_items = 'N') THEN
       RETURN  'N';
   END IF;

   IF (p_bid_visibility = 'OPEN_BIDDING') THEN
       RETURN  'Y';
   ELSE
       IF (p_bid_visibility = 'SEALED_BIDDING') THEN
          --  blind negotiation
          IF (v_is_auctioneer) THEN
              RETURN  'Y';
	  ELSE
              RETURN  'N';
          END IF;
       ELSE  -- sealed negotiation
          IF (p_sealed_auction_status = 'LOCKED') THEN
              -- bids locked
              RETURN  'N';
          ELSE
              IF (p_sealed_auction_status = 'UNLOCKED') THEN
                 -- bids unlocked
                 IF (v_is_auctioneer) THEN
                     RETURN  'Y';
	         ELSE
                     RETURN  'N';
                 END IF;
              ELSE  -- bids open
                 RETURN  'Y';
              END IF;
          END IF;
       END IF;
   END IF;

END MONITOR;


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
  p_auction_header_id 	  IN        Auction Header Id
  p_has_scoring_teams_flag IN		If auction has scoring teams

 COMMENT   : check if monitor icon should be active or not for buyer homepage and search page
======================================================================*/
FUNCTION BUYER_MONITOR (p_doctype_id        IN NUMBER,
                  p_bid_visibility          IN VARCHAR2,
        		  p_sealed_auction_status   IN VARCHAR2,
                  p_auctioneer_id           IN NUMBER,
                  p_viewer_id               IN NUMBER,
                  p_has_items               IN VARCHAR2,
                  p_doc_type                IN VARCHAR2,
                  p_auction_status          IN VARCHAR2,
                  p_view_by_date            IN DATE,
                  p_open_bidding_date       IN DATE,
				  p_auction_header_id     IN NUMBER,
				  p_has_scoring_teams_flag IN VARCHAR2
				  ) RETURN VARCHAR2
IS


v_is_auctioneer boolean := FALSE;
l_doc_type PON_AUC_DOCTYPES.internal_name%TYPE;

CURSOR 	c_price_visibility (p_cur_auction_header_id NUMBER) IS
SELECT  pst.team_id
FROM    pon_scoring_teams pst,
        pon_scoring_team_members pstm
WHERE   pst.auction_header_id = pstm.auction_header_id
AND     pst.team_id = pstm.team_id
AND     pst.price_visible_flag = 'Y'
AND     pstm.auction_header_id = p_cur_auction_header_id
AND     pstm.user_id = FND_GLOBAL.user_id;

l_team_id pon_scoring_teams.team_id%TYPE;
l_menu_name pon_neg_team_members.menu_name%TYPE;

BEGIN

   -- Teams Scoring
   -- If the current user does not have price visibility return N
   -- User has price visibility on THIS auction when
   -- 1. user is a scorer
   -- 2. AND belongs to a team that has price visiblity
   -- We check only if user does not have price visibility
   l_team_id := -1;
   IF (p_has_scoring_teams_flag = 'Y') THEN
        BEGIN
        -- check if user is a scorer first
   		SELECT 	menu_name INTO l_menu_name
   		FROM	pon_neg_team_members
   		WHERE	auction_header_id = p_auction_header_id
   		AND		list_id = -1
   		AND		user_id = FND_GLOBAL.user_id;

   		IF ((l_menu_name IS NOT NULL) AND (l_menu_name = 'PON_SOURCING_SCORENEG')) THEN
            -- if user is a scorer check if on a team that has price visibility
	   		OPEN 	c_price_visibility(p_auction_header_id);
			FETCH  	c_price_visibility INTO l_team_id;
			CLOSE 	c_price_visibility;

			IF (l_team_id = -1) THEN
				RETURN 'N';
   			END IF;
   		END IF;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                null;
              WHEN OTHERS THEN
                raise;
            END;
	END IF;

   l_doc_type := p_doc_type;

   IF (p_auctioneer_id is NULL) THEN
       RETURN  'N';
   END IF;

   -- if negotiation does not have lines, return N
   IF (p_has_items = 'N') THEN
       RETURN  'N';
   END IF;

   -- if negotiation is not open for preview, return N
   IF (p_view_by_date IS NOT NULL AND p_view_by_date > SYSDATE) THEN
      RETURN 'N';
   ELSIF (p_view_by_date IS NULL AND p_open_bidding_date > SYSDATE) THEN
      RETURN 'N';
   END IF;

   IF l_doc_type IS NULL THEN
       SELECT internal_name
       INTO   l_doc_type
       FROM   PON_AUC_DOCTYPES
       WHERE  doctype_id = p_doctype_id;
   END IF;

   IF (l_doc_type= 'REQUEST_FOR_INFORMATION') THEN
       RETURN  'N';
   END IF;

   IF (p_auction_status IN ('DRAFT','DELETED','AMENDED')) THEN
      RETURN 'N';
   END IF;

   IF (p_auctioneer_id = p_viewer_id) THEN
       v_is_auctioneer := TRUE;
   ELSE
       v_is_auctioneer := FALSE;
   END IF;

   IF (p_bid_visibility = 'OPEN_BIDDING') THEN
       RETURN  'Y';
   ELSE
       IF (p_bid_visibility = 'SEALED_BIDDING') THEN
          --  blind negotiation
          IF (v_is_auctioneer) THEN
              RETURN  'Y';
	      ELSE
              RETURN  'N';
          END IF;
       ELSE  -- sealed negotiation
          IF (p_sealed_auction_status = 'LOCKED') THEN
              -- bids locked
              RETURN  'N';
          ELSE
              IF (p_sealed_auction_status = 'UNLOCKED') THEN
                 -- bids unlocked
                 IF (v_is_auctioneer) THEN
                     RETURN  'Y';
	             ELSE
                     RETURN  'N';
                 END IF;
              ELSE  -- bids open
                 RETURN  'Y';
              END IF;
          END IF;
       END IF;
   END IF;

END BUYER_MONITOR;


/*======================================================================
 FUNCTION :  MONITOR_IMAGE    PUBLIC
 PARAMETERS:
  p_doctype_id            IN        document type id
  p_bid_visibility        IN        bid visibility
  p_sealed_auction_status IN        sealed auction status
  p_auctioneer_id         IN        auctioneer trading partner id
  p_viewer_id             IN        viewer trading partner id
  p_publishdate           IN        auction open bidding date
  p_contract_type         IN        auction outcome(STANDARD, BLANKET, CONTRACT)
  p_has_items             IN        has Items Flag for negotiation
  p_doc_type              IN        Type of the negotiation(RFI,RFQ,AUCTION)
  p_auction_status        IN        Status of the auction

 COMMENT   : return the monitor image name, either 'MonitorActive'
             or 'MonitorInactive'
======================================================================*/

FUNCTION MONITOR_IMAGE (p_doctype_id IN NUMBER,
                  p_bid_visibility IN VARCHAR2,
		  p_sealed_auction_status IN VARCHAR2,
                  p_auctioneer_id  IN NUMBER,
                  p_viewer_id IN NUMBER,
		  p_startdate IN DATE,
                  p_has_items IN VARCHAR2) RETURN VARCHAR2
IS

BEGIN

     IF(MONITOR(p_doctype_id, p_bid_visibility, p_sealed_auction_status, p_auctioneer_id,  p_viewer_id, p_startdate,p_has_items) = 'Y') THEN
        RETURN  'MonitorActive';
     ELSE
        RETURN  'MonitorInactive';
     END IF;

END MONITOR_IMAGE;

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
  p_auction_header_id 	  IN        Auction Header Id
  p_has_scoring_teams_flag IN		If auction has scoring teams


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
				  p_has_scoring_teams_flag IN VARCHAR2
				  ) RETURN VARCHAR2
IS

BEGIN

     IF(BUYER_MONITOR(p_doctype_id, p_bid_visibility, p_sealed_auction_status,
                      p_auctioneer_id, p_viewer_id, p_has_items, p_doc_type, p_auction_status,
					  p_view_by_date, p_open_bidding_date, p_auction_header_id,
					  p_has_scoring_teams_flag) = 'Y') THEN
        RETURN  'MonitorActive';
     ELSE
        RETURN  'MonitorInactive';
     END IF;

END BUYER_MONITOR_IMAGE;


/*======================================================================
 FUNCTION :  DICUSSION_URL    PUBLIC
 PARAMETERS:
  p_auction_id            IN        auction header id
  p_viewer_party_id       IN        viewer's trading partner id
  p_app                   IN        app name
  p_subtab_pos            IN        subtab position

 COMMENT   : returns javascript for discussion icon
             OAPageContext should add corresponding javascript definitions.
             This assumes the threaded discussion pages are still in JSP.
             Once they are moved to OAF, this function needs to be updated.
======================================================================*/

FUNCTION DISCUSSION_URL (p_auction_id IN NUMBER,
                         p_viewer_party_id IN NUMBER,
                         p_app IN VARCHAR2,
                         p_subtab_pos IN VARCHAR2) RETURN VARCHAR2
IS

v_discussion_id  NUMBER;

CURSOR discussion_id IS
    select discussion_id
      from pon_discussions
     where entity_name = 'PON_AUCTION_HEADERS_ALL' and
           pk1_value = to_char(p_auction_id);

BEGIN

    open discussion_id;
    fetch discussion_id
    into v_discussion_id;
    close discussion_id;

    -- error handling if discussin id is null?

    RETURN 'javascript:openDiscussionWindow(''/OA_HTML/jsp/pon/discussions/ThreadedNegotiationSummary.jsp?app=' || p_app || '&'
           || 'SubTab=' || p_subtab_pos || '&' || 'discussion_id=' || v_discussion_id || ''',''discussion_' || v_discussion_id || '_user_' || p_viewer_party_id || '_depth_'' + (parseInt(getDiscussionWindowDepth()) + 1))';

END DISCUSSION_URL;



/*======================================================================
 FUNCTION :  GET_TIMEZONE_DISP   PUBLIC
 PARAMETERS:
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id


 COMMENT   : returns timezone to display
======================================================================*/

FUNCTION GET_TIMEZONE_DISP(p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2) RETURN VARCHAR2
IS



v_client_timezone VARCHAR2(50);
v_time_zone_name FND_TIMEZONES_VL.NAME%TYPE := NULL;


BEGIN

  -- get client time zone, if null use server time zone
  v_client_timezone := p_client_timezone_id;
  if (v_client_timezone is null or v_client_timezone = '') then
	v_client_timezone := p_server_timezone_id;
  end if;


  -- it's better to get time zone name in the middle tier once
  -- instead of firing a sql to get the name for each table row
  begin
    select name
      into v_time_zone_name
      from fnd_timezones_vl
     where upgrade_tz_id = to_number(v_client_timezone);
  exception
      WHEN NO_DATA_FOUND THEN
           v_time_zone_name := 'Unknown Timezone';
  end;

  return v_time_zone_name;

END GET_TIMEZONE_DISP;


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
			p_startdate IN DATE ,
                        p_enddate IN DATE ,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2) RETURN VARCHAR2
IS

v_time_remaining VARCHAR2(100) := NULL;
v_close_date     VARCHAR2(100) := NULL;

BEGIN
  v_time_remaining := PON_AUCTION_PKG.TIME_REMAINING(
			p_startdate,
			p_enddate,
               		p_client_timezone_id,
			p_server_timezone_id,
			p_date_format);

  --
  -- Convert the dates to the user's timezone.
  --
  v_close_date := DISPLAY_DATE_TIME(p_enddate,
                                    p_client_timezone_id,
                                    p_server_timezone_id,
                                    p_date_format);

  return v_time_remaining || '/' || v_close_date;
END;
*/

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
			p_startdate IN DATE ,
                        p_enddate IN DATE ,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2,
			p_days_string IN VARCHAR2,
			p_day_string IN VARCHAR2,
			p_hours_string IN VARCHAR2,
			p_hour_string IN VARCHAR2,
			p_minutes_string IN VARCHAR2,
			p_minute_string IN VARCHAR2) RETURN VARCHAR2
IS

v_time_remaining VARCHAR2(100) := NULL;
v_close_date     VARCHAR2(100) := NULL;

BEGIN
  v_time_remaining := PON_AUCTION_PKG.TIME_REMAINING(
			p_startdate,
			p_enddate,
               		p_client_timezone_id,
			p_server_timezone_id,
			p_date_format,
			p_days_string,
			p_day_string,
			p_hours_string,
			p_hour_string,
			p_minutes_string,
			p_minute_string);

  --
  -- Convert the dates to the user's timezone.
  --
  v_close_date := DISPLAY_DATE_TIME(p_enddate,
                                    p_client_timezone_id,
                                    p_server_timezone_id,
                                    p_date_format);

  return v_time_remaining || '/' || v_close_date;
END;
*/

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
FUNCTION TIME_REMAINING_CLOSE_DATE(p_startdate IN DATE ,
                        p_enddate IN DATE ,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2) RETURN VARCHAR2
IS

v_time_remaining VARCHAR2(100) := NULL;
v_close_date     VARCHAR2(100) := NULL;

BEGIN
  v_time_remaining := PON_AUCTION_PKG.TIME_REMAINING(p_startdate, p_enddate,
               p_client_timezone_id, p_server_timezone_id,  p_date_format);


  --
  -- Convert the dates to the user's timezone.
  --
  v_close_date := DISPLAY_DATE_TIME(p_enddate,
                                    p_client_timezone_id,
                                    p_server_timezone_id,
                                    p_date_format);


  return '<b>' || v_time_remaining || '</b> <br>' || v_close_date;

END TIME_REMAINING_CLOSE_DATE;
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
		without the timezone at the end
======================================================================*/

/*
FUNCTION TIME_REMAINING_CLOSE_DATE_NOTZ(p_startdate IN DATE ,
                        p_enddate IN DATE ,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2) RETURN VARCHAR2
IS

v_time_remaining VARCHAR2(100) := NULL;
v_close_date     VARCHAR2(100) := NULL;
v_difference     NUMBER := 0;

BEGIN
 v_difference := to_number(p_enddate-sysdate);

   -- bug fix 2835097
   IF (v_difference <= 31) THEN

  v_time_remaining := PON_AUCTION_PKG.TIME_REMAINING(p_startdate, p_enddate,
               p_client_timezone_id, p_server_timezone_id,  p_date_format);

 END IF;


  --
  -- Convert the dates to the user's timezone.
  --
  v_close_date := DISPLAY_DATE_TIME(p_enddate,
                                    p_client_timezone_id,
                                    p_server_timezone_id,
                                    p_date_format,
				    'N');

   IF (v_difference > 31) THEN
     return v_close_date;
   ELSE
     return v_time_remaining || ' ' || v_close_date;
   END IF;

END TIME_REMAINING_CLOSE_DATE_NOTZ;
*/



/*======================================================================
 FUNCTION :  DISPLAY_DATE_TIME   PUBLIC
 PARAMETERS:
  p_date                 IN        a date value
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format
  p_display_timezone     IN        whether or not to display timezone

 COMMENT   : returns date and time converted to client time zone
             assumes the passed in date is in server time zone
======================================================================*/

FUNCTION DISPLAY_DATE_TIME(p_date IN DATE ,
                           p_client_timezone_id IN VARCHAR2,
                           p_server_timezone_id IN VARCHAR2,
                           p_date_format IN VARCHAR2,
			   p_display_timezone IN VARCHAR2 )
RETURN VARCHAR2
IS

v_time_format     VARCHAR2(20)  := ' HH24:MI:SS';  -- time format is fixed
v_client_timezone VARCHAR2(50);
v_new_date	  DATE;
v_time_zone_name FND_TIMEZONES_VL.NAME%TYPE := NULL;
v_return_string   VARCHAR2(1000);

BEGIN

  -- get client time zone, if null use server time zone
  v_client_timezone := p_client_timezone_id;
  if (v_client_timezone is null or v_client_timezone = '') then
	v_client_timezone := p_server_timezone_id;
  end if;

  --
  -- Convert the dates to the user's timezone.
  --

  IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(v_client_timezone) = 1) THEN
     v_new_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_date,p_server_timezone_id,v_client_timezone);
  ELSE
     v_new_date := p_date;
     v_client_timezone := p_server_timezone_id;
  END IF;

  IF (p_display_timezone = 'Y') THEN
    v_time_zone_name :=  GET_TIMEZONE_DISP(p_client_timezone_id => v_client_timezone,
                                           p_server_timezone_id => p_server_timezone_id);
  END IF;

  v_return_string := to_char(v_new_date, p_date_format || v_time_format);
  IF (p_display_timezone = 'Y') THEN
     v_return_string := v_return_string || ' ' || v_time_zone_name;
  END IF;

  return  v_return_string;

END DISPLAY_DATE_TIME;
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
                      p_server_timezone_id IN VARCHAR2)
         RETURN DATE
IS
v_client_timezone VARCHAR2(50);
v_new_date        DATE;
BEGIN
  -- get client time zone, if null use server time zone
  v_client_timezone := p_client_timezone_id;
  if (v_client_timezone is null or v_client_timezone = '') then
        v_client_timezone := p_server_timezone_id;
  end if;

  --
  -- Convert the dates to the user's timezone.
  --

  IF (PON_OEX_TIMEZONE_PKG.VALID_ZONE(v_client_timezone) = 1) THEN
     v_new_date := PON_OEX_TIMEZONE_PKG.CONVERT_TIME(p_date,p_server_timezone_id,v_client_timezone);
  ELSE
     v_new_date := p_date;
  END IF;

 RETURN  v_new_date;
END CONVERT_DATE;

/*======================================================================
 FUNCTION :  DISPLAY_DATE     PUBLIC
 PARAMETERS:
  p_date                 IN        a date value
  p_client_timezone_id   IN        client (viewer) time zone id
  p_server_timezone_id   IN        server time zone id
  p_date_format          IN        date format
  p_display_timzezone    IN        whether to display time zone

 COMMENT   : returns date converted to client time zone
             assumes the passed in date is in server time zone
======================================================================*/

FUNCTION DISPLAY_DATE (p_date IN DATE ,
                           p_client_timezone_id IN VARCHAR2,
                           p_server_timezone_id IN VARCHAR2,
                           p_date_format IN VARCHAR2,
                           p_display_timezone IN VARCHAR2 )
RETURN VARCHAR2
IS
v_time_format     VARCHAR2(20)  := ' HH24:MI:SS';  -- time format is fixed
return_date     VARCHAR2(20) := null;
BEGIN

   return_date := DISPLAY_DATE_TIME(p_date, p_client_timezone_id,
                                    p_server_timezone_id,
                                    p_date_format,
                                    p_display_timezone);

  return to_char(to_date(return_date,p_date_format || v_time_format), p_date_format);
END DISPLAY_DATE;

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
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2
IS

v_is_auctioneer boolean := FALSE;
v_is_auction_sealed boolean := FALSE;

BEGIN

    IF (p_auctioneer_id = p_viewer_tp_id) THEN
        v_is_auctioneer := TRUE;
    ELSE
        v_is_auctioneer := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_AUCTION') THEN
        v_is_auction_sealed := TRUE;
    ELSE
        v_is_auction_sealed := FALSE;
    END IF;

    IF (p_query_type = 'Glance') THEN
      -- for glance query, for auctioneers, show number of bids,
      -- for bidders, show the bid number
      IF(v_is_auctioneer) THEN
         IF(p_number_of_bids > 0) THEN
            RETURN 'BidHist';
         ELSE
            RETURN 'NumOfBids';
         END IF;
      ELSE -- bidder
         IF( (not v_is_auction_sealed) or
            (v_is_auction_sealed and p_sealed_auction_status = 'ACTIVE')) THEN
            RETURN 'ViewBid';
         ELSE
            -- bidder can't see even the number of bids if this auction is not active
            RETURN 'Sealed';
         END IF;
      END IF;
    ELSE
      IF (p_query_type = 'Invite') THEN
        -- for invites, always show number of bids
        IF(v_is_auctioneer) THEN
          IF( (not v_is_auction_sealed) or
             (v_is_auction_sealed and (not p_sealed_auction_status = 'LOCKED'))) THEN
            IF(p_number_of_bids > 0) THEN
               RETURN 'BidHist';
            ELSE
               RETURN 'NumOfBids';
            END IF;
          ELSE -- the auctioneer can't see number of bids at that time
            RETURN 'Sealed';
          END IF;
        ELSE -- bidder
          IF ( (not v_is_auction_sealed) and (not p_bid_visibility = 'SEALED_BIDDING') or (v_is_auction_sealed and p_sealed_auction_status = 'ACTIVE') ) THEN
            IF(p_number_of_bids > 0) THEN
               RETURN 'BidHist';
            ELSE
               RETURN 'NumOfBids';
            END IF;
          ELSE -- bidder can't see even the number of bids if this auction is not active
            RETURN 'NegStyle';
          END IF;
        END IF;
      END IF;
    END IF;

END RESPONSE_VIEWMORENEGS;

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
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2
IS

v_is_auctioneer boolean := FALSE;
v_is_auction_sealed boolean := FALSE;
v_is_auction_blind boolean := FALSE;

BEGIN

    IF (p_auctioneer_id = p_viewer_tp_id) THEN
        v_is_auctioneer := TRUE;
    ELSE
        v_is_auctioneer := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_AUCTION') THEN
        v_is_auction_sealed := TRUE;
    ELSE
        v_is_auction_sealed := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_BIDDING') THEN
        v_is_auction_blind := TRUE;
    ELSE
        v_is_auction_blind := FALSE;
    END IF;

    IF (((not v_is_auction_sealed) or
           (v_is_auction_sealed and p_sealed_auction_status = 'ACTIVE')) and
          (( not v_is_auction_blind ) or
            (v_is_auction_blind and v_is_auctioneer)) ) THEN

         IF(p_number_of_bids > 0) THEN
            RETURN 'BidHist';
         ELSE
            RETURN 'NumOfBids';
         END IF;
    END IF;

    IF (v_is_auction_sealed and (not p_sealed_auction_status = 'ACTIVE')) THEN
         IF (v_is_auctioneer)  THEN
            IF (p_sealed_auction_status = 'UNLOCKED') THEN
                -- auctioneer can see all the bids if this auction is unlocked

               IF(p_number_of_bids > 0) THEN
                 RETURN 'BidHist';
               ELSE
                 RETURN 'NumOfBids';
               END IF;
            ELSE
               IF (p_sealed_auction_status = 'LOCKED') THEN
                  -- now auctioneer can see the number of bids but not the bid detail
                 RETURN 'NumOfBids';
               END IF;
            END IF;
         ELSE
            -- bidder can't see even the number of bids if this auction is not active
           RETURN 'Sealed';
         END IF;
    END IF;

    IF (v_is_auction_blind and not v_is_auctioneer) THEN
        RETURN 'Blind';
    END IF;

END RESPONSE_VIEWAUCTIONS;


/*======================================================================
 FUNCTION :  TRUNCATE   PUBLIC
 PARAMETERS:
  p_string         IN    input string

 COMMENT   : Truncate a large string to 30 chars appended by ...
             This is equivalent to SummaryPages.truncate
======================================================================*/

FUNCTION TRUNCATE (p_string IN VARCHAR2) RETURN VARCHAR2
IS

BEGIN

         return truncate(p_string, 30);

END TRUNCATE;

/*======================================================================
 FUNCTION :  TRUNCATE_DISPLAY_STRING   PUBLIC
 PARAMETERS:
  p_string         IN    input string

 COMMENT   : Truncate a large string to 240 chars (default) appended by ...
             This is equivalent to AuctionUtil.truncateDisplayString
======================================================================*/

FUNCTION TRUNCATE_DISPLAY_STRING (p_string IN VARCHAR2) RETURN VARCHAR2
IS

BEGIN

         return truncate(p_string, 240);

END TRUNCATE_DISPLAY_STRING;

/*======================================================================
 FUNCTION :  TRUNCATE   PUBLIC
 PARAMETERS:
  p_string         IN    input string
  p_length         IN    truncation length

 COMMENT   : Truncate a large string appended by ...
======================================================================*/

FUNCTION TRUNCATE (p_string IN VARCHAR2,
                   p_length IN NUMBER) RETURN VARCHAR2
IS

BEGIN
      IF (p_length = null or p_length < 1) THEN
         return p_string;
      END IF;

      IF (length(p_string) > p_length) THEN
         return substr(p_string, 1, p_length) || '...';
      ELSE
         return p_string;
      END IF;

END TRUNCATE;

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

FUNCTION RESPONSE_VIEWACTIVEBIDS (p_auction_id NUMBER,
                   p_auction_status IN VARCHAR2,
                   p_auctioneer_id IN NUMBER,
                   p_viewer_tp_id IN  NUMBER,
                   p_viewer_tpc_id IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
                   p_sealed_auction_status IN VARCHAR2,
                   p_bidStatus IN VARCHAR2,
                   p_bidder_tpc_id IN NUMBER) RETURN VARCHAR2
IS

v_is_auctioneer boolean := FALSE;
v_is_viewer_the_bidder boolean := FALSE;
v_is_auction_sealed boolean := FALSE;
v_is_auction_blind boolean := FALSE;
v_is_draft boolean := FALSE;
v_most_recent_auction_id NUMBER;
v_auction_status VARCHAR2(25);
v_bidding_status VARCHAR2(25);
v_two_part_flag pon_auction_headers_all.two_part_flag%TYPE;
v_technical_lock_status pon_auction_headers_all.technical_lock_status%TYPE;

BEGIN

    IF (p_bidStatus IS NOT NULL AND p_bidStatus = 'DRAFT') THEN
      v_is_draft := TRUE;
    END IF;
    --
    IF (p_viewer_tpc_id = p_bidder_tpc_id) THEN
      v_is_viewer_the_bidder := TRUE;
    END IF;
    --
    IF (p_auctioneer_id = p_viewer_tp_id) THEN
        v_is_auctioneer := TRUE;
    ELSE
        v_is_auctioneer := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_AUCTION') THEN
        v_is_auction_sealed := TRUE;
    ELSE
        v_is_auction_sealed := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_BIDDING') THEN
        v_is_auction_blind := TRUE;
    ELSE
        v_is_auction_blind := FALSE;
    END IF;

    SELECT nvl(two_part_flag, 'N'), nvl(technical_lock_status, 'N')
    INTO v_two_part_flag, v_technical_lock_status
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auction_id;

    IF ((v_is_auction_sealed) AND
          ((v_two_part_flag = 'N' AND NOT p_sealed_auction_status = 'ACTIVE') OR (v_two_part_flag = 'Y' AND NOT v_technical_lock_status = 'ACTIVE')) AND
          (NOT v_is_auctioneer) AND
          (NOT v_is_viewer_the_bidder) AND
          (NOT v_is_draft)) THEN

       RETURN 'SealedAuction';

    ELSIF ((v_is_auction_blind) AND (NOT v_is_auctioneer) AND (NOT v_is_viewer_the_bidder) AND (NOT v_is_draft)) THEN
       RETURN 'BlindAuction';

    ELSE
      -- Now check if there are any amendments pending
       IF ((p_bidStatus IS NOT NULL AND p_bidStatus = 'RESUBMISSION') OR
           (p_auction_status = 'AMENDED' and v_is_draft)) THEN

        -- check whether the most recent amendment has been closed or cancelled
        -- if yes, then don't need to show warning icon on seller home page
        -- and active/draft responses page

        select max(ah.auction_header_id)
        into v_most_recent_auction_id
        from pon_auction_headers_all ah,
             pon_auction_headers_all ah2
        where ah.auction_status <> 'DRAFT'
        and ah.auction_header_id_orig_amend = ah2.auction_header_id_orig_amend
        and ah2.auction_header_id = p_auction_id;

        select auction_status,
               decode(sign(close_bidding_date - sysdate), 1, 'NOT_CLOSED', 'CLOSED')
        into v_auction_status,
             v_bidding_status
        from pon_auction_headers_all
        where auction_header_id = v_most_recent_auction_id;

        IF ((v_auction_status IS NOT NULL AND v_auction_status = 'CANCELLED') OR
            (v_bidding_status = 'CLOSED')) THEN
          IF (v_is_draft) THEN
             RETURN 'DraftBid';
          ELSE
             RETURN 'BidNumber';
          END IF;
        ELSE
          IF (v_is_draft) THEN
             RETURN 'ResubmitDraft';
          ELSE
             RETURN 'Resubmit';
          END IF;
        END IF;

     ELSE

      IF v_is_draft THEN
          RETURN 'DraftBid';
      ELSE
          RETURN 'BidNumber';
      END IF;

     END IF;

    END IF;

END RESPONSE_VIEWACTIVEBIDS;


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
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2
IS

v_is_auction_sealed boolean := FALSE;
v_is_auction_blind boolean := FALSE;

BEGIN

    IF (p_bid_visibility = 'SEALED_AUCTION') THEN
        v_is_auction_sealed := TRUE;
    ELSE
        v_is_auction_sealed := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_BIDDING') THEN
        v_is_auction_blind := TRUE;
    ELSE
        v_is_auction_blind := FALSE;
    END IF;

    IF ( (v_is_auction_sealed) AND
          (NOT p_sealed_auction_status = 'ACTIVE')) THEN

       RETURN 'SealedAuction';

    ELSIF (v_is_auction_blind) THEN
       RETURN 'BlindAuction';

    ELSIF (p_number_of_bids > 0) THEN
	RETURN 'NumOfBidsURL';
    ELSE
        RETURN 'NumOfBidsText';
    END IF;

END NUMBIDS_VIEWACTIVEBIDS;

/*======================================================================
 FUNCTION :  BID_NUMBER_SORT   PUBLIC
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
  p_bid_number            IN    bid Number

 COMMENT   : This function is to determine sorting column of bid number.
             The sorting order is :
             Bids whose number we can display
             Blind
             Sealed
======================================================================*/

FUNCTION BID_NUMBER_SORT (p_auction_id NUMBER,
                   p_auction_status IN VARCHAR2,
                   p_auctioneer_id IN NUMBER,
                   p_viewer_tp_id IN  NUMBER,
                   p_viewer_tpc_id IN NUMBER,
                   p_bid_visibility IN VARCHAR2,
                   p_sealed_auction_status IN VARCHAR2,
                   p_bidStatus IN VARCHAR2,
                   p_bidder_tpc_id IN NUMBER,
                   p_bid_number IN NUMBER) RETURN NUMBER
IS

v_is_auctioneer boolean := FALSE;
v_is_viewer_the_bidder boolean := FALSE;
v_is_auction_sealed boolean := FALSE;
v_is_auction_blind boolean := FALSE;
v_is_draft boolean := FALSE;
v_most_recent_auction_id NUMBER;
v_auction_status VARCHAR2(25);
v_bidding_status VARCHAR2(25);

BEGIN

    IF (p_bidStatus IS NOT NULL AND p_bidStatus = 'DRAFT') THEN
      v_is_draft := TRUE;
    END IF;
    --
    IF (p_viewer_tpc_id = p_bidder_tpc_id) THEN
      v_is_viewer_the_bidder := TRUE;
    END IF;
    --
    IF (p_auctioneer_id = p_viewer_tp_id) THEN
        v_is_auctioneer := TRUE;
    ELSE
        v_is_auctioneer := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_AUCTION') THEN
        v_is_auction_sealed := TRUE;
    ELSE
        v_is_auction_sealed := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_BIDDING') THEN
        v_is_auction_blind := TRUE;
    ELSE
        v_is_auction_blind := FALSE;
    END IF;

    IF ((v_is_auction_sealed) AND
          (NOT p_sealed_auction_status = 'ACTIVE') AND
          (NOT v_is_auctioneer) AND
          (NOT v_is_viewer_the_bidder) AND
          (NOT v_is_draft)) THEN

       RETURN p_bid_number+2000000;

    ELSIF ((v_is_auction_blind) AND (NOT v_is_auctioneer) AND (NOT v_is_viewer_the_bidder) AND (NOT v_is_draft)) THEN
       RETURN p_bid_number+1000000;
          ELSE
             RETURN p_bid_number;
          END IF;

END BID_NUMBER_SORT;

/*======================================================================
 FUNCTION :  HTML_FORMATTED_HR_ADDRESS   PUBLIC
 PARAMETERS:
   p_location_id   IN    location id for the address
   p_language      IN    language
 COMMENT   : Returns the html formatted address for the given location
======================================================================*/
FUNCTION HTML_FORMATTED_HR_ADDRESS(p_location_id IN NUMBER,
				   p_language IN VARCHAR2) RETURN VARCHAR2

  IS

     v_address_name hr_locations.location_code%TYPE;
     v_address_1 hr_locations.address_line_1%TYPE;
     v_address_2 hr_locations.address_line_2%TYPE;
     v_address_3 hr_locations.address_line_3%TYPE;
     v_city hr_locations.town_or_city%TYPE;
     v_state hr_locations.region_2%TYPE;
     v_province_or_region hr_locations.region_3%TYPE;
     v_zip_code hr_locations.postal_code%TYPE;
     v_postal_code hr_locations.postal_code%TYPE;
     v_country hr_locations.country%TYPE;
     v_county hr_locations.region_1%TYPE;
     v_territory_name fnd_territories_tl.territory_short_name%TYPE;
     v_return_string VARCHAR2(1000);

BEGIN

   SELECT
     hl.location_code,
     hl.address_line_1,
     hl.address_line_2,
     hl.address_line_3,
     hl.town_or_city,
     hl.region_2,
     hl.region_3,
     hl.postal_code,
     hl.postal_code,
     hl.country,
     hl.region_1
     INTO
     v_address_name,
     v_address_1,
     v_address_2,
     v_address_3,
     v_city,
     v_state,
     v_province_or_region,
     v_zip_code,
     v_postal_code,
     v_country,
     v_county
     FROM hr_locations hl
     WHERE hl.location_id = p_location_id;

BEGIN
   SELECT
     tl.territory_short_name
     INTO v_territory_name
     FROM fnd_territories_tl tl
     WHERE tl.territory_code = v_country
     AND tl.territory_code NOT IN ('ZR','FX','LX')
     AND tl.language = p_language;
     EXCEPTION
   WHEN no_data_found THEN
      v_territory_name := v_country;
END;

   IF (v_country = 'JP') THEN
      v_return_string := v_territory_name || '<br>';

      -- zip code
      IF (v_postal_code IS NOT null) THEN
	 v_return_string := v_return_string || v_postal_code || '<br>';
      ELSE
	 IF (v_zip_code IS NOT null) THEN
	    v_return_string := v_return_string || v_zip_code || '<br>';
	 END IF;
      END IF;

      -- province
      IF (v_province_or_region IS NOT null) THEN
         v_return_string := v_return_string || v_province_or_region || '<br>';
      END IF;

      -- city
      v_return_string := v_return_string || v_city || '<br>';

      -- address
      v_return_string := v_return_string || v_address_1 || '<br>';
      IF (v_address_2 IS NOT null) THEN
	 v_return_string := v_return_string || v_address_2 || '<br>';
      END IF;
      IF (v_address_3 IS NOT null) THEN
	 v_return_string := v_return_string || v_address_3 || '<br>';
      END IF;

    ELSE -- not a japanese address

      -- address
      v_return_string := v_address_1 || '<br>';
      IF (v_address_2 IS NOT null) THEN
	 v_return_string := v_return_string || v_address_2 || '<br>';
      END IF;
      IF (v_address_3 IS NOT null) THEN
	 v_return_string := v_return_string || v_address_3 || '<br>';
      END IF;

      -- city
      v_return_string := v_return_string || v_city;

      -- state
      IF (v_country = 'US') THEN -- US address
	 IF (v_state is NOT null) THEN
	    v_return_string := v_return_string || ',' || v_state;
	 END IF;
      ELSE -- not a US address
	 IF (v_province_or_region IS NOT null) THEN
	    v_return_string := v_return_string || '<br>' || v_province_or_region;
	 END IF;
      END IF;

      -- postal or zip code
      IF (v_postal_code IS NOT null) THEN
	 v_return_string := v_return_string || ' ' || v_postal_code;
      ELSE
	 IF (v_zip_code IS NOT null) THEN
	    v_return_string := v_return_string || ' ' || v_zip_code;
	 END IF;
      END IF;

      v_return_string := v_return_string || '<br>' || v_territory_name;

   END IF;
   RETURN v_return_string;

END html_formatted_hr_address;


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
                                      p_email2 IN VARCHAR2) RETURN VARCHAR2
IS

  v_email_1 VARCHAR2(400) := NULL;
  v_email_2 VARCHAR2(400) := NULL;
  v_separator VARCHAR2(10) := NULL;

BEGIN

  IF (p_email1 is not null) THEN
    v_email_1 := '<a href="mailto:' || p_email1 || '">' || p_email1 || '</a>';
  END IF;

  IF (p_email2 is not null) THEN
    v_email_2 := '<a href="mailto:' || p_email2 || '">' || p_email2 || '</a>';
  END IF;

  IF (p_email1 is not null and p_email2 is not null) THEN
    v_separator := ' / ';
  END IF;

  return v_email_1 || v_separator ||  v_email_2;

END HTML_FORMATTED_EMAIL_STRING;

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
                                        p_app_name IN VARCHAR2) RETURN VARCHAR2
IS

v_return_string VARCHAR2(1000) := NULL;

CURSOR bids IS
    select bid_number
      from pon_bid_headers
     where auction_header_id = p_auction_header_id and
           trading_partner_id = p_trading_partner_id and
           bid_status = 'ACTIVE';

CURSOR counteroffers IS
    select substrb(to_char(bid_number)||(decode (bid_revision_number,null,'','-'||to_char(bid_revision_number))),0,10) bid_number_display,
           bid_number
      from pon_bid_headers
     where auction_header_id = p_auction_header_id and
           trading_partner_id = p_trading_partner_id and
           bid_status = 'ACTIVE' and
           nvl(award_status,'NONE') <> 'COMMITTED';

BEGIN

    load_doctype_rules;

    IF (g_offer_rules(p_doctype_id) <> 'Y') THEN
      -- for RFQs, Auctions, use bids cursor
      FOR bid IN bids LOOP
         v_return_string := v_return_string || '<a href="jsp/pon/auctions/ViewBid.jsp?AUCTION_HEADER_ID=' || p_auction_header_id || '&' || 'BID_NUMBER=' || bid.bid_number || '&' || 'app=' || p_app_name ||  '">' || bid.bid_number || '</a> <BR>';
      END LOOP;
    ELSE
      -- for offers, use counteroffers and commitments
      FOR counteroffer IN counteroffers LOOP
         v_return_string := v_return_string || '<a href="jsp/pon/auctions/viewCounterDetails.jsp?doc_id=' || p_auction_header_id || '&' ||
             'resp_id=' || counteroffer.bid_number || '&' || 'app=' || p_app_name || '">' || counteroffer.bid_number_display || '</a> <BR>';
      END LOOP;

    END IF;

    return v_return_string;

END GET_HTML_FORMATTED_BID_STRING;


/*======================================================================
 FUNCTION :  RESPONSE_VIEWBIDDERSLIST   PUBLIC
 PARAMETERS:
  p_doctype_id            IN    doc type id
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
                   p_sealed_auction_status IN VARCHAR2) RETURN VARCHAR2
IS

v_is_auctioneer boolean := FALSE;
v_is_auction_sealed boolean := FALSE;
v_is_auction_blind boolean := FALSE;
v_number_of_bids  NUMBER;

BEGIN

    IF (p_auctioneer_id = p_viewer_tp_id) THEN
        v_is_auctioneer := TRUE;
    ELSE
        v_is_auctioneer := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_AUCTION') THEN
        v_is_auction_sealed := TRUE;
    ELSE
        v_is_auction_sealed := FALSE;
    END IF;

    IF (p_bid_visibility = 'SEALED_BIDDING') THEN
        v_is_auction_blind := TRUE;
    ELSE
        v_is_auction_blind := FALSE;
    END IF;


    load_doctype_rules;

    IF (g_offer_rules(p_doctype_id) = 'Y') THEN
        SELECT count(*)
          INTO v_number_of_bids
          FROM pon_bid_headers
         WHERE auction_header_id = p_auction_header_id and
               trading_partner_id = p_trading_partner_id and
               bid_status = 'ACTIVE' and
               nvl(award_status,'NONE') <> 'COMMITTED';

         IF(v_number_of_bids > 0) THEN
            RETURN 'BidNumberString';
         ELSE
            RETURN 'NoBid';
         END IF;
    ELSE
       SELECT count(*)
         INTO v_number_of_bids
         FROM pon_bid_headers
        WHERE auction_header_id = p_auction_header_id and
              trading_partner_id = p_trading_partner_id and
              bid_status = 'ACTIVE';
    END IF;


    IF (((not v_is_auction_sealed) or
           (v_is_auction_sealed and (not v_is_auctioneer) and p_sealed_auction_status = 'ACTIVE') or
        (v_is_auction_sealed and v_is_auctioneer and (not p_sealed_auction_status = 'LOCKED')) )  )   THEN

         IF(v_number_of_bids > 0) THEN
            RETURN 'BidNumberString';
         ELSE
            RETURN 'NoBid';
         END IF;
    ELSE  -- can't see bid detail
         IF(v_number_of_bids > 0) THEN
            RETURN 'Sealed';
         ELSE
            IF(v_is_auctioneer) THEN
                RETURN 'NoBid';
            ELSE
                RETURN null;
            END IF;
         END IF;
    END IF;

END RESPONSE_VIEWBIDDERSLIST;

/*======================================================================
 FUNCTION :  GET_ACTIVE_BID_COUNT    PUBLIC
 PARAMETERS:
  p_auction_header_id     IN    auction id
  p_line_number           IN    line number

 COMMENT   : Returns the number of active bids for the given auction's line
             number.
======================================================================*/
FUNCTION GET_ACTIVE_BID_COUNT (p_auction_header_id   IN NUMBER,
                               p_line_number IN NUMBER)
       RETURN NUMBER
IS
  v_active_bids_count NUMBER := 0;
BEGIN
    SELECT count(*)
     INTO  v_active_bids_count
    FROM pon_bid_headers bh
        , pon_bid_item_prices bl
    WHERE  bh.auction_header_id = p_auction_header_id
      and  bh.bid_status = 'ACTIVE'
      --added by Allen Yang for Surrogate Bid 2008/09/26
      -------------------------------------------------------
      and (bh.submit_stage is null or bh.submit_stage <> 'TECHNICAL')
      -------------------------------------------------------
      and  bl.bid_number = bh.bid_number
      and  bl.line_number = p_line_number;

    RETURN v_active_bids_count;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END GET_ACTIVE_BID_COUNT;


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
                               p_compatibility OUT NOCOPY VARCHAR2)
IS
BEGIN

	DBMS_UTILITY.DB_VERSION(p_version, p_compatibility);

END GET_DATABASE_VERSION;


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
FUNCTION TIME_REMAINING_ONLY_NOTZ(p_startdate IN DATE ,
                        p_enddate IN DATE ,
                        p_client_timezone_id IN VARCHAR2,
                        p_server_timezone_id IN VARCHAR2,
                        p_date_format IN VARCHAR2) RETURN VARCHAR2
IS

v_time_remaining VARCHAR2(100) := NULL;
v_close_date     VARCHAR2(100) := NULL;
v_difference     NUMBER := 0;

BEGIN
 v_difference := to_number(p_enddate-sysdate);

   IF (v_difference <= 31) THEN

  v_time_remaining := PON_AUCTION_PKG.TIME_REMAINING(p_startdate, p_enddate,
               p_client_timezone_id, p_server_timezone_id,  p_date_format);

 END IF;
  --
  -- Convert the dates to the user's timezone.
  --
  v_close_date := DISPLAY_DATE_TIME(p_enddate,
                                    p_client_timezone_id,
                                    p_server_timezone_id,
                                    p_date_format,
				    'N');

   IF (v_difference > 31) THEN
     return v_close_date;
   ELSE
     return v_time_remaining;
   END IF;

END TIME_REMAINING_ONLY_NOTZ;
*/

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
) IS
 l_rowid                varchar2(30);
 l_attached_document_id number;
 l_document_id          number;
 l_media_id             number := NULL;
 l_lang                 varchar2(40);
 l_category_id          NUMBER;
BEGIN
  SELECT category_id, fnd_attached_documents_s.nextval
  INTO l_category_id, l_attached_document_id
  FROM fnd_document_categories
  WHERE name = p_category_name;

  fnd_attached_documents_pkg.insert_row (
        x_rowid                 => l_rowid                      ,
        x_attached_document_id  =>l_attached_document_id,
        x_document_id           => l_document_id                ,
        x_creation_date         => SYSDATE                      ,
        x_created_by            => fnd_global.user_id           ,
        x_last_update_date      => SYSDATE                      ,
        x_last_updated_by       => fnd_global.user_id           ,
        x_last_update_login     => fnd_global.login_id          ,
        x_seq_num               => p_seq_num                    ,
        x_entity_name           => p_entity_name                ,
        x_column1               => NULL                         ,
        x_pk1_value             => p_pk1_value                  ,
        x_pk2_value             => p_pk2_value                  ,
        x_pk3_value             => p_pk3_value                  ,
        x_pk4_value             => p_pk4_value                  ,
        x_pk5_value             => p_pk5_value                  ,
        x_automatically_added_flag      => 'N'                  ,
        x_request_id            => NULL                         ,
        x_program_application_id        =>NULL                  ,
        x_program_id            => NULL                         ,
        x_program_update_date   => NULL                         ,
        x_attribute_category    => NULL                         ,
        x_attribute1            => NULL                         ,
        x_attribute2            => NULL                         ,
        x_attribute3            => NULL                         ,
        x_attribute4            => NULL                         ,
        x_attribute5            => NULL                         ,
        x_attribute6            => NULL                         ,
        x_attribute7            => NULL                         ,
        x_attribute8            => NULL                         ,
        x_attribute9            => NULL                         ,
        x_attribute10           => NULL                         ,
        x_attribute11           => NULL                         ,
        x_attribute12           => NULL                         ,
        x_attribute13           => NULL                         ,
        x_attribute14           => NULL                         ,
        x_attribute15           => NULL                         ,
        x_datatype_id           => p_datatype_id                ,
        x_category_id           => l_category_id                ,
        x_security_type         => 4                            ,
        x_security_id           => NULL                         ,
        x_publish_flag          => 'Y'                          ,
        x_image_type            => NULL                         ,
        x_storage_type          => NULL                         ,
        x_usage_type            => 'O'                          ,
        x_language              => USERENV('LANG')              ,
        x_description           => p_document_description       ,
        x_url                   => p_url                        ,
        x_media_id              => l_media_id                   ,
        x_doc_attribute_category        => NULL                 ,
        x_doc_attribute1        => NULL                         ,
        x_doc_attribute2        => NULL                         ,
        x_doc_attribute3        => NULL                         ,
        x_doc_attribute4        => NULL                         ,
        x_doc_attribute5        => NULL                         ,
        x_doc_attribute6        => NULL                         ,
        x_doc_attribute7        => NULL                         ,
        x_doc_attribute8        => NULL                         ,
        x_doc_attribute9        => NULL                         ,
        x_doc_attribute10       => NULL                         ,
        x_doc_attribute11       => NULL                         ,
        x_doc_attribute12       => NULL                         ,
        x_doc_attribute13       => NULL                         ,
        x_doc_attribute14       => NULL                         ,
        x_doc_attribute15       => NULL
  );
END create_url_attachment;


/*=========================================================================+
--
-- 12.0 ECO 4749273 - SEND TO LIST BEHAVIOR CHANGE IN ONLINE DISCUSSION
--
-- GET_TEAM_MEMBER_CNT takes AUCTION_HEADER_ID,DISCUSSION_ID,
-- USER_ID and TRADING_PARTNER_CONTACT_ID as parameters and
--
-- Returns the number of team members for given negotiation.
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
                             p_trading_partner_contact_id IN NUMBER) return NUMBER
AS
l_member_cnt NUMBER := 0;
BEGIN
 BEGIN
     SELECT COUNT(1)
     INTO l_member_cnt
     FROM pon_neg_team_members pntm
     WHERE pntm.auction_header_id = p_auction_header_id
       AND (pntm.user_id <> p_user_id
             OR EXISTS(SELECT 1
                       FROM pon_thread_entries pte
                       WHERE pte.discussion_id = p_discussion_id
                         AND pte.from_id <> p_trading_partner_contact_id
                         AND pte.vendor_id IS NULL
                       )
            );

 EXCEPTION
   WHEN OTHERS THEN
      l_member_cnt := 0;
 END;

 RETURN l_member_cnt;

END GET_TEAM_MEMBER_CNT;

/*======================================================================
  *  FUNCTION :  APPROVAL_CONDITION    PUBLIC
  *  PARAMETERS:
  *     p_user_id         IN     User Id of the Buyer
  *
  *  COMMENT   : Returns whether the Negotiation requires approval from
  *     the manager of the buyer if present
  *======================================================================*/

  FUNCTION APPROVAL_CONDITION(p_user_id IN NUMBER) RETURN VARCHAR2
  IS
  v_is_manager_present NUMBER := 0;
  v_approval_status VARCHAR2(50) := NULL;
  v_display_approval_status fnd_new_messages.message_text%TYPE := NULL;
  BEGIN

     SELECT count(1)
     INTO v_is_manager_present
     FROM per_all_assignments_f ass,
          fnd_user sup,
          fnd_user emp,
          per_all_people_f per
     WHERE ass.person_id = emp.employee_id
      AND ass.supervisor_id = sup.employee_id
      AND ass.primary_flag = 'Y'
      AND ass.assignment_type = 'E'
      AND TRUNC(sysdate) BETWEEN ass.effective_start_date
      AND ass.effective_end_date
      AND sup.start_date <= sysdate
      AND nvl(sup.end_date,   sysdate) >= sysdate
      AND per.person_id = sup.employee_id
      AND emp.user_id = p_user_id
      AND TRUNC(SYSDATE) BETWEEN per.effective_start_date AND per.effective_end_date
      AND rownum = 1;

     IF v_is_manager_present > 0 THEN
       v_approval_status := 'PON_AUC_APPROVAL_REQUIRED';
     ELSE
       v_approval_status := 'PON_AUC_APPROVAL_NOT_REQUIRED';
     END IF;

     SELECT message_text
       INTO v_display_approval_status
     FROM fnd_new_messages
     WHERE application_id = 396
       AND language_code = userenv('LANG')
       AND message_name = v_approval_status;

      RETURN v_display_approval_status;

   END APPROVAL_CONDITION;

END PON_OA_UTIL_PKG;

/

  GRANT EXECUTE ON "APPS"."PON_OA_UTIL_PKG" TO "EBSBI";
