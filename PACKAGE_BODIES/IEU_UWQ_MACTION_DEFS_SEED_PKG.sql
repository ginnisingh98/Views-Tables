--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_MACTION_DEFS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_MACTION_DEFS_SEED_PKG" AS
/* $Header: IEUMACTB.pls 120.1 2005/07/07 02:18:38 appldev ship $ */
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
      ACTION_PROC_TYPE_CODE,
      maction_def_type_flag,
      global_form_params,
      multi_select_flag,
      maction_def_key,
      application_id
    ) VALUES (
      p_uwq_maction_defs_rec.maction_def_id,
      p_uwq_maction_defs_rec.created_by,
      p_uwq_maction_defs_rec.creation_date,
      p_uwq_maction_defs_rec.last_updated_by,
      p_uwq_maction_defs_rec.last_update_date,
      p_uwq_maction_defs_rec.last_update_login,
      p_uwq_maction_defs_rec.action_proc,
      p_uwq_maction_defs_rec.ACTION_PROC_TYPE_CODE,
      p_uwq_maction_defs_rec.maction_def_type_flag,
      p_uwq_maction_defs_rec.global_form_params,
      p_uwq_maction_defs_rec.multi_select_flag,
      p_uwq_maction_defs_rec.maction_def_key,
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
      action_proc = p_uwq_maction_defs_rec.action_proc,
      ACTION_PROC_TYPE_CODE = p_uwq_maction_defs_rec.ACTION_PROC_TYPE_CODE,
      MACTION_DEF_TYPE_FLAG =   p_uwq_maction_defs_rec.maction_def_type_flag,
      GLOBAL_FORM_PARAMS = p_uwq_maction_defs_rec.global_form_params,
      MULTI_SELECT_FLAG = p_uwq_maction_defs_rec.multi_select_flag,
      MACTION_DEF_KEY = p_uwq_maction_defs_rec.maction_def_key

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
		p_ACTION_PROC_TYPE_CODE IN VARCHAR2,
                p_MACTION_DEF_TYPE_FLAG  IN VARCHAR2,
	            p_GLOBAL_FORM_PARAMS IN VARCHAR2,
	            p_MULTI_SELECT_FLAG IN VARCHAR2,
	            p_MACTION_DEF_KEY IN VARCHAR2,
                  p_last_update_date IN VARCHAR2,
                p_application_short_name IN VARCHAR2,
		        p_action_user_label IN VARCHAR2,
                p_action_description IN VARCHAR2,
                p_owner IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id		     number := 0;
       l_uwq_maction_defs_rec uwq_maction_defs_rec_type;
       l_last_update_date date;
       p_application_id	     number(15);

    BEGIN

       --IF (p_owner = 'SEED') then
       --   user_id := -1;
       --END IF;

       user_id := fnd_load_util.owner_id(P_OWNER);

       select a.application_id
       into   p_application_id
       from   fnd_application a
       where  a.application_short_name = p_application_short_name;

      if (p_last_update_date is null) then
           l_last_update_date := sysdate;
      else
           l_last_update_date := to_date(p_last_update_date, 'YYYY/MM/DD');
      end if;

	l_uwq_maction_defs_rec.maction_def_id   := p_maction_def_id;
	l_uwq_maction_defs_rec.action_proc := p_action_proc;
	l_uwq_maction_defs_rec.ACTION_PROC_TYPE_CODE := p_ACTION_PROC_TYPE_CODE;
      l_uwq_maction_defs_rec.maction_def_type_flag := p_MACTION_DEF_TYPE_FLAG ;
	l_uwq_maction_defs_rec.global_form_params  := p_GLOBAL_FORM_PARAMS;
	l_uwq_maction_defs_rec.multi_select_flag := p_MULTI_SELECT_FLAG;
	l_uwq_maction_defs_rec.maction_def_key := p_MACTION_DEF_KEY;
	l_uwq_maction_defs_rec.application_id := p_application_id;
	l_uwq_maction_defs_rec.action_user_label := p_action_user_label;
	l_uwq_maction_defs_rec.action_description := p_action_description;
    	l_uwq_maction_defs_rec.last_update_date := l_last_update_date;
     	l_uwq_maction_defs_rec.last_updated_by := user_id;
     	l_uwq_maction_defs_rec.last_update_login := 0;

       Update_Row (p_uwq_maction_defs_rec => l_uwq_maction_defs_rec);
      EXCEPTION
         when no_data_found then

	l_uwq_maction_defs_rec.maction_def_id   := p_maction_def_id;
	l_uwq_maction_defs_rec.action_proc := p_action_proc;
      l_uwq_maction_defs_rec.ACTION_PROC_TYPE_CODE := p_ACTION_PROC_TYPE_CODE;
      l_uwq_maction_defs_rec.maction_def_type_flag := p_MACTION_DEF_TYPE_FLAG ;
	l_uwq_maction_defs_rec.global_form_params  := p_GLOBAL_FORM_PARAMS;
	l_uwq_maction_defs_rec.multi_select_flag := p_MULTI_SELECT_FLAG;
	l_uwq_maction_defs_rec.maction_def_key := p_MACTION_DEF_KEY;
	l_uwq_maction_defs_rec.application_id := p_application_id;
	l_uwq_maction_defs_rec.action_user_label := p_action_user_label;
	l_uwq_maction_defs_rec.action_description := p_action_description;
     	l_uwq_maction_defs_rec.last_update_date := l_last_update_date;
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
    p_last_update_date IN VARCHAR2,
    p_owner IN VARCHAR2) IS
  user_id		     number := 0;
  BEGIN

      -- only UPDATE rows that have not been altered by user

      user_id := fnd_load_util.owner_id(P_OWNER);

      UPDATE ieu_uwq_maction_defs_tl SET
	action_user_label = p_action_user_label,
      source_lang = userenv('LANG'),
	action_description = p_action_description,
      last_update_date = decode(p_last_update_date, null, sysdate, to_date(p_last_update_date, 'YYYY/MM/DD')),
      --last_updated_by = decode(p_owner, 'SEED', -1, 0),
      last_updated_by = user_id,
      last_update_login = 0
      WHERE maction_def_id = p_maction_def_id
      AND   userenv('LANG') IN (language, source_lang);
