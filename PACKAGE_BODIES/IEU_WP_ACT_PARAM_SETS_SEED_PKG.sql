--------------------------------------------------------
--  DDL for Package Body IEU_WP_ACT_PARAM_SETS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_ACT_PARAM_SETS_SEED_PKG" AS
/* $Header: IEUWAPSB.pls 120.1 2005/07/07 03:18:41 appldev ship $ */

  PROCEDURE Update_Row (p_WP_ACT_PARAM_SETS_rec IN WP_ACT_PARAM_SETS_rec_type) IS

  BEGIN
     -- API body
    UPDATE ieu_WP_ACT_PARAM_SETS_b SET
      last_updated_by = p_WP_ACT_PARAM_SETS_rec.last_updated_by,
      last_update_date = p_WP_ACT_PARAM_SETS_rec.last_update_date,
      last_update_login = p_WP_ACT_PARAM_SETS_rec.last_update_login,
      ACTION_PARAM_SET_ID =   p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID,
      WP_ACTION_DEF_ID = p_WP_ACT_PARAM_SETS_rec.WP_ACTION_DEF_ID
    WHERE ACTION_PARAM_SET_ID = p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID;


    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    UPDATE ieu_WP_ACT_PARAM_SETS_tl SET
      ACTION_PARAM_SET_LABEL = p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_LABEL,
      action_param_set_desc = p_wp_act_param_sets_rec.action_param_set_desc,
      source_lang = USERENV('LANG'),
      last_updated_by = p_WP_ACT_PARAM_SETS_rec.last_updated_by,
      last_update_date = p_WP_ACT_PARAM_SETS_rec.last_update_date,
      last_update_login = p_WP_ACT_PARAM_SETS_rec.last_update_login
    WHERE ACTION_PARAM_SET_ID = p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID
    AND USERENV('LANG') IN (language, source_lang);

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;
     -- End of API body

  END Update_Row;

  PROCEDURE Load_Row (
              p_ACTION_PARAM_SET_ID IN NUMBER,
              p_WP_ACTION_DEF_ID IN NUMBER,
              p_ACTION_PARAM_SET_LABEL IN VARCHAR2,
              p_action_param_set_desc IN VARCHAR2,
              p_last_update_date iN VARCHAR2,
              p_owner IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id		     number := 0;
       l_WP_ACT_PARAM_SETS_rec WP_ACT_PARAM_SETS_rec_type;
       l_last_update_date DATE;
       p_application_id	     number(15);

    BEGIN

      --IF (p_owner = 'SEED') then
      --    user_id := -1;
      --END IF;

      user_id := fnd_load_util.owner_id(P_OWNER);

      if (p_last_update_date is null) then
           l_last_update_date := sysdate;
      else
           l_last_update_date := to_date(p_last_update_date, 'YYYY/MM/DD');
      end if;

      l_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID   := p_ACTION_PARAM_SET_ID;
      l_WP_ACT_PARAM_SETS_rec.WP_ACTION_DEF_ID  := p_WP_ACTION_DEF_ID;
      l_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_LABEL := p_ACTION_PARAM_SET_LABEL;
      l_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_DESC := p_ACTION_PARAM_SET_DESC;
      l_WP_ACT_PARAM_SETS_rec.last_update_date := l_last_update_date;
      l_WP_ACT_PARAM_SETS_rec.last_updated_by := user_id;
      l_WP_ACT_PARAM_SETS_rec.last_update_login := 0;

      Update_Row (p_WP_ACT_PARAM_SETS_rec => l_WP_ACT_PARAM_SETS_rec);
      EXCEPTION
         when no_data_found then

      l_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID   := p_ACTION_PARAM_SET_ID;
      l_WP_ACT_PARAM_SETS_rec.WP_ACTION_DEF_ID  := p_WP_ACTION_DEF_ID;
      l_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_LABEL := p_ACTION_PARAM_SET_LABEL;
      l_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_DESC := p_ACTION_PARAM_SET_DESC;
      l_WP_ACT_PARAM_SETS_rec.last_update_date := l_last_update_date;
      l_WP_ACT_PARAM_SETS_rec.last_updated_by := user_id;
      l_WP_ACT_PARAM_SETS_rec.last_update_login := 0;
      l_WP_ACT_PARAM_SETS_rec.creation_date := sysdate;
      l_WP_ACT_PARAM_SETS_rec.created_by := user_id;

      Insert_Row (p_WP_ACT_PARAM_SETS_rec => l_WP_ACT_PARAM_SETS_rec);

      END;
  END Load_Row;



  PROCEDURE translate_row (
     p_ACTION_PARAM_SET_ID IN NUMBER,
     p_ACTION_PARAM_SET_LABEL IN VARCHAR2,
     p_action_param_set_desc IN VARCHAR2,
     p_last_update_date iN VARCHAR2,
     p_owner IN VARCHAR2) IS

  user_id		     number := 0;

  BEGIN

      -- only UPDATE rows that have not been altered by user

      user_id := fnd_load_util.owner_id(P_OWNER);

      UPDATE ieu_WP_ACT_PARAM_SETS_tl SET
        ACTION_PARAM_SET_LABEL = p_ACTION_PARAM_SET_LABEL,
        action_param_set_desc = p_action_param_set_desc,
        source_lang = userenv('LANG'),
        last_update_date = decode(p_last_update_date,null,sysdate,to_date(p_last_update_date, 'YYYY/MM/DD')),
        --last_updated_by = decode(p_owner, 'SEED', -1, 0),
        last_updated_by = user_id,
        last_update_login = 0
      WHERE ACTION_PARAM_SET_ID = p_ACTION_PARAM_SET_ID
      AND   userenv('LANG') IN (language, source_lang);
end translate_row;



procedure DELETE_ROW (
  X_ACTION_PARAM_SET_ID in NUMBER
) is
begin
  delete from IEU_WP_ACT_PARAM_SETS_TL
  where ACTION_PARAM_SET_ID = X_ACTION_PARAM_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_WP_ACT_PARAM_SETS_B
  where ACTION_PARAM_SET_ID = X_ACTION_PARAM_SET_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Insert_Row (p_WP_ACT_PARAM_SETS_rec IN WP_ACT_PARAM_SETS_rec_type) IS

CURSOR c IS
  SELECT 'X' FROM ieu_WP_ACT_PARAM_SETS_b
  WHERE ACTION_PARAM_SET_ID = p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID;

    l_dummy CHAR(1);

  BEGIN

   -- API body
     insert into IEU_WP_ACT_PARAM_SETS_B
                           ( ACTION_PARAM_SET_ID,
                             CREATED_BY,
                             CREATION_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN,
                             WP_ACTION_DEF_ID,
                             OBJECT_VERSION_NUMBER,
					    Security_group_id)
                      values( p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID,
                              FND_GLOBAL.USER_ID,
                              SYSDATE,
                              FND_GLOBAL.USER_ID,
                              SYSDATE,
                              FND_GLOBAL.LOGIN_ID,
                              p_WP_ACT_PARAM_SETS_rec.WP_ACTION_DEF_ID,
                              1,
						null);
   INSERT INTO ieu_WP_ACT_PARAM_SETS_tl (
      ACTION_PARAM_SET_ID,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      ACTION_PARAM_SET_LABEL,
      action_param_set_desc,
      object_version_number,
	 security_group_id,
      source_lang
    ) SELECT
        p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID,
        l.language_code,
        p_WP_ACT_PARAM_SETS_rec.created_by,
        p_WP_ACT_PARAM_SETS_rec.creation_date,
        p_WP_ACT_PARAM_SETS_rec.last_updated_by,
        p_WP_ACT_PARAM_SETS_rec.last_update_date,
        p_WP_ACT_PARAM_SETS_rec.last_update_login,
        p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_LABEL,
        p_WP_ACT_PARAM_SETS_rec.action_PARAM_set_DESC,
        1,
	   null,
        USERENV('LANG')
      FROM fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND NOT EXISTS
        (SELECT NULL
         FROM ieu_WP_ACT_PARAM_SETS_tl t
         WHERE t.ACTION_PARAM_SET_ID = p_WP_ACT_PARAM_SETS_rec.ACTION_PARAM_SET_ID
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

procedure ADD_LANGUAGE
is
begin
  delete from IEU_WP_ACT_PARAM_SETS_TL T
  where not exists
    (select NULL
    from IEU_WP_ACT_PARAM_SETS_B B
    where B.ACTION_PARAM_SET_ID = T.ACTION_PARAM_SET_ID
    );

  update IEU_WP_ACT_PARAM_SETS_TL T set (
      ACTION_PARAM_SET_LABEL,
      ACTION_PARAM_SET_DESC
    ) = (select
      B.ACTION_PARAM_SET_LABEL,
      B.ACTION_PARAM_SET_DESC
    from IEU_WP_ACT_PARAM_SETS_TL B
    where B.ACTION_PARAM_SET_ID = T.ACTION_PARAM_SET_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ACTION_PARAM_SET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ACTION_PARAM_SET_ID,
      SUBT.LANGUAGE
    from IEU_WP_ACT_PARAM_SETS_TL SUBB, IEU_WP_ACT_PARAM_SETS_TL SUBT
    where SUBB.ACTION_PARAM_SET_ID = SUBT.ACTION_PARAM_SET_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ACTION_PARAM_SET_LABEL <> SUBT.ACTION_PARAM_SET_LABEL
      or SUBB.ACTION_PARAM_SET_DESC <> SUBT.ACTION_PARAM_SET_DESC
      or (SUBB.ACTION_PARAM_SET_DESC is null and SUBT.ACTION_PARAM_SET_DESC is not null)
      or (SUBB.ACTION_PARAM_SET_DESC is not null and SUBT.ACTION_PARAM_SET_DESC is null)
  ));

  insert into IEU_WP_ACT_PARAM_SETS_TL (
    ACTION_PARAM_SET_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    ACTION_PARAM_SET_LABEL,
    ACTION_PARAM_SET_DESC,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ACTION_PARAM_SET_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.ACTION_PARAM_SET_LABEL,
    B.ACTION_PARAM_SET_DESC,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_WP_ACT_PARAM_SETS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_WP_ACT_PARAM_SETS_TL T
    where T.ACTION_PARAM_SET_ID = B.ACTION_PARAM_SET_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Load_Seed_Row (
  P_UPLOAD_MODE IN VARCHAR2,
  p_ACTION_PARAM_SET_ID          IN NUMBER,
  p_WP_ACTION_DEF_ID  IN NUMBER,
  /* p_WP_ACTION_KEY        IN VARCHAR2,*/
  p_ACTION_PARAM_SET_LABEL IN VARCHAR2,
  p_action_param_set_desc  IN VARCHAR2,
  p_last_update_date iN VARCHAR2,
  p_owner             IN VARCHAR2
)is
begin

if (P_UPLOAD_MODE = 'NLS') then
  TRANSLATE_ROW (
    P_ACTION_PARAM_SET_ID,
    p_ACTION_PARAM_SET_LABEL,
    p_action_param_set_desc,
    P_LAST_UPDATE_DATE,
    P_OWNER);
else
  LOAD_ROW (
    P_ACTION_PARAM_SET_ID,
    P_WP_ACTION_DEF_ID,
    p_ACTION_PARAM_SET_LABEL,
    p_action_param_set_desc,
    P_LAST_UPDATE_DATE,
    P_OWNER);
end if;

end Load_Seed_Row;


END IEU_WP_ACT_PARAM_SETS_SEED_PKG;

/
