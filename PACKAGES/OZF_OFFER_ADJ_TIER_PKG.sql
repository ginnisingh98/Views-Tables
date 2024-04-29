--------------------------------------------------------
--  DDL for Package OZF_OFFER_ADJ_TIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFER_ADJ_TIER_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftoats.pls 120.1 2005/08/03 01:52:16 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adj_Tier_PKG
-- Purpose
--
-- History
--     Tue Aug 02 2005:10/45 PM RSSHARMA R12 changes.Added new Field for offer_discount_line_id
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
          px_offer_adjst_tier_id   IN OUT NOCOPY NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_offer_tiers_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_offer_discount_line_id NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER);





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
          p_offer_adjst_tier_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_offer_tiers_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_offer_discount_line_id NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER);





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
    p_offer_adjst_tier_id  NUMBER,
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
    p_offer_adjst_tier_id  NUMBER,
    p_object_version_number  NUMBER);


END OZF_Offer_Adj_Tier_PKG;

 

/
