--------------------------------------------------------
--  DDL for Package Body PON_AUCTION_DISCUSSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUCTION_DISCUSSION_PKG" AS
/* $Header: PONAUCDB.pls 120.3.12010000.2 2014/11/08 10:30:49 spapana ship $ */

g_module_prefix        CONSTANT VARCHAR2(50) := 'pon.plsql.PON_AUCTION_DISCUSSION_PKG.';

FUNCTION GET_UNREAD_MESSAGE_COUNT (p_auction_header_id NUMBER,
                                   p_user_id NUMBER,
                                   p_company_id NUMBER) RETURN NUMBER IS

         unread_message_count NUMBER;
         row_found NUMBER;
         l_discussion_id NUMBER;
         l_module_name VARCHAR2(30) := 'GET_UNREAD_MESSAGE_COUNT';

BEGIN
         row_found := 0;

         -- Find if user has permission to view this discussion.
         -- If User donot have permission to view the discussion return 0.
         -- else fetch unread message count.
         BEGIN
            SELECT 1
             INTO row_found
             FROM pon_auction_headers_all ah
             WHERE ah.AUCTION_HEADER_ID = p_auction_header_id and
                   (ah.bid_list_type = 'PUBLIC_BID_LIST'
                    OR
                    ah.trading_partner_id = p_company_id
                    OR
                    EXISTS (SELECT 1
                             FROM pon_bidding_parties
                             WHERE auction_header_id = p_auction_header_id
                             AND trading_partner_id = p_company_id)
                    OR
                    EXISTS (SELECT 1
                             FROM pon_bid_headers
                             WHERE auction_header_id = p_auction_header_id
                             AND trading_partner_contact_id = p_user_id));
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
             row_found := 0;
         END;

         IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
              FND_LOG.string (log_level => FND_LOG.level_procedure,
              module => g_module_prefix || l_module_name,
              message  => 'Entering PON_THREAD_DISC_PKG.GET_UNREAD_MESSAGE_COUNT'
                      || ', row_found = ' || row_found
                      || ', p_auction_header_id = ' ||  p_auction_header_id
                      || ', p_user_id = ' || p_user_id
                      || ', p_company_id = '|| p_company_id  );
         END IF;


         IF (row_found = 1) THEN

             BEGIN
                 select discussion_id
                 into l_discussion_id
                 from pon_discussions pd
                 where pd.pk1_value = to_char(p_auction_header_id)
                 AND pd.entity_name = 'PON_AUCTION_HEADERS_ALL' ;
             EXCEPTION
	         WHEN TOO_MANY_ROWS THEN
                 IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string (log_level => FND_LOG.level_procedure,
                    module => g_module_prefix || l_module_name,
                    message  => 'PON_THREAD_DISC_PKG.GET_UNREAD_MESSAGE_COUNT'
                            || ', Exception : Multiple Discussion Rows found for given auction header id : '|| p_auction_header_id);
                 END IF;
                 select discussion_id
                 into l_discussion_id
                 from pon_discussions pd
                 where pd.pk1_value = to_char(p_auction_header_id)
                 AND pd.entity_name = 'PON_AUCTION_HEADERS_ALL'
                 AND ROWNUM = 1;
             END;

         IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
              FND_LOG.string (log_level => FND_LOG.level_procedure,
              module => g_module_prefix || l_module_name,
              message  => 'PON_THREAD_DISC_PKG.GET_UNREAD_MESSAGE_COUNT'
                      || ', l_discussion_id = '|| l_discussion_id);
         END IF;


             SELECT count(1)
             INTO unread_message_count
             FROM pon_thread_entries pte,
                 pon_auction_headers_all ah
             WHERE ah.auction_header_id = p_auction_header_id
                   AND pte.discussion_id = l_discussion_id
                   AND (((pte.broadcast_flag = 'N' OR pte.broadcast_flag = 'G')
                           AND
                           EXISTS (SELECT 1
                                   FROM pon_te_recipients
                                   WHERE entry_id = pte.entry_id
                                   -- Check that the message was sent directly to the user
                                   -- and has not yet been read by that user
                             AND ((to_id = p_user_id
                                   AND
                                   read_flag = 'N')
                             -- Check that the user belongs to the same company as the
                             -- negotiation creator but that the message has been sent to
                             -- the negotiation creator but has not yet been read by the user
                             OR
                             (ah.trading_partner_id = p_company_id
                              AND
                              pte.message_type='EXTERNAL'
                              AND entry_id not in
                                   (SELECT entry_id
                                     FROM pon_te_recipients
                                     WHERE to_id = p_user_id
                                     AND read_flag = 'Y'
                                     AND entry_id = pte.entry_id)
                             )
                       )
             )
           )
           OR
           (pte.broadcast_flag = 'Y'
            AND
              ((pte.message_type='EXTERNAL')
               OR
               (ah.trading_partner_id = p_company_id AND pte.message_type='INTERNAL')
               AND
               entry_id in (SELECT entry_id
                            FROM pon_te_recipients
                            WHERE to_id = p_user_id
                            AND entry_id = pte.entry_id)
             )
            AND
            (entry_id not in (SELECT entry_id
                              FROM pon_te_recipients
                              WHERE to_id = p_user_id
                              AND read_flag = 'Y'
                              AND entry_id = pte.entry_id)
            )));

         ELSE
            unread_message_count:=0;
         END IF;

  RETURN unread_message_count;

END;  --end of function


 /*
  * The function will return the value one of the following values.
  *  RepliedByOth    : if any neg team member has already replied to the given message.
  *  NotRepliedByOth : No body has replied yet to the given message.
  */
  FUNCTION GET_REPLIED_STATUS( p_to_id IN NUMBER, p_entry_id IN NUMBER,
                               p_auctioneer_tp_id IN NUMBER, p_message_type IN VARCHAR2 ) RETURN VARCHAR2 IS

     l_reply_count NUMBER;
     l_module_name VARCHAR2(25) := 'GET_REPLIED_STATUS';

  BEGIN
         IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
              FND_LOG.string (log_level => FND_LOG.level_procedure,
              module => g_module_prefix || l_module_name,
              message  => 'Entering PON_THREAD_DISC_PKG.GET_REPLIED_STATUS'
                      || ', p_to_id = ' ||  p_to_id
                      || ', p_auctioneer_tp_id = ' || p_auctioneer_tp_id
                      || ', p_entry_id = ' || p_entry_id
                      || ', p_message_type = '|| p_message_type);
         END IF;

        BEGIN
             -- Bug 19931871 : see bug for more details
             SELECT count(1) into l_reply_count
                FROM PON_TE_RECIPIENTS PTR,
                     PON_THREAD_ENTRIES PTE
                WHERE PTR.replied_flag ='Y'
                and PTR.entry_id = p_entry_id
                and PTE.ENTRY_ID = PTR.ENTRY_ID
                and PTR.to_company_id = p_auctioneer_tp_id   -- Auctioneer's trading partner id
                --and PTE.FROM_COMPANY_ID <> p_auctioneer_tp_id
                and PTR.to_id  <> p_to_id                    -- Replied by Others
                --and 'EXTERNAL'= p_message_type               -- Replied to External Messages
                and 'INTERNAL'= p_message_type
                and ROWNUM = 1;

         EXCEPTION
	     WHEN NO_DATA_FOUND THEN
                l_reply_count := 0;
         END;
	 IF( l_reply_count > 0 ) THEN
                return 'RepliedByOth';
         ELSE
                return 'NotRepliedByOth';
         END IF;
  END;


END PON_AUCTION_DISCUSSION_PKG;

/
