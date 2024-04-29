--------------------------------------------------------
--  DDL for Package Body OZF_CODE_CONVERSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CODE_CONVERSION_PKG" as
/* $Header: ozftsccb.pls 120.3 2007/12/21 07:44:26 gdeepika ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Code_Conversion_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Code_Conversion_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftsccb.pls';




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
          px_code_conversion_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_org_id   IN OUT NOCOPY NUMBER,
          p_party_id    NUMBER,
          p_cust_account_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
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
          p_attribute15    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

  -- R12 Enhancements
  /* IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO px_org_id
       FROM DUAL;
   END IF;
   */

   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_code_conversions_all(
           code_conversion_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           org_id,
           party_id,
           cust_account_id,
           code_conversion_type,
           external_code,
           internal_code,
           description,
           start_date_active,
           end_date_active,
           attribute_category,
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
           attribute15
   ) VALUES (
           DECODE( px_code_conversion_id, FND_API.G_MISS_NUM, NULL, px_code_conversion_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_org_id, FND_API.G_MISS_NUM, NULL, px_org_id),
           DECODE( p_party_id, FND_API.G_MISS_NUM, NULL, p_party_id),
           DECODE( p_cust_account_id, FND_API.G_MISS_NUM, NULL, p_cust_account_id),
           DECODE( p_code_conversion_type, FND_API.g_miss_char, NULL, p_code_conversion_type),
           DECODE( p_external_code, FND_API.g_miss_char, NULL, p_external_code),
           DECODE( p_internal_code, FND_API.g_miss_char, NULL, p_internal_code),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
           DECODE( p_start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
           DECODE( p_end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
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
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15));

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
          p_code_conversion_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_org_id    NUMBER,
          p_party_id    NUMBER,
          p_cust_account_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
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
          p_attribute15    VARCHAR2)

 IS
 BEGIN
    Update ozf_code_conversions_all
    SET
              code_conversion_id = DECODE( p_code_conversion_id, null, code_conversion_id, FND_API.G_MISS_NUM, null, p_code_conversion_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              org_id = DECODE( p_org_id, null, org_id, FND_API.G_MISS_NUM, null, p_org_id),
              party_id = DECODE( p_party_id, null, party_id, FND_API.G_MISS_NUM, null, p_party_id),
              cust_account_id = DECODE( p_cust_account_id, null, cust_account_id, FND_API.G_MISS_NUM, null, p_cust_account_id),
              code_conversion_type = DECODE( p_code_conversion_type, null, code_conversion_type, FND_API.g_miss_char, null, p_code_conversion_type),
              external_code = DECODE( p_external_code, null, external_code, FND_API.g_miss_char, null, p_external_code),
              internal_code = DECODE( p_internal_code, null, internal_code, FND_API.g_miss_char, null, p_internal_code),
              description = DECODE( p_description, null, description, FND_API.g_miss_char, null, p_description),
              start_date_active = DECODE( p_start_date_active, to_date(NULL), start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
              end_date_active = DECODE( p_end_date_active, to_date(NULL), end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
              attribute_category = DECODE( p_attribute_category, null, attribute_category, FND_API.g_miss_char, null, p_attribute_category),
              attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.g_miss_char, null, p_attribute1),
              attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.g_miss_char, null, p_attribute2),
              attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.g_miss_char, null, p_attribute3),
              attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.g_miss_char, null, p_attribute4),
              attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.g_miss_char, null, p_attribute5),
              attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.g_miss_char, null, p_attribute6),
              attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.g_miss_char, null, p_attribute7),
              attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.g_miss_char, null, p_attribute8),
              attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.g_miss_char, null, p_attribute9),
              attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.g_miss_char, null, p_attribute10),
              attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.g_miss_char, null, p_attribute11),
              attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.g_miss_char, null, p_attribute12),
              attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.g_miss_char, null, p_attribute13),
              attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.g_miss_char, null, p_attribute14),
              attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.g_miss_char, null, p_attribute15)
   WHERE code_conversion_id = p_code_conversion_id
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
    p_code_conversion_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_code_conversions_all
    WHERE code_conversion_id = p_code_conversion_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;


