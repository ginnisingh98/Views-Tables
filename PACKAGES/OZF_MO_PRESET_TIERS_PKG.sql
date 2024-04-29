--------------------------------------------------------
--  DDL for Package OZF_MO_PRESET_TIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_MO_PRESET_TIERS_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftmopts.pls 120.0 2005/07/11 18:16:49 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_MO_PRESET_TIERS_PKG
-- Purpose
--
-- History
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_market_preset_tier_id IN OUT NOCOPY NUMBER
          , p_offer_market_option_id NUMBER
          , p_pbh_offer_discount_id NUMBER
          , p_dis_offer_discount_id NUMBER
          , px_object_version_number IN OUT NOCOPY NUMBER
          , p_creation_date    DATE
          , p_created_by    NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          );

--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_market_preset_tier_id IN OUT NOCOPY NUMBER
          , p_offer_market_option_id NUMBER
          , p_pbh_offer_discount_id NUMBER
          , p_dis_offer_discount_id NUMBER
          , p_object_version_number IN OUT NOCOPY NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          );


--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_market_preset_tier_id  NUMBER,
    p_object_version_number  NUMBER);




--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_market_preset_tier_id  NUMBER,
    p_object_version_number  NUMBER);




END OZF_MO_PRESET_TIERS_PKG;

 

/
