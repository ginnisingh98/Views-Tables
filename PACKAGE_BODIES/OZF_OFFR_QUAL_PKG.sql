--------------------------------------------------------
--  DDL for Package Body OZF_OFFR_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFR_QUAL_PKG" as
 /* $Header: ozftoqfb.pls 120.0 2005/06/01 00:36:39 appldev noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          OZF_Offr_Qual_PKG
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


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offr_Qual_PKG';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftoqfb.pls';




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
           px_qualifier_id   IN OUT NOCOPY NUMBER,
           p_creation_date    DATE,
           p_created_by    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_last_update_login    NUMBER,
           p_qualifier_grouping_no    NUMBER,
           p_qualifier_context    VARCHAR2,
           p_qualifier_attribute    VARCHAR2,
           p_qualifier_attr_value    VARCHAR2,
           p_start_date_active    DATE,
           p_end_date_active    DATE,
           p_offer_id    NUMBER,
           p_offer_discount_line_id    NUMBER,
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
           p_active_flag    VARCHAR2,
           p_object_version_number NUMBER)

  IS
    x_rowid    VARCHAR2(30);
    px_object_version_number NUMBER;

 BEGIN


    px_object_version_number := nvl(px_object_version_number, 1);

    INSERT INTO ozf_offer_qualifiers(
            qualifier_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            qualifier_grouping_no,
            qualifier_context,
            qualifier_attribute,
            qualifier_attr_value,
            start_date_active,
            end_date_active,
            offer_id,
            offer_discount_line_id,
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
            active_flag,
            object_version_number
    ) VALUES (
            DECODE( px_qualifier_id, FND_API.G_MISS_NUM, NULL, px_qualifier_id),
            DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
            DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
            DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
            DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
            DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
            DECODE( p_qualifier_grouping_no, FND_API.G_MISS_NUM, NULL, p_qualifier_grouping_no),
            DECODE( p_qualifier_context, FND_API.g_miss_char, NULL, p_qualifier_context),
            DECODE( p_qualifier_attribute, FND_API.g_miss_char, NULL, p_qualifier_attribute),
            DECODE( p_qualifier_attr_value, FND_API.g_miss_char, NULL, p_qualifier_attr_value),
            DECODE( p_start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
            DECODE( p_end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
            DECODE( p_offer_id, FND_API.G_MISS_NUM, NULL, p_offer_id),
            DECODE( p_offer_discount_line_id, FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id),
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
            DECODE( p_active_flag, FND_API.g_miss_char, NULL, p_active_flag),
            DECODE( p_object_version_number, FND_API.g_miss_num, NULL, p_object_version_number)
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
           p_qualifier_id    NUMBER,
           p_last_update_date    DATE,
           p_last_updated_by    NUMBER,
           p_last_update_login    NUMBER,
           p_qualifier_grouping_no    NUMBER,
           p_qualifier_context    VARCHAR2,
           p_qualifier_attribute    VARCHAR2,
           p_qualifier_attr_value    VARCHAR2,
           p_start_date_active    DATE,
           p_end_date_active    DATE,
           p_offer_id    NUMBER,
           p_offer_discount_line_id    NUMBER,
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
           p_active_flag    VARCHAR2,
           p_object_version_number NUMBER)

  IS
  BEGIN
     Update ozf_offer_qualifiers
     SET
               qualifier_id = DECODE( p_qualifier_id, null, qualifier_id, FND_API.G_MISS_NUM, null, p_qualifier_id),
               last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
               last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
               last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
               qualifier_grouping_no = DECODE( p_qualifier_grouping_no, null, qualifier_grouping_no, FND_API.G_MISS_NUM, null, p_qualifier_grouping_no),
               qualifier_context = DECODE( p_qualifier_context, null, qualifier_context, FND_API.g_miss_char, null, p_qualifier_context),
               qualifier_attribute = DECODE( p_qualifier_attribute, null, qualifier_attribute, FND_API.g_miss_char, null, p_qualifier_attribute),
               qualifier_attr_value = DECODE( p_qualifier_attr_value, null, qualifier_attr_value, FND_API.g_miss_char, null, p_qualifier_attr_value),
               start_date_active = DECODE( p_start_date_active, to_date(NULL), start_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_start_date_active),
               end_date_active = DECODE( p_end_date_active, to_date(NULL), end_date_active, FND_API.G_MISS_DATE, to_date(NULL), p_end_date_active),
               offer_id = DECODE( p_offer_id, null, offer_id, FND_API.G_MISS_NUM, null, p_offer_id),
               offer_discount_line_id = DECODE( p_offer_discount_line_id, null, offer_discount_line_id, FND_API.G_MISS_NUM, null, p_offer_discount_line_id),
               context = DECODE( p_context, null, context, FND_API.g_miss_char, null, p_context),
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
               attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.g_miss_char, null, p_attribute15),
               active_flag = DECODE( p_active_flag, null, active_flag, FND_API.g_miss_char, null, p_active_flag),
               object_version_number = DECODE(p_object_version_number,null,object_version_number,FND_API.g_miss_num,null,p_object_version_number+1)

    WHERE qualifier_id = p_qualifier_id
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
     p_qualifier_id  NUMBER,
     p_object_version_number  NUMBER)
  IS
  BEGIN
    DELETE FROM ozf_offer_qualifiers
     WHERE qualifier_id = p_qualifier_id
     AND object_version_number = p_object_version_number;
    If (SQL%NOTFOUND) then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;
  END Delete_Row ;





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
     p_qualifier_id  NUMBER,
     p_object_version_number  NUMBER)
  IS
    CURSOR C IS
         SELECT *
          FROM ozf_offer_qualifiers
         WHERE qualifier_id =  p_qualifier_id
         AND object_version_number = p_object_version_number
         FOR UPDATE OF qualifier_id NOWAIT;
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



 END OZF_Offr_Qual_PKG;

/
