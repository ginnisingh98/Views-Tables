--------------------------------------------------------
--  DDL for Package Body IEO_SVR_TYPES_SEED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_SVR_TYPES_SEED_PVT" AS
/* $Header: IEOSEEDB.pls 115.0 2000/01/19 10:10:02 pkm ship     $ */

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
      max_minor_load_factor
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
      p_svr_types_rec.max_minor_load_factor
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
      max_minor_load_factor = p_svr_types_rec.max_minor_load_factor
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
                p_owner IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id		     number := 0;
       l_svr_types_rec uwq_svr_types_rec_type;

    BEGIN

       IF (p_owner = 'SEED') then
          user_id := -1;
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
        last_updated_by = decode(p_owner, 'SEED', -1, 0),
        last_update_login = 0
      WHERE type_id = p_type_id
      AND   userenv('LANG') IN (language, source_lang);

  END translate_row;

END IEO_SVR_TYPES_SEED_PVT;

/
