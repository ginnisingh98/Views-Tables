--------------------------------------------------------
--  DDL for Package Body OZF_NA_RULE_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_NA_RULE_HEADER_PKG" as
/* $Header: ozftnarb.pls 120.0 2005/06/01 01:58:18 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Na_Rule_Header_PKG
-- Purpose
--
-- History
--        Tue Dec 16 2003:2/13 PM RSSHARMA Fixed delete_row. Delete the row from tl table also
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Na_Rule_Header_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftdnrb.pls';




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
          px_na_rule_header_id   IN OUT NOCOPY NUMBER,
          p_user_status_id    NUMBER,
          p_status_code    VARCHAR2,
          p_start_date    DATE,
          p_end_date    DATE,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO ozf_na_rule_headers_b(
           na_rule_header_id,
           user_status_id,
           status_code,
           start_date,
           end_date,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login
   ) VALUES (
           DECODE( px_na_rule_header_id, FND_API.G_MISS_NUM, NULL, px_na_rule_header_id),
           DECODE( p_user_status_id, FND_API.G_MISS_NUM, NULL, p_user_status_id),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_start_date, FND_API.G_MISS_DATE, NULL, p_start_date),
           DECODE( p_end_date, FND_API.G_MISS_DATE, NULL, p_end_date),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login));

   INSERT INTO ozf_na_rule_headers_tl(
           na_rule_header_id ,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           name ,
           description
)
SELECT
           DECODE( px_na_rule_header_id, FND_API.G_MISS_NUM, NULL, px_na_rule_header_id),
           l.language_code,
           DECODE( p_last_update_date, to_date(NULL), SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, to_date(NULL), SYSDATE, p_creation_date),
           DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           USERENV('LANG'),
           DECODE( p_name, FND_API.G_MISS_CHAR, NULL, p_name),
           DECODE( p_description, FND_API.G_MISS_CHAR, NULL, p_description)
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND   NOT EXISTS(SELECT NULL FROM ozf_na_rule_headers_tl t
                    WHERE t.na_rule_header_id = DECODE( px_na_rule_header_id, FND_API.G_MISS_NUM, NULL, px_na_rule_header_id)
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
          p_na_rule_header_id    NUMBER,
          p_user_status_id    NUMBER,
          p_status_code    VARCHAR2,
          p_start_date    DATE,
          p_end_date    DATE,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2
)

 IS
 BEGIN
    Update ozf_na_rule_headers_b
    SET
              na_rule_header_id = DECODE( p_na_rule_header_id, null, na_rule_header_id, FND_API.G_MISS_NUM, null, p_na_rule_header_id),
              user_status_id = DECODE( p_user_status_id, null, user_status_id, FND_API.G_MISS_NUM, null, p_user_status_id),
              status_code = DECODE( p_status_code, null, status_code, FND_API.g_miss_char, null, p_status_code),
              start_date = DECODE( p_start_date, null, start_date, FND_API.G_MISS_DATE, null, p_start_date),
              end_date = DECODE( p_end_date, null, end_date, FND_API.G_MISS_DATE, null, p_end_date),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE na_rule_header_id = p_na_rule_header_id
   AND   object_version_number = p_object_version_number;

   UPDATE ozf_na_rule_headers_tl
   set name = DECODE( p_name, null, name, FND_API.g_miss_char, null, p_name),
       description   = DECODE( p_description, null, description, FND_API.g_miss_char, null, p_description),
       last_update_date   = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
       last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
       last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
       source_lang = USERENV('LANG')
   WHERE na_rule_header_id = p_na_rule_header_id
   AND USERENV('LANG') IN (language, source_lang);

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
    p_na_rule_header_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_na_rule_headers_b
    WHERE na_rule_header_id = p_na_rule_header_id
    AND object_version_number = p_object_version_number;
   If (SQL%NOTFOUND) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

   DELETE FROM ozf_na_rule_headers_tl
    WHERE na_rule_header_id = p_na_rule_header_id;

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
    p_na_rule_header_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_na_rule_headers_b
        WHERE na_rule_header_id =  p_na_rule_header_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF na_rule_header_id NOWAIT;
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
   delete from ozf_na_rule_headers_tl T
   where not exists
   (select NULL
   from ozf_na_rule_headers_b b
   where b.na_rule_header_id = t.na_rule_header_id
   );

   update ozf_na_rule_headers_tl t set (
   name
   , description
   ) = (select
   b.name
   , b.description
   from ozf_na_rule_headers_tl b
   where b.na_rule_header_id = t.na_rule_header_id
   and b.language = t.source_lang)
   where (
   t.na_rule_header_id,
   t.language
   ) in (select
           subt.na_rule_header_id,
           subt.language
           from ozf_na_rule_headers_tl subb, ozf_na_rule_headers_tl subt
           where subb.na_rule_header_id  = subt.na_rule_header_id
           and subb.language = subt.source_lang
           and (subb.name <> subt.name
           or subb.description <> subt.description
           or (subb.description is null and subt.description is not null)
           or (subb.description is not null and subt.description is null)
           ));

   insert into ozf_na_rule_headers_tl (
   na_rule_header_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   name,
   description,
   language,
   source_lang
   ) select
       b.na_rule_header_id,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       b.name,
       b.description,
       l.language_code,
       b.source_lang
       from ozf_na_rule_headers_tl b, fnd_languages l
       where l.installed_flag in ('I', 'B')
           and b.language = userenv('lang')
           and not exists
           (select null
               from ozf_na_rule_headers_tl t
               where t.na_rule_header_id = b.na_rule_header_id
               and t.language = l.language_code);
END ADD_LANGUAGE;




END OZF_Na_Rule_Header_PKG;

/
