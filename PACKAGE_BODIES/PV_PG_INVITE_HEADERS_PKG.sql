--------------------------------------------------------
--  DDL for Package Body PV_PG_INVITE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_INVITE_HEADERS_PKG" as
/* $Header: pvxtpihb.pls 120.1 2005/08/29 14:18:31 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Pv_Pg_Invite_Headers_PKG
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Pv_Pg_Invite_Headers_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxtpihb.pls';




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
          px_invite_header_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_qp_list_header_id    VARCHAR2,
          p_invite_type_code    VARCHAR2,
          p_invite_for_program_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_partner_id    NUMBER,
          p_invite_end_date    DATE,
          p_order_header_id    NUMBER,
          p_invited_by_partner_id    NUMBER,
          p_EMAIL_CONTENT    VARCHAR2,
          p_trxn_extension_id NUMBER
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := nvl(px_object_version_number, 1);


   INSERT INTO pv_pg_invite_headers_b(
           invite_header_id,
           object_version_number,
           qp_list_header_id,
           invite_type_code,
           invite_for_program_id,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           partner_id,
           invite_end_date,
           order_header_id,
           invited_by_partner_id,
           trxn_extension_id
   ) VALUES (
           DECODE( px_invite_header_id, FND_API.G_MISS_NUM, NULL, px_invite_header_id),
           DECODE( px_object_version_number, FND_API.G_MISS_NUM, 1, px_object_version_number),
           DECODE( p_qp_list_header_id, FND_API.g_miss_char, NULL, p_qp_list_header_id),
           DECODE( p_invite_type_code, FND_API.g_miss_char, NULL, p_invite_type_code),
           DECODE( p_invite_for_program_id, FND_API.G_MISS_NUM, NULL, p_invite_for_program_id),
           DECODE( p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_creation_date, FND_API.G_MISS_DATE, SYSDATE, p_creation_date),
           DECODE( p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, p_last_update_date),
           DECODE( p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           DECODE( p_partner_id, FND_API.G_MISS_NUM, NULL, p_partner_id),
           DECODE( p_invite_end_date, FND_API.G_MISS_DATE, NULL, p_invite_end_date),
           DECODE( p_order_header_id, FND_API.G_MISS_NUM, NULL, p_order_header_id),
           DECODE( p_invited_by_partner_id, FND_API.G_MISS_NUM, NULL, p_invited_by_partner_id),
	   DECODE( p_trxn_extension_id, FND_API.G_MISS_NUM, NULL, p_trxn_extension_id)
           );

   INSERT INTO pv_pg_invite_headers_tl(
           invite_header_id ,
           language ,
           last_update_date ,
           last_updated_by ,
           creation_date ,
           created_by ,
           last_update_login ,
           source_lang ,
           EMAIL_CONTENT
)
SELECT
           DECODE( px_invite_header_id, FND_API.G_MISS_NUM, NULL, px_invite_header_id),
           l.language_code,
           DECODE( p_last_update_date, NULL, SYSDATE, p_last_update_date),
           DECODE( p_last_updated_by, NULL, FND_GLOBAL.USER_ID, p_last_updated_by),
           DECODE( p_creation_date, NULL, SYSDATE, p_creation_date),
           DECODE( p_created_by, NULL, FND_GLOBAL.USER_ID, p_created_by),
           DECODE( p_last_update_login, NULL, FND_GLOBAL.CONC_LOGIN_ID, p_last_update_login),
           USERENV('LANG'),
           DECODE( p_EMAIL_CONTENT , FND_API.G_MISS_CHAR, NULL, p_EMAIL_CONTENT)
   FROM fnd_languages l
   WHERE l.installed_flag IN ('I','B')
   AND   NOT EXISTS(SELECT NULL FROM pv_pg_invite_headers_tl t
                    WHERE t.invite_header_id = DECODE( px_invite_header_id, FND_API.G_MISS_NUM, NULL, px_invite_header_id)
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
          p_invite_header_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_qp_list_header_id    VARCHAR2,
          p_invite_type_code    VARCHAR2,
          p_invite_for_program_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_partner_id    NUMBER,
          p_invite_end_date    DATE,
          p_order_header_id    NUMBER,
          p_invited_by_partner_id    NUMBER,
          p_EMAIL_CONTENT    VARCHAR2,
	  p_trxn_extension_id NUMBER
)

 IS
 BEGIN
    Update pv_pg_invite_headers_b
    SET
              invite_header_id = DECODE( p_invite_header_id, null, invite_header_id, FND_API.G_MISS_NUM, null, p_invite_header_id),
            object_version_number = nvl(p_object_version_number,0) + 1 ,
              qp_list_header_id = DECODE( p_qp_list_header_id, null, qp_list_header_id, FND_API.g_miss_char, null, p_qp_list_header_id),
              invite_type_code = DECODE( p_invite_type_code, null, invite_type_code, FND_API.g_miss_char, null, p_invite_type_code),
              invite_for_program_id = DECODE( p_invite_for_program_id, null, invite_for_program_id, FND_API.G_MISS_NUM, null, p_invite_for_program_id),
              last_updated_by = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
              partner_id = DECODE( p_partner_id, null, partner_id, FND_API.G_MISS_NUM, null, p_partner_id),
              invite_end_date = DECODE( p_invite_end_date, null, invite_end_date, FND_API.G_MISS_DATE, null, p_invite_end_date),
              order_header_id = DECODE( p_order_header_id, null, order_header_id, FND_API.G_MISS_NUM, null, p_order_header_id),
              invited_by_partner_id = DECODE( p_invited_by_partner_id, null, invited_by_partner_id, FND_API.G_MISS_NUM, null, p_invited_by_partner_id),
              trxn_extension_id = DECODE( p_trxn_extension_id, null, trxn_extension_id, FND_API.G_MISS_NUM, null, p_trxn_extension_id)
   WHERE invite_header_id = p_invite_header_id
   AND   object_version_number = p_object_version_number;

   UPDATE pv_pg_invite_headers_tl
   set EMAIL_CONTENT   = DECODE( p_EMAIL_CONTENT, null, EMAIL_CONTENT, FND_API.g_miss_char, null, p_EMAIL_CONTENT),
       last_update_date   = DECODE( p_last_update_date, null, last_update_date, FND_API.G_MISS_DATE, null, p_last_update_date),
       last_updated_by   = DECODE( p_last_updated_by, null, last_updated_by, FND_API.G_MISS_NUM, null, p_last_updated_by),
       last_update_login   = DECODE( p_last_update_login, null, last_update_login, FND_API.G_MISS_NUM, null, p_last_update_login),
       source_lang = USERENV('LANG')
   WHERE invite_header_id = p_invite_header_id
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
    p_invite_header_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
 BEGIN
   DELETE FROM pv_pg_invite_headers_b
    WHERE invite_header_id = p_invite_header_id
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
    p_invite_header_id  NUMBER,
    p_object_version_number  NUMBER)
 IS
   CURSOR C IS
        SELECT *
         FROM pv_pg_invite_headers_b
        WHERE invite_header_id =  p_invite_header_id
        AND object_version_number = p_object_version_number
        FOR UPDATE OF invite_header_id NOWAIT;
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
   -- changing by ktsao as per performance team guidelines to fix performance issue
   -- as described in bug 3723612 (*** RTIKKU  03/24/05 12:46pm ***)
   INSERT /*+ append parallel(tt) */  INTO pv_pg_invite_headers_tl tt (
   INVITE_HEADER_ID,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   email_content,
   language,
   source_lang
   )
   select /*+ parallel(v) parallel(t) use_nl(t)  */ v.* from
    ( SELECT /*+ no_merge ordered parallel(b) */
       b.INVITE_HEADER_ID,
       b.creation_date,
       b.created_by,
       b.last_update_date,
       b.last_updated_by,
       b.last_update_login,
       b.email_content,
       l.language_code,
       b.source_lang
      FROM pv_pg_invite_headers_tl B ,
        FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ( 'I','B' )
     AND B.LANGUAGE = USERENV ( 'LANG' )
   ) v, pv_pg_invite_headers_tl t
    WHERE t.INVITE_HEADER_ID(+) = v.INVITE_HEADER_ID
   AND t.language(+) = v.language_code
   AND t.INVITE_HEADER_ID IS NULL;

END ADD_LANGUAGE;

END Pv_Pg_Invite_Headers_PKG;

/
