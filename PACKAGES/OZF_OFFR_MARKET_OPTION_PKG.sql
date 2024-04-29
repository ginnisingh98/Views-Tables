--------------------------------------------------------
--  DDL for Package OZF_OFFR_MARKET_OPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OFFR_MARKET_OPTION_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftomos.pls 120.0 2005/06/23 10:51:06 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFR_MARKET_OPTION_PKG
-- Purpose
--
-- History
--           Wed May 18 2005:11/57 AM RSSHARMA Added Insert_row and Update_row for Volume Offers
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
          px_offer_market_option_id IN OUT NOCOPY NUMBER
          , p_offer_id NUMBER
          , p_qp_list_header_id NUMBER
          , p_group_number NUMBER
          , p_retroactive_flag VARCHAR2
          , p_beneficiary_party_id NUMBER
          , p_combine_schedule_flag VARCHAR2
          , p_volume_tracking_level_code VARCHAR2
          , p_accrue_to_code VARCHAR2
          , p_precedence NUMBER
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
          p_offer_market_option_id NUMBER
          , p_offer_id NUMBER
          , p_qp_list_header_id NUMBER
          , p_group_number NUMBER
          , p_retroactive_flag VARCHAR2
          , p_beneficiary_party_id NUMBER
          , p_combine_schedule_flag VARCHAR2
          , p_volume_tracking_level_code VARCHAR2
          , p_accrue_to_code VARCHAR2
          , p_precedence NUMBER
          , p_object_version_number NUMBER
          , p_creation_date    DATE
          , p_created_by    NUMBER
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
    p_offer_market_option_id  NUMBER,
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
    p_offer_market_option_id  NUMBER,
    p_object_version_number  NUMBER);




END OZF_OFFR_MARKET_OPTION_PKG;

 

/
