--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PS_POSTINGS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PS_POSTINGS_B_PKG" as
/* $Header: amstpstb.pls 115.9 2002/12/19 04:16:57 ryedator ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PS_POSTINGS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstpstb.pls';

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createInsertBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          px_posting_id   IN OUT NOCOPY NUMBER,
          p_max_no_contents    NUMBER,
          p_posting_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_default_content_id    NUMBER,
          p_status_code    VARCHAR2,
          p_posting_name   IN VARCHAR2,
          p_display_name   IN VARCHAR2,
          p_posting_description IN VARCHAR2,
          p_attribute_category    VARCHAR2,
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
          p_attribute15    VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);

BEGIN

   px_object_version_number := 1;

   INSERT INTO AMS_IBA_PS_POSTINGS_B(
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number,
           posting_id,
           max_no_contents,
           posting_type,
           content_type,
           default_content_id,
           status_code,
           attribute_category,
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
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
           DECODE( px_posting_id, FND_API.g_miss_num, NULL, px_posting_id),
           DECODE( p_max_no_contents, FND_API.g_miss_num, NULL, p_max_no_contents),
           DECODE( p_posting_type, FND_API.g_miss_char, NULL, p_posting_type),
           DECODE( p_content_type, FND_API.g_miss_char, NULL, p_content_type),
           DECODE( p_default_content_id, FND_API.g_miss_num, NULL, p_default_content_id),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_attribute_category, FND_API.g_miss_char, NULL, p_attribute_category),
           DECODE( p_attribute1, FND_API.g_miss_char, NULL, p_attribute1),
           DECODE( p_attribute2, FND_API.g_miss_char, NULL, p_attribute2),
           DECODE( p_attribute3, FND_API.g_miss_char, NULL, p_attribute3),
           DECODE( p_attribute4, FND_API.g_miss_char, NULL, p_attribute4),
           DECODE( p_attribute5, FND_API.g_miss_char, NULL, p_attribute5),
           DECODE( p_attribute6, FND_API.g_miss_char, NULL, p_attribute6),
           DECODE( p_attribute7, FND_API.g_miss_char, NULL, p_attribute7),
           DECODE( p_attribute8, FND_API.g_miss_char, NULL, p_attribute8),
           DECODE( p_attribute9, FND_API.g_miss_char, NULL, p_attribute9),
           DECODE( p_attribute10, FND_API.g_miss_char, NULL, p_attribute10),
           DECODE( p_attribute11, FND_API.g_miss_char, NULL, p_attribute11),
           DECODE( p_attribute12, FND_API.g_miss_char, NULL, p_attribute12),
           DECODE( p_attribute13, FND_API.g_miss_char, NULL, p_attribute13),
           DECODE( p_attribute14, FND_API.g_miss_char, NULL, p_attribute14),
           DECODE( p_attribute15, FND_API.g_miss_char, NULL, p_attribute15));


INSERT INTO ams_iba_ps_postings_tl (
    created_by,
    creation_date,
    last_update_date,
    last_update_login,
    last_updated_by,
    object_version_number,
    posting_id,
    posting_name,
    display_name,
    posting_description,
    language,
    source_lang
) SELECT
    FND_GLOBAL.user_id,
    SYSDATE,
    SYSDATE,
    FND_GLOBAL.conc_login_id,
    FND_GLOBAL.conc_login_id,
    DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
    DECODE( px_posting_id, FND_API.g_miss_num, NULL, px_posting_id),
    decode( p_posting_name, FND_API.G_MISS_CHAR, NULL, p_posting_name),
    decode( p_display_name, FND_API.G_MISS_CHAR, NULL, p_display_name),
    decode( p_posting_description, FND_API.G_MISS_CHAR, NULL, p_posting_description),
    l.language_code,
    USERENV('LANG')
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT null
    FROM ams_iba_ps_postings_tl t
    WHERE t.posting_id = DECODE( px_posting_id, FND_API.g_miss_num, NULL, px_posting_id)
    AND t.language = l.language_code);

END Insert_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
--
--  NAME
--  createUpdateBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_posting_id    NUMBER,
          p_max_no_contents    NUMBER,
          p_posting_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_default_content_id    NUMBER,
          p_status_code    VARCHAR2,
          p_posting_name   IN VARCHAR2,
          p_display_name   IN VARCHAR2,
          p_posting_description IN VARCHAR2,
          p_attribute_category    VARCHAR2,
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
          p_attribute15    VARCHAR2)

 IS
 BEGIN
    Update AMS_IBA_PS_POSTINGS_B
    SET
       created_by = DECODE( p_created_by, FND_API.g_miss_num, created_by, p_created_by),
       creation_date = DECODE( p_creation_date, FND_API.g_miss_date, creation_date, p_creation_date),
       last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
       last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
       last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
       object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number),
       posting_id = DECODE( p_posting_id, FND_API.g_miss_num, posting_id, p_posting_id),
       max_no_contents = DECODE( p_max_no_contents, FND_API.g_miss_num, max_no_contents, p_max_no_contents),
       posting_type = DECODE( p_posting_type, FND_API.g_miss_char, posting_type, p_posting_type),
       content_type = DECODE( p_content_type, FND_API.g_miss_char, content_type, p_content_type),
       default_content_id = DECODE( p_default_content_id, FND_API.g_miss_num, default_content_id, p_default_content_id),
       status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
       attribute_category = DECODE( p_attribute_category, FND_API.g_miss_char, attribute_category, p_attribute_category),
       attribute1 = DECODE( p_attribute1, FND_API.g_miss_char, attribute1, p_attribute1),
       attribute2 = DECODE( p_attribute2, FND_API.g_miss_char, attribute2, p_attribute2),
       attribute3 = DECODE( p_attribute3, FND_API.g_miss_char, attribute3, p_attribute3),
       attribute4 = DECODE( p_attribute4, FND_API.g_miss_char, attribute4, p_attribute4),
       attribute5 = DECODE( p_attribute5, FND_API.g_miss_char, attribute5, p_attribute5),
       attribute6 = DECODE( p_attribute6, FND_API.g_miss_char, attribute6, p_attribute6),
       attribute7 = DECODE( p_attribute7, FND_API.g_miss_char, attribute7, p_attribute7),
       attribute8 = DECODE( p_attribute8, FND_API.g_miss_char, attribute8, p_attribute8),
       attribute9 = DECODE( p_attribute9, FND_API.g_miss_char, attribute9, p_attribute9),
       attribute10 = DECODE( p_attribute10, FND_API.g_miss_char, attribute10, p_attribute10),
       attribute11 = DECODE( p_attribute11, FND_API.g_miss_char, attribute11, p_attribute11),
       attribute12 = DECODE( p_attribute12, FND_API.g_miss_char, attribute12, p_attribute12),
       attribute13 = DECODE( p_attribute13, FND_API.g_miss_char, attribute13, p_attribute13),
       attribute14 = DECODE( p_attribute14, FND_API.g_miss_char, attribute14, p_attribute14),
       attribute15 = DECODE( p_attribute15, FND_API.g_miss_char, attribute15, p_attribute15)

   WHERE posting_id = p_posting_id
   AND object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;


UPDATE ams_iba_ps_postings_tl SET
    posting_name = decode( p_posting_name, FND_API.G_MISS_CHAR, posting_name, p_posting_name),
    display_name = decode( p_display_name, FND_API.G_MISS_CHAR, display_name, p_posting_name),
    posting_description = decode( p_posting_description, FND_API.G_MISS_CHAR, posting_description, p_posting_description),
    last_update_date = SYSDATE,
    last_updated_by = FND_GLOBAL.user_id,
    last_update_login = FND_GLOBAL.conc_login_id,
    source_lang = USERENV('LANG')
  WHERE posting_id = p_posting_id
  AND USERENV('LANG') IN (language, source_lang);

  IF (SQL%NOTFOUND) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

END Update_Row;

----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ======================================================
--
--  NAME
--  createDeleteBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_POSTING_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM AMS_IBA_PS_POSTINGS_B
    WHERE POSTING_ID = p_POSTING_ID;
   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ======================================================
--
--  NAME
--  createLockBody
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_posting_id    NUMBER,
          p_max_no_contents    NUMBER,
          p_posting_type    VARCHAR2,
          p_content_type    VARCHAR2,
          p_default_content_id    NUMBER,
          p_status_code    VARCHAR2,
          p_attribute_category    VARCHAR2,
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
          p_attribute15    VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PS_POSTINGS_B
        WHERE POSTING_ID =  p_POSTING_ID
        FOR UPDATE of POSTING_ID NOWAIT;
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
           (      Recinfo.created_by = p_created_by)
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.object_version_number = p_object_version_number)
            OR (    ( Recinfo.object_version_number IS NULL )
                AND (  p_object_version_number IS NULL )))
       AND (    ( Recinfo.posting_id = p_posting_id)
            OR (    ( Recinfo.posting_id IS NULL )
                AND (  p_posting_id IS NULL )))
       AND (    ( Recinfo.max_no_contents = p_max_no_contents)
            OR (    ( Recinfo.max_no_contents IS NULL )
                AND (  p_max_no_contents IS NULL )))
       AND (    ( Recinfo.posting_type = p_posting_type)
            OR (    ( Recinfo.posting_type IS NULL )
                AND (  p_posting_type IS NULL )))
       AND (    ( Recinfo.content_type = p_content_type)
            OR (    ( Recinfo.content_type IS NULL )
                AND (  p_content_type IS NULL )))
       AND (    ( Recinfo.default_content_id = p_default_content_id)
            OR (    ( Recinfo.default_content_id IS NULL )
                AND (  p_default_content_id IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
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
  delete from AMS_IBA_PS_POSTINGS_TL T
  where not exists
    (select NULL
    from AMS_IBA_PS_POSTINGS_B B
    where B.POSTING_ID = T.POSTING_ID
    );

  update AMS_IBA_PS_POSTINGS_TL T set (
      POSTING_NAME,
      DISPLAY_NAME,
      POSTING_DESCRIPTION
    ) = (select
      B.POSTING_NAME,
      B.DISPLAY_NAME,
      B.POSTING_DESCRIPTION
    from AMS_IBA_PS_POSTINGS_TL B
    where B.POSTING_ID = T.POSTING_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.POSTING_ID,
      T.LANGUAGE
  ) in (select
      SUBT.POSTING_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PS_POSTINGS_TL SUBB, AMS_IBA_PS_POSTINGS_TL SUBT
    where SUBB.POSTING_ID = SUBT.POSTING_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.POSTING_NAME <> SUBT.POSTING_NAME
      or SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.POSTING_DESCRIPTION <> SUBT.POSTING_DESCRIPTION
      or (SUBB.POSTING_DESCRIPTION is null and SUBT.POSTING_DESCRIPTION is not null)
      or (SUBB.POSTING_DESCRIPTION is not null and SUBT.POSTING_DESCRIPTION is null)
  ));

  insert into AMS_IBA_PS_POSTINGS_TL (
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LAST_UPDATED_BY,
    OBJECT_VERSION_NUMBER,
    POSTING_ID,
    POSTING_NAME,
    DISPLAY_NAME,
    POSTING_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATED_BY,
    B.OBJECT_VERSION_NUMBER,
    B.POSTING_ID,
    B.POSTING_NAME,
    B.DISPLAY_NAME,
    B.POSTING_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PS_POSTINGS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PS_POSTINGS_TL T
    where T.POSTING_ID = B.POSTING_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END AMS_IBA_PS_POSTINGS_B_PKG;

/
