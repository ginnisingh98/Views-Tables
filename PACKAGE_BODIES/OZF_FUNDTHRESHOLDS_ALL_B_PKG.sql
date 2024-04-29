--------------------------------------------------------
--  DDL for Package Body OZF_FUNDTHRESHOLDS_ALL_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUNDTHRESHOLDS_ALL_B_PKG" as
/* $Header: ozftthrb.pls 115.3 2004/03/17 03:48:50 rimehrot noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_FUNDTHRESHOLDS_ALL_B_PKG
-- Purpose
--
-- History
--       03/05/2002  mpande UPdated Added Addlanguage and TransaletROw procedure
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_THRESHOLDS_ALL_B_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozftthrb.pls';


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
          px_threshold_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_owner    NUMBER,
          p_enable_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2,
          p_language    VARCHAR2,
          p_source_lang    VARCHAR2,
          p_threshold_type VARCHAR2)

 IS
   x_rowid    VARCHAR2(30);


BEGIN


   px_object_version_number := 1;


   INSERT INTO OZF_THRESHOLDS_ALL_B(
           threshold_id,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           created_from,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           threshold_calendar,
           start_period_name,
           end_period_name,
           start_date_active,
           end_date_active,
           owner,
           enable_flag,
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
           attribute15,
           org_id,
           security_group_id,
           object_version_number,
           threshold_type
   ) VALUES (
           px_threshold_id,
           p_last_update_date,
           p_last_updated_by,
           p_last_update_login,
           p_creation_date,
           p_created_by,
           p_created_from,
           p_request_id,
           p_program_application_id,
           p_program_id,
           p_program_update_date,
           p_threshold_calendar,
           p_start_period_name,
           p_end_period_name,
           p_start_date_active,
           p_end_date_active,
           p_owner,
           p_enable_flag,
           p_attribute_category,
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
           p_attribute15,
           p_org_id,
           p_security_group_id,
           px_object_version_number,
           p_threshold_type);

-- insert to ozf_thresholds_all_tl table


INSERT INTO OZF_THRESHOLDS_ALL_TL(
           threshold_id,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           created_from,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           name,
           description,
           language,
           source_lang,
           org_id,
           security_group_id
   ) VALUES (
           px_threshold_id,
           p_last_update_date,
           p_last_updated_by,
           p_last_update_login,
           p_creation_date,
           p_created_by,
           p_created_from,
           p_request_id,
           p_program_application_id,
           p_program_id,
           p_program_update_date,
           p_name,
           p_description,
           p_language,
           USERENV('LANG'),
           p_org_id,
           p_security_group_id);
/*
       INSERT INTO ozf_thresholds_all_tl
                  (threshold_id,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   creation_date,
                   created_by,
                   created_from,
                   request_id,
                   program_application_id,
                   program_id,
                   program_update_date,
                   name,
                   description,
                   source_lang,
                   language,
                   org_id,
		   security_group_id)
         SELECT   px_threshold_id
	          , SYSDATE   -- LAST_UPDATE_DATE
                  , NVL(fnd_global.user_id, -1)   -- LAST_UPDATED_BY
                 ,NVL(fnd_global.conc_login_id, -1)   -- LAST_UPDATE_LOGIN
                 , SYSDATE   -- CREATION_DATE
                 , NVL(fnd_global.user_id, -1)   -- CREATED_BY
                , p_created_from   -- CREATED_FROM
                 , fnd_global.conc_request_id   -- REQUEST_ID
                 , fnd_global.prog_appl_id   -- PROGRAM_APPLICATION_ID
                 ,fnd_global.conc_program_id   -- PROGRAM_ID
                 , SYSDATE   -- PROGRAM_UPDATE_DATE
                 , p_name
                 ,p_description
                 , USERENV('LANG')
                 , p_source_lang
                 ,TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'), 1, 10))   -- ORG_ID
                 ,p_security_group_id
         FROM     fnd_languages l
         WHERE  l.installed_flag IN('I', 'B')
            AND NOT EXISTS(SELECT   NULL
                           FROM     ozf_thresholds_all_tl t
                           WHERE  t.threshold_id = px_threshold_id
                              AND t.language = l.language_code);
*/
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
          p_threshold_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_threshold_calendar   VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_owner    NUMBER,
          p_enable_flag    VARCHAR2,
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
          p_attribute15    VARCHAR2,
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name    VARCHAR2,
          p_description    VARCHAR2,
          p_language    VARCHAR2,
          p_source_lang    VARCHAR2,
          p_threshold_type VARCHAR2)

 IS
 BEGIN
    Update OZF_THRESHOLDS_ALL_B
    SET
              threshold_id = p_threshold_id,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              last_update_login = p_last_update_login,
              created_from = p_created_from,
              request_id = p_request_id,
              program_application_id = p_program_application_id,
              program_id = p_program_id,
              program_update_date = p_program_update_date,
              threshold_calendar = p_threshold_calendar,
              start_period_name = p_start_period_name,
              end_period_name = p_end_period_name,
              start_date_active = p_start_date_active,
              end_date_active = p_end_date_active,
              owner = p_owner,
              enable_flag = p_enable_flag,
              attribute_category = p_attribute_category,
              attribute1 = p_attribute1,
              attribute2 = p_attribute2,
              attribute3 = p_attribute3,
              attribute4 = p_attribute4,
              attribute5 = p_attribute5,
              attribute6 = p_attribute6,
              attribute7 = p_attribute7,
              attribute8 = p_attribute8,
              attribute9 = p_attribute9,
              attribute10 = p_attribute10,
              attribute11 = p_attribute11,
              attribute12 = p_attribute12,
              attribute13 = p_attribute13,
              attribute14 = p_attribute14,
              attribute15 = p_attribute15,
             -- org_id = p_org_id,
              security_group_id = p_security_group_id,
              object_version_number = DECODE( px_object_version_number, FND_API.g_miss_num, object_version_number+1, px_object_version_number+1),
              threshold_type = p_threshold_type
   WHERE THRESHOLD_ID = p_THRESHOLD_ID
   AND   object_version_number = px_object_version_number;


   IF (SQL%NOTFOUND) THEN
     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   px_object_version_number := px_object_version_number +1;
