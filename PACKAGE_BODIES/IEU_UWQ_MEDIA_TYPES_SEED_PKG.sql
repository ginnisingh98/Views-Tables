--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_MEDIA_TYPES_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_MEDIA_TYPES_SEED_PKG" AS
/* $Header: IEUSEEDB.pls 120.1 2005/06/23 02:40:28 appldev ship $ */

  PROCEDURE Insert_Row (p_uwq_media_types_rec IN uwq_media_types_rec_type) IS

    CURSOR c IS         SELECT 'X' FROM ieu_uwq_media_types_b
                WHERE media_type_id = p_uwq_media_types_rec.media_type_id;

    l_dummy CHAR(1);

  BEGIN

     -- API body
    INSERT INTO ieu_uwq_media_types_b (
      media_type_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      media_type_uuid,
      simple_blending_order,
      tel_reqd_flag,
      svr_login_rule_id,
      application_id,
      sh_category_type,
         image_file_name,
      classification_query_proc,
      blended_flag,
      blended_dir
    ) VALUES (
      p_uwq_media_types_rec.media_type_id,
      p_uwq_media_types_rec.created_by,
      p_uwq_media_types_rec.creation_date,
      p_uwq_media_types_rec.last_updated_by,
      p_uwq_media_types_rec.last_update_date,
      p_uwq_media_types_rec.last_update_login,
      p_uwq_media_types_rec.media_type_uuid,
      p_uwq_media_types_rec.simple_blending_order,
      p_uwq_media_types_rec.tel_reqd_flag,
      p_uwq_media_types_rec.svr_login_rule_id,
      p_uwq_media_types_rec.application_id,
         p_uwq_media_types_rec.sh_category_type,
         p_uwq_media_types_rec.image_file_name,
      p_uwq_media_types_rec.classification_query_proc,
      p_uwq_media_types_rec.blended_flag,
      p_uwq_media_types_rec.blended_dir
    );

    INSERT INTO ieu_uwq_media_types_tl (
      media_type_id,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      media_type_name,
      source_lang,
      media_type_description
    ) SELECT
        p_uwq_media_types_rec.media_type_id,
        l.language_code,
        p_uwq_media_types_rec.created_by,
        p_uwq_media_types_rec.creation_date,
        p_uwq_media_types_rec.last_updated_by,
        p_uwq_media_types_rec.last_update_date,
        p_uwq_media_types_rec.last_update_login,
        p_uwq_media_types_rec.media_type_name,
        USERENV('LANG'),
        p_uwq_media_types_rec.media_type_description
      FROM fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND NOT EXISTS
        (SELECT NULL
         FROM ieu_uwq_media_types_tl t
         WHERE t.media_type_id = p_uwq_media_types_rec.media_type_id
         AND t.language = l.language_code);

    OPEN c;
    FETCH c INTO l_dummy;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
     -- End of API body

  END Insert_Row;

  PROCEDURE Update_Row (p_uwq_media_types_rec IN uwq_media_types_rec_type) IS

  BEGIN
     -- API body
    UPDATE ieu_uwq_media_types_b SET
      last_updated_by = p_uwq_media_types_rec.last_updated_by,
      last_update_date = p_uwq_media_types_rec.last_update_date,
      last_update_login = p_uwq_media_types_rec.last_update_login,
      media_type_uuid = p_uwq_media_types_rec.media_type_uuid,
      simple_blending_order = p_uwq_media_types_rec.simple_blending_order,
      tel_reqd_flag = p_uwq_media_types_rec.tel_reqd_flag,
      svr_login_rule_id = p_uwq_media_types_rec.svr_login_rule_id,
      application_id = p_uwq_media_types_rec.application_id,
         image_file_name = p_uwq_media_types_rec.image_file_name,
         sh_category_type = p_uwq_media_types_rec.sh_category_type,
      classification_query_proc = p_uwq_media_types_rec.classification_query_proc,
      blended_flag = p_uwq_media_types_rec.blended_flag,
      blended_dir = p_uwq_media_types_rec.blended_dir
    WHERE media_type_id = p_uwq_media_types_rec.media_type_id;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    UPDATE ieu_uwq_media_types_tl SET
      media_type_name = p_uwq_media_types_rec.media_type_name,
      source_lang = USERENV('LANG'),
      media_type_description = p_uwq_media_types_rec.media_type_description,
      last_updated_by = p_uwq_media_types_rec.last_updated_by,
      last_update_date = p_uwq_media_types_rec.last_update_date,
      last_update_login = p_uwq_media_types_rec.last_update_login
    WHERE media_type_id = p_uwq_media_types_rec.media_type_id
    AND USERENV('LANG') IN (language, source_lang);

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;
     -- End of API body

  END Update_Row;

  PROCEDURE Load_Row (
                p_media_type_id IN NUMBER,
                p_media_type_uuid IN VARCHAR2,
                p_simple_blending_order IN NUMBER,
                p_tel_reqd_flag IN VARCHAR2,
                p_svr_login_rule_id IN NUMBER,
                p_application_id IN NUMBER,
                         p_sh_category_type IN VARCHAR2,
                         p_image_file_name IN VARCHAR2,
                         p_classification_query_proc IN VARCHAR2,
                p_blended_flag IN VARCHAR2,
                p_blended_dir IN VARCHAR2,
                      p_media_type_name IN VARCHAR2,
                p_media_type_description IN VARCHAR2,
                p_owner IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id               number := 0;
       l_uwq_media_types_rec uwq_media_types_rec_type;

    BEGIN

       --IF (p_owner = 'SEED') then
       --   user_id := 1;
       --END IF;
       user_id := fnd_load_util.owner_id(P_OWNER);

           l_uwq_media_types_rec.media_type_id   := p_media_type_id;
           l_uwq_media_types_rec.media_type_uuid := p_media_type_uuid;
        l_uwq_media_types_rec.simple_blending_order := p_simple_blending_order;
        l_uwq_media_types_rec.tel_reqd_flag := p_tel_reqd_flag;
        l_uwq_media_types_rec.svr_login_rule_id := p_svr_login_rule_id;
        l_uwq_media_types_rec.application_id := p_application_id;
           l_uwq_media_types_rec.sh_category_type := p_sh_category_type;
           l_uwq_media_types_rec.image_file_name := p_image_file_name;
           l_uwq_media_types_rec.classification_query_proc := p_classification_query_proc;
        l_uwq_media_types_rec.blended_flag := p_blended_flag;
        l_uwq_media_types_rec.blended_dir := p_blended_dir;
        l_uwq_media_types_rec.media_type_name := p_media_type_name;
           l_uwq_media_types_rec.media_type_description := p_media_type_description;
        l_uwq_media_types_rec.last_update_date := sysdate;
        l_uwq_media_types_rec.last_updated_by := user_id;
           l_uwq_media_types_rec.last_update_login := 0;

       Update_Row (p_uwq_media_types_rec => l_uwq_media_types_rec);
      EXCEPTION
         when no_data_found then

        l_uwq_media_types_rec.media_type_id   := p_media_type_id;
        l_uwq_media_types_rec.media_type_uuid := p_media_type_uuid;
        l_uwq_media_types_rec.simple_blending_order := p_simple_blending_order;
        l_uwq_media_types_rec.tel_reqd_flag := p_tel_reqd_flag;
        l_uwq_media_types_rec.svr_login_rule_id := p_svr_login_rule_id;
        l_uwq_media_types_rec.application_id := p_application_id;
           l_uwq_media_types_rec.sh_category_type := p_sh_category_type;
           l_uwq_media_types_rec.image_file_name := p_image_file_name;
           l_uwq_media_types_rec.classification_query_proc := p_classification_query_proc;
        l_uwq_media_types_rec.blended_flag := p_blended_flag;
        l_uwq_media_types_rec.blended_dir := p_blended_dir;
        l_uwq_media_types_rec.media_type_name := p_media_type_name;
        l_uwq_media_types_rec.media_type_description := p_media_type_description;
        l_uwq_media_types_rec.last_update_date := sysdate;
        l_uwq_media_types_rec.last_updated_by := user_id;
        l_uwq_media_types_rec.last_update_login := 0;
        l_uwq_media_types_rec.creation_date := sysdate;
        l_uwq_media_types_rec.created_by := user_id;

        Insert_Row (p_uwq_media_types_rec => l_uwq_media_types_rec);

      END;
  END load_row;

  PROCEDURE translate_row (
    p_media_type_id IN NUMBER,
    p_media_type_name IN VARCHAR2,
    p_media_type_description IN VARCHAR2,
    p_owner IN VARCHAR2) IS

  BEGIN

      -- only UPDATE rows that have not been altered by user

      UPDATE ieu_uwq_media_types_tl SET
        media_type_name = p_media_type_name,
        source_lang = userenv('LANG'),
        media_type_description = p_media_type_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', 1, 0),
        last_update_login = 0
      WHERE media_type_id = p_media_type_id
      AND   userenv('LANG') IN (language, source_lang);

  END translate_row;

PROCEDURE ADD_LANGUAGE
is
begin
  delete from IEU_UWQ_MEDIA_TYPES_TL T
  where not exists
    (select NULL
    from IEU_UWQ_MEDIA_TYPES_B B
    where B.MEDIA_TYPE_ID = T.MEDIA_TYPE_ID
    );

  update IEU_UWQ_MEDIA_TYPES_TL T set (
      MEDIA_TYPE_NAME,
      MEDIA_TYPE_DESCRIPTION
    ) = (select
      B.MEDIA_TYPE_NAME,
      B.MEDIA_TYPE_DESCRIPTION
    from IEU_UWQ_MEDIA_TYPES_TL B
    where B.MEDIA_TYPE_ID = T.MEDIA_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MEDIA_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MEDIA_TYPE_ID,
      SUBT.LANGUAGE
    from IEU_UWQ_MEDIA_TYPES_TL SUBB, IEU_UWQ_MEDIA_TYPES_TL SUBT
    where SUBB.MEDIA_TYPE_ID = SUBT.MEDIA_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEDIA_TYPE_NAME <> SUBT.MEDIA_TYPE_NAME
      or SUBB.MEDIA_TYPE_DESCRIPTION <> SUBT.MEDIA_TYPE_DESCRIPTION
      or (SUBB.MEDIA_TYPE_DESCRIPTION is null and SUBT.MEDIA_TYPE_DESCRIPTION is not null)
      or (SUBB.MEDIA_TYPE_DESCRIPTION is not null and SUBT.MEDIA_TYPE_DESCRIPTION is null)
  ));

  insert into IEU_UWQ_MEDIA_TYPES_TL (
    MEDIA_TYPE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    MEDIA_TYPE_NAME,
    MEDIA_TYPE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.MEDIA_TYPE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.MEDIA_TYPE_NAME,
    B.MEDIA_TYPE_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_UWQ_MEDIA_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_UWQ_MEDIA_TYPES_TL T
    where T.MEDIA_TYPE_ID = B.MEDIA_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

/***** Added on 01/17/01 for NLS issues ****/

procedure DELETE_ROW (
  X_MEDIA_TYPE_ID in NUMBER
  ) is
  begin
    delete from IEU_UWQ_MEDIA_TYPES_TL
    where MEDIA_TYPE_ID = X_MEDIA_TYPE_ID;

    if (sql%notfound) then
          raise no_data_found;
    end if;

    delete from IEU_UWQ_MEDIA_TYPES_B
    where MEDIA_TYPE_ID = X_MEDIA_TYPE_ID;

    if (sql%notfound) then
       raise no_data_found;
    end if;
 end DELETE_ROW;


procedure LOCK_ROW (
 X_MEDIA_TYPE_ID in NUMBER,
 X_MEDIA_TYPE_UUID in VARCHAR2,
 X_LANGUAGE in VARCHAR2,
 X_CREATED_BY in NUMBER,
 X_CREATION_DATE in DATE,
 X_LAST_UPDATED_BY in NUMBER,
 X_LAST_UPDATE_DATE in DATE,
 X_MEDIA_TYPE_NAME in VARCHAR2,
 X_SOURCE_LANG in VARCHAR2,
 X_MEDIA_TYPE_DESCRIPTION in VARCHAR2,
 X_OBJECT_VERSION_NUMBER in NUMBER
) is


cursor c is select
 MEDIA_TYPE_UUID
 from IEU_UWQ_MEDIA_TYPES_B
 where MEDIA_TYPE_ID = X_MEDIA_TYPE_ID
 for update of MEDIA_TYPE_ID nowait;
 recinfo c%rowtype;

cursor c1 is select
 MEDIA_TYPE_ID,
 language,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 MEDIA_TYPE_NAME,
 SOURCE_LANG,
 MEDIA_TYPE_DESCRIPTION,
 OBJECT_VERSION_NUMBER,
 decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
 from IEU_UWQ_MEDIA_TYPES_TL
 where MEDIA_TYPE_ID = X_MEDIA_TYPE_ID
 and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
 for update of MEDIA_TYPE_ID nowait;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.MEDIA_TYPE_UUID = X_MEDIA_TYPE_UUID)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
   if (tlinfo.BASELANG = 'Y') then
    if (    (tlinfo.MEDIA_TYPE_ID = X_MEDIA_TYPE_ID)
        AND (tlinfo.LANGUAGE = X_LANGUAGE)
        AND (tlinfo.CREATED_BY = X_CREATED_BY)
        AND (tlinfo.CREATION_DATE = X_CREATION_DATE)
        AND (tlinfo.LAST_UPDATED_BY = X_LAST_UPDATED_BY)
        AND (tlinfo.LAST_UPDATE_DATE = X_LAST_UPDATE_DATE)
        AND (tlinfo.MEDIA_TYPE_NAME = X_MEDIA_TYPE_NAME)
        AND ((tlinfo.SOURCE_LANG = X_SOURCE_LANG)
                OR ((tlinfo.SOURCE_LANG is null) AND (X_SOURCE_LANG is null)))
        AND ((tlinfo.MEDIA_TYPE_DESCRIPTION = X_MEDIA_TYPE_DESCRIPTION)
                OR ((tlinfo.MEDIA_TYPE_DESCRIPTION is null) AND (X_MEDIA_TYPE_DESCRIPTION is null)))
        AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
                OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
        ) then
                null;
    else
                fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
                app_exception.raise_exception;
    end if;
   end if;
  end loop;
  return;
