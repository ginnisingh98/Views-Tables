--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_TIER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_TIER_PKG" as
/* $Header: ozftoatb.pls 120.3 2005/08/03 01:55:38 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adj_Tier_PKG
-- Purpose
--
-- History
--     Tue Aug 02 2005:10/45 PM RSSHARMA R12 changes.Added new Field for offer_discount_line_id
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Adj_Tier_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'offtadjb.pls';




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
          px_offer_adjst_tier_id   IN OUT NOCOPY NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_offer_tiers_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_offer_discount_line_id NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offer_adjustment_tiers(
           offer_adjst_tier_id,
           offer_adjustment_id,
           volume_offer_tiers_id,
           qp_list_header_id,
           discount_type_code,
           original_discount,
           modified_discount,
           offer_discount_line_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE(px_offer_adjst_tier_id, FND_API.G_MISS_NUM,NULL, px_offer_adjst_tier_id),
           DECODE(p_offer_adjustment_id, FND_API.G_MISS_NUM, NULL, p_offer_adjustment_id),
           decode(p_volume_offer_tiers_id, fnd_api.g_miss_num, null, p_volume_offer_tiers_id),
           DECODE(p_qp_list_header_id, fnd_api.g_miss_num, null, p_qp_list_header_id),
           DECODE(p_discount_type_code, FND_API.G_MISS_CHAR, NULL, p_discount_type_code),
           decode(p_original_discount, FND_API.G_MISS_NUM, NULL, p_original_discount),
           DECODE(p_modified_discount, FND_API.G_MISS_NUM, NULL, p_modified_discount),
           decode(p_offer_discount_line_id , FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
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
          p_offer_adjst_tier_id    NUMBER,
          p_offer_adjustment_id    NUMBER,
          p_volume_offer_tiers_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_original_discount    NUMBER,
          p_modified_discount    NUMBER,
          p_offer_discount_line_id NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER)

 IS
 BEGIN
    Update ozf_offer_adjustment_tiers
    SET
              offer_adjst_tier_id = DECODE( p_offer_adjst_tier_id, null, offer_adjst_tier_id, FND_API.G_MISS_NUM, null, p_offer_adjst_tier_id),
              offer_adjustment_id = DECODE( p_offer_adjustment_id, null, offer_adjustment_id, FND_API.G_MISS_NUM, null, p_offer_adjustment_id),
              volume_offer_tiers_id = DECODE( p_volume_offer_tiers_id, null, volume_offer_tiers_id, FND_API.G_MISS_NUM, null, p_volume_offer_tiers_id),
              qp_list_header_id = DECODE( p_qp_list_header_id, null, qp_list_header_id, FND_API.G_MISS_NUM, null, p_qp_list_header_id),
              discount_type_code = DECODE( p_discount_type_code, null, discount_type_code, FND_API.g_miss_char, null, p_discount_type_code),
              original_discount = DECODE( p_original_discount, null, original_discount, FND_API.G_MISS_NUM, null, p_original_discount),
              modified_discount = DECODE( p_modified_discount, null, modified_discount, FND_API.G_MISS_NUM, null, p_modified_discount),
              offer_discount_line_id = DECODE(P_OFFER_DISCOUNT_LINE_ID , NULL, offer_discount_line_id, FND_API.G_MISS_NUM, NULL, p_offer_discount_line_id),
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = object_version_number + 1
   WHERE offer_adjst_tier_id = p_offer_adjst_tier_id
   AND   object_version_number = px_object_version_number;


   IF (SQL%NOTFOUND) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   px_object_version_number := nvl(px_object_version_number,0) + 1;

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
    p_offer_adjst_tier_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_offer_adjustment_tiers
    WHERE offer_adjst_tier_id = p_offer_adjst_tier_id
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
    p_offer_adjst_tier_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_offer_adjustment_tiers
        WHERE offer_adjst_tier_id =  p_offer_adjst_tier_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF offer_adjst_tier_id NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN

   OPEN c;
   FETCH c INTO Recinfo;
   IF (c%NOTFOUND) THEN
      CLOSE c;
      OZF_Utility_PVT.error_message ('OZF_API_RECORD_NOT_FOUND');
      RAISE FND_API.g_exc_error;
   END IF;
   CLOSE c;
END Lock_Row;



END OZF_Offer_Adj_Tier_PKG;

/
