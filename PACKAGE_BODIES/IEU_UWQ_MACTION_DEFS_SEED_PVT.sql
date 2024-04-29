--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_MACTION_DEFS_SEED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_MACTION_DEFS_SEED_PVT" AS
/* $Header: IEUMACTB.pls 115.1 2000/02/29 15:55:10 pkm ship      $ */

  PROCEDURE Insert_Row (p_uwq_maction_defs_rec IN uwq_maction_defs_rec_type) IS

    CURSOR c IS 	SELECT 'X' FROM ieu_uwq_maction_defs_b
      		WHERE maction_def_id = p_uwq_maction_defs_rec.maction_def_id;

    l_dummy CHAR(1);

  BEGIN

     -- API body
    INSERT INTO ieu_uwq_maction_defs_b (
      maction_def_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      action_proc,
      application_id
    ) VALUES (
      p_uwq_maction_defs_rec.maction_def_id,
      p_uwq_maction_defs_rec.created_by,
      p_uwq_maction_defs_rec.creation_date,
      p_uwq_maction_defs_rec.last_updated_by,
      p_uwq_maction_defs_rec.last_update_date,
      p_uwq_maction_defs_rec.last_update_login,
      p_uwq_maction_defs_rec.action_proc,
      p_uwq_maction_defs_rec.application_id
    );

    INSERT INTO ieu_uwq_maction_defs_tl (
      maction_def_id,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      action_user_label,
      source_lang,
      action_description
    ) SELECT
      	p_uwq_maction_defs_rec.maction_def_id,
      	l.language_code,
      	p_uwq_maction_defs_rec.created_by,
      	p_uwq_maction_defs_rec.creation_date,
      	p_uwq_maction_defs_rec.last_updated_by,
      	p_uwq_maction_defs_rec.last_update_date,
      	p_uwq_maction_defs_rec.last_update_login,
      	p_uwq_maction_defs_rec.action_user_label,
      	USERENV('LANG'),
      	p_uwq_maction_defs_rec.action_description
      FROM fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND NOT EXISTS
        (SELECT NULL
         FROM ieu_uwq_maction_defs_tl t
         WHERE t.maction_def_id = p_uwq_maction_defs_rec.maction_def_id
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

  PROCEDURE Update_Row (p_uwq_maction_defs_rec IN uwq_maction_defs_rec_type) IS

  BEGIN
     -- API body
    UPDATE ieu_uwq_maction_defs_b SET
      last_updated_by = p_uwq_maction_defs_rec.last_updated_by,
      last_update_date = p_uwq_maction_defs_rec.last_update_date,
      last_update_login = p_uwq_maction_defs_rec.last_update_login,
      action_proc = p_uwq_maction_defs_rec.action_proc
    WHERE maction_def_id = p_uwq_maction_defs_rec.maction_def_id;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    UPDATE ieu_uwq_maction_defs_tl SET
      action_user_label = p_uwq_maction_defs_rec.action_user_label,
      source_lang = USERENV('LANG'),
      action_description = p_uwq_maction_defs_rec.action_description,
      last_updated_by = p_uwq_maction_defs_rec.last_updated_by,
      last_update_date = p_uwq_maction_defs_rec.last_update_date,
      last_update_login = p_uwq_maction_defs_rec.last_update_login
    WHERE maction_def_id = p_uwq_maction_defs_rec.maction_def_id
    AND USERENV('LANG') IN (language, source_lang);

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;
     -- End of API body

  END Update_Row;

  PROCEDURE Load_Row (
                p_maction_def_id IN NUMBER,
                p_action_proc IN VARCHAR2,
                p_application_short_name IN VARCHAR2,
		p_action_user_label IN VARCHAR2,
                p_action_description IN VARCHAR2,
                p_owner IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id		     number := 0;
       l_uwq_maction_defs_rec uwq_maction_defs_rec_type;

       p_application_id	     number(15);

    BEGIN

       IF (p_owner = 'SEED') then
          user_id := -1;
       END IF;

       select a.application_id
       into   p_application_id
       from   fnd_application a
       where  a.application_short_name = p_application_short_name;

	l_uwq_maction_defs_rec.maction_def_id   := p_maction_def_id;
	l_uwq_maction_defs_rec.action_proc := p_action_proc;
	l_uwq_maction_defs_rec.application_id := p_application_id;
	l_uwq_maction_defs_rec.action_user_label := p_action_user_label;
	l_uwq_maction_defs_rec.action_description := p_action_description;
       	l_uwq_maction_defs_rec.last_update_date := sysdate;
       	l_uwq_maction_defs_rec.last_updated_by := user_id;
       	l_uwq_maction_defs_rec.last_update_login := 0;

       Update_Row (p_uwq_maction_defs_rec => l_uwq_maction_defs_rec);
      EXCEPTION
         when no_data_found then

	l_uwq_maction_defs_rec.maction_def_id   := p_maction_def_id;
	l_uwq_maction_defs_rec.action_proc := p_action_proc;
	l_uwq_maction_defs_rec.application_id := p_application_id;
	l_uwq_maction_defs_rec.action_user_label := p_action_user_label;
	l_uwq_maction_defs_rec.action_description := p_action_description;
       	l_uwq_maction_defs_rec.last_update_date := sysdate;
       	l_uwq_maction_defs_rec.last_updated_by := user_id;
       	l_uwq_maction_defs_rec.last_update_login := 0;
        l_uwq_maction_defs_rec.creation_date := sysdate;
        l_uwq_maction_defs_rec.created_by := user_id;

        Insert_Row (p_uwq_maction_defs_rec => l_uwq_maction_defs_rec);

      END;
  END load_row;

  PROCEDURE translate_row (
    p_maction_def_id IN NUMBER,
    p_action_user_label IN VARCHAR2,
    p_action_description IN VARCHAR2,
    p_owner IN VARCHAR2) IS

  BEGIN

      -- only UPDATE rows that have not been altered by user

      UPDATE ieu_uwq_maction_defs_tl SET
	action_user_label = p_action_user_label,
        source_lang = userenv('LANG'),
	action_description = p_action_description,
        last_update_date = sysdate,
        last_updated_by = decode(p_owner, 'SEED', -1, 0),
        last_update_login = 0
      WHERE maction_def_id = p_maction_def_id
      AND   userenv('LANG') IN (language, source_lang);

  END translate_row;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_UWQ_MACTION_DEFS_TL T
  where not exists
    (select NULL
    from IEU_UWQ_MACTION_DEFS_B B
    where B.MACTION_DEF_ID = T.MACTION_DEF_ID
    );

  update IEU_UWQ_MACTION_DEFS_TL T set (
      ACTION_USER_LABEL,
      ACTION_DESCRIPTION
    ) = (select
      B.ACTION_USER_LABEL,
      B.ACTION_DESCRIPTION
    from IEU_UWQ_MACTION_DEFS_TL B
    where B.MACTION_DEF_ID = T.MACTION_DEF_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.MACTION_DEF_ID,
      T.LANGUAGE
  ) in (select
      SUBT.MACTION_DEF_ID,
      SUBT.LANGUAGE
    from IEU_UWQ_MACTION_DEFS_TL SUBB, IEU_UWQ_MACTION_DEFS_TL SUBT
    where SUBB.MACTION_DEF_ID = SUBT.MACTION_DEF_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ACTION_USER_LABEL <> SUBT.ACTION_USER_LABEL
      or SUBB.ACTION_DESCRIPTION <> SUBT.ACTION_DESCRIPTION
      or (SUBB.ACTION_DESCRIPTION is null and SUBT.ACTION_DESCRIPTION is not null)
      or (SUBB.ACTION_DESCRIPTION is not null and SUBT.ACTION_DESCRIPTION is null)
  ));

  insert into IEU_UWQ_MACTION_DEFS_TL (
    ACTION_DESCRIPTION,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACTION_USER_LABEL,
    MACTION_DEF_ID,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ACTION_DESCRIPTION,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.ACTION_USER_LABEL,
    B.MACTION_DEF_ID,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_UWQ_MACTION_DEFS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_UWQ_MACTION_DEFS_TL T
    where T.MACTION_DEF_ID = B.MACTION_DEF_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END IEU_UWQ_MACTION_DEFS_SEED_PVT;

/
