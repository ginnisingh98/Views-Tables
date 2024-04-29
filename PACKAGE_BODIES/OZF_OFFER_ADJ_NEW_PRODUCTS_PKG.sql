--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_NEW_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_NEW_PRODUCTS_PKG" as
/* $Header: ozftanpb.pls 120.0 2006/03/30 13:47:44 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJ_NEW_PRODUCTS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_OFFER_ADJ_NEW_PRODUCTS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftanpb.pls';
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
          px_offer_adj_new_product_id   IN OUT NOCOPY  NUMBER,
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id      NUMBER,
          p_product_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY  NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO OZF_OFFER_ADJ_NEW_PRODUCTS(
           offer_adj_new_product_id,
           offer_adj_new_line_id,
           offer_adjustment_id,
           product_context,
           product_attribute,
           product_attr_value,
           excluder_flag,
           uom_code,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_offer_adj_new_product_id, FND_API.g_miss_num, NULL, px_offer_adj_new_product_id),
           DECODE( p_offer_adj_new_line_id, FND_API.g_miss_num, NULL, p_offer_adj_new_line_id),
           DECODE( p_offer_adjustment_id, FND_API.g_miss_num, NULL, p_offer_adjustment_id),
           DECODE( p_product_context, FND_API.g_miss_char, NULL, p_product_context),
           DECODE( p_product_attribute, FND_API.g_miss_char, NULL, p_product_attribute),
           DECODE( p_product_attr_value, FND_API.g_miss_char, NULL, p_product_attr_value),
           DECODE( p_excluder_flag, FND_API.g_miss_char, NULL, p_excluder_flag),
           DECODE( p_uom_code, FND_API.g_miss_char, NULL, p_uom_code),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));
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
          p_offer_adj_new_product_id    NUMBER,
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id      NUMBER,
          p_product_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
 BEGIN
    Update OZF_OFFER_ADJ_NEW_PRODUCTS
    SET
              offer_adj_new_product_id = DECODE( p_offer_adj_new_product_id , null, offer_adj_new_product_id, FND_API.g_miss_num , null , p_offer_adj_new_product_id)
              , offer_adj_new_line_id = DECODE( p_offer_adj_new_line_id, null, offer_adj_new_line_id, FND_API.g_miss_num, null , p_offer_adj_new_line_id)
              , offer_adjustment_id   = DECODE(p_offer_adjustment_id , null, offer_adjustment_id, FND_API.g_miss_num, null, p_offer_adjustment_id)
              , product_context = DECODE( p_product_context, null, product_context,FND_API.g_miss_char, null, p_product_context)
              , product_attribute = DECODE( p_product_attribute, null , product_attribute, FND_API.g_miss_char , null,  p_product_attribute)
              , product_attr_value = DECODE( p_product_attr_value, null, product_attr_value, FND_API.g_miss_char, null,  p_product_attr_value)
              , excluder_flag = DECODE( p_excluder_flag, null , excluder_flag, FND_API.g_miss_char , null,  p_excluder_flag)
              , uom_code = DECODE( p_uom_code, null , uom_code, FND_API.g_miss_char , null, p_uom_code)
              , last_update_date = DECODE( p_last_update_date, null , last_update_date,FND_API.g_miss_date, null,  p_last_update_date)
              , last_updated_by = DECODE( p_last_updated_by, null , last_updated_by, FND_API.g_miss_num , null , p_last_updated_by)
              , last_update_login = DECODE( p_last_update_login, null , last_update_login, FND_API.g_miss_num, null , p_last_update_login)
              , object_version_number = nvl(p_object_version_number,0) + 1
   WHERE OFFER_ADJ_NEW_PRODUCT_ID = p_OFFER_ADJ_NEW_PRODUCT_ID
   AND   object_version_number = p_object_version_number;

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
    p_OFFER_ADJ_NEW_PRODUCT_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_OFFER_ADJ_NEW_PRODUCTS
    WHERE OFFER_ADJ_NEW_PRODUCT_ID = p_OFFER_ADJ_NEW_PRODUCT_ID;
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
          p_offer_adj_new_product_id    NUMBER,
          p_offer_adj_new_line_id    NUMBER,
          p_offer_adjustment_id      NUMBER,
          p_product_context    VARCHAR2,
          p_product_attribute    VARCHAR2,
          p_product_attr_value    VARCHAR2,
          p_excluder_flag    VARCHAR2,
          p_uom_code    VARCHAR2,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_OFFER_ADJ_NEW_PRODUCTS
        WHERE OFFER_ADJ_NEW_PRODUCT_ID =  p_OFFER_ADJ_NEW_PRODUCT_ID
        FOR UPDATE of OFFER_ADJ_NEW_PRODUCT_ID NOWAIT;
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
           (      Recinfo.offer_adj_new_product_id = p_offer_adj_new_product_id)
       AND (    ( Recinfo.offer_adj_new_line_id = p_offer_adj_new_line_id)
            OR (    ( Recinfo.offer_adj_new_line_id IS NULL )
                AND (  p_offer_adj_new_line_id IS NULL )))
       AND (    ( Recinfo.product_context = p_product_context)
            OR (    ( Recinfo.product_context IS NULL )
                AND (  p_product_context IS NULL )))
       AND (    ( Recinfo.offer_adjustment_id = p_offer_adjustment_id)
            OR (    ( Recinfo.offer_adjustment_id IS NULL )
                AND (  p_offer_adjustment_id IS NULL )))
       AND (    ( Recinfo.product_attribute = p_product_attribute)
            OR (    ( Recinfo.product_attribute IS NULL )
                AND (  p_product_attribute IS NULL )))
       AND (    ( Recinfo.product_attr_value = p_product_attr_value)
            OR (    ( Recinfo.product_attr_value IS NULL )
                AND (  p_product_attr_value IS NULL )))
       AND (    ( Recinfo.excluder_flag = p_excluder_flag)
            OR (    ( Recinfo.excluder_flag IS NULL )
                AND (  p_excluder_flag IS NULL )))
       AND (    ( Recinfo.uom_code = p_uom_code)
            OR (    ( Recinfo.uom_code IS NULL )
                AND (  p_uom_code IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END OZF_OFFER_ADJ_NEW_PRODUCTS_PKG;

/
