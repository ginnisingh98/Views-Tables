--------------------------------------------------------
--  DDL for Package Body IEO_SVR_TYPES_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_SVR_TYPES_SEED_PKG" AS
/* $Header: IEOSEEDB.pls 115.8 2003/01/02 17:07:23 dolee ship $ */

  PROCEDURE Insert_Row (p_svr_types_rec IN uwq_svr_types_rec_type) IS

    CURSOR c IS SELECT 'X' FROM ieo_svr_types_b
    WHERE  type_id = p_svr_types_rec.type_id;

    l_dummy CHAR(1);

  BEGIN

     -- API body
    INSERT INTO ieo_svr_types_b (
      type_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      type_uuid,
      rt_refresh_rate,
      max_major_load_factor,
      max_minor_load_factor,
      application_short_name
    ) VALUES (
      p_svr_types_rec.type_id,
      p_svr_types_rec.created_by,
      p_svr_types_rec.creation_date,
      p_svr_types_rec.last_updated_by,
      p_svr_types_rec.last_update_date,
      p_svr_types_rec.last_update_login,
      p_svr_types_rec.type_uuid,
      p_svr_types_rec.rt_refresh_rate,
      p_svr_types_rec.max_major_load_factor,
      p_svr_types_rec.max_minor_load_factor,
      p_svr_types_rec.application_short_name
    );

    INSERT INTO ieo_svr_types_tl (
      type_id,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      type_name,
      source_lang,
      type_description,
      type_extra
    ) SELECT
         p_svr_types_rec.type_id,
         l.language_code,
         p_svr_types_rec.created_by,
         p_svr_types_rec.creation_date,
         p_svr_types_rec.last_updated_by,
         p_svr_types_rec.last_update_date,
         p_svr_types_rec.last_update_login,
         p_svr_types_rec.type_name,
         USERENV('LANG'),
         p_svr_types_rec.type_description,
         p_svr_types_rec.type_extra
      FROM fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND NOT EXISTS
        (SELECT NULL
         FROM ieo_svr_types_tl t
         WHERE t.type_id = p_svr_types_rec.type_id
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

  PROCEDURE Update_Row (p_svr_types_rec IN uwq_svr_types_rec_type) IS

  BEGIN
     -- API body
    UPDATE ieo_svr_types_b SET
      last_updated_by   = p_svr_types_rec.last_updated_by,
      last_update_date  = p_svr_types_rec.last_update_date,
      last_update_login = p_svr_types_rec.last_update_login,
      type_uuid = p_svr_types_rec.type_uuid,
      rt_refresh_rate = p_svr_types_rec.rt_refresh_rate,
      max_major_load_factor = p_svr_types_rec.max_major_load_factor,
      max_minor_load_factor = p_svr_types_rec.max_minor_load_factor,
      application_short_name = p_svr_types_rec.application_short_name
    WHERE type_id = p_svr_types_rec.type_id;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    UPDATE ieo_svr_types_tl SET
      type_name = p_svr_types_rec.type_name,
      source_lang = USERENV('LANG'),
      type_description = p_svr_types_rec.type_description,
      last_updated_by  = p_svr_types_rec.last_updated_by,
      last_update_date = p_svr_types_rec.last_update_date,
      last_update_login = p_svr_types_rec.last_update_login,
      type_extra = p_svr_types_rec.type_extra
    WHERE type_id = p_svr_types_rec.type_id
    AND USERENV('LANG') IN (language, source_lang);

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;
     -- End of API body

  END Update_Row;

  PROCEDURE Load_Row (
      p_type_id IN NUMBER,
      p_type_uuid IN VARCHAR2,
      p_rt_refresh_rate  IN NUMBER,
      p_max_major_load_factor IN NUMBER,
      p_max_minor_load_factor IN NUMBER,
      p_type_name IN VARCHAR2,
      p_type_description IN VARCHAR2,
      p_type_extra IN VARCHAR2,
      p_owner IN VARCHAR2,
      p_application_short_name IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id         number := 0;
       l_svr_types_rec uwq_svr_types_rec_type;

    BEGIN

       IF (p_owner = 'SEED') then
          user_id := 1;
       END IF;

      l_svr_types_rec.type_id   := p_type_id;
      l_svr_types_rec.type_uuid := p_type_uuid;
      l_svr_types_rec.rt_refresh_rate := p_rt_refresh_rate;
      l_svr_types_rec.max_major_load_factor := p_max_major_load_factor;
      l_svr_types_rec.max_minor_load_factor := p_max_minor_load_factor;
      l_svr_types_rec.type_name := p_type_name;
      l_svr_types_rec.type_description := p_type_description;
      l_svr_types_rec.type_extra := p_type_extra;
      l_svr_types_rec.last_update_date := sysdate;
      l_svr_types_rec.last_updated_by := user_id;
      l_svr_types_rec.last_update_login := 0;
      l_svr_types_rec.application_short_name := p_application_short_name;

      Update_Row (p_svr_types_rec => l_svr_types_rec);
      EXCEPTION
         when no_data_found then

      l_svr_types_rec.type_id   := p_type_id;
      l_svr_types_rec.type_uuid := p_type_uuid;
      l_svr_types_rec.rt_refresh_rate := p_rt_refresh_rate;
      l_svr_types_rec.max_major_load_factor := p_max_major_load_factor;
      l_svr_types_rec.max_minor_load_factor := p_max_minor_load_factor;
      l_svr_types_rec.type_name := p_type_name;
      l_svr_types_rec.type_description := p_type_description;
      l_svr_types_rec.last_update_date := sysdate;
      l_svr_types_rec.last_updated_by := user_id;
      l_svr_types_rec.last_update_login := 0;
      l_svr_types_rec.creation_date := sysdate;
      l_svr_types_rec.created_by := user_id;
      l_svr_types_rec.application_short_name := p_application_short_name;

      Insert_Row (p_svr_types_rec => l_svr_types_rec);

      END;
  END load_row;

  PROCEDURE translate_row (
    p_type_id IN NUMBER,
    p_type_name IN VARCHAR2,
    p_type_description IN VARCHAR2,
    p_type_extra IN VARCHAR2,
    p_owner IN VARCHAR2) IS
  BEGIN

      -- only UPDATE rows that have not been altered by user

     UPDATE ieo_svr_types_tl SET
     type_name = p_type_name,
     source_lang = userenv('LANG'),
     type_description = p_type_description,
     type_extra = p_type_extra,
     last_update_date = sysdate,
     last_updated_by = decode(p_owner, 'SEED', 1, 0),
     last_update_login = 0
     WHERE type_id = p_type_id
     AND   userenv('LANG') IN (language, source_lang);

  END translate_row;

PROCEDURE ADD_LANGUAGE
is
begin
  delete from IEO_SVR_TYPES_TL T
  where not exists
    (select NULL
    from IEO_SVR_TYPES_B B
    where B.TYPE_ID = T.TYPE_ID
    );

  update IEO_SVR_TYPES_TL T set (
      TYPE_NAME,
      TYPE_DESCRIPTION,
      TYPE_EXTRA
    ) = (select
      B.TYPE_NAME,
      B.TYPE_DESCRIPTION,
      B.TYPE_EXTRA
    from IEO_SVR_TYPES_TL B
    where B.TYPE_ID = T.TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.TYPE_ID,
      SUBT.LANGUAGE
    from IEO_SVR_TYPES_TL SUBB, IEO_SVR_TYPES_TL SUBT
    where SUBB.TYPE_ID = SUBT.TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TYPE_NAME <> SUBT.TYPE_NAME
      or SUBB.TYPE_DESCRIPTION <> SUBT.TYPE_DESCRIPTION
      or (SUBB.TYPE_DESCRIPTION is null and SUBT.TYPE_DESCRIPTION is not null)
      or (SUBB.TYPE_DESCRIPTION is not null and SUBT.TYPE_DESCRIPTION is null)
      or SUBB.TYPE_EXTRA <> SUBT.TYPE_EXTRA
      or (SUBB.TYPE_EXTRA is null and SUBT.TYPE_EXTRA is not null)
      or (SUBB.TYPE_EXTRA is not null and SUBT.TYPE_EXTRA is null)
  ));

  insert into IEO_SVR_TYPES_TL (
    TYPE_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    TYPE_NAME,
    TYPE_DESCRIPTION,
    TYPE_EXTRA,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.TYPE_ID,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.TYPE_NAME,
    B.TYPE_DESCRIPTION,
    B.TYPE_EXTRA,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEO_SVR_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEO_SVR_TYPES_TL T
    where T.TYPE_ID = B.TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END IEO_SVR_TYPES_SEED_PKG;

/
