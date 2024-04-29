--------------------------------------------------------
--  DDL for Package IRC_OFFERS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_OFFERS_BK3" AUTHID CURRENT_USER as
/* $Header: iriofapi.pkh 120.10.12010000.1 2008/07/28 12:43:40 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_offer_b >----------------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_offer_b
  (
   P_OBJECT_VERSION_NUMBER       in number
  ,P_OFFER_ID                    in number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_offer_a >----------------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_offer_a
  (
   P_OBJECT_VERSION_NUMBER       in number
  ,P_OFFER_ID                    in number
  );
--
end IRC_OFFERS_BK3;

/