end LOCK_ROW;

PROCEDURE Load_Seed_Row (
  p_upload_mode IN VARCHAR2,
  p_media_type_id IN NUMBER,
  p_media_type_uuid IN VARCHAR2,
  p_simple_blending_order IN NUMBER,
  p_tel_reqd_flag IN VARCHAR2,
  p_svr_login_rule_id IN NUMBER,
  p_application_id IN NUMBER,
  p_sh_category_type IN VARCHAR2,
  p_image_file_name IN VARCHAR2,
  p_classification_query_proc IN VARCHAR2,
  p_blended_flag IN VARCHAR2,
  p_blended_dir IN VARCHAR2,
  p_media_type_name IN VARCHAR2,
  p_media_type_description IN VARCHAR2,
  p_owner IN VARCHAR2
)is
begin
if (p_upload_mode = 'NLS') then
  TRANSLATE_ROW (
    P_MEDIA_TYPE_ID,
    P_MEDIA_TYPE_NAME,
    P_MEDIA_TYPE_DESCRIPTION,
    P_OWNER);
else
  LOAD_ROW (
    P_MEDIA_TYPE_ID,
    P_MEDIA_TYPE_UUID,
    P_SIMPLE_BLENDING_ORDER,
    P_TEL_REQD_FLAG,
    P_SVR_LOGIN_RULE_ID,
    P_APPLICATION_ID,
    P_SH_CATEGORY_TYPE,
    P_IMAGE_FILE_NAME,
    P_CLASSIFICATION_QUERY_PROC,
    P_BLENDED_FLAG,
    P_BLENDED_DIR,
    P_MEDIA_TYPE_NAME,
    P_MEDIA_TYPE_DESCRIPTION,
    P_OWNER);
end if;
end Load_Seed_Row;

END IEU_UWQ_MEDIA_TYPES_SEED_PKG;

/
