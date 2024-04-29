--------------------------------------------------------
--  DDL for Package Body OZF_DISC_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_DISC_LINE_PKG" as
/* $Header: ozftodlb.pls 120.1 2006/05/04 15:25:15 julou noship $ */
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_DISC_LINE_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftdlb.pls';




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
          p_offer_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offer_discount_lines(
           offer_discount_line_id,
           parent_discount_line_id,
           volume_from,
           volume_to,
           volume_operator,
           volume_type,
           volume_break_type,
           discount,
           discount_type,
           tier_type,
           tier_level,
           incompatibility_group,
           precedence,
           bucket,
           scan_value,
           scan_data_quantity,
           scan_unit_forecast,
           channel_id,
           adjustment_flag,
           start_date_active,
           end_date_active,
           uom_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number,
           context,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           offer_id
   ) VALUES (
           DECODE( px_offer_discount_line_id, FND_API.G_MISS_NUM, NULL, px_offer_discount_line_id),
           DECODE( p_parent_discount_line_id, FND_API.G_MISS_NUM, NULL, p_parent_discount_line_id),
           DECODE( p_volume_from, FND_API.G_MISS_NUM, NULL, p_volume_from),
           DECODE( p_volume_to, FND_API.G_MISS_NUM, NULL, p_volume_to),
           DECODE( p_volume_operator, FND_API.g_miss_char, NULL, p_volume_operator),
           DECODE( p_volume_type, FND_API.g_miss_char, NULL, p_volume_type),
           DECODE( p_volume_break_type, FND_API.g_miss_char, NULL, p_volume_break_type),
           DECODE( p_discount, FND_API.G_MISS_NUM, NULL, p_discount),
           DECODE( p_discount_type, FND_API.g_miss_char, NULL, p_discount_type),
           DECODE( p_tier_type, FND_API.g_miss_char, NULL, p_tier_type),
           DECODE( p_tier_level, FND_API.g_miss_char, NULL, p_tier_level),
           DECODE( p_incompatibility_group, FND_API.g_miss_char, NULL, p_incompatibility_group),
           DECODE( p_precedence, FND_API.G_MISS_NUM, NULL, p_precedence),
           DECODE( p_bucket, FND_API.g_miss_char, NULL, p_bucket),
           DECODE( p_scan_value, FND_API.G_MISS_NUM, NULL, p_scan_value),
           DECODE( p_scan_data_quantity, FND_API.G_MISS_NUM, NULL, p_scan_data_quantity),
           DECODE( p_scan_unit_forecast, FND_API.G_MISS_NUM, NULL, p_scan_unit_forecast),
           DECODE( p_channel_id, FND_API.G_MISS_NUM, NULL, p_channel_id),
           DECODE( p_adjustment_flag, FND_API.g_miss_char, NULL, p_adjustment_flag),
           DECODE( p_start_date_active, FND_API.G_MISS_DATE, to_date(NULL) , p_start_date_active),
           DECODE( p_end_date_active, FND_API.G_MISS_DATE,  to_date(NULL), p_end_date_active),
           DECODE( p_uom_code, FND_API.g_miss_char, NULL, p_uom_code),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
            DECODE( p_context, FND_API.g_miss_char, NULL, p_context),
            DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
            DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
            DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
            DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
            DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
            DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
            DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
            DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
            DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
            DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
            DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
            DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
            DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
            DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
            DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15),
           DECODE( p_offer_id, FND_API.G_MISS_NUM, NULL, p_offer_id));