-- update ozf_thresholds_all_tl table
 Update OZF_THRESHOLDS_ALL_TL
    SET
              threshold_id = p_threshold_id,
              last_update_date = p_last_update_date,
              last_updated_by = p_last_updated_by,
              last_update_login = p_last_update_login,
              created_from = p_created_from,
              request_id = p_request_id,
              program_application_id = p_program_application_id,
              program_id = p_program_id,
              program_update_date = p_program_update_date,
              name = p_name,
              description = p_description,
              language = p_language,
              source_lang = p_source_lang,
             -- org_id = p_org_id,
              security_group_id = p_security_group_id
   WHERE THRESHOLD_ID = p_THRESHOLD_ID;

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
    p_THRESHOLD_ID  NUMBER)
 IS
 BEGIN
   DELETE FROM OZF_THRESHOLDS_ALL_B
    WHERE THRESHOLD_ID = p_THRESHOLD_ID;

   DELETE FROM OZF_THRESHOLDS_ALL_TL
    WHERE THRESHOLD_ID = p_THRESHOLD_ID;

   If (SQL%NOTFOUND) then
RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   End If;
 END Delete_Row ;



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
          p_threshold_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_created_from    VARCHAR2,
          p_request_id    NUMBER,
          p_program_application_id    NUMBER,
          p_program_id    NUMBER,
          p_program_update_date    DATE,
          p_threshold_calendar    VARCHAR2,
          p_start_period_name    VARCHAR2,
          p_end_period_name    VARCHAR2,
          p_start_date_active    DATE,
          p_end_date_active    DATE,
          p_owner    NUMBER,
          p_enable_flag    VARCHAR2,
	  P_attribute_category   VARCHAR2,
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
          p_org_id    NUMBER,
          p_security_group_id    NUMBER,
          p_object_version_number    NUMBER)

 IS
   CURSOR C IS
        SELECT *
         FROM OZF_THRESHOLDS_ALL_B
        WHERE THRESHOLD_ID =  p_THRESHOLD_ID
        FOR UPDATE of THRESHOLD_ID NOWAIT;
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
           (      Recinfo.threshold_id = p_threshold_id)
       AND (    ( Recinfo.last_update_date = p_last_update_date)
            OR (    ( Recinfo.last_update_date IS NULL )
                AND (  p_last_update_date IS NULL )))
       AND (    ( Recinfo.last_updated_by = p_last_updated_by)
            OR (    ( Recinfo.last_updated_by IS NULL )
                AND (  p_last_updated_by IS NULL )))
       AND (    ( Recinfo.last_update_login = p_last_update_login)
            OR (    ( Recinfo.last_update_login IS NULL )
                AND (  p_last_update_login IS NULL )))
       AND (    ( Recinfo.creation_date = p_creation_date)
            OR (    ( Recinfo.creation_date IS NULL )
                AND (  p_creation_date IS NULL )))
       AND (    ( Recinfo.created_by = p_created_by)
            OR (    ( Recinfo.created_by IS NULL )
                AND (  p_created_by IS NULL )))
       AND (    ( Recinfo.created_from = p_created_from)
            OR (    ( Recinfo.created_from IS NULL )
                AND (  p_created_from IS NULL )))
       AND (    ( Recinfo.request_id = p_request_id)
            OR (    ( Recinfo.request_id IS NULL )
                AND (  p_request_id IS NULL )))
       AND (    ( Recinfo.program_application_id = p_program_application_id)
            OR (    ( Recinfo.program_application_id IS NULL )
                AND (  p_program_application_id IS NULL )))
       AND (    ( Recinfo.program_id = p_program_id)
            OR (    ( Recinfo.program_id IS NULL )
                AND (  p_program_id IS NULL )))
       AND (    ( Recinfo.program_update_date = p_program_update_date)
            OR (    ( Recinfo.program_update_date IS NULL )
                AND (  p_program_update_date IS NULL )))
       AND (    ( Recinfo.threshold_calendar = p_threshold_calendar)
            OR (    ( Recinfo.threshold_calendar IS NULL )
                AND (  p_threshold_calendar IS NULL )))
       AND (    ( Recinfo.start_period_name = p_start_period_name)
            OR (    ( Recinfo.start_period_name IS NULL )
                AND (  p_start_period_name IS NULL )))
       AND (    ( Recinfo.end_period_name = p_end_period_name)
            OR (    ( Recinfo.end_period_name IS NULL )
                AND (  p_end_period_name IS NULL )))
       AND (    ( Recinfo.start_date_active = p_start_date_active)
            OR (    ( Recinfo.start_date_active IS NULL )
                AND (  p_start_date_active IS NULL )))
       AND (    ( Recinfo.end_date_active = p_end_date_active)
            OR (    ( Recinfo.end_date_active IS NULL )
                AND (  p_end_date_active IS NULL )))
       AND (    ( Recinfo.owner = p_owner)
            OR (    ( Recinfo.owner IS NULL )
                AND (  p_owner IS NULL )))
       AND (    ( Recinfo.enable_flag = p_enable_flag)
            OR (    ( Recinfo.enable_flag IS NULL )
                AND (  p_enable_flag IS NULL )))
       AND (    ( Recinfo.attribute1 = p_attribute1)
            OR (    ( Recinfo.attribute1 IS NULL )
                AND (  p_attribute1 IS NULL )))
       AND (    ( Recinfo.attribute2 = p_attribute2)
            OR (    ( Recinfo.attribute2 IS NULL )
                AND (  p_attribute2 IS NULL )))
       AND (    ( Recinfo.attribute3 = p_attribute3)
            OR (    ( Recinfo.attribute3 IS NULL )
                AND (  p_attribute3 IS NULL )))
       AND (    ( Recinfo.attribute4 = p_attribute4)
            OR (    ( Recinfo.attribute4 IS NULL )
                AND (  p_attribute4 IS NULL )))
       AND (    ( Recinfo.attribute5 = p_attribute5)
            OR (    ( Recinfo.attribute5 IS NULL )
                AND (  p_attribute5 IS NULL )))
       AND (    ( Recinfo.attribute6 = p_attribute6)
            OR (    ( Recinfo.attribute6 IS NULL )
                AND (  p_attribute6 IS NULL )))
       AND (    ( Recinfo.attribute7 = p_attribute7)
            OR (    ( Recinfo.attribute7 IS NULL )
                AND (  p_attribute7 IS NULL )))
       AND (    ( Recinfo.attribute8 = p_attribute8)
            OR (    ( Recinfo.attribute8 IS NULL )
                AND (  p_attribute8 IS NULL )))
       AND (    ( Recinfo.attribute9 = p_attribute9)
            OR (    ( Recinfo.attribute9 IS NULL )
                AND (  p_attribute9 IS NULL )))
       AND (    ( Recinfo.attribute10 = p_attribute10)
            OR (    ( Recinfo.attribute10 IS NULL )
                AND (  p_attribute10 IS NULL )))
       AND (    ( Recinfo.attribute11 = p_attribute11)
            OR (    ( Recinfo.attribute11 IS NULL )
                AND (  p_attribute11 IS NULL )))
       AND (    ( Recinfo.attribute12 = p_attribute12)
            OR (    ( Recinfo.attribute12 IS NULL )
                AND (  p_attribute12 IS NULL )))
       AND (    ( Recinfo.attribute13 = p_attribute13)
            OR (    ( Recinfo.attribute13 IS NULL )
                AND (  p_attribute13 IS NULL )))
       AND (    ( Recinfo.attribute14 = p_attribute14)
            OR (    ( Recinfo.attribute14 IS NULL )
                AND (  p_attribute14 IS NULL )))
       AND (    ( Recinfo.attribute15 = p_attribute15)
            OR (    ( Recinfo.attribute15 IS NULL )
                AND (  p_attribute15 IS NULL )))
       AND (    ( Recinfo.org_id = p_org_id)
            OR (    ( Recinfo.org_id IS NULL )
                AND (  p_org_id IS NULL )))
       AND (    ( Recinfo.security_group_id = p_security_group_id)
            OR (    ( Recinfo.security_group_id IS NULL )
                AND (  p_security_group_id IS NULL )))
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

