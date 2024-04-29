--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_PERFORMANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_PERFORMANCES_PKG" as
/* $Header: ozftperb.pls 120.0 2005/06/01 02:50:06 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_PERFORMANCES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_OFFER_PERFORMANCES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftperb.pls';


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_offer_performance_id   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_product_attribute_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_channel_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_estimated_value    NUMBER,
          p_required_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_security_group_id    NUMBER,
          p_requirement_type  VARCHAR2,
          p_uom_code       VARCHAR2,
          p_description    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO OZF_OFFER_PERFORMANCES(
           offer_performance_id,
           list_header_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           product_attribute_context,
           product_attribute,
           product_attr_value,
           channel_id,
           start_date,
           end_date,
           estimated_value,
           required_flag,
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
           attribute15,
           security_group_id,
           requirement_type,
           uom_code,
           description)
   VALUES (
           DECODE( px_offer_performance_id, FND_API.g_miss_num, NULL, px_offer_performance_id),
           DECODE( p_list_header_id, FND_API.g_miss_num, NULL, p_list_header_id),
           DECODE( p_last_update_date, FND_API.g_miss_date, to_date(NULL), p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, to_date(NULL), p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_product_attribute_context, FND_API.g_miss_char, NULL, p_product_attribute_context),
           DECODE( p_product_attribute, FND_API.g_miss_char, NULL, p_product_attribute),
           DECODE( p_product_attr_value, FND_API.g_miss_char, NULL, p_product_attr_value),
           DECODE( p_channel_id, FND_API.g_miss_num, NULL, p_channel_id),
           DECODE( p_start_date, FND_API.g_miss_date, to_date(NULL), p_start_date),
           DECODE( p_end_date, FND_API.g_miss_date, to_date(NULL), p_end_date),
           DECODE( p_estimated_value, FND_API.g_miss_num, NULL, p_estimated_value),
           DECODE( p_required_flag, FND_API.g_miss_char, NULL, p_required_flag),
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
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15),
           DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id),
           DECODE( p_requirement_type, FND_API.g_miss_char, NULL, p_requirement_type),
           DECODE( p_uom_code, FND_API.g_miss_char, NULL, p_uom_code),
           DECODE( p_description, FND_API.g_miss_char, NULL, p_description));
END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_offer_performance_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
	  p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_product_attribute_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_channel_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_estimated_value    NUMBER,
          p_required_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_security_group_id    NUMBER,
          p_requirement_type  VARCHAR2,
          p_uom_code       VARCHAR2,
          p_description    VARCHAR2)

 IS
 BEGIN
    Update OZF_OFFER_PERFORMANCES
    SET
              offer_performance_id = DECODE( p_offer_performance_id, FND_API.g_miss_num, offer_performance_id, p_offer_performance_id),
              list_header_id = DECODE( p_list_header_id, FND_API.g_miss_num, list_header_id, p_list_header_id),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              product_attribute_context = DECODE( p_product_attribute_context, FND_API.g_miss_char, product_attribute_context, p_product_attribute_context),
              product_attribute = DECODE( p_product_attribute, FND_API.g_miss_char, product_attribute, p_product_attribute),
              product_attr_value = DECODE( p_product_attr_value, FND_API.g_miss_char, product_attr_value, p_product_attr_value),
              channel_id = DECODE( p_channel_id, FND_API.g_miss_num, channel_id, p_channel_id),
              start_date = DECODE( p_start_date, FND_API.g_miss_date, start_date, p_start_date),
              end_date = DECODE( p_end_date, FND_API.g_miss_date, end_date, p_end_date),
              estimated_value = DECODE( p_estimated_value, FND_API.g_miss_num, estimated_value, p_estimated_value),
              required_flag = DECODE( p_required_flag, FND_API.g_miss_char, required_flag, p_required_flag),
              attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
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
              security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id),
              requirement_type = DECODE( p_requirement_type, FND_API.g_miss_char, requirement_type, p_requirement_type),
              uom_code = DECODE( p_uom_code, FND_API.g_miss_char, uom_code, p_uom_code),
              description = DECODE( p_description, FND_API.g_miss_char, description, p_description)
   WHERE OFFER_PERFORMANCE_ID = p_OFFER_PERFORMANCE_ID
   AND   object_version_number = p_object_version_number-1;

   IF (SQL%NOTFOUND) THEN
RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_OFFER_PERFORMANCE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_OFFER_PERFORMANCES
    WHERE OFFER_PERFORMANCE_ID = p_OFFER_PERFORMANCE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_offer_performance_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_product_attribute_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_channel_id    NUMBER,
          p_start_date    DATE,
          p_end_date    DATE,
          p_estimated_value    NUMBER,
          p_required_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_security_group_id    NUMBER,
          p_requirement_type  VARCHAR2,
          p_uom_code       VARCHAR2,
          p_description    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_OFFER_PERFORMANCES
        WHERE OFFER_PERFORMANCE_ID =  p_OFFER_PERFORMANCE_ID
        FOR UPDATE of OFFER_PERFORMANCE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.offer_performance_id = p_offer_performance_id)
       AND (    ( Recinfo.list_header_id = p_list_header_id)
            OR (    ( Recinfo.list_header_id IS NULL )
                AND (  p_list_header_id IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.product_attribute_context = p_product_attribute_context)
            OR (    ( Recinfo.product_attribute_context IS NULL )
                AND (  p_product_attribute_context IS NULL )))
       AND (    ( Recinfo.product_attribute = p_product_attribute)
            OR (    ( Recinfo.product_attribute IS NULL )
                AND (  p_product_attribute IS NULL )))
       AND (    ( Recinfo.product_attr_value = p_product_attr_value)
            OR (    ( Recinfo.product_attr_value IS NULL )
                AND (  p_product_attr_value IS NULL )))
       AND (    ( Recinfo.channel_id = p_channel_id)
            OR (    ( Recinfo.channel_id IS NULL )
                AND (  p_channel_id IS NULL )))
       AND (    ( Recinfo.start_date = p_start_date)
            OR (    ( Recinfo.start_date IS NULL )
                AND (  p_start_date IS NULL )))
       AND (    ( Recinfo.end_date = p_end_date)
            OR (    ( Recinfo.end_date IS NULL )
                AND (  p_end_date IS NULL )))
       AND (    ( Recinfo.estimated_value = p_estimated_value)
            OR (    ( Recinfo.estimated_value IS NULL )
                AND (  p_estimated_value IS NULL )))
       AND (    ( Recinfo.required_flag = p_required_flag)
            OR (    ( Recinfo.required_flag IS NULL )
                AND (  p_required_flag IS NULL )))
       AND (    ( Recinfo.attribute_category = p_attribute_category)
            OR (    ( Recinfo.attribute_category IS NULL )
                AND (  p_attribute_category IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_OFFER_PERFORMANCES_PKG;

/
