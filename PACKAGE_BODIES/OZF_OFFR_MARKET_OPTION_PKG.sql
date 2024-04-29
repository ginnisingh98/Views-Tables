--------------------------------------------------------
--  DDL for Package Body OZF_OFFR_MARKET_OPTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFR_MARKET_OPTION_PKG" as
/* $Header: ozftomob.pls 120.1 2005/08/24 02:59:31 rssharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_OFFR_MARKET_OPTION_PKG
-- Purpose
--
-- History
--           Wed May 18 2005:11/57 AM RSSHARMA Added Insert_row and Update_row for Volume Offers
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_OFFR_MARKET_OPTION_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftomob.pls';




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
          px_offer_market_option_id IN OUT NOCOPY NUMBER
          , p_offer_id NUMBER
          , p_qp_list_header_id NUMBER
          , p_group_number NUMBER
          , p_retroactive_flag VARCHAR2
          , p_beneficiary_party_id NUMBER
          , p_combine_schedule_flag VARCHAR2
          , p_volume_tracking_level_code VARCHAR2
          , p_accrue_to_code VARCHAR2
          , p_precedence NUMBER
          , px_object_version_number IN OUT NOCOPY NUMBER
          , p_creation_date    DATE
          , p_created_by    NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          )
 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offr_market_options(
                offer_market_option_id
                , offer_id
                , qp_list_header_id
                , group_number
                , retroactive_flag
                , beneficiary_party_id
                , combine_schedule_flag
                , volume_tracking_level_code
                , accrue_to_code
                , precedence
                , object_version_number
                , last_update_date
                , last_updated_by
                , creation_date
                , created_by
                , last_update_login
                )
                VALUES
                (
           DECODE( px_offer_market_option_id, FND_API.G_MISS_NUM, NULL, px_offer_market_option_id)
           , DECODE( p_offer_id, FND_API.G_MISS_NUM, NULL, p_offer_id)
           , DECODE( p_qp_list_header_id, FND_API.G_MISS_NUM, NULL, p_qp_list_header_id)
           , DECODE( p_group_number, FND_API.G_MISS_NUM, NULL, p_group_number)
           , DECODE( p_retroactive_flag, FND_API.g_miss_char, NULL, p_retroactive_flag)
           , DECODE( p_beneficiary_party_id, FND_API.G_MISS_NUM, NULL, p_beneficiary_party_id)
           , DECODE( p_combine_schedule_flag, FND_API.g_miss_char, NULL, p_combine_schedule_flag)
           , DECODE( p_volume_tracking_level_code, FND_API.g_miss_char, NULL, p_volume_tracking_level_code)
           , DECODE( p_accrue_to_code, FND_API.g_miss_char, NULL, p_accrue_to_code)
           , DECODE( p_precedence, FND_API.G_MISS_NUM, NULL, p_precedence)
           , DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number)
           , DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date)
           , DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by)
           , DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date)
           , DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by)
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
          p_offer_market_option_id NUMBER
          , p_offer_id NUMBER
          , p_qp_list_header_id NUMBER
          , p_group_number NUMBER
          , p_retroactive_flag VARCHAR2
          , p_beneficiary_party_id NUMBER
          , p_combine_schedule_flag VARCHAR2
          , p_volume_tracking_level_code VARCHAR2
          , p_accrue_to_code VARCHAR2
          , p_precedence NUMBER
          , p_object_version_number NUMBER
          , p_creation_date    DATE
          , p_created_by    NUMBER
          , p_last_update_date    DATE
          , p_last_updated_by    NUMBER
          , p_last_update_login    NUMBER
          )

 IS
 BEGIN
    Update ozf_offr_market_options
    SET
              offer_market_option_id = DECODE( p_offer_market_option_id, null, offer_market_option_id, FND_API.G_MISS_NUM, null, p_offer_market_option_id),
              offer_id = DECODE( p_offer_id, null, offer_id, FND_API.G_MISS_NUM, null, p_offer_id),
              qp_list_header_id = DECODE( p_qp_list_header_id, null, qp_list_header_id, FND_API.G_MISS_NUM, null, p_qp_list_header_id),
              group_number = DECODE( p_group_number, null, group_number, FND_API.G_MISS_NUM, null, p_group_number),
              retroactive_flag = DECODE( p_retroactive_flag, null, retroactive_flag, FND_API.g_miss_char, null, p_retroactive_flag),
              beneficiary_party_id = DECODE( p_beneficiary_party_id, null, beneficiary_party_id, FND_API.g_miss_num, null, p_beneficiary_party_id),
              combine_schedule_flag = DECODE( p_combine_schedule_flag, null, combine_schedule_flag, FND_API.g_miss_char, null, p_combine_schedule_flag),
              volume_tracking_level_code = DECODE( p_volume_tracking_level_code, null, volume_tracking_level_code, FND_API.G_MISS_CHAR, null, p_volume_tracking_level_code),
              accrue_to_code = DECODE( p_accrue_to_code, null, accrue_to_code, FND_API.g_miss_char, null, p_accrue_to_code),
              precedence = DECODE( p_precedence, null, precedence, FND_API.G_MISS_NUM, null, p_precedence),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(null), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              object_version_number = nvl(p_object_version_number,0) + 1
   WHERE offer_market_option_id = p_offer_market_option_id
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
    p_offer_market_option_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_offr_market_options
    WHERE offer_market_option_id = p_offer_market_option_id
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
    p_offer_market_option_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_offr_market_options
        WHERE offer_market_option_id = p_offer_market_option_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF offer_market_option_id NOWAIT;
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



END OZF_OFFR_MARKET_OPTION_PKG;

/
