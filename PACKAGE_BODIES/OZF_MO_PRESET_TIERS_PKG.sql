--------------------------------------------------------
--  DDL for Package Body OZF_MO_PRESET_TIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_MO_PRESET_TIERS_PKG" AS
/* $Header: ozftmoptb.pls 120.1 2005/08/24 02:59:38 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_MO_PRESET_TIERS_PKG
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
          px_market_preset_tier_id IN OUT NOCOPY NUMBER
          , p_offer_market_option_id NUMBER
          , p_pbh_offer_discount_id NUMBER
          , p_dis_offer_discount_id NUMBER
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
          INSERT INTO ozf_market_preset_tiers
          (
            market_preset_tier_id
            , offer_market_option_id
            , pbh_offer_discount_id
            , dis_offer_discount_id
            , object_version_number
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , last_update_login
          )
          VALUES
          (
            DECODE(px_market_preset_tier_id, FND_API.G_MISS_NUM, null, px_market_preset_tier_id)
            , DECODE(p_offer_market_option_id , FND_API.G_MISS_NUM, null, p_offer_market_option_id)
            , DECODE(p_pbh_offer_discount_id , FND_API.G_MISS_NUM, null, p_pbh_offer_discount_id)
            , DECODE(p_dis_offer_discount_id , FND_API.G_MISS_NUM, null, p_dis_offer_discount_id)
            , DECODE(px_object_version_number, FND_API.G_MISS_NUM, null, px_object_version_number)
            , DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date)
            , DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by)
            , DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date)
            , DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by)
            , DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login)
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
          p_market_preset_tier_id IN OUT NOCOPY NUMBER
          , p_offer_market_option_id NUMBER
          , p_pbh_offer_discount_id NUMBER
          , p_dis_offer_discount_id NUMBER
          , p_object_version_number IN OUT NOCOPY NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          )
          IS
          BEGIN
          UPDATE ozf_market_preset_tiers
          set market_preset_tier_id = DECODE(p_market_preset_tier_id, null, market_preset_tier_id, FND_API.G_MISS_NUM, null, p_market_preset_tier_id)
          , offer_market_option_id = DECODE(p_offer_market_option_id , null, offer_market_option_id, FND_API.G_MISS_NUM, null, p_offer_market_option_id)
          , pbh_offer_discount_id = DECODE(p_pbh_offer_discount_id, null, pbh_offer_discount_id, FND_API.G_MISS_NUM, null, p_pbh_offer_discount_id)
          , dis_offer_discount_id =DECODE(p_dis_offer_discount_id, null, dis_offer_discount_id, FND_API.G_MISS_NUM, null, p_dis_offer_discount_id)
          , object_version_number = nvl(p_object_version_number,0) + 1
          , last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(null), p_last_update_date)
          , last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by)
          , last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
          WHERE market_preset_tier_id = p_market_preset_tier_id
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
    p_market_preset_tier_id  NUMBER,
    p_object_version_number  NUMBER)
    IS
    BEGIN
    DELETE FROM ozf_market_preset_tiers
    WHERE market_preset_tier_id = p_market_preset_tier_id
    AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
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
    p_market_preset_tier_id  NUMBER,
    p_object_version_number  NUMBER)
    IS
    CURSOR C IS
    SELECT * FROM ozf_market_preset_tiers
    WHERE market_preset_tier_id = p_market_preset_tier_id
    AND object_version_Number = p_object_version_number
    FOR UPDATE OF market_preset_tier_id NOWAIT;
    Recinfo c%ROWTYPE;
    BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (c%NOTFOUND) THEN
    CLOSE C;
    Ozf_utility_pvt.Error_message('AMS_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
    END IF;
    CLOSE C;
    END Lock_Row;




END OZF_MO_PRESET_TIERS_PKG;

/