procedure ADD_LANGUAGE
is
begin
  delete from OZF_THRESHOLDS_ALL_TL T
  where not exists
    (select NULL
    from OZF_THRESHOLDS_ALL_B B
    where B.THRESHOLD_ID = T.THRESHOLD_ID
    );

  update OZF_THRESHOLDS_ALL_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from OZF_THRESHOLDS_ALL_TL B
    where B.THRESHOLD_ID = T.THRESHOLD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.THRESHOLD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.THRESHOLD_ID,
      SUBT.LANGUAGE
    from OZF_THRESHOLDS_ALL_TL SUBB, OZF_THRESHOLDS_ALL_TL SUBT
    where SUBB.THRESHOLD_ID = SUBT.THRESHOLD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into OZF_THRESHOLDS_ALL_TL (
    THRESHOLD_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    CREATED_FROM,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.THRESHOLD_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.CREATED_FROM,
    B.REQUEST_ID,
    B.PROGRAM_APPLICATION_ID,
    B.PROGRAM_ID,
    B.PROGRAM_UPDATE_DATE,
    B.NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OZF_THRESHOLDS_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OZF_THRESHOLDS_ALL_TL T
    where T.THRESHOLD_ID = B.THRESHOLD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  X_THRESHOLD_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNERS in VARCHAR2
)
IS
BEGIN
  update OZF_THRESHOLDS_ALL_TL set
    name = nvl(x_name, name),
    description = nvl(x_description, description),
    source_lang = userenv('LANG'),
    last_update_date = sysdate,
    last_updated_by = decode(x_owners, 'SEED', 1, 0),
    last_update_login = 0
  where threshold_id = x_threshold_id
  and userenv('LANG') in (language, source_lang);
END TRANSLATE_ROW;


END OZF_FUNDTHRESHOLDS_ALL_B_PKG;

/
