--------------------------------------------------------
--  DDL for Package Body OZF_PROD_RELN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PROD_RELN_PKG" as
/* $Header: ozftdprb.pls 120.0 2005/06/01 01:00:32 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Prod_Reln_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Prod_Reln_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftrb.b.pls';




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
          px_discount_product_reln_id   IN OUT NOCOPY NUMBER,
          p_offer_discount_line_id    NUMBER,
          p_off_discount_product_id    NUMBER,
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


   INSERT INTO ozf_discount_product_reln(
           discount_product_reln_id,
           offer_discount_line_id,
           off_discount_product_id,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_discount_product_reln_id, FND_API.G_MISS_NUM, NULL, px_discount_product_reln_id),
           DECODE( p_offer_discount_line_id, FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id),
           DECODE( p_off_discount_product_id, FND_API.G_MISS_NUM, NULL, p_off_discount_product_id),
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
          p_discount_product_reln_id    NUMBER,
          p_offer_discount_line_id    NUMBER,
          p_off_discount_product_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number   IN NUMBER)


 IS
 BEGIN
    Update ozf_discount_product_reln
    SET
              discount_product_reln_id = DECODE( p_discount_product_reln_id, null, discount_product_reln_id, FND_API.G_MISS_NUM, null, p_discount_product_reln_id),
              offer_discount_line_id = DECODE( p_offer_discount_line_id, null, offer_discount_line_id, FND_API.G_MISS_NUM, null, p_offer_discount_line_id),
              off_discount_product_id = DECODE( p_off_discount_product_id, null, off_discount_product_id, FND_API.G_MISS_NUM, null, p_off_discount_product_id),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = nvl(p_object_version_number,0) + 1
   WHERE discount_product_reln_id = p_discount_product_reln_id
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
    p_discount_product_reln_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_discount_product_reln
    WHERE discount_product_reln_id = p_discount_product_reln_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;

--  ========================================================
--
--  NAME
--  Delete
--
--  PURPOSE
--  Used for hard deleting a relationship if the Discount line is deleted
--  NOTES
--
--  HISTORY
--
--  ========================================================

PROCEDURE Delete(
    p_offer_discount_line_id  NUMBER
)
IS
BEGIN
   DELETE FROM ozf_discount_product_reln
    WHERE offer_discount_line_id = p_offer_discount_line_id;

   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

END DELETE;



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
    p_discount_product_reln_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_discount_product_reln
        WHERE discount_product_reln_id =  p_discount_product_reln_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF discount_product_reln_id NOWAIT;
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



END OZF_Prod_Reln_PKG;

/
