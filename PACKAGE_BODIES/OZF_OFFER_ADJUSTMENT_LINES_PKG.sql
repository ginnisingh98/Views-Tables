--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJUSTMENT_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJUSTMENT_LINES_PKG" as
/* $Header: ozftobcb.pls 120.0 2005/06/01 01:47:44 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFER_ADJUSTMENT_LINES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_OFFER_ADJUSTMENT_LINES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftobcb.pls';


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
          px_offer_adjustment_line_id   IN OUT NOCOPY NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_list_line_id    NUMBER,
          p_arithmetic_operator    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_security_group_id    NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO OZF_OFFER_ADJUSTMENT_LINES(
           offer_adjustment_line_id,
           offer_adjustment_id,
           list_line_id,
           arithmetic_operator,
           original_discount,
           modified_discount,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
           security_group_id
   ) VALUES (
           DECODE( px_offer_adjustment_line_id, FND_API.g_miss_num, NULL, px_offer_adjustment_line_id),
           DECODE( p_offer_adjustment_id, FND_API.g_miss_num, NULL, p_offer_adjustment_id),
           DECODE( p_list_line_id, FND_API.g_miss_num, NULL, p_list_line_id),
           DECODE( p_arithmetic_operator, FND_API.g_miss_char, NULL, p_arithmetic_operator),
           DECODE( p_original_discount, FND_API.g_miss_num, NULL, p_original_discount),
           DECODE( p_modified_discount, FND_API.g_miss_num, NULL, p_modified_discount),
           DECODE( p_last_update_date, FND_API.g_miss_date, to_date(NULL), p_last_update_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_creation_date, FND_API.g_miss_date, to_date(NULL), p_creation_date),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( p_security_group_id, FND_API.g_miss_num, NULL, p_security_group_id));
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
          p_offer_adjustment_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_list_line_id    NUMBER,
          p_arithmetic_operator    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER)

 IS
 BEGIN
    Update OZF_OFFER_ADJUSTMENT_LINES
    SET
              offer_adjustment_line_id = DECODE( p_offer_adjustment_line_id, FND_API.g_miss_num, offer_adjustment_line_id, p_offer_adjustment_line_id),
              offer_adjustment_id = DECODE( p_offer_adjustment_id, FND_API.g_miss_num, offer_adjustment_id, p_offer_adjustment_id),
              list_line_id = DECODE( p_list_line_id, FND_API.g_miss_num, list_line_id, p_list_line_id),
              arithmetic_operator = DECODE( p_arithmetic_operator, FND_API.g_miss_char, arithmetic_operator, p_arithmetic_operator),
              original_discount = DECODE( p_original_discount, FND_API.g_miss_num, original_discount, p_original_discount),
              modified_discount = DECODE( p_modified_discount, FND_API.g_miss_num, modified_discount, p_modified_discount),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              security_group_id = DECODE( p_security_group_id, FND_API.g_miss_num, security_group_id, p_security_group_id)
   WHERE OFFER_ADJUSTMENT_LINE_ID = p_OFFER_ADJUSTMENT_LINE_ID
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
    p_OFFER_ADJUSTMENT_LINE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_OFFER_ADJUSTMENT_LINES
    WHERE OFFER_ADJUSTMENT_LINE_ID = p_OFFER_ADJUSTMENT_LINE_ID;
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
          p_offer_adjustment_line_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_list_line_id    NUMBER,
          p_arithmetic_operator    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_security_group_id    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_OFFER_ADJUSTMENT_LINES
        WHERE OFFER_ADJUSTMENT_LINE_ID =  p_OFFER_ADJUSTMENT_LINE_ID
        FOR UPDATE of OFFER_ADJUSTMENT_LINE_ID NOWAIT;
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
           (      Recinfo.offer_adjustment_line_id = p_offer_adjustment_line_id)
       AND (    ( Recinfo.offer_adjustment_id = p_offer_adjustment_id)
            OR (    ( Recinfo.offer_adjustment_id IS NULL )
                AND (  p_offer_adjustment_id IS NULL )))
       AND (    ( Recinfo.list_line_id = p_list_line_id)
            OR (    ( Recinfo.list_line_id IS NULL )
                AND (  p_list_line_id IS NULL )))
       AND (    ( Recinfo.arithmetic_operator = p_arithmetic_operator)
            OR (    ( Recinfo.arithmetic_operator IS NULL )
                AND (  p_arithmetic_operator IS NULL )))
       AND (    ( Recinfo.original_discount = p_original_discount)
            OR (    ( Recinfo.original_discount IS NULL )
                AND (  p_original_discount IS NULL )))
       AND (    ( Recinfo.modified_discount = p_modified_discount)
            OR (    ( Recinfo.modified_discount IS NULL )
                AND (  p_modified_discount IS NULL )))
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

END OZF_OFFER_ADJUSTMENT_LINES_PKG;

/
