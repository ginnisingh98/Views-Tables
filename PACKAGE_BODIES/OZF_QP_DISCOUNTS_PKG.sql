--------------------------------------------------------
--  DDL for Package Body OZF_QP_DISCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QP_DISCOUNTS_PKG" AS
/* $Header: ozftoqpdb.pls 120.1 2005/08/24 02:59:28 rssharma noship $ */
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
          px_qp_discount_id IN OUT NOCOPY NUMBER
          , p_list_line_id NUMBER
          , p_offer_discount_line_id NUMBER
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
          INSERT INTO ozf_qp_discounts
          (
          ozf_qp_discount_id
          , list_line_id
          , offer_discount_line_id
          , object_version_number
          , creation_date
          , created_by
          , last_updated_by
          , last_update_date
          , last_update_login
          )
          VALUES
          (
          DECODE(px_qp_discount_id, FND_API.G_MISS_NUM, NULL,px_qp_discount_id)
          , DECODE(p_list_line_id, FND_API.G_MISS_NUM, NULL, p_list_line_id)
          , DECODE(p_offer_discount_line_id, FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id)
          , DECODE(px_object_version_number,FND_API.G_MISS_NUM, 1, px_object_version_number)
          , DECODE(p_creation_date, FND_API.G_MISS_DATE,sysdate, p_creation_date)
          , DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,p_created_by)
          , DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id, p_last_updated_by)
          , DECODE(p_last_update_date, FND_API.G_MISS_DATE, sysdate, p_last_update_date)
          , DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.conc_login_id,p_last_update_login)
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
          p_qp_discount_id NUMBER
          , p_list_line_id NUMBER
          , p_offer_discount_line_id NUMBER
          , p_object_version_number NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          )
          IS
          BEGIN
          UPDATE ozf_qp_discounts
          SET
          ozf_qp_discount_id = DECODE(p_qp_discount_id, NULL, ozf_qp_discount_id, FND_API.G_MISS_NUM, NULL,  p_qp_discount_id)
          , list_line_id = DECODE(p_list_line_id , NULL, list_line_id, FND_API.G_MISS_NUM, NULL, p_list_line_id)
          , offer_discount_line_id = DECODE(p_offer_discount_line_id, NULL, offer_discount_line_id,FND_API.G_MISS_NUM, null, p_offer_discount_line_id)
          , object_version_number = nvl(p_object_version_number,0)+1
          , last_update_date = DECODE(p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), last_update_date)
          , last_updated_by = DECODE(p_last_updated_by, NULL, last_updated_by, FND_API.G_MISS_NUM,null, p_last_updated_by)
          , last_update_login = DECODE(p_last_update_login, NULL, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
          WHERE ozf_qp_discount_id = p_qp_discount_id
          AND object_version_number = p_object_version_number;

          IF SQL%NOTFOUND THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
    p_qp_discount_id NUMBER
    , p_object_version_number  NUMBER)
    IS
    BEGIN
        DELETE FROM ozf_qp_discounts
        WHERE ozf_qp_discount_id = p_qp_discount_id
        AND object_version_number = p_object_version_number;

        IF SQL%NOTFOUND THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
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
    p_qp_discount_id NUMBER
    , p_object_version_number  NUMBER)
    IS
    CURSOR c IS
    SELECT * FROM ozf_qp_discounts
    WHERE ozf_qp_discount_id = p_qp_discount_id
    AND object_version_number = p_object_version_number
    FOR UPDATE OF ozf_qp_discount_id NOWAIT;

    recinfo c%ROWTYPE;
    BEGIN
    OPEN c;
    FETCH c INTO recinfo;
    IF c%NOTFOUND THEN
      AMS_Utility_PVT.error_message ('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
    END IF;
    CLOSE C;
    END Lock_Row;




END OZF_QP_DISCOUNTS_PKG;

/