END Insert_Row;

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
          p_formula_id NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offer_discount_lines(
           offer_discount_line_id,
           parent_discount_line_id,
           volume_from,
           volume_to,
           volume_operator,
           volume_type,
           volume_break_type,
           discount,
           discount_type,
           tier_type,
           tier_level,
           incompatibility_group,
           precedence,
           bucket,
           scan_value,
           scan_data_quantity,
           scan_unit_forecast,
           channel_id,
           adjustment_flag,
           start_date_active,
           end_date_active,
           uom_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number,
           context,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15,
           offer_id,
           formula_id
   ) VALUES (
           DECODE( px_offer_discount_line_id, FND_API.G_MISS_NUM, NULL, px_offer_discount_line_id),
           DECODE( p_parent_discount_line_id, FND_API.G_MISS_NUM, NULL, p_parent_discount_line_id),
           DECODE( p_volume_from, FND_API.G_MISS_NUM, NULL, p_volume_from),
           DECODE( p_volume_to, FND_API.G_MISS_NUM, NULL, p_volume_to),
           DECODE( p_volume_operator, FND_API.g_miss_char, NULL, p_volume_operator),
           DECODE( p_volume_type, FND_API.g_miss_char, NULL, p_volume_type),
           DECODE( p_volume_break_type, FND_API.g_miss_char, NULL, p_volume_break_type),
           DECODE( p_discount, FND_API.G_MISS_NUM, NULL, p_discount),
           DECODE( p_discount_type, FND_API.g_miss_char, NULL, p_discount_type),
           DECODE( p_tier_type, FND_API.g_miss_char, NULL, p_tier_type),
           DECODE( p_tier_level, FND_API.g_miss_char, NULL, p_tier_level),
           DECODE( p_incompatibility_group, FND_API.g_miss_char, NULL, p_incompatibility_group),
           DECODE( p_precedence, FND_API.G_MISS_NUM, NULL, p_precedence),
           DECODE( p_bucket, FND_API.g_miss_char, NULL, p_bucket),
           DECODE( p_scan_value, FND_API.G_MISS_NUM, NULL, p_scan_value),
           DECODE( p_scan_data_quantity, FND_API.G_MISS_NUM, NULL, p_scan_data_quantity),
           DECODE( p_scan_unit_forecast, FND_API.G_MISS_NUM, NULL, p_scan_unit_forecast),
           DECODE( p_channel_id, FND_API.G_MISS_NUM, NULL, p_channel_id),
           DECODE( p_adjustment_flag, FND_API.g_miss_char, NULL, p_adjustment_flag),
           DECODE( p_start_date_active, FND_API.G_MISS_DATE, to_date(NULL) , p_start_date_active),
           DECODE( p_end_date_active, FND_API.G_MISS_DATE,  to_date(NULL), p_end_date_active),
           DECODE( p_uom_code, FND_API.g_miss_char, NULL, p_uom_code),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
            DECODE( p_context, FND_API.g_miss_char, NULL, p_context),
            DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
            DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
            DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
            DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
            DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
            DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
            DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
            DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
            DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
            DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
            DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
            DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
            DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
            DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
            DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15),
           DECODE( p_offer_id, FND_API.G_MISS_NUM, NULL, p_offer_id),
           DECODE( p_formula_id, FND_API.G_MISS_NUM, NULL, p_formula_id)
           );

