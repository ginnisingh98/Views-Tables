--------------------------------------------------------
--  DDL for Package Body IEU_WP_PARAM_PROPS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_PARAM_PROPS_SEED_PKG" AS
/* $Header: IEUWPROB.pls 120.2 2005/08/04 23:19:32 appldev ship $ */

  PROCEDURE Update_Row (p_wp_param_props_rec IN wp_param_props_rec_type) IS

  BEGIN
     -- API body
    UPDATE ieu_wp_param_props_b SET
      last_updated_by = p_wp_param_props_rec.last_updated_by,
      last_update_date = p_wp_param_props_rec.last_update_date,
      last_update_login = p_wp_param_props_rec.last_update_login,
      ACTION_PARAM_SET_ID = p_wp_param_props_rec.ACTION_PARAM_SET_ID,
      param_id =   p_wp_param_props_rec.param_id,
      property_id = p_wp_param_props_rec.property_id,
      property_value = p_wp_param_props_rec.property_value,
      value_override_flag = p_wp_param_props_rec.value_override_flag,
      NOT_VALID_FLAG = p_wp_param_props_rec.NOT_VALID_FLAG
    WHERE param_property_id  = p_wp_param_props_rec.PARAM_PROPERTY_ID;


    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    UPDATE ieu_wp_param_props_tl SET
      property_value = p_wp_param_props_rec.property_value_tl,
      source_lang = USERENV('LANG'),
      last_updated_by = p_wp_param_props_rec.last_updated_by,
      last_update_date = p_wp_param_props_rec.last_update_date,
      last_update_login = p_wp_param_props_rec.last_update_login
    WHERE param_property_id  = p_wp_param_props_rec.PARAM_PROPERTY_ID
    AND USERENV('LANG') IN (language, source_lang);

    IF (SQL%NOTFOUND) THEN
      null;
    END IF;
     -- End of API body

  END Update_Row;

  PROCEDURE Load_Row (
                    p_PARAM_PROPERTY_ID IN NUMBER,
                    p_ACTION_PARAM_SET_ID IN NUMBER,
                    p_PARAM_ID IN NUMBER,
                    p_PROPERTY_ID IN NUMBER,
                    p_PROPERTY_VALUE IN VARCHAR2,
                    p_VALUE_OVERRIDE_FLAG IN VARCHAR2,
                    p_PROPERTY_VALUE_TL IN VARCHAR2,
                    p_NOT_VALID_FLAG IN VARCHAR2,
                    p_last_update_date IN VARCHAR2,
                    p_owner IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id         number := 0;
       l_wp_param_props_rec wp_param_props_rec_type;
       p_application_id      number(15);
       l_param_property_id   number;
       l_last_update_date DATE;
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

      l_wp_param_props_rec.PARAM_PROPERTY_ID   := p_PARAM_PROPERTY_ID;
      l_wp_param_props_rec.ACTION_PARAM_SET_ID := p_ACTION_PARAM_SET_ID;
      l_wp_param_props_rec.PARAM_ID := p_PARAM_ID ;
      l_wp_param_props_rec.PROPERTY_ID  := p_PROPERTY_ID;
      l_wp_param_props_rec.PROPERTY_VALUE := p_PROPERTY_VALUE;
      l_wp_param_props_rec.PROPERTY_VALUE_TL := p_PROPERTY_VALUE_TL;
      l_wp_param_props_rec.VALUE_OVERRIDE_FLAG := p_VALUE_OVERRIDE_FLAG;
      l_wp_param_props_rec.last_update_date := l_last_update_date;
      l_wp_param_props_rec.last_updated_by := user_id;
      l_wp_param_props_rec.last_update_login := 0;
      l_wp_param_props_rec.NOT_VALID_FLAG := p_NOT_VALID_FLAG;
      l_wp_param_props_rec.creation_date := sysdate;
      l_wp_param_props_rec.created_by := user_id;

      Update_Row (p_wp_param_props_rec => l_wp_param_props_rec);
      EXCEPTION
         when no_data_found then
           Insert_Row (p_wp_param_props_rec => l_wp_param_props_rec);
      END;
  END Load_Row;



  PROCEDURE translate_row (
     p_PARAM_PROPERTY_ID IN NUMBER,
     p_PROPERTY_VALUE_TL IN VARCHAR2,
     p_last_update_date IN VARCHAR2,
     p_owner IN VARCHAR2)
  IS
     user_id         number := 0;

     BEGIN

     user_id := fnd_load_util.owner_id(P_OWNER);

      -- only UPDATE rows that have not been altered by user
      UPDATE ieu_wp_param_props_tl SET
          PROPERTY_VALUE = p_PROPERTY_VALUE_TL,
          source_lang = userenv('LANG'),
          last_update_date = decode(p_last_update_date, null,sysdate,to_date(p_last_update_date, 'YYYY/MM/DD')),
          --last_updated_by = decode(p_owner, 'SEED', -1, 0),
          last_updated_by = user_id,
          last_update_login = 0
      WHERE PARAM_PROPERTY_ID = p_PARAM_PROPERTY_ID
      AND   userenv('LANG') IN (language, source_lang);
end translate_row;



procedure DELETE_ROW (
  X_PARAM_PROPERTY_ID in NUMBER)
is
begin
  delete from IEU_WP_PARAM_PROPS_TL
  where PARAM_PROPERTY_ID = X_PARAM_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_WP_PARAM_PROPS_B
  where PARAM_PROPERTY_ID = X_PARAM_PROPERTY_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Insert_Row (p_wp_param_props_rec IN wp_param_props_rec_type)
IS
    CURSOR c IS
    SELECT 'X'
    FROM ieu_wp_param_props_b
    WHERE param_property_id = p_wp_param_props_rec.param_property_id;

    l_dummy CHAR(1);
    l_trans_flag IEU_WP_PROPERTIES_B.VALUE_TRANSLATABLE_FLAG%TYPE;
    l_temp ieu_wp_param_props_b.property_value%type;
    l_sequence  NUMBER;
  BEGIN
   -- API body
  -- if (p_wp_param_props_rec.property_id <> 10000) then
     insert into IEU_WP_PARAM_PROPS_B
                           ( PARAM_PROPERTY_ID,
                             CREATED_BY,
                             CREATION_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN,
                             ACTION_PARAM_SET_ID,
                             PARAM_ID,
                             PROPERTY_ID,
                             PROPERTY_VALUE,
                             VALUE_OVERRIDE_FLAG,
                             NOT_VALID_FLAG,
                             OBJECT_VERSION_NUMBER,
					    security_group_id)
                      values( p_wp_param_props_rec.PARAM_PROPERTY_ID,
                              FND_GLOBAL.USER_ID,
                              SYSDATE,
                              FND_GLOBAL.USER_ID,
                              SYSDATE,
                              FND_GLOBAL.LOGIN_ID,
                              p_wp_param_props_rec.ACTION_PARAM_SET_ID,
                              p_wp_param_props_rec.PARAM_ID,
                              p_wp_param_props_rec.PROPERTY_ID,
                              p_wp_param_props_rec.PROPERTY_VALUE,
                              p_wp_param_props_rec.VALUE_OVERRIDE_FLAG,
                              p_wp_param_props_rec.NOT_VALID_FLAG,
                              1,
						null);

     select VALUE_TRANSLATABLE_FLAG into l_trans_flag
     from ieu_wp_properties_b
     where property_id =p_wp_param_props_rec.PROPERTY_ID;

     if (l_trans_flag = 'Y') then
        INSERT INTO ieu_wp_param_props_tl (
         PARAM_PROPERTY_ID,
         language,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         property_value,
         object_version_number,
	    security_group_id,
         source_lang
       ) SELECT
         p_wp_param_props_rec.PARAM_PROPERTY_ID,
         l.language_code,
         p_wp_param_props_rec.created_by,
         p_wp_param_props_rec.creation_date,
         p_wp_param_props_rec.last_updated_by,
         p_wp_param_props_rec.last_update_date,
         p_wp_param_props_rec.last_update_login,
         p_wp_param_props_rec.PROPERTY_VALUE_TL,
         1,
	    null,
         USERENV('LANG')
        FROM fnd_languages l
        WHERE l.installed_flag IN ('I', 'B')
        AND NOT EXISTS
        (SELECT NULL
         FROM ieu_wp_param_props_tl t
         WHERE t.PARAM_PROPERTY_ID = p_wp_param_props_rec.PARAM_PROPERTY_ID
         AND t.language = l.language_code);
    end if ;
    OPEN c;
    FETCH c INTO l_dummy;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
     -- End of API body
 -- end if;
  END Insert_Row;

procedure ADD_LANGUAGE
is
begin
  delete from IEU_WP_PARAM_PROPS_TL T
  where not exists
    (select NULL
    from IEU_WP_PARAM_PROPS_B B
    where B.PARAM_PROPERTY_ID = T.PARAM_PROPERTY_ID
    );

  update IEU_WP_PARAM_PROPS_TL T set (
      PROPERTY_VALUE
    ) = (select
      B.PROPERTY_VALUE
    from IEU_WP_PARAM_PROPS_TL B
    where B.PARAM_PROPERTY_ID = T.PARAM_PROPERTY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAM_PROPERTY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAM_PROPERTY_ID,
      SUBT.LANGUAGE
    from IEU_WP_PARAM_PROPS_TL SUBB, IEU_WP_PARAM_PROPS_TL SUBT
    where SUBB.PARAM_PROPERTY_ID = SUBT.PARAM_PROPERTY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PROPERTY_VALUE <> SUBT.PROPERTY_VALUE
      or (SUBB.PROPERTY_VALUE is null and SUBT.PROPERTY_VALUE is not null)
      or (SUBB.PROPERTY_VALUE is not null and SUBT.PROPERTY_VALUE is null)
  ));

  insert into IEU_WP_PARAM_PROPS_TL (
    PARAM_PROPERTY_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    PROPERTY_VALUE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PARAM_PROPERTY_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.PROPERTY_VALUE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_WP_PARAM_PROPS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_WP_PARAM_PROPS_TL T
    where T.PARAM_PROPERTY_ID = B.PARAM_PROPERTY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Load_seed_Row (
  p_upload_mode IN VARCHAR2,
  p_PARAM_PROPERTY_ID IN NUMBER,
  p_ACTION_PARAM_SET_ID IN NUMBER,
  p_PARAM_ID IN NUMBER,
  p_PROPERTY_ID IN NUMBER,
  p_PROPERTY_VALUE IN VARCHAR2,
  p_VALUE_OVERRIDE_FLAG IN VARCHAR2,
  p_PROPERTY_VALUE_TL IN VARCHAR2,
  p_NOT_VALID_FLAG    IN VARCHAR2,
  p_last_update_date IN VARCHAR2,
  p_owner IN VARCHAR2
)is
begin

if (P_UPLOAD_MODE = 'NLS') then
  TRANSLATE_ROW (
    P_PARAM_PROPERTY_ID,
    P_PROPERTY_VALUE_TL,
    P_LAST_UPDATE_DATE,
    P_OWNER);
else
  LOAD_ROW (
    P_PARAM_PROPERTY_ID,
    P_ACTION_PARAM_SET_ID,
    P_PARAM_ID,
    P_PROPERTY_ID,
    P_PROPERTY_VALUE,
    P_VALUE_OVERRIDE_FLAG,
    P_PROPERTY_VALUE_TL,
    p_NOT_VALID_FLAG,
    P_LAST_UPDATE_DATE,
    P_OWNER);
end if;
end Load_seed_Row ;

END IEU_WP_PARAM_PROPS_SEED_PKG;

/
