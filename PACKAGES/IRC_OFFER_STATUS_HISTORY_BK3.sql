--------------------------------------------------------
--  DDL for Package IRC_OFFER_STATUS_HISTORY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFER_STATUS_HISTORY_BK3" AUTHID CURRENT_USER as
/* $Header: iriosapi.pkh 120.8.12010000.1 2008/07/28 12:43:59 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_offer_status_history_b >--------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_offer_status_history_b
  (
   P_OBJECT_VERSION_NUMBER     IN   NUMBER
  ,P_OFFER_STATUS_HISTORY_ID   IN   NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_offer_status_history_a >--------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_offer_status_history_a
  (
   P_OBJECT_VERSION_NUMBER     IN   NUMBER
  ,P_OFFER_STATUS_HISTORY_ID   IN   NUMBER
  );
end IRC_OFFER_STATUS_HISTORY_BK3;

/
