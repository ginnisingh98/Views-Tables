--------------------------------------------------------
--  DDL for Package OZF_DISC_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_DISC_LINE_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftodls.pls 120.1 2006/05/04 15:25:26 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_DISC_LINE_PKG
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
          px_offer_discount_line_id   IN OUT NOCOPY NUMBER,
          p_parent_discount_line_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_operator    VARCHAR2,
          p_volume_type    VARCHAR2,
          p_volume_break_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_tier_level    VARCHAR2,
          p_incompatibility_group    VARCHAR2,
          p_precedence    NUMBER,
          p_bucket    VARCHAR2,
          p_scan_value    NUMBER,
          p_scan_data_quantity    NUMBER,
          p_scan_unit_forecast    NUMBER,
          p_channel_id    NUMBER,
          p_adjustment_flag    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
           p_context    VARCHAR2,
           p_attribute1    VARCHAR2,
           p_attribute2    VARCHAR2,
           p_attribute3    VARCHAR2,
           p_attribute4    VARCHAR2,
           p_attribute5    VARCHAR2,
           p_attribute6    VARCHAR2,
           p_attribute7    VARCHAR2,
           p_attribute8    VARCHAR2,
           p_attribute9    VARCHAR2,
           p_attribute10    VARCHAR2,
           p_attribute11    VARCHAR2,
           p_attribute12    VARCHAR2,
           p_attribute13    VARCHAR2,
           p_attribute14    VARCHAR2,
           p_attribute15    VARCHAR2,
          p_offer_id    NUMBER);


--  ========================================================
--
--  NAME
--  Insert_Row for volume offer
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_offer_discount_line_id   IN OUT NOCOPY NUMBER,
          p_parent_discount_line_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_operator    VARCHAR2,
          p_volume_type    VARCHAR2,
          p_volume_break_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_tier_level    VARCHAR2,
          p_incompatibility_group    VARCHAR2,
          p_precedence    NUMBER,
          p_bucket    VARCHAR2,
          p_scan_value    NUMBER,
          p_scan_data_quantity    NUMBER,
          p_scan_unit_forecast    NUMBER,
          p_channel_id    NUMBER,
          p_adjustment_flag    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
           p_context    VARCHAR2,
           p_attribute1    VARCHAR2,
           p_attribute2    VARCHAR2,
           p_attribute3    VARCHAR2,
           p_attribute4    VARCHAR2,
           p_attribute5    VARCHAR2,
           p_attribute6    VARCHAR2,
           p_attribute7    VARCHAR2,
           p_attribute8    VARCHAR2,
           p_attribute9    VARCHAR2,
           p_attribute10    VARCHAR2,
           p_attribute11    VARCHAR2,
           p_attribute12    VARCHAR2,
           p_attribute13    VARCHAR2,
           p_attribute14    VARCHAR2,
           p_attribute15    VARCHAR2,
          p_offer_id    NUMBER,
          p_formula_id NUMBER);




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
          p_offer_discount_line_id    NUMBER,
          p_parent_discount_line_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_operator    VARCHAR2,
          p_volume_type    VARCHAR2,
          p_volume_break_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_tier_level    VARCHAR2,
          p_incompatibility_group    VARCHAR2,
          p_precedence    NUMBER,
          p_bucket    VARCHAR2,
          p_scan_value    NUMBER,
          p_scan_data_quantity    NUMBER,
          p_scan_unit_forecast    NUMBER,
          p_channel_id    NUMBER,
          p_adjustment_flag    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_uom_code    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER,
           p_context    VARCHAR2,
           p_attribute1    VARCHAR2,
           p_attribute2    VARCHAR2,
           p_attribute3    VARCHAR2,
           p_attribute4    VARCHAR2,
           p_attribute5    VARCHAR2,
           p_attribute6    VARCHAR2,
           p_attribute7    VARCHAR2,
           p_attribute8    VARCHAR2,
           p_attribute9    VARCHAR2,
           p_attribute10    VARCHAR2,
           p_attribute11    VARCHAR2,
           p_attribute12    VARCHAR2,
           p_attribute13    VARCHAR2,
           p_attribute14    VARCHAR2,
           p_attribute15    VARCHAR2,
          p_offer_id    NUMBER);

--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE for volume_offer
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_offer_discount_line_id    NUMBER,
          p_parent_discount_line_id    NUMBER,
          p_volume_from    NUMBER,
          p_volume_to    NUMBER,
          p_volume_operator    VARCHAR2,
          p_volume_type    VARCHAR2,
          p_volume_break_type    VARCHAR2,
          p_discount    NUMBER,
          p_discount_type    VARCHAR2,
          p_tier_type    VARCHAR2,
          p_tier_level    VARCHAR2,
          p_incompatibility_group    VARCHAR2,
          p_precedence    NUMBER,
          p_bucket    VARCHAR2,
          p_scan_value    NUMBER,
          p_scan_data_quantity    NUMBER,
          p_scan_unit_forecast    NUMBER,
          p_channel_id    NUMBER,
          p_adjustment_flag    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_uom_code    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER,
           p_context    VARCHAR2,
           p_attribute1    VARCHAR2,
           p_attribute2    VARCHAR2,
           p_attribute3    VARCHAR2,
           p_attribute4    VARCHAR2,
           p_attribute5    VARCHAR2,
           p_attribute6    VARCHAR2,
           p_attribute7    VARCHAR2,
           p_attribute8    VARCHAR2,
           p_attribute9    VARCHAR2,
           p_attribute10    VARCHAR2,
           p_attribute11    VARCHAR2,
           p_attribute12    VARCHAR2,
           p_attribute13    VARCHAR2,
           p_attribute14    VARCHAR2,
           p_attribute15    VARCHAR2,
          p_offer_id    NUMBER,
          p_formula_id NUMBER
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
    p_offer_discount_line_id  NUMBER,
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
    p_offer_discount_line_id  NUMBER,
    p_object_version_number  NUMBER);



PROCEDURE delete_tiers(p_offer_discount_line_id NUMBER);

END OZF_DISC_LINE_PKG;

 

/
