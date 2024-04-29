--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJUSTMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJUSTMENT_PKG" as
/* $Header: ozftoadb.pls 120.0 2005/06/01 02:22:16 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adjustment_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Adjustment_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftadjb.pls';




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
          px_offer_adjustment_id   IN OUT NOCOPY NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
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
          p_offer_adjustment_name    VARCHAR2,
          p_description    VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_offer_adjustments_b(
           offer_adjustment_id,
           effective_date,
           approved_date,
           settlement_code,
           status_code,
           list_header_id,
           version,
           budget_adjusted_flag,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           object_version_number,
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
           attribute15
   ) VALUES (
           px_offer_adjustment_id,
           p_effective_date,
           p_approved_date,
           p_settlement_code,
           p_status_code,
           p_list_header_id,
           p_version,
           p_budget_adjusted_flag,
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           p_attribute1,
           p_attribute2,
           p_attribute3,
           p_attribute4,
           p_attribute5,
           p_attribute6,
           p_attribute7,
           p_attribute8,
           p_attribute9,
           p_attribute10,
           p_attribute11,
           p_attribute12,
           p_attribute13,
           p_attribute14,
           p_attribute15);

   INSERT INTO ozf_offer_adjustments_tl(
           offer_adjustment_id ,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           offer_adjustment_name ,
           description
)
SELECT
           px_offer_adjustment_id,
           l.language_code,
           DECODE( p_last_update_date, to_date(NULL), SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, to_date(NULL), SYSDATE, p_creation_date),
           DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           USERENV('LANG'),
           p_offer_adjustment_name,
           p_description
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND   NOT EXISTS(SELECT NULL FROM ozf_offer_adjustments_tl t
                    WHERE t.offer_adjustment_id = DECODE( px_offer_adjustment_id, FND_API.G_MISS_NUM, NULL, px_offer_adjustment_id)
                    AND   t.language = l.language_code);
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
          p_offer_adjustment_id    NUMBER,
          p_effective_date    DATE,
          p_approved_date    DATE,
          p_settlement_code    VARCHAR2,
          p_status_code    VARCHAR2,
          p_list_header_id    NUMBER,
          p_version    NUMBER,
          p_budget_adjusted_flag    VARCHAR2,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
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
          p_offer_adjustment_name    VARCHAR2,
          p_description    VARCHAR2
)

 IS
 BEGIN
    Update ozf_offer_adjustments_b
    SET
              offer_adjustment_id = DECODE( p_offer_adjustment_id, null, offer_adjustment_id, FND_API.G_MISS_NUM, null, p_offer_adjustment_id),
              effective_date = DECODE( p_effective_date, to_date(NULL), effective_date, FND_API.G_MISS_DATE, to_date(NULL), p_effective_date),
              approved_date = DECODE( p_approved_date, to_date(NULL), approved_date, FND_API.G_MISS_DATE, to_date(NULL), p_approved_date),
              settlement_code = DECODE( p_settlement_code, null, settlement_code, FND_API.g_miss_char, null, p_settlement_code),
              status_code = DECODE( p_status_code, null, status_code, FND_API.g_miss_char, null, p_status_code),
              list_header_id = DECODE( p_list_header_id, null, list_header_id, FND_API.G_MISS_NUM, null, p_list_header_id),
              version = DECODE( p_version, null, version, FND_API.G_MISS_NUM, null, p_version),
              budget_adjusted_flag = DECODE( p_budget_adjusted_flag, null, budget_adjusted_flag, FND_API.g_miss_char, null, p_budget_adjusted_flag),
              last_update_date = DECODE( p_last_update_date, to_date(null), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
            object_version_number = object_version_number + 1 ,
              attribute1 = DECODE( p_attribute1, null, attribute1, FND_API.g_miss_char, null, p_attribute1),
              attribute2 = DECODE( p_attribute2, null, attribute2, FND_API.g_miss_char, null, p_attribute2),
              attribute3 = DECODE( p_attribute3, null, attribute3, FND_API.g_miss_char, null, p_attribute3),
              attribute4 = DECODE( p_attribute4, null, attribute4, FND_API.g_miss_char, null, p_attribute4),
              attribute5 = DECODE( p_attribute5, null, attribute5, FND_API.g_miss_char, null, p_attribute5),
              attribute6 = DECODE( p_attribute6, null, attribute6, FND_API.g_miss_char, null, p_attribute6),
              attribute7 = DECODE( p_attribute7, null, attribute7, FND_API.g_miss_char, null, p_attribute7),
              attribute8 = DECODE( p_attribute8, null, attribute8, FND_API.g_miss_char, null, p_attribute8),
              attribute9 = DECODE( p_attribute9, null, attribute9, FND_API.g_miss_char, null, p_attribute9),
              attribute10 = DECODE( p_attribute10, null, attribute10, FND_API.g_miss_char, null, p_attribute10),
              attribute11 = DECODE( p_attribute11, null, attribute11, FND_API.g_miss_char, null, p_attribute11),
              attribute12 = DECODE( p_attribute12, null, attribute12, FND_API.g_miss_char, null, p_attribute12),
              attribute13 = DECODE( p_attribute13, null, attribute13, FND_API.g_miss_char, null, p_attribute13),
              attribute14 = DECODE( p_attribute14, null, attribute14, FND_API.g_miss_char, null, p_attribute14),
              attribute15 = DECODE( p_attribute15, null, attribute15, FND_API.g_miss_char, null, p_attribute15)
   WHERE offer_adjustment_id = p_offer_adjustment_id
   AND   object_version_number = px_object_version_number;

   UPDATE ozf_offer_adjustments_tl
   set offer_adjustment_name = DECODE( p_offer_adjustment_name, null, offer_adjustment_name, FND_API.g_miss_char, null, p_offer_adjustment_name),
       description   = DECODE( p_description, null, description, FND_API.g_miss_char, null, p_description),
       last_update_date   = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
       last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
       last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
       source_lang = USERENV('LANG')
   WHERE offer_adjustment_id = p_offer_adjustment_id
   AND USERENV('LANG') IN (language, source_lang);

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
    p_offer_adjustment_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN

    DELETE FROM ozf_offer_adjustments_tl
    WHERE offer_adjustment_id = p_offer_adjustment_id;
    If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

   DELETE FROM ozf_offer_adjustments_b
    WHERE offer_adjustment_id = p_offer_adjustment_id
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
    p_offer_adjustment_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_offer_adjustments_b
        WHERE offer_adjustment_id =  p_offer_adjustment_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF offer_adjustment_id NOWAIT;
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

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           add_language
--   Type
--           Private
--   History
--
--   NOTE
--
-- End of Comments
-- ===============================================================



PROCEDURE Add_Language
IS
BEGIN
   delete from ozf_offer_adjustments_tl T
   where not exists
   (select NULL
   from ozf_offer_adjustments_b b
   where b.offer_adjustment_id = t.offer_adjustment_id
   );

   update ozf_offer_adjustments_tl t set (
   offer_adjustment_name
   , description
   ) = (select
   b.offer_adjustment_name
   , b.description
   from ozf_offer_adjustments_tl b
   where b.offer_adjustment_id = t.offer_adjustment_id
   and b.language = t.source_lang)
   where (
   t.offer_adjustment_id,
   t.language
   ) in (select
           subt.offer_adjustment_id,
           subt.language
           from ozf_offer_adjustments_tl subb, ozf_offer_adjustments_tl subt
           where subb.offer_adjustment_id  = subt.offer_adjustment_id
           and subb.language = subt.source_lang
           and (subb.offer_adjustment_name <> subt.offer_adjustment_name
           or subb.description <> subt.description
           or (subb.description is null and subt.description is not null)
           or (subb.description is not null and subt.description is null)
           ));

   insert into ozf_offer_adjustments_tl (
   offer_adjustment_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   offer_adjustment_name,
   description,
   language,
   source_lang
   ) select
       b.offer_adjustment_id,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       b.offer_adjustment_name,
       b.description,
       l.language_code,
       b.source_lang
       from ozf_offer_adjustments_tl b, fnd_languages l
       where l.installed_flag in ('I', 'B')
           and b.language = userenv('lang')
           and not exists
           (select null
               from ozf_offer_adjustments_tl t
               where t.offer_adjustment_id = b.offer_adjustment_id
               and t.language = l.language_code);
END ADD_LANGUAGE;




END OZF_Offer_Adjustment_PKG;

/
