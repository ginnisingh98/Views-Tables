--------------------------------------------------------
--  DDL for Package PON_AUCTION_DISCUSSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUCTION_DISCUSSION_PKG" AUTHID CURRENT_USER AS
/* $Header: PONAUCDS.pls 120.0 2005/06/01 17:53:33 appldev noship $ */

  FUNCTION GET_UNREAD_MESSAGE_COUNT (p_auction_header_id NUMBER,
                                     p_user_id NUMBER,
                                     p_company_id NUMBER) RETURN NUMBER;

 /*
  * This function will be invoked from Discussion Summary page.
  * The function will return the value one of the following values.
  *  RepliedByOth    : if any neg team member has already replied to the given message.
  *  NotRepliedByOth : No body has replied yet to the given message.
  */
  FUNCTION GET_REPLIED_STATUS( p_to_id IN NUMBER,
                               p_entry_id IN NUMBER,
                               p_auctioneer_tp_id IN NUMBER,
                               p_message_type IN VARCHAR2
                              )
                              RETURN VARCHAR2;

END PON_AUCTION_DISCUSSION_PKG;

 

/
