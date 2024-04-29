--------------------------------------------------------
--  DDL for Package Body OZF_VO_DISC_STRUCT_NAME_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VO_DISC_STRUCT_NAME_PKG" AS
/* $Header: ozftdsnb.pls 120.3 2005/11/15 13:50:55 gramanat noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_VO_DISC_STRUCT_NAME_PKG
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

PROCEDURE Add_Language
IS
BEGIN
   delete from ozf_offr_disc_struct_name_tl T
   where not exists
   (select NULL
   from ozf_offr_disc_struct_name_b b
   where b.offr_disc_struct_name_id = t.offr_disc_struct_name_id
   );

   update ozf_offr_disc_struct_name_tl t set (
   discount_table_name
   , description
   ) = (select
   b.discount_table_name
   , b.description
   from ozf_offr_disc_struct_name_tl b
   where b.offr_disc_struct_name_id = t.offr_disc_struct_name_id
   and b.language = t.source_lang)
   where (
   t.offr_disc_struct_name_id,
   t.language
   ) in (select
           subt.offr_disc_struct_name_id,
           subt.language
           from ozf_offr_disc_struct_name_tl subb, ozf_offr_disc_struct_name_tl subt
           where subb.offr_disc_struct_name_id  = subt.offr_disc_struct_name_id
           and subb.language = subt.source_lang
           and (subb.discount_table_name <> subt.discount_table_name
           or subb.description <> subt.description
           or (subb.description is null and subt.description is not null)
           or (subb.description is not null and subt.description is null)
           ));

   insert into ozf_offr_disc_struct_name_tl (
   offr_disc_struct_name_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   discount_table_name,
   description,
   language,
   source_lang
   ) select
       b.offr_disc_struct_name_id,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       b.discount_table_name,
       b.description,
       l.language_code,
       b.source_lang
       from ozf_offr_disc_struct_name_tl b, fnd_languages l
       where l.installed_flag in ('I', 'B')
           and b.language = userenv('lang')
           and not exists
           (select null
               from ozf_offr_disc_struct_name_tl t
               where t.offr_disc_struct_name_id = b.offr_disc_struct_name_id
               and t.language = l.language_code);
END ADD_LANGUAGE;




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
px_offr_disc_struct_name_id IN OUT NOCOPY NUMBER
, p_offer_discount_line_id IN NUMBER
, p_creation_date IN DATE
, p_created_by IN NUMBER
, p_last_updated_by IN NUMBER
, p_last_update_date IN DATE
, p_last_update_login IN NUMBER
, p_name IN VARCHAR2
, p_description IN VARCHAR2
, px_object_version_number IN OUT NOCOPY NUMBER
)
IS
   x_rowid    VARCHAR2(30);
BEGIN
   px_object_version_number := nvl(px_object_version_number, 1);

   INSERT INTO ozf_offr_disc_struct_name_b(
           offr_disc_struct_name_id
           , offer_discount_line_id
           , object_version_number
           , creation_date
           , created_by
           , last_updated_by
           , last_update_date
           , last_update_login
           ) VALUES (
            px_offr_disc_struct_name_id
           , p_offer_discount_line_id
           , DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number)
           , DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date)
           , DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by)
           , DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by)
           , DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date)
           , DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login)
           );

   INSERT INTO ozf_offr_disc_struct_name_tl(
           offr_disc_struct_name_id
           , language
           , last_update_date
           , last_updated_by
           , creation_date
           , created_by
           , last_update_login
           , source_lang
           , discount_table_name
           , description
           )
SELECT
           px_offr_disc_struct_name_id
           , l.language_code
           , DECODE( p_last_update_date, to_date(NULL), SYSDATE, p_last_update_date)
           , DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by)
           , DECODE( p_creation_date, to_date(NULL), SYSDATE, p_creation_date)
           , DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by)
           , DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login)
           , USERENV('LANG')
           , p_name
           , p_description
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND   NOT EXISTS(SELECT NULL FROM ozf_offr_disc_struct_name_tl t
                    WHERE t.offr_disc_struct_name_id = DECODE( px_offr_disc_struct_name_id, FND_API.G_MISS_NUM, NULL, px_offr_disc_struct_name_id)
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
p_offr_disc_struct_name_id IN NUMBER
, p_offer_discount_line_id IN NUMBER
, p_last_update_date IN DATE
, p_last_updated_by IN NUMBER
, p_last_update_login IN NUMBER
, p_name IN VARCHAR2
, p_description IN VARCHAR2
, px_object_version_number IN OUT NOCOPY NUMBER
)
IS
BEGIN
    Update ozf_offr_disc_struct_name_b
    SET
              offr_disc_struct_name_id = DECODE( p_offr_disc_struct_name_id, null, offr_disc_struct_name_id, FND_API.G_MISS_NUM, null, p_offr_disc_struct_name_id)
              , offer_discount_line_id = DECODE( p_offer_discount_line_id, null, offer_discount_line_id, FND_API.G_MISS_NUM, null, p_offer_discount_line_id)
              , last_update_date = DECODE( p_last_update_date, to_date(null), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date)
              , last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by)
              , last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
              , object_version_number = object_version_number + 1
   WHERE offr_disc_struct_name_id = p_offr_disc_struct_name_id
   AND   object_version_number = px_object_version_number;

   UPDATE ozf_offr_disc_struct_name_tl
   set discount_table_name = DECODE( p_name, null, discount_table_name, FND_API.g_miss_char, null, p_name)
       , description   = DECODE( p_description, null, description, FND_API.g_miss_char, null, p_description)
       , last_update_date   = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date)
       , last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by)
       , last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
       , source_lang = USERENV('LANG')
   WHERE offr_disc_struct_name_id = p_offr_disc_struct_name_id
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
    p_offr_disc_struct_name_id  NUMBER,
    p_object_version_number  NUMBER
    )
    IS
 BEGIN
    DELETE FROM ozf_offr_disc_struct_name_tl
    WHERE offr_disc_struct_name_id = p_offr_disc_struct_name_id;

    If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    End If;

   DELETE FROM ozf_offr_disc_struct_name_b
    WHERE offr_disc_struct_name_id = p_offr_disc_struct_name_id
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
    p_offr_disc_struct_name_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_offr_disc_struct_name_b
        WHERE offr_disc_struct_name_id =  p_offr_disc_struct_name_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF offr_disc_struct_name_id NOWAIT;
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


/*
PROCEDURE Add_Language
IS
BEGIN
   delete from ozf_offr_disc_struct_name_tl T
   where not exists
   (select NULL
   from ozf_offr_disc_struct_name_b b
   where b.offr_disc_struct_name_id = t.offr_disc_struct_name_id
   );

   update ozf_offr_disc_struct_name_tl t set (
   name
   , description
   ) = (select
     b.name
   , b.description
   from ozf_offr_disc_struct_name_tl b
   where b.offr_disc_struct_name_id = t.offr_disc_struct_name_id
   and b.language = t.source_lang)
   where (
   t.offr_disc_struct_name_id,
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
*/


END OZF_VO_DISC_STRUCT_NAME_PKG;

/
