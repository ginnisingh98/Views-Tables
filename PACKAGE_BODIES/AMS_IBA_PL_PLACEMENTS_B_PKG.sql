--------------------------------------------------------
--  DDL for Package Body AMS_IBA_PL_PLACEMENTS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IBA_PL_PLACEMENTS_B_PKG" as
/* $Header: amstplcb.pls 120.0 2005/06/01 03:42:23 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_PLACEMENTS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_IBA_PL_PLACEMENTS_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amstplcb.pls';

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
          px_placement_id   IN OUT NOCOPY NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_id    NUMBER,
          p_page_ref_code    VARCHAR2,
          p_location_code    VARCHAR2,
          p_param1    VARCHAR2,
          p_param2    VARCHAR2,
          p_param3    VARCHAR2,
          p_param4    VARCHAR2,
          p_param5    VARCHAR2,
          p_stylesheet_id    NUMBER,
          p_posting_id    NUMBER,
          p_status_code    VARCHAR2,
          p_track_events_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name in VARCHAR2,
          p_description in VARCHAR2
)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO AMS_IBA_PL_PLACEMENTS_B(
           placement_id,
           site_id,
           site_ref_code,
           page_id,
           page_ref_code,
           location_code,
           param1,
           param2,
           param3,
           param4,
           param5,
           stylesheet_id,
           posting_id,
           status_code,
           track_events_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           object_version_number
   ) VALUES (
           DECODE( px_placement_id, FND_API.g_miss_num, NULL, px_placement_id),
           DECODE( p_site_id, FND_API.g_miss_num, NULL, p_site_id),
           DECODE( p_site_ref_code, FND_API.g_miss_char, NULL, p_site_ref_code),
           DECODE( p_page_id, FND_API.g_miss_num, NULL, p_page_id),
           DECODE( p_page_ref_code, FND_API.g_miss_char, NULL, p_page_ref_code),
           DECODE( p_location_code, FND_API.g_miss_char, NULL, p_location_code),
           DECODE( p_param1, FND_API.g_miss_char, NULL, p_param1),
           DECODE( p_param2, FND_API.g_miss_char, NULL, p_param2),
           DECODE( p_param3, FND_API.g_miss_char, NULL, p_param3),
           DECODE( p_param4, FND_API.g_miss_char, NULL, p_param4),
           DECODE( p_param5, FND_API.g_miss_char, NULL, p_param5),
           DECODE( p_stylesheet_id, FND_API.g_miss_num, NULL, p_stylesheet_id),
           DECODE( p_posting_id, FND_API.g_miss_num, NULL, p_posting_id),
           DECODE( p_status_code, FND_API.g_miss_char, NULL, p_status_code),
           DECODE( p_track_events_flag, FND_API.g_miss_char, NULL, p_track_events_flag),
           DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
           DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
           DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
           DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
           DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
           DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number));

  insert into AMS_IBA_PL_PLACEMENTS_TL (
    PLACEMENT_ID,
    NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER,
    LANGUAGE,
    SOURCE_LANG
  ) select
        DECODE( px_placement_id, FND_API.g_miss_num, NULL, px_placement_id),
        DECODE( p_name, FND_API.g_miss_char, NULL, p_name),
	DECODE( p_description, FND_API.g_miss_char, NULL, p_description),
        DECODE( p_created_by, FND_API.g_miss_num, NULL, p_created_by),
        DECODE( p_creation_date, FND_API.g_miss_date, NULL, p_creation_date),
        DECODE( p_last_updated_by, FND_API.g_miss_num, NULL, p_last_updated_by),
        DECODE( p_last_update_date, FND_API.g_miss_date, NULL, p_last_update_date),
        DECODE( p_last_update_login, FND_API.g_miss_num, NULL, p_last_update_login),
        DECODE( px_object_version_number, FND_API.g_miss_num, NULL, px_object_version_number),
        l.language_code,
        userenv('LANG')
  FROM fnd_languages l
  WHERE l.installed_flag IN ('I', 'B')
  AND NOT EXISTS
    (SELECT NULL
    FROM ams_iba_pl_placements_tl t
    WHERE t.placement_id = DECODE( px_placement_id, FND_API.g_miss_num, NULL, px_placement_id)
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
          p_placement_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_id    NUMBER,
          p_page_ref_code    VARCHAR2,
          p_location_code    VARCHAR2,
          p_param1    VARCHAR2,
          p_param2    VARCHAR2,
          p_param3    VARCHAR2,
          p_param4    VARCHAR2,
          p_param5    VARCHAR2,
          p_stylesheet_id    NUMBER,
          p_posting_id    NUMBER,
          p_status_code    VARCHAR2,
          p_track_events_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name        VARCHAR2,
          p_description VARCHAR2)

 IS
 BEGIN
    Update AMS_IBA_PL_PLACEMENTS_B
    SET
              site_id = DECODE( p_site_id, FND_API.g_miss_num, site_id, p_site_id),
              site_ref_code = DECODE( p_site_ref_code, FND_API.g_miss_char, site_ref_code, p_site_ref_code),
              page_id = DECODE( p_page_id, FND_API.g_miss_num, page_id, p_page_id),
              page_ref_code = DECODE( p_page_ref_code, FND_API.g_miss_char, page_ref_code, p_page_ref_code),
              location_code = DECODE( p_location_code, FND_API.g_miss_char, location_code, p_location_code),
              param1 = DECODE( p_param1, FND_API.g_miss_char, param1, p_param1),
              param2 = DECODE( p_param2, FND_API.g_miss_char, param2, p_param2),
              param3 = DECODE( p_param3, FND_API.g_miss_char, param3, p_param3),
              param4 = DECODE( p_param4, FND_API.g_miss_char, param4, p_param4),
              param5 = DECODE( p_param5, FND_API.g_miss_char, param5, p_param5),
              stylesheet_id = DECODE( p_stylesheet_id, FND_API.g_miss_num, stylesheet_id, p_stylesheet_id),
              posting_id = DECODE( p_posting_id, FND_API.g_miss_num, posting_id, p_posting_id),
              status_code = DECODE( p_status_code, FND_API.g_miss_char, status_code, p_status_code),
              track_events_flag = DECODE( p_track_events_flag, FND_API.g_miss_char, track_events_flag, p_track_events_flag),
              last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
              last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
              last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
              object_version_number = DECODE( p_object_version_number, FND_API.g_miss_num, object_version_number, p_object_version_number)
   WHERE PLACEMENT_ID = p_PLACEMENT_ID
   AND   object_version_number = p_object_version_number;

   IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  UPDATE ams_iba_pl_placements_tl SET
    name = DECODE(p_name,FND_API.g_miss_char,name,p_name),
    description = DECODE(p_description,FND_API.g_miss_char,description,p_description),
    last_update_date = DECODE( p_last_update_date, FND_API.g_miss_date, last_update_date, p_last_update_date),
    last_updated_by = DECODE( p_last_updated_by, FND_API.g_miss_num, last_updated_by, p_last_updated_by),
    last_update_login = DECODE( p_last_update_login, FND_API.g_miss_num, last_update_login, p_last_update_login),
    source_lang = USERENV('LANG')
  WHERE placement_id = p_placement_id
  AND USERENV('LANG') IN (language, source_lang);

   IF (SQL%NOTFOUND) THEN
	RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

END Update_Row;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
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
    p_placement_id  NUMBER)
 IS
 BEGIN

   DELETE FROM ams_iba_pl_placements_tl
   WHERE placement_id = p_placement_id;

   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;


   DELETE FROM ams_iba_pl_placements_b
   WHERE placement_id = p_placement_id;

   If (SQL%NOTFOUND) then
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;

 END Delete_Row ;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_IBA_PL_PLACEMENTS_TL T
  where not exists
    (select NULL
    from AMS_IBA_PL_PLACEMENTS_B B
    where B.PLACEMENT_ID = T.PLACEMENT_ID
    );

  update AMS_IBA_PL_PLACEMENTS_TL T set (
      NAME,
      description
    ) = (select
      B.NAME,
      B.description
    from AMS_IBA_PL_PLACEMENTS_TL B
    where B.PLACEMENT_ID = T.PLACEMENT_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PLACEMENT_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PLACEMENT_ID,
      SUBT.LANGUAGE
    from AMS_IBA_PL_PLACEMENTS_TL SUBB, AMS_IBA_PL_PLACEMENTS_TL SUBT
    where SUBB.PLACEMENT_ID = SUBT.PLACEMENT_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.LANGUAGE <> SUBT.LANGUAGE
  ));

  insert into AMS_IBA_PL_PLACEMENTS_TL (
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PLACEMENT_ID,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.PLACEMENT_ID,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_IBA_PL_PLACEMENTS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_IBA_PL_PLACEMENTS_TL T
    where T.PLACEMENT_ID = B.PLACEMENT_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;


----------------------------------------------------------
----          MEDIA           ----
----------------------------------------------------------

--  ========================================================
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
          p_placement_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_id    NUMBER,
          p_page_ref_code    VARCHAR2,
          p_location_code    VARCHAR2,
          p_param1    VARCHAR2,
          p_param2    VARCHAR2,
          p_param3    VARCHAR2,
          p_param4    VARCHAR2,
          p_param5    VARCHAR2,
          p_stylesheet_id    NUMBER,
          p_posting_id    NUMBER,
          p_status_code    VARCHAR2,
          p_track_events_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM AMS_IBA_PL_PLACEMENTS_B
        WHERE PLACEMENT_ID =  p_PLACEMENT_ID
        FOR UPDATE of PLACEMENT_ID NOWAIT;
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
           (      Recinfo.placement_id = p_placement_id)
       AND (    ( Recinfo.site_id = p_site_id)
            OR (    ( Recinfo.site_id IS NULL )
                AND (  p_site_id IS NULL )))
       AND (    ( Recinfo.site_ref_code = p_site_ref_code)
            OR (    ( Recinfo.site_ref_code IS NULL )
                AND (  p_site_ref_code IS NULL )))
       AND (    ( Recinfo.page_id = p_page_id)
            OR (    ( Recinfo.page_id IS NULL )
                AND (  p_page_id IS NULL )))
       AND (    ( Recinfo.page_ref_code = p_page_ref_code)
            OR (    ( Recinfo.page_ref_code IS NULL )
                AND (  p_page_ref_code IS NULL )))
       AND (    ( Recinfo.location_code = p_location_code)
            OR (    ( Recinfo.location_code IS NULL )
                AND (  p_location_code IS NULL )))
       AND (    ( Recinfo.param1 = p_param1)
            OR (    ( Recinfo.param1 IS NULL )
                AND (  p_param1 IS NULL )))
       AND (    ( Recinfo.param2 = p_param2)
            OR (    ( Recinfo.param2 IS NULL )
                AND (  p_param2 IS NULL )))
       AND (    ( Recinfo.param3 = p_param3)
            OR (    ( Recinfo.param3 IS NULL )
                AND (  p_param3 IS NULL )))
       AND (    ( Recinfo.param4 = p_param4)
            OR (    ( Recinfo.param4 IS NULL )
                AND (  p_param4 IS NULL )))
       AND (    ( Recinfo.param5 = p_param5)
            OR (    ( Recinfo.param5 IS NULL )
                AND (  p_param5 IS NULL )))
       AND (    ( Recinfo.stylesheet_id = p_stylesheet_id)
            OR (    ( Recinfo.stylesheet_id IS NULL )
                AND (  p_stylesheet_id IS NULL )))
       AND (    ( Recinfo.posting_id = p_posting_id)
            OR (    ( Recinfo.posting_id IS NULL )
                AND (  p_posting_id IS NULL )))
       AND (    ( Recinfo.status_code = p_status_code)
            OR (    ( Recinfo.status_code IS NULL )
                AND (  p_status_code IS NULL )))
       AND (    ( Recinfo.track_events_flag = p_track_events_flag)
            OR (    ( Recinfo.track_events_flag IS NULL )
                AND (  p_track_events_flag IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
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
       ) THEN
       RETURN;
   ELSE
       FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
END Lock_Row;

END AMS_IBA_PL_PLACEMENTS_B_PKG;

/
