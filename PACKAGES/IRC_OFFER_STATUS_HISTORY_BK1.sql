--------------------------------------------------------
--  DDL for Package IRC_OFFER_STATUS_HISTORY_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_STATUS_HISTORY_BK1" AUTHID CURRENT_USER as
/* $Header: iriosapi.pkh 120.8.12010000.1 2008/07/28 12:43:59 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_offer_status_history_b >--------------------|
-- ----------------------------------------------------------------------------
--
  procedure create_offer_status_history_b
  ( P_EFFECTIVE_DATE     IN  DATE
   ,P_OFFER_ID           IN  NUMBER
   ,P_STATUS_CHANGE_DATE IN  DATE
   ,P_OFFER_STATUS       IN  VARCHAR2
   ,P_CHANGE_REASON      IN  VARCHAR2
   ,P_DECLINE_REASON     IN  VARCHAR2
   ,P_NOTE_TEXT          IN  VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_offer_status_history_a >--------------------|
-- ----------------------------------------------------------------------------
--
  procedure create_offer_status_history_a
  ( P_EFFECTIVE_DATE           IN  DATE
   ,P_OFFER_ID                 IN  NUMBER
   ,P_STATUS_CHANGE_DATE       IN  DATE
   ,P_OFFER_STATUS             IN  VARCHAR2
   ,P_CHANGE_REASON            IN  VARCHAR2
   ,P_DECLINE_REASON           IN  VARCHAR2
   ,P_NOTE_TEXT                IN  VARCHAR2
   ,P_OFFER_STATUS_HISTORY_ID  IN  NUMBER
   ,P_OBJECT_VERSION_NUMBER    IN  NUMBER
  );
--
end IRC_OFFER_STATUS_HISTORY_BK1;

/