END Insert_Row;






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
          p_offer_id    NUMBER)

 IS
 BEGIN
    Update ozf_offer_discount_lines
    SET
              offer_discount_line_id = DECODE( p_offer_discount_line_id, null, offer_discount_line_id, FND_API.G_MISS_NUM, null, p_offer_discount_line_id),
              parent_discount_line_id = DECODE( p_parent_discount_line_id, null, parent_discount_line_id, FND_API.G_MISS_NUM, null, p_parent_discount_line_id),
              volume_from = DECODE( p_volume_from, null, volume_from, FND_API.G_MISS_NUM, null, p_volume_from),
              volume_to = DECODE( p_volume_to, null, volume_to, FND_API.G_MISS_NUM, null, p_volume_to),
              volume_operator = DECODE( p_volume_operator, null, volume_operator, FND_API.g_miss_char, null, p_volume_operator),
              volume_type = DECODE( p_volume_type, null, volume_type, FND_API.g_miss_char, null, p_volume_type),
              volume_break_type = DECODE( p_volume_break_type, null, volume_break_type, FND_API.g_miss_char, null, p_volume_break_type),
              discount = DECODE( p_discount, null, discount, FND_API.G_MISS_NUM, null, p_discount),
              discount_type = DECODE( p_discount_type, null, discount_type, FND_API.g_miss_char, null, p_discount_type),
              tier_type = DECODE( p_tier_type, null, tier_type, FND_API.g_miss_char, null, p_tier_type),
              tier_level = DECODE( p_tier_level, null, tier_level, FND_API.g_miss_char, null, p_tier_level),
              incompatibility_group = DECODE( p_incompatibility_group, null, incompatibility_group, FND_API.g_miss_char, null, p_incompatibility_group),
              precedence = DECODE( p_precedence, null, precedence, FND_API.G_MISS_NUM, null, p_precedence),
              bucket = DECODE( p_bucket, null, bucket, FND_API.g_miss_char, null, p_bucket),
              scan_value = DECODE( p_scan_value, null, scan_value, FND_API.G_MISS_NUM, null, p_scan_value),
              scan_data_quantity = DECODE( p_scan_data_quantity, null, scan_data_quantity, FND_API.G_MISS_NUM, null, p_scan_data_quantity),
              scan_unit_forecast = DECODE( p_scan_unit_forecast, null, scan_unit_forecast, FND_API.G_MISS_NUM, null, p_scan_unit_forecast),
              channel_id = DECODE( p_channel_id, null, channel_id, FND_API.G_MISS_NUM, null, p_channel_id),
              adjustment_flag = DECODE( p_adjustment_flag, null, adjustment_flag, FND_API.g_miss_char, null, p_adjustment_flag),
              start_date_active = DECODE( p_start_date_active, to_date(NULL), start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
              end_date_active = DECODE( p_end_date_active, to_date(NULL), end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
              uom_code = DECODE( p_uom_code, null, uom_code, FND_API.g_miss_char, null, p_uom_code),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(null), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              object_version_number = nvl(p_object_version_number,0) + 1 ,
               context = DECODE( p_context, FND_API.g_miss_char, context, p_context),
               attribute1 = DECODE( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
               attribute2 = DECODE( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
               attribute3 = DECODE( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
               attribute4 = DECODE( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
               attribute5 = DECODE( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
               attribute6 = DECODE( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
               attribute7 = DECODE( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
               attribute8 = DECODE( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
               attribute9 = DECODE( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
               attribute10 = DECODE( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
               attribute11 = DECODE( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
               attribute12 = DECODE( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
               attribute13 = DECODE( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
               attribute14 = DECODE( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
               attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15),
              offer_id = DECODE( p_offer_id, null, offer_id, FND_API.G_MISS_NUM, null, p_offer_id)
   WHERE offer_discount_line_id = p_offer_discount_line_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


END Update_Row;



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
          p_offer_id    NUMBER,
          p_formula_id NUMBER)

 IS
 BEGIN
    Update ozf_offer_discount_lines
    SET
              offer_discount_line_id = DECODE( p_offer_discount_line_id, null, offer_discount_line_id, FND_API.G_MISS_NUM, null, p_offer_discount_line_id),
              parent_discount_line_id = DECODE( p_parent_discount_line_id, null, parent_discount_line_id, FND_API.G_MISS_NUM, null, p_parent_discount_line_id),
              volume_from = DECODE( p_volume_from, null, volume_from, FND_API.G_MISS_NUM, null, p_volume_from),
              volume_to = DECODE( p_volume_to, null, volume_to, FND_API.G_MISS_NUM, null, p_volume_to),
              volume_operator = DECODE( p_volume_operator, null, volume_operator, FND_API.g_miss_char, null, p_volume_operator),
              volume_type = DECODE( p_volume_type, null, volume_type, FND_API.g_miss_char, null, p_volume_type),
              volume_break_type = DECODE( p_volume_break_type, null, volume_break_type, FND_API.g_miss_char, null, p_volume_break_type),
              discount = DECODE( p_discount, null, discount, FND_API.G_MISS_NUM, null, p_discount),
              discount_type = DECODE( p_discount_type, null, discount_type, FND_API.g_miss_char, null, p_discount_type),
              tier_type = DECODE( p_tier_type, null, tier_type, FND_API.g_miss_char, null, p_tier_type),
              tier_level = DECODE( p_tier_level, null, tier_level, FND_API.g_miss_char, null, p_tier_level),
              incompatibility_group = DECODE( p_incompatibility_group, null, incompatibility_group, FND_API.g_miss_char, null, p_incompatibility_group),
              precedence = DECODE( p_precedence, null, precedence, FND_API.G_MISS_NUM, null, p_precedence),
              bucket = DECODE( p_bucket, null, bucket, FND_API.g_miss_char, null, p_bucket),
              scan_value = DECODE( p_scan_value, null, scan_value, FND_API.G_MISS_NUM, null, p_scan_value),
              scan_data_quantity = DECODE( p_scan_data_quantity, null, scan_data_quantity, FND_API.G_MISS_NUM, null, p_scan_data_quantity),
              scan_unit_forecast = DECODE( p_scan_unit_forecast, null, scan_unit_forecast, FND_API.G_MISS_NUM, null, p_scan_unit_forecast),
              channel_id = DECODE( p_channel_id, null, channel_id, FND_API.G_MISS_NUM, null, p_channel_id),
              adjustment_flag = DECODE( p_adjustment_flag, null, adjustment_flag, FND_API.g_miss_char, null, p_adjustment_flag),
              start_date_active = DECODE( p_start_date_active, to_date(NULL), start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
              end_date_active = DECODE( p_end_date_active, to_date(NULL), end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
              uom_code = DECODE( p_uom_code, null, uom_code, FND_API.g_miss_char, null, p_uom_code),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(null), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
               context = DECODE( p_context, FND_API.g_miss_char, context, p_context),
               attribute1 = DECODE( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
               attribute2 = DECODE( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
               attribute3 = DECODE( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
               attribute4 = DECODE( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
               attribute5 = DECODE( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
               attribute6 = DECODE( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
               attribute7 = DECODE( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
               attribute8 = DECODE( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
               attribute9 = DECODE( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
               attribute10 = DECODE( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
               attribute11 = DECODE( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
               attribute12 = DECODE( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
               attribute13 = DECODE( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
               attribute14 = DECODE( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
               attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15),
              offer_id = DECODE( p_offer_id, null, offer_id, FND_API.G_MISS_NUM, null, p_offer_id),
              formula_id = DECODE( p_formula_id, null, formula_id, FND_API.G_MISS_NUM, null, p_formula_id)
   WHERE offer_discount_line_id = p_offer_discount_line_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


END Update_Row;



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
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_offer_discount_lines
    WHERE offer_discount_line_id = p_offer_discount_line_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;




PROCEDURE delete_tiers(p_offer_discount_line_id NUMBER)
IS
BEGIN
    DELETE FROM ozf_offer_discount_lines WHERE parent_discount_line_id = p_offer_discount_line_id;

   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

END delete_tiers;
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
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_offer_discount_lines
        WHERE offer_discount_line_id =  p_offer_discount_line_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF offer_discount_line_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;



END OZF_DISC_LINE_PKG;

/