--  ========================================================
--
--  NAME
--  Insert_Supp_Code_Conv_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Supp_Code_Conv_Row(
          px_code_conversion_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_org_id   IN OUT NOCOPY NUMBER,

          p_supp_trade_profile_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
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
          p_attribute15    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN

  -- R12 Enhancements
  /* IF (px_org_id IS NULL OR px_org_id = FND_API.G_MISS_NUM) THEN
       SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
       INTO px_org_id
       FROM DUAL;
   END IF;
   */

   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_supp_code_conversions_all(
           code_conversion_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           org_id,
           supp_trade_profile_id,
           code_conversion_type,
           external_code,
           internal_code,
           description,
           start_date_active,
           end_date_active,
           attribute_category,
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
           attribute15
   ) VALUES (
           DECODE( px_code_conversion_id, FND_API.G_MISS_NUM, NULL, px_code_conversion_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_org_id, FND_API.G_MISS_NUM, NULL, px_org_id),
           DECODE( p_supp_trade_profile_id, FND_API.G_MISS_NUM, NULL,p_supp_trade_profile_id ),
           DECODE( p_code_conversion_type, FND_API.g_miss_char, NULL, p_code_conversion_type),
           DECODE( p_external_code, FND_API.g_miss_char, NULL, p_external_code),
           DECODE( p_internal_code, FND_API.g_miss_char, NULL, p_internal_code),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
           DECODE( p_start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
           DECODE( p_end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
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
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15));

END Insert_Supp_Code_Conv_Row;




--  ========================================================
--
--  NAME
--  Update_Supp_Code_Conv_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Supp_Code_Conv_Row(
          p_code_conversion_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_org_id    NUMBER,
          p_supp_trade_profile_id    NUMBER,
          p_code_conversion_type    VARCHAR2,
          p_external_code    VARCHAR2,
          p_internal_code    VARCHAR2,
          p_description    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_attribute_category    VARCHAR2,
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
          p_attribute15    VARCHAR2)

 IS
 BEGIN
    Update ozf_supp_code_conversions_all
    SET
              code_conversion_id = DECODE( p_code_conversion_id, null, code_conversion_id, FND_API.G_MISS_NUM, null, p_code_conversion_id),
              object_version_number = nvl(p_object_version_number,0) + 1 ,
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              org_id = DECODE( p_org_id, null, org_id, FND_API.G_MISS_NUM, null, p_org_id),
              supp_trade_profile_id = DECODE( p_supp_trade_profile_id, null, supp_trade_profile_id, FND_API.G_MISS_NUM, null, p_supp_trade_profile_id),
              code_conversion_type = DECODE( p_code_conversion_type, null, code_conversion_type, FND_API.g_miss_char, null, p_code_conversion_type),
              external_code = DECODE( p_external_code, null, external_code, FND_API.g_miss_char, null, p_external_code),
              internal_code = DECODE( p_internal_code, null, internal_code, FND_API.g_miss_char, null, p_internal_code),
              description = DECODE( p_description, null, description, FND_API.g_miss_char, null, p_description),
              start_date_active = DECODE( p_start_date_active, to_date(NULL), start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
              end_date_active = DECODE( p_end_date_active, to_date(NULL), end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
              attribute_category = DECODE( p_attribute_category, null, attribute_category, FND_API.g_miss_char, null, p_attribute_category),
              attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.g_miss_char, null, p_attribute1),
              attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.g_miss_char, null, p_attribute2),
              attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.g_miss_char, null, p_attribute3),
              attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.g_miss_char, null, p_attribute4),
              attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.g_miss_char, null, p_attribute5),
              attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.g_miss_char, null, p_attribute6),
              attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.g_miss_char, null, p_attribute7),
              attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.g_miss_char, null, p_attribute8),
              attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.g_miss_char, null, p_attribute9),
              attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.g_miss_char, null, p_attribute10),
              attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.g_miss_char, null, p_attribute11),
              attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.g_miss_char, null, p_attribute12),
              attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.g_miss_char, null, p_attribute13),
              attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.g_miss_char, null, p_attribute14),
              attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.g_miss_char, null, p_attribute15)
   WHERE code_conversion_id = p_code_conversion_id
   AND   object_version_number = p_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


END Update_Supp_Code_Conv_Row;




--  ========================================================
--
--  NAME
--  Delete_Supp_Code_Conv_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Supp_Code_Conv_Row(
    p_code_conversion_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_supp_code_conversions_all
    WHERE code_conversion_id = p_code_conversion_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Supp_Code_Conv_Row ;




END OZF_Code_Conversion_PKG;


/