end translate_row;

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
    object_version_number,
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
    1,
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

/* Modified */

procedure LOCK_ROW (
  X_MACTION_DEF_ID in NUMBER,
  X_ACTION_PROC in VARCHAR2,
  X_ACTION_PROC_TYPE_CODE in VARCHAR2,
  X_MACTION_DEF_TYPE_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_GLOBAL_FORM_PARAMS in VARCHAR2,
  X_ACTION_USER_LABEL in VARCHAR2,
  X_ACTION_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      ACTION_PROC,
      ACTION_PROC_TYPE_CODE,
      MACTION_DEF_TYPE_FLAG,
      APPLICATION_ID,
      GLOBAL_FORM_PARAMS
    from IEU_UWQ_MACTION_DEFS_B
    where MACTION_DEF_ID = X_MACTION_DEF_ID
    for update of MACTION_DEF_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      ACTION_USER_LABEL,
      ACTION_DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from IEU_UWQ_MACTION_DEFS_TL
    where MACTION_DEF_ID = X_MACTION_DEF_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of MACTION_DEF_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    (recinfo.ACTION_PROC = X_ACTION_PROC)
      AND ( (recinfo.ACTION_PROC_TYPE_CODE = X_ACTION_PROC_TYPE_CODE) OR
            ( (recinfo.ACTION_PROC_TYPE_CODE is NULL) AND (X_ACTION_PROC_TYPE_CODE is NULL) ) )
      AND ( (recinfo.MACTION_DEF_TYPE_FLAG = X_MACTION_DEF_TYPE_FLAG) OR
            ( (recinfo.MACTION_DEF_TYPE_FLAG IS NULL) AND (X_MACTION_DEF_TYPE_FLAG IS NULL) ) )
      AND (recinfo.APPLICATION_ID = X_APPLICATION_ID)
      AND ((recinfo.GLOBAL_FORM_PARAMS = X_GLOBAL_FORM_PARAMS)
           OR ((recinfo.GLOBAL_FORM_PARAMS is null) AND (X_GLOBAL_FORM_PARAMS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.ACTION_USER_LABEL = X_ACTION_USER_LABEL)
          AND ((tlinfo.ACTION_DESCRIPTION = X_ACTION_DESCRIPTION)
               OR ((tlinfo.ACTION_DESCRIPTION is null) AND (X_ACTION_DESCRIPTION is null)))
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

procedure DELETE_ROW (
  X_MACTION_DEF_ID in NUMBER
) is
begin
  delete from IEU_UWQ_MACTION_DEFS_TL
  where MACTION_DEF_ID = X_MACTION_DEF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_UWQ_MACTION_DEFS_B
  where MACTION_DEF_ID = X_MACTION_DEF_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Load_Seed_Row (
  p_upload_mode IN VARCHAR2,
  p_maction_def_id IN NUMBER,
  p_action_proc IN VARCHAR2,
  p_ACTION_PROC_TYPE_CODE IN VARCHAR2,
  p_MACTION_DEF_TYPE_FLAG  IN VARCHAR2,
  p_GLOBAL_FORM_PARAMS IN VARCHAR2,
  p_MULTI_SELECT_FLAG IN VARCHAR2,
  p_MACTION_DEF_KEY IN VARCHAR2,
  p_last_update_date IN VARCHAR2,
  p_application_short_name IN VARCHAR2,
  p_action_user_label IN VARCHAR2,
  p_action_description IN VARCHAR2,
  p_owner IN VARCHAR2
)is
begin

  if (P_UPLOAD_MODE = 'NLS') then
          TRANSLATE_ROW (
             P_MACTION_DEF_ID,
             P_ACTION_USER_LABEL,
             P_ACTION_DESCRIPTION,
             P_LAST_UPDATE_DATE,
             P_OWNER);

  else
          LOAD_ROW (
                   P_MACTION_DEF_ID,
                   P_ACTION_PROC,
                   P_ACTION_PROC_TYPE_CODE,
                   p_MACTION_DEF_TYPE_FLAG,
                   P_GLOBAL_FORM_PARAMS,
                   P_MULTI_SELECT_FLAG,
                   p_MACTION_DEF_KEY,
                   P_LAST_UPDATE_DATE,
                   P_APPLICATION_SHORT_NAME,
                   P_ACTION_USER_LABEL,
                   P_ACTION_DESCRIPTION,
                   P_OWNER);
  end if;

end Load_Seed_Row;

END IEU_UWQ_MACTION_DEFS_SEED_PKG;

/
