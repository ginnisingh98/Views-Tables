--------------------------------------------------------
--  DDL for Package Body OZF_VOL_OFFR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOL_OFFR_PKG" as
/* $Header: ozftvob.pls 120.0 2005/06/01 03:00:19 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Vol_Offr_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Vol_Offr_PKG';
--G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftam.b.pls';




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
          px_volume_offer_tiers_id   IN OUT NOCOPY NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_discount    NUMBER,
          p_break_type_code    VARCHAR2,
          p_tier_value_from    NUMBER,
          p_tier_value_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_active    VARCHAR2,
          p_uom_code    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER)
 IS
   x_rowid    VARCHAR2(30);
BEGIN
   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_volume_offer_tiers(
           volume_offer_tiers_id,
           qp_list_header_id,
           discount_type_code,
           discount,
           break_type_code,
           tier_value_from,
           tier_value_to,
           volume_type,
           active,
           uom_code,
           object_version_number
   ) VALUES (
           px_volume_offer_tiers_id,
           p_qp_list_header_id,
           p_discount_type_code,
           p_discount,
           p_break_type_code,
           p_tier_value_from,
           p_tier_value_to,
           p_volume_type,
           p_active,
           p_uom_code,
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
          p_volume_offer_tiers_id    NUMBER,
          p_qp_list_header_id    NUMBER,
          p_discount_type_code    VARCHAR2,
          p_discount    NUMBER,
          p_break_type_code    VARCHAR2,
          p_tier_value_from    NUMBER,
          p_tier_value_to    NUMBER,
          p_volume_type    VARCHAR2,
          p_active    VARCHAR2,
          p_uom_code    VARCHAR2,
          px_object_version_number   IN OUT NOCOPY NUMBER
        )
 IS
 BEGIN
 OZF_UTILITY_PVT.debug_message('before inserting');
 OZF_UTILITY_PVT.debug_message('id: ' || p_volume_offer_tiers_id);
OZF_UTILITY_PVT.debug_message('ver: ' || px_object_version_number);

    Update ozf_volume_offer_tiers
    SET
              volume_offer_tiers_id = DECODE( p_volume_offer_tiers_id, null, volume_offer_tiers_id, FND_API.G_MISS_NUM, null, p_volume_offer_tiers_id),
              qp_list_header_id = DECODE( p_qp_list_header_id, null, qp_list_header_id, FND_API.G_MISS_NUM, null, p_qp_list_header_id),
              discount_type_code = DECODE( p_discount_type_code, null, discount_type_code, FND_API.g_miss_char, null, p_discount_type_code),
              discount = DECODE( p_discount, null, discount, FND_API.G_MISS_NUM, null, p_discount),
              break_type_code = DECODE( p_break_type_code, null, break_type_code, FND_API.g_miss_char, null, p_break_type_code),
              tier_value_from = DECODE( p_tier_value_from, null, tier_value_from, FND_API.G_MISS_NUM, null, p_tier_value_from),
              tier_value_to = DECODE( p_tier_value_to, null, tier_value_to, FND_API.G_MISS_NUM, null, p_tier_value_to),
              volume_type = DECODE( p_volume_type, null, volume_type, FND_API.g_miss_char, null, p_volume_type),
              active = DECODE( p_active, null, active, FND_API.g_miss_char, null, p_active),
              uom_code = DECODE( p_uom_code, null, uom_code, FND_API.g_miss_char, null, p_uom_code),
            object_version_number = object_version_number + 1
   WHERE volume_offer_tiers_id = p_volume_offer_tiers_id
   AND   object_version_number = px_object_version_number;

   IF (SQL%NOTFOUND) THEN
   OZF_UTILITY_PVT.debug_message('no data found');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
OZF_UTILITY_PVT.debug_message('after inserting');

   px_object_version_number := nvl(px_object_version_number,0) + 1;
OZF_UTILITY_PVT.debug_message('table handler end');
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
    p_volume_offer_tiers_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_volume_offer_tiers
    WHERE volume_offer_tiers_id = p_volume_offer_tiers_id
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
    p_volume_offer_tiers_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_volume_offer_tiers
        WHERE volume_offer_tiers_id =  p_volume_offer_tiers_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF volume_offer_tiers_id NOWAIT;
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



END OZF_Vol_Offr_PKG;

/
