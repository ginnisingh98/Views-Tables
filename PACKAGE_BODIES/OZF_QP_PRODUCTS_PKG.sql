--------------------------------------------------------
--  DDL for Package Body OZF_QP_PRODUCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QP_PRODUCTS_PKG" AS
/* $Header: ozftoqppb.pls 120.1 2005/08/24 02:59:26 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_QP_PRODUCTS_PKG
-- Purpose
--
-- History
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
          px_qp_product_id IN OUT NOCOPY NUMBER
          , p_off_discount_product_id NUMBER
          , p_pricing_attribute_id NUMBER
          , px_object_version_number IN OUT NOCOPY NUMBER
          , p_creation_date    DATE
          , p_created_by    NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          )
          IS
          BEGIN
          px_object_version_number := nvl(px_object_version_number,1);

          INSERT INTO ozf_qp_products
          (
            qp_product_id
            , off_discount_product_id
            , pricing_attribute_id
            , object_version_number
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , last_update_login
          )
          values
          (
          DECODE(px_qp_product_id , FND_API.G_MISS_NUM, null, px_qp_product_id)
          , DECODE(p_off_discount_product_id , FND_API.G_MISS_NUM , NULL, p_off_discount_product_id)
          , DECODE(p_pricing_attribute_id, FND_API.G_MISS_NUM, NULL, p_pricing_attribute_id)
          , DECODE(px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number)
          , DECODE(p_last_update_date, FND_API.G_MISS_DATE,sysdate, p_last_update_date)
          , DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id, p_last_updated_by)
          , DECODE(p_creation_date, FND_API.G_MISS_DATE, sysdate, p_creation_date)
          , DECODE(p_created_by , FND_API.G_MISS_NUM,FND_GLOBAL.user_id, p_created_by)
          , DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.conc_login_id, p_last_update_login)
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
          p_qp_product_id NUMBER
          , p_off_discount_product_id NUMBER
          , p_pricing_attribute_id NUMBER
          , p_object_version_number NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          )
          IS
          BEGIN
          UPDATE ozf_qp_products
          SET
          qp_product_id = DECODE(p_qp_product_id , NULL, qp_product_id, FND_API.G_MISS_NUM, null, p_qp_product_id)
          , off_discount_product_id = DECODE(p_off_discount_product_id, NULL , off_discount_product_id, FND_API.G_MISS_NUM, NULL, p_off_discount_product_id)
          , pricing_attribute_id = DECODE(p_pricing_attribute_id, NULL, pricing_attribute_id, FND_API.G_MISS_NUM,NULL, p_pricing_attribute_id)
          , object_version_number = nvl(p_object_version_number,0)+1
          , last_update_date = DECODE(p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), last_update_date)
          , last_updated_by = DECODE(p_last_updated_by, NULL, last_updated_by, FND_API.G_MISS_NUM,null, p_last_updated_by)
          , last_update_login = DECODE(p_last_update_login, NULL, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
          WHERE qp_product_id = p_qp_product_id
          AND object_version_number = p_object_version_number;

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
    p_qp_product_id NUMBER
    , p_object_version_number  NUMBER)
    IS
    BEGIN
   DELETE FROM ozf_qp_products
    WHERE qp_product_id = p_qp_product_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
    END Delete_Row;




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
    p_qp_product_id NUMBER
    , p_object_version_number  NUMBER)
    IS
   CURSOR C IS
        SELECT *
         FROM ozf_qp_products
        WHERE qp_product_id = p_qp_product_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF qp_product_id NOWAIT;
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




END OZF_QP_PRODUCTS_PKG;

/
