--------------------------------------------------------
--  DDL for Package OZF_QUAL_MARKET_OPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QUAL_MARKET_OPTION_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftqmos.pls 120.0 2005/06/23 10:56:06 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_QUAL_MARKET_OPTION_PKG
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
        px_qualifier_market_option_id IN OUT NOCOPY NUMBER
        , p_offer_market_option_id NUMBER
        , p_qp_qualifier_id NUMBER
        , px_object_version_number IN OUT NOCOPY NUMBER
        , p_last_update_date DATE
        , p_last_updated_by NUMBER
        , p_creation_date DATE
        , p_created_by NUMBER
        , p_last_update_login NUMBER
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
        p_qualifier_market_option_id NUMBER
        , p_offer_market_option_id NUMBER
        , p_qp_qualifier_id NUMBER
        , p_object_version_number NUMBER
        , p_last_update_date DATE
        , p_last_updated_by NUMBER
        , p_last_update_login NUMBER
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
    p_qualifier_market_option_id  NUMBER,
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
    p_qualifier_market_option_id  NUMBER,
    p_object_version_number  NUMBER);




END OZF_QUAL_MARKET_OPTION_PKG;

 

/
