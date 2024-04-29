--------------------------------------------------------
--  DDL for Package Body AMS_CONTENT_RULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CONTENT_RULES_B_PKG" as
/* $Header: amstctrb.pls 120.2 2006/05/30 11:10:24 prageorg noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CONTENT_RULES_B_PKG
--
-- Purpose
--          Private api created to Update/insert/Delete general
--          and object-specific content rules
--
-- History
--    21-mar-2002    jieli       Created.
--    29-apr-2002    soagrawa    Modified last_updated_Date to last_update_date
--    28-mar-2003    soagrawa    Added add_language. Bug# 2876033
--    29-May-2006    prageorg    Added delivery_mode bug 4920064
--
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_CONTENT_RULES_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstctrb.pls';



--  ========================================================
--
--  NAME
--     Insert_Row
--
--  HISTORY
--     21-mar-2002  jieli     Created
--     11-apr-2002  soagrawa  Removed hardcoding of table of content flag and enabled flag
--     29-May-2006  prageorg  Added delivery_mode bug 4896511
--  ========================================================
PROCEDURE Insert_Row(
          px_content_rule_id   IN OUT NOCOPY NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_updated_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_sender    VARCHAR2,
          p_reply_to    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_table_of_content_flag    VARCHAR2,
          p_trigger_code    VARCHAR2,
          p_enabled_flag    VARCHAR2,
     p_subject         VARCHAR2,
     p_sender_display_name    VARCHAR2,
     -- ADDED BY PRAGEORG ON 5/29/2006
     p_delivery_mode  VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);
   l_rowid VARCHAR2(20);
   l_last_update_date DATE;

   cursor C is select ROWID from AMS_content_rules_b
   where content_rule_ID = px_content_rule_id;


BEGIN


   px_object_version_number := 1;
   AMS_UTILITY_PVT.debug_message('SONALI table handler '||p_last_updated_date);

   l_last_update_date := p_last_updated_date;
   IF p_last_updated_date IS NULL
   THEN l_last_update_date := sysdate;
   END IF;

   AMS_UTILITY_PVT.debug_message('SONALI table handler '||l_last_update_date);

   INSERT INTO AMS_CONTENT_RULES_B(
           content_rule_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           object_type,
           object_id,
           sender,
           reply_to,
           cover_letter_id,
           table_of_content_flag,
           trigger_code,
           enabled_flag,
           default_flag,
	   sender_display_name,
	   -- ADDED BY PRAGEORG ON 5/29/2006
           delivery_mode
   ) VALUES (
           DECODE( px_content_rule_id, FND_API.g_miss_num, NULL, px_content_rule_id)
           , DECODE( p_created_by, FND_API.g_miss_num, 1, p_created_by)
           , DECODE( p_creation_date, FND_API.g_miss_date, sysdate, p_creation_date)
           , DECODE( p_last_updated_by, FND_API.g_miss_num, 1, p_last_updated_by)
           , DECODE( p_last_updated_date, FND_API.g_miss_date, sysdate, l_last_update_date)
           , DECODE( p_last_update_login, FND_API.g_miss_num, 1, p_last_update_login)
           , DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number)
           , DECODE( p_object_type, FND_API.g_miss_char, NULL, p_object_type)
           , DECODE( p_object_id, FND_API.g_miss_num, NULL, p_object_id)
           , DECODE( p_sender, FND_API.g_miss_char, NULL, p_sender)
           , DECODE( p_reply_to, FND_API.g_miss_char, NULL, p_reply_to)
           , DECODE( p_cover_letter_id, FND_API.g_miss_num, NULL, p_cover_letter_id)
           , DECODE( p_table_of_content_flag, FND_API.g_miss_char, 'N', NVL(p_table_of_content_flag, 'N')) --'N',
           , DECODE( p_trigger_code, FND_API.g_miss_char, NULL, p_trigger_code)
           , DECODE( p_enabled_flag, FND_API.g_miss_char, 'Y', NVL(p_enabled_flag, 'Y')) --'Y',
           , 'N' -- DECODE( p_default_flag, FND_API.g_miss_char, 'Y', p_default_flag) --'Y'
	   , DECODE( p_sender_display_name, FND_API.g_miss_char, NULL, p_sender_display_name)--anchaudh
	    -- ADDED BY PRAGEORG ON 5/29/2006
           , DECODE( p_delivery_mode, FND_API.g_miss_char, NULL, p_delivery_mode)
           );

 INSERT INTO AMS_CONTENT_RULES_TL(
           content_rule_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           language,
           source_lang,
           email_subject
   )  select
    px_content_rule_id,
    sysdate,
    p_last_updated_by,
    sysdate,
    p_created_by,
    p_last_update_login,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    p_subject
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ams_content_rules_tl T
    where T.content_rule_ID = px_content_rule_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END Insert_Row;


--  ========================================================
--
--  NAME
--     Update_Row
--
--  HISTORY
--     21-mar-2002  jieli     Created
--     29-May-2006  prageorg  Added delivery_mode
--  ========================================================


PROCEDURE Update_Row(
          p_content_rule_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_updated_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_sender    VARCHAR2,
          p_reply_to    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_table_of_content_flag    VARCHAR2,
          p_trigger_code    VARCHAR2,
          p_enabled_flag    VARCHAR2,
     p_subject         VARCHAR2,
     p_sender_display_name    VARCHAR2,
     -- ADDED BY PRAGEORG ON 5/29/2006
     p_delivery_mode  VARCHAR2)

 IS
 BEGIN
    Update AMS_CONTENT_RULES_B
    SET
              content_rule_id = DECODE( p_content_rule_id, FND_API.g_miss_num, content_rule_id, p_content_rule_id),
              created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
              creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = DECODE( p_last_updated_date, FND_API.g_miss_date, last_update_date, p_last_updated_date),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
              object_type = DECODE( p_object_type, FND_API.g_miss_char, object_type, p_object_type),
              object_id = DECODE( p_object_id, FND_API.g_miss_num, object_id, p_object_id),
              sender = DECODE( p_sender, FND_API.g_miss_char, sender, p_sender),
              reply_to = DECODE( p_reply_to, FND_API.g_miss_char, reply_to, p_reply_to),
              cover_letter_id = DECODE( p_cover_letter_id, FND_API.g_miss_num, cover_letter_id, p_cover_letter_id),
              table_of_content_flag = DECODE( p_table_of_content_flag, FND_API.g_miss_char, table_of_content_flag, p_table_of_content_flag),
              trigger_code = DECODE( p_trigger_code, FND_API.g_miss_char, trigger_code, p_trigger_code),
              enabled_flag = DECODE( p_enabled_flag, FND_API.g_miss_char, enabled_flag, p_enabled_flag),
	      sender_display_name = DECODE( p_sender_display_name, FND_API.g_miss_char, sender_display_name, p_sender_display_name),--anchaudh
	       -- added by prageorg on 5/29/2006
              delivery_mode = DECODE( p_delivery_mode, FND_API.g_miss_char, delivery_mode, p_delivery_mode)

   WHERE CONTENT_RULE_ID = p_CONTENT_RULE_ID
   AND   object_version_number = p_object_version_number;

   update AMS_CONTENT_RULES_TL
   set
           last_update_date=DECODE( p_last_updated_date, FND_API.g_miss_date, last_update_date, p_last_updated_date),
           last_updated_by=DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
           creation_date=DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
           created_by=DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
           last_update_login=DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
           source_lang=userenv('LANG'),
           email_subject=DECODE( p_subject, FND_API.g_miss_char, email_subject, p_subject)
   where CONTENT_RULE_ID = p_CONTENT_RULE_ID
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

END Update_Row;


--  ========================================================
--
--  NAME
--     Delete_Row
--
--  HISTORY
--     21-mar-2002  jieli     Created
--  ========================================================


PROCEDURE Delete_Row(
    p_CONTENT_RULE_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_CONTENT_RULES_B
    WHERE CONTENT_RULE_ID = p_CONTENT_RULE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  DELETE FROM AMS_CONTENT_RULES_TL
    WHERE CONTENT_RULE_ID = p_CONTENT_RULE_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
 END Delete_Row ;



--  ========================================================
--
--  NAME
--     Lock_Row
--
--  HISTORY
--     21-mar-2002  jieli     Created
--     29-May-2006  prageorg  Added delivery_mode
--  ========================================================


PROCEDURE Lock_Row(
          p_content_rule_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_updated_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_sender    VARCHAR2,
          p_reply_to    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_table_of_content_flag    VARCHAR2,
          p_trigger_code    VARCHAR2,
          p_enabled_flag    VARCHAR2,
     p_subject         VARCHAR2,
     p_sender_display_name    VARCHAR2,
     -- ADDED BY PRAGEORG ON 5/29/2006
     p_delivery_mode  VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_CONTENT_RULES_B
        WHERE CONTENT_RULE_ID =  p_CONTENT_RULE_ID
        FOR UPDATE of CONTENT_RULE_ID NOWAIT;
   Recinfo C%ROWTYPE;
 BEGIN
    OPEN c;
    FETCH c INTO Recinfo;
    If (c%NOTFOUND) then
        CLOSE c;
        FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
    CLOSE C;
    IF (
           (      Recinfo.content_rule_id = p_content_rule_id)
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_updated_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_updated_date IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.object_type = p_object_type)
            OR (    ( Recinfo.object_type IS NULL )
                AND (  p_object_type IS NULL )))
       AND (    ( Recinfo.object_id = p_object_id)
            OR (    ( Recinfo.object_id IS NULL )
                AND (  p_object_id IS NULL )))
       AND (    ( Recinfo.sender = p_sender)
            OR (    ( Recinfo.sender IS NULL )
                AND (  p_sender IS NULL )))
       AND (    ( Recinfo.reply_to = p_reply_to)
            OR (    ( Recinfo.reply_to IS NULL )
                AND (  p_reply_to IS NULL )))
       AND (    ( Recinfo.cover_letter_id = p_cover_letter_id)
            OR (    ( Recinfo.cover_letter_id IS NULL )
                AND (  p_cover_letter_id IS NULL )))
       AND (    ( Recinfo.table_of_content_flag = p_table_of_content_flag)
            OR (    ( Recinfo.table_of_content_flag IS NULL )
                AND (  p_table_of_content_flag IS NULL )))
       AND (    ( Recinfo.trigger_code = p_trigger_code)
            OR (    ( Recinfo.trigger_code IS NULL )
                AND (  p_trigger_code IS NULL )))
       AND (    ( Recinfo.enabled_flag = p_enabled_flag)
            OR (    ( Recinfo.enabled_flag IS NULL )
                AND (  p_enabled_flag IS NULL )))
       AND (    ( Recinfo.sender_display_name = p_sender_display_name)
            OR (    ( Recinfo.sender_display_name IS NULL )
                AND (  p_sender_display_name IS NULL )))--anchaudh
       AND (    ( Recinfo.delivery_mode = p_delivery_mode)
            OR (    ( Recinfo.delivery_mode IS NULL )
                AND (  p_delivery_mode IS NULL )))--prageorg
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;


procedure ADD_LANGUAGE
is
begin
  delete from AMS_CONTENT_RULES_TL T
  where not exists
    (select NULL
    from AMS_CONTENT_RULES_B B
    where B.content_rule_id = T.content_rule_id
    );

  update AMS_CONTENT_RULES_TL T set (
      email_subject
    ) = (select
      B.email_subject
    from AMS_CONTENT_RULES_tl B
    where B.content_rule_id = T.content_rule_id
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.content_rule_id,
      T.LANGUAGE
  ) in (select
      SUBT.content_rule_id,
      SUBT.LANGUAGE
    from AMS_CONTENT_RULES_TL SUBB, AMS_CONTENT_RULES_TL SUBT
    where SUBB.content_rule_id = SUBT.content_rule_id
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.email_subject <> SUBT.email_subject
  ));

  insert into AMS_CONTENT_RULES_TL (
     CONTENT_RULE_ID,
     CREATED_BY,
     CREATION_DATE,
     EMAIL_SUBJECT,
     LANGUAGE,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     LAST_UPDATED_BY,
     SECURITY_GROUP_ID,
     SOURCE_LANG
  ) select
     B.CONTENT_RULE_ID,
     B.CREATED_BY,
     B.CREATION_DATE,
     B.EMAIL_SUBJECT,
     L.LANGUAGE_CODE,
     B.LAST_UPDATE_DATE,
     B.LAST_UPDATE_LOGIN,
     B.LAST_UPDATED_BY,
     B.SECURITY_GROUP_ID,
     B.SOURCE_LANG
  from AMS_CONTENT_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_CONTENT_RULES_TL T
    where T.content_rule_id = B.content_rule_id
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


END AMS_CONTENT_RULES_B_PKG;

/
