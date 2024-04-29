--------------------------------------------------------
--  DDL for Package Body OZF_CREATE_OZF_PROD_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CREATE_OZF_PROD_LINE_PKG" as
/* $Header: ozftodpb.pls 120.0 2005/06/01 02:55:05 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Create_Ozf_Prod_Line_PKG
-- Purpose
--
-- History
--           Wed May 18 2005:11/52 AM RSSHARMA Added Insert_row and Update_row methods for Volume Offer
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Create_Ozf_Prod_Line_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftodpb.pls';




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
          px_off_discount_product_id   IN OUT NOCOPY NUMBER,
          p_parent_off_disc_prod_id IN NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offer_discount_products(
           off_discount_product_id,
           parent_off_disc_prod_id,
           product_level,
           product_id,
           excluder_flag,
           uom_code,
           start_date_active,
           end_date_active,
           offer_discount_line_id,
           offer_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_off_discount_product_id, FND_API.G_MISS_NUM, NULL, px_off_discount_product_id),
           DECODE( p_parent_off_disc_prod_id, FND_API.G_MISS_NUM, NULL, p_parent_off_disc_prod_id),
           DECODE( p_product_level, FND_API.g_miss_char, NULL, p_product_level),
           DECODE( p_product_id, FND_API.G_MISS_NUM, NULL, p_product_id),
           DECODE( p_excluder_flag, FND_API.g_miss_char, NULL, p_excluder_flag),
           DECODE( p_uom_code, FND_API.g_miss_char, NULL, p_uom_code),
           DECODE( p_start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
           DECODE( p_end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
           DECODE( p_offer_discount_line_id, FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id),
           DECODE( p_offer_id, FND_API.G_MISS_NUM, NULL, p_offer_id),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number));

END Insert_Row;



--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE  Insert row for Release 12 Volume Offers
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_off_discount_product_id   IN OUT NOCOPY NUMBER,
          p_parent_off_disc_prod_id IN NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_product_context VARCHAR2,
          p_product_attribute VARCHAR2,
          p_product_attr_value VARCHAR2,
          p_apply_discount_flag VARCHAR2,
          p_include_volume_flag VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offer_discount_products(
           off_discount_product_id,
           parent_off_disc_prod_id,
           product_level,
           product_id,
           excluder_flag,
           uom_code,
           start_date_active,
           end_date_active,
           offer_discount_line_id,
           offer_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           product_context,
           product_attribute,
           product_attr_value,
           apply_discount_flag,
           include_volume_flag,
           object_version_number
   ) VALUES (
           DECODE( px_off_discount_product_id, FND_API.G_MISS_NUM, NULL, px_off_discount_product_id),
           DECODE( p_parent_off_disc_prod_id, FND_API.G_MISS_NUM, NULL, p_parent_off_disc_prod_id),
           DECODE( p_product_level, FND_API.g_miss_char, NULL, p_product_level),
           DECODE( p_product_id, FND_API.G_MISS_NUM, NULL, p_product_id),
           DECODE( p_excluder_flag, FND_API.g_miss_char, NULL, p_excluder_flag),
           DECODE( p_uom_code, FND_API.g_miss_char, NULL, p_uom_code),
           DECODE( p_start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
           DECODE( p_end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
           DECODE( p_offer_discount_line_id, FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id),
           DECODE( p_offer_id, FND_API.G_MISS_NUM, NULL, p_offer_id),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_product_context, FND_API.g_miss_char, NULL, p_product_context),
           DECODE( p_product_attribute, FND_API.g_miss_char, NULL, p_product_attribute),
           DECODE( p_product_attr_value, FND_API.g_miss_char, NULL, p_product_attr_value),
           DECODE( p_apply_discount_flag, FND_API.g_miss_char, NULL, p_apply_discount_flag),
           DECODE( p_include_volume_flag, FND_API.g_miss_char, NULL, p_include_volume_flag),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number)
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
          p_off_discount_product_id    NUMBER,
          p_parent_off_disc_prod_id    NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER)

 IS
 BEGIN
    Update ozf_offer_discount_products
    SET
              off_discount_product_id = DECODE( p_off_discount_product_id, null, off_discount_product_id, FND_API.G_MISS_NUM, null, p_off_discount_product_id),
              parent_off_disc_prod_id = DECODE( p_parent_off_disc_prod_id, null, parent_off_disc_prod_id, FND_API.G_MISS_NUM, null, p_parent_off_disc_prod_id),
              product_level = DECODE( p_product_level, null, product_level, FND_API.g_miss_char, null, p_product_level),
              product_id = DECODE( p_product_id, null, product_id, FND_API.G_MISS_NUM, null, p_product_id),
              excluder_flag = DECODE( p_excluder_flag, null, excluder_flag, FND_API.g_miss_char, null, p_excluder_flag),
              uom_code = DECODE( p_uom_code, null, uom_code, FND_API.g_miss_char, null, p_uom_code),
              start_date_active = DECODE( p_start_date_active, to_date(NULL), start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
              end_date_active = DECODE( p_end_date_active, to_date(NULL), end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
              offer_discount_line_id = DECODE( p_offer_discount_line_id, null, offer_discount_line_id, FND_API.G_MISS_NUM, null, p_offer_discount_line_id),
              offer_id = DECODE( p_offer_id, null, offer_id, FND_API.G_MISS_NUM, null, p_offer_id),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = nvl(p_object_version_number,0) + 1
   WHERE off_discount_product_id = p_off_discount_product_id
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
--  PURPOSE  Update row for Release 12 Volume Offers
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_off_discount_product_id    NUMBER,
          p_parent_off_disc_prod_id    NUMBER,
          p_product_level    VARCHAR2,
          p_product_id    NUMBER,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_offer_discount_line_id    NUMBER,
          p_offer_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_product_context VARCHAR2,
          p_product_attribute VARCHAR2,
          p_product_attr_value VARCHAR2,
          p_apply_discount_flag VARCHAR2,
          p_include_volume_flag VARCHAR2,
          p_object_version_number   IN NUMBER)

 IS
 BEGIN
    Update ozf_offer_discount_products
    SET
              off_discount_product_id = DECODE( p_off_discount_product_id, null, off_discount_product_id, FND_API.G_MISS_NUM, null, p_off_discount_product_id),
              parent_off_disc_prod_id = DECODE( p_parent_off_disc_prod_id, null, parent_off_disc_prod_id, FND_API.G_MISS_NUM, null, p_parent_off_disc_prod_id),
              product_level = DECODE( p_product_level, null, product_level, FND_API.g_miss_char, null, p_product_level),
              product_id = DECODE( p_product_id, null, product_id, FND_API.G_MISS_NUM, null, p_product_id),
              excluder_flag = DECODE( p_excluder_flag, null, excluder_flag, FND_API.g_miss_char, null, p_excluder_flag),
              uom_code = DECODE( p_uom_code, null, uom_code, FND_API.g_miss_char, null, p_uom_code),
              start_date_active = DECODE( p_start_date_active, to_date(NULL), start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
              end_date_active = DECODE( p_end_date_active, to_date(NULL), end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
              offer_discount_line_id = DECODE( p_offer_discount_line_id, null, offer_discount_line_id, FND_API.G_MISS_NUM, null, p_offer_discount_line_id),
              offer_id = DECODE( p_offer_id, null, offer_id, FND_API.G_MISS_NUM, null, p_offer_id),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              product_context = DECODE( p_product_context, null, product_context, FND_API.g_miss_char, null, p_product_context),
              product_attribute = DECODE( p_product_attribute, null, product_attribute, FND_API.g_miss_char, null, p_product_attribute),
              product_attr_value = DECODE( p_product_attr_value, null, product_attr_value, FND_API.g_miss_char, null, p_product_attr_value),
              apply_discount_flag = DECODE( p_apply_discount_flag, null, apply_discount_flag, FND_API.g_miss_char, null, p_apply_discount_flag),
              include_volume_flag = DECODE( p_include_volume_flag, null, include_volume_flag, FND_API.g_miss_char, null, p_include_volume_flag),
            object_version_number = nvl(p_object_version_number,0) + 1
   WHERE off_discount_product_id = p_off_discount_product_id
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
    p_off_discount_product_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_offer_discount_products
    WHERE off_discount_product_id = p_off_discount_product_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;


PROCEDURE Delete_Product(
    p_offer_discount_line_id  NUMBER
)
IS
BEGIN
DELETE FROM ozf_offer_discount_products
WHERE offer_discount_line_id = p_offer_discount_line_id;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

END Delete_Product;


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
    p_off_discount_product_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_offer_discount_products
        WHERE off_discount_product_id =  p_off_discount_product_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF off_discount_product_id NOWAIT;
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



END OZF_Create_Ozf_Prod_Line_PKG;

/
