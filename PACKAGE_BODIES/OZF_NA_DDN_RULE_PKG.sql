--------------------------------------------------------
--  DDL for Package Body OZF_NA_DDN_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_NA_DDN_RULE_PKG" as
/* $Header: ozftdnrb.pls 120.1 2006/02/25 19:23:10 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Na_Ddn_Rule_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Na_Ddn_Rule_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstam.b.pls';




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
          px_na_deduction_rule_id   IN OUT NOCOPY NUMBER,
          p_transaction_source_code    VARCHAR2,
          p_transaction_type_code    VARCHAR2,
          p_deduction_identifier_id    VARCHAR2,
          p_deduction_identifier_org_id NUMBER,
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


   INSERT INTO ozf_na_deduction_rules_b(
           na_deduction_rule_id,
           transaction_source_code,
           transaction_type_code,
           deduction_identifier_id,
           deduction_identifier_org_id,
           object_version_number,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login
   ) VALUES (
           DECODE( px_na_deduction_rule_id, FND_API.G_MISS_NUM, NULL, px_na_deduction_rule_id),
           DECODE( p_transaction_source_code, FND_API.g_miss_char, NULL, p_transaction_source_code),
           DECODE( p_transaction_type_code, FND_API.g_miss_char, NULL, p_transaction_type_code),
           DECODE( p_deduction_identifier_id, FND_API.G_MISS_CHAR, NULL, p_deduction_identifier_id),
           DECODE( p_deduction_identifier_org_id, FND_API.G_MISS_NUM, NULL, p_deduction_identifier_org_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login));

   INSERT INTO ozf_na_deduction_rules_tl(
           na_deduction_rule_id ,
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
           DECODE( px_na_deduction_rule_id, FND_API.G_MISS_NUM, NULL, px_na_deduction_rule_id),
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
   AND   NOT EXISTS(SELECT NULL FROM ozf_na_deduction_rules_tl t
                    WHERE t.na_deduction_rule_id = DECODE( px_na_deduction_rule_id, FND_API.G_MISS_NUM, NULL, px_na_deduction_rule_id)
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
          p_na_deduction_rule_id    NUMBER,
          p_transaction_source_code    VARCHAR2,
          p_transaction_type_code    VARCHAR2,
          p_deduction_identifier_id    VARCHAR2,
          p_deduction_identifier_org_id NUMBER,
          p_object_version_number   IN NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2
)

 IS
 BEGIN
    Update ozf_na_deduction_rules_b
    SET
              na_deduction_rule_id = DECODE( p_na_deduction_rule_id, null, na_deduction_rule_id, FND_API.G_MISS_NUM, null, p_na_deduction_rule_id),
              transaction_source_code = DECODE( p_transaction_source_code, null, transaction_source_code, FND_API.g_miss_char, null, p_transaction_source_code),
              transaction_type_code = DECODE( p_transaction_type_code, null, transaction_type_code, FND_API.g_miss_char, null, p_transaction_type_code),
              deduction_identifier_id = DECODE( p_deduction_identifier_id, null, deduction_identifier_id, FND_API.G_MISS_CHAR, null, p_deduction_identifier_id),
              deduction_identifier_org_id = DECODE( p_deduction_identifier_org_id, null, deduction_identifier_org_id, FND_API.G_MISS_NUM, null, p_deduction_identifier_org_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              last_update_date = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login)
   WHERE na_deduction_rule_id = p_na_deduction_rule_id
   AND   object_version_number = p_object_version_number;

   UPDATE ozf_na_deduction_rules_tl
   set name = DECODE( p_name, null, name, FND_API.g_miss_char, null, p_name),
       description   = DECODE( p_description, null, description, FND_API.g_miss_char, null, p_description),
       last_update_date   = DECODE( p_last_update_date, to_date(NULL), last_update_date, FND_API.G_MISS_DATE, to_date(NULL), p_last_update_date),
       last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
       last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
       source_lang = USERENV('LANG')
   WHERE na_deduction_rule_id = p_na_deduction_rule_id
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
    p_na_deduction_rule_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM ozf_na_deduction_rules_b
    WHERE na_deduction_rule_id = p_na_deduction_rule_id
    AND object_version_number = p_object_version_number;
  DELETE FROM ozf_na_deduction_rules_tl
   WHERE na_deduction_rule_id = p_na_deduction_rule_id;

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
    p_na_deduction_rule_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM ozf_na_deduction_rules_b
        WHERE na_deduction_rule_id =  p_na_deduction_rule_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF na_deduction_rule_id NOWAIT;
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
   delete from ozf_na_deduction_rules_tl T
   where not exists
   (select NULL
   from ozf_na_deduction_rules_b b
   where b.na_deduction_rule_id = t.na_deduction_rule_id
   );

   update ozf_na_deduction_rules_tl t set (
   name
   , description
   ) = (select
   b.name
   , b.description
   from ozf_na_deduction_rules_tl b
   where b.na_deduction_rule_id = t.na_deduction_rule_id
   and b.language = t.source_lang)
   where (
   t.na_deduction_rule_id,
   t.language
   ) in (select
           subt.na_deduction_rule_id,
           subt.language
           from ozf_na_deduction_rules_tl subb, ozf_na_deduction_rules_tl subt
           where subb.na_deduction_rule_id  = subt.na_deduction_rule_id
           and subb.language = subt.source_lang
           and (subb.name <> subt.name
           or subb.description <> subt.description
           or (subb.description is null and subt.description is not null)
           or (subb.description is not null and subt.description is null)
           ));

   insert into ozf_na_deduction_rules_tl (
   na_deduction_rule_id,
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
       b.na_deduction_rule_id,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       b.name,
       b.description,
       l.language_code,
       b.source_lang
       from ozf_na_deduction_rules_tl b, fnd_languages l
       where l.installed_flag in ('I', 'B')
           and b.language = userenv('lang')
           and not exists
           (select null
               from ozf_na_deduction_rules_tl t
               where t.na_deduction_rule_id = b.na_deduction_rule_id
               and t.language = l.language_code);
END ADD_LANGUAGE;




END OZF_Na_Ddn_Rule_PKG;

/
