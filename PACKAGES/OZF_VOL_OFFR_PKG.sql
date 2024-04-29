--------------------------------------------------------
--  DDL for Package OZF_VOL_OFFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_VOL_OFFR_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftvos.pls 120.0 2005/06/01 01:33:19 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Vol_Offr_PKG
-- Purpose
--
-- History
--
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
          px_volume_offer_tiers_id   IN OUT NOCOPY NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_discount    NUMBER,
          p_break_type_code    VARCHAR2,
          p_tier_value_from    NUMBER,
          p_tier_value_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_active    VARCHAR2,
          p_uom_code    VARCHAR2,
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
          p_volume_offer_tiers_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_discount    NUMBER,
          p_break_type_code    VARCHAR2,
          p_tier_value_from    NUMBER,
          p_tier_value_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_active    VARCHAR2,
          p_uom_code    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER
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
    p_volume_offer_tiers_id  NUMBER,
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
    p_volume_offer_tiers_id  NUMBER,
    p_object_version_number  NUMBER);


END OZF_Vol_Offr_PKG;

 

/
