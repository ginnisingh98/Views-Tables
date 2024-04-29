--------------------------------------------------------
--  DDL for Package Body IEU_WP_PARAM_DEFS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_PARAM_DEFS_SEED_PKG" AS
/* $Header: IEUWACPB.pls 120.1 2005/07/07 02:25:50 appldev ship $ */

  PROCEDURE Update_Row (p_WP_PARAM_DEFS_rec IN WP_PARAM_DEFS_rec_type) IS

  BEGIN
     -- API body
    UPDATE ieu_WP_PARAM_DEFS_b SET
      last_updated_by = p_WP_PARAM_DEFS_rec.last_updated_by,
      last_update_date = p_WP_PARAM_DEFS_rec.last_update_date,
      last_update_login = p_WP_PARAM_DEFS_rec.last_update_login,
      param_name =  p_WP_PARAM_DEFS_rec.param_name,
      data_type =  p_WP_PARAM_DEFS_rec.data_type
    WHERE PARAM_ID = p_WP_PARAM_DEFS_rec.PARAM_ID;

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;

    UPDATE ieu_WP_PARAM_DEFS_tl SET
      param_user_label = p_WP_PARAM_DEFS_rec.PARAM_USER_LABEL,
      param_description = p_WP_PARAM_DEFS_rec.PARAM_DESCRIPTION,
      source_lang = USERENV('LANG'),
      last_updated_by = p_WP_PARAM_DEFS_rec.last_updated_by,
      last_update_date = p_WP_PARAM_DEFS_rec.last_update_date,
      last_update_login = p_WP_PARAM_DEFS_rec.last_update_login
    WHERE PARAM_ID = p_WP_PARAM_DEFS_rec.PARAM_ID
    AND USERENV('LANG') IN (language, source_lang);

    IF (SQL%NOTFOUND) THEN
      RAISE no_data_found;
    END IF;
     -- End of API body

  END Update_Row;

  PROCEDURE Load_Row (
                    p_PARAM_ID          IN NUMBER,
                    p_PARAM_NAME        IN VARCHAR2,
                    p_DATA_TYPE         IN VARCHAR2,
                    p_param_user_label  IN VARCHAR2,
		        p_param_description IN VARCHAR2,
                    p_last_update_date IN VARCHAR2,
                    p_owner             IN VARCHAR2) IS
  BEGIN

    DECLARE
       user_id		     number := 0;
       l_WP_PARAM_DEFS_rec WP_PARAM_DEFS_rec_type;
       l_last_update_date date;
       p_application_id	     number(15);

    BEGIN

       --IF (p_owner = 'SEED') then
       --   user_id := -1;
       --END IF;

       user_id := fnd_load_util.owner_id(P_OWNER);

       if (p_last_update_date is null) then
           l_last_update_date := sysdate;
       else
           l_last_update_date := to_date(p_last_update_date, 'YYYY/MM/DD');
       end if;

         l_WP_PARAM_DEFS_rec.param_id:= p_PARAM_ID;
         l_WP_PARAM_DEFS_rec.param_name := p_PARAM_NAME;
         l_WP_PARAM_DEFS_rec.data_type:= p_DATA_TYPE;
	   l_WP_PARAM_DEFS_rec.param_user_label := p_param_user_label;
         l_WP_PARAM_DEFS_rec.param_description := p_param_description;
         l_WP_PARAM_DEFS_rec.last_update_date := l_last_update_date;
         l_WP_PARAM_DEFS_rec.last_updated_by := user_id;
         l_WP_PARAM_DEFS_rec.last_update_login := 0;

       Update_Row (p_WP_PARAM_DEFS_rec => l_WP_PARAM_DEFS_rec);
      EXCEPTION
         when no_data_found then

         l_WP_PARAM_DEFS_rec.param_id:= p_PARAM_ID;
         l_WP_PARAM_DEFS_rec.param_name := p_PARAM_NAME;
         l_WP_PARAM_DEFS_rec.data_type := p_DATA_TYPE;
	   l_WP_PARAM_DEFS_rec.param_user_label := p_param_user_label;
         l_WP_PARAM_DEFS_rec.param_description := p_param_description;
	   l_WP_PARAM_DEFS_rec.last_update_date := l_last_update_date;
         l_WP_PARAM_DEFS_rec.last_updated_by := user_id;
         l_WP_PARAM_DEFS_rec.last_update_login := 0;
         l_WP_PARAM_DEFS_rec.creation_date := sysdate;
         l_WP_PARAM_DEFS_rec.created_by := user_id;

        Insert_Row (p_WP_PARAM_DEFS_rec => l_WP_PARAM_DEFS_rec);

      END;
  END Load_Row;



  PROCEDURE translate_row (
                        p_PARAM_ID IN NUMBER,
			p_param_user_label IN VARCHAR2,
			p_param_description IN VARCHAR2,
                  p_last_update_date IN VARCHAR2,
                	p_owner IN VARCHAR2) IS

  user_id		     number := 0;

  BEGIN

      -- only UPDATE rows that have not been altered by user

      user_id := fnd_load_util.owner_id(P_OWNER);

      UPDATE ieu_WP_PARAM_DEFS_tl SET
	param_user_label = p_param_user_label,
        param_description = p_param_description,
        source_lang = userenv('LANG'),
        last_update_date = decode(p_last_update_date, null,sysdate,to_date(p_last_update_date,'YYYY/MM/DD')),
        --last_updated_by = decode(p_owner, 'SEED', -1, 0),
        last_updated_by = user_id,
        last_update_login = 0
      WHERE PARAM_ID = p_PARAM_ID
      AND   userenv('LANG') IN (language, source_lang);
end translate_row;



procedure DELETE_ROW (
  r_PARAM_ID in NUMBER
) is
begin
  delete from IEU_WP_PARAM_DEFS_TL
  where PARAM_ID = r_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from IEU_WP_PARAM_DEFS_B
  where PARAM_ID = r_PARAM_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

   PROCEDURE Insert_Row (p_WP_PARAM_DEFS_rec IN WP_PARAM_DEFS_rec_type) IS

    CURSOR c IS 	SELECT 'X' FROM ieu_WP_PARAM_DEFS_b
      		WHERE PARAM_ID = p_WP_PARAM_DEFS_rec.PARAM_ID;

    l_dummy CHAR(1);

  BEGIN

   -- API body
     insert into IEU_WP_PARAM_DEFS_B
                           ( PARAM_ID,
                             CREATED_BY,
                             CREATION_DATE,
                             LAST_UPDATED_BY,
                             LAST_UPDATE_DATE,
                             LAST_UPDATE_LOGIN,
			                       PARAM_NAME,
			                       DATA_TYPE,
                             OBJECT_VERSION_NUMBER)
                      values( p_WP_PARAM_DEFS_rec.PARAM_ID,
                              FND_GLOBAL.USER_ID,
                              SYSDATE,
                              FND_GLOBAL.USER_ID,
                              SYSDATE,
                              FND_GLOBAL.LOGIN_ID,
                              p_WP_PARAM_DEFS_rec.param_name,
                              p_WP_PARAM_DEFS_rec.data_type,
                              1);
   INSERT INTO ieu_WP_PARAM_DEFS_tl (
      PARAM_ID,
      language,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      param_user_label,
      param_description,
      object_version_number,
      source_lang
    ) SELECT
      	p_WP_PARAM_DEFS_rec.PARAM_ID,
      	l.language_code,
      	p_WP_PARAM_DEFS_rec.created_by,
      	p_WP_PARAM_DEFS_rec.creation_date,
      	p_WP_PARAM_DEFS_rec.last_updated_by,
      	p_WP_PARAM_DEFS_rec.last_update_date,
      	p_WP_PARAM_DEFS_rec.last_update_login,
      	p_WP_PARAM_DEFS_rec.param_user_label,
	p_WP_PARAM_DEFS_rec.param_description,
	1,
      	USERENV('LANG')
      FROM fnd_languages l
      WHERE l.installed_flag IN ('I', 'B')
      AND NOT EXISTS
        (SELECT NULL
         FROM ieu_WP_PARAM_DEFS_tl t
         WHERE t.PARAM_ID = p_WP_PARAM_DEFS_rec.PARAM_ID
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
  delete from IEU_WP_PARAM_DEFS_TL T
  where not exists
    (select NULL
    from IEU_WP_PARAM_DEFS_B B
    where B.PARAM_ID = T.PARAM_ID
    );

  update IEU_WP_PARAM_DEFS_TL T set (
      PARAM_USER_LABEL,
      PARAM_DESCRIPTION
    ) = (select
      B.PARAM_USER_LABEL,
      B.PARAM_DESCRIPTION
    from IEU_WP_PARAM_DEFS_TL B
    where B.PARAM_ID = T.PARAM_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PARAM_ID,
      T.LANGUAGE
  ) in (select
      SUBT.PARAM_ID,
      SUBT.LANGUAGE
    from IEU_WP_PARAM_DEFS_TL SUBB, IEU_WP_PARAM_DEFS_TL SUBT
    where SUBB.PARAM_ID = SUBT.PARAM_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PARAM_USER_LABEL <> SUBT.PARAM_USER_LABEL
      or SUBB.PARAM_DESCRIPTION <> SUBT.PARAM_DESCRIPTION
      or (SUBB.PARAM_DESCRIPTION is null and SUBT.PARAM_DESCRIPTION is not null)
      or (SUBB.PARAM_DESCRIPTION is not null and SUBT.PARAM_DESCRIPTION is null)
  ));

  insert into IEU_WP_PARAM_DEFS_TL (
    PARAM_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    PARAM_USER_LABEL,
    PARAM_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PARAM_ID,
    B.OBJECT_VERSION_NUMBER,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.PARAM_USER_LABEL,
    B.PARAM_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEU_WP_PARAM_DEFS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from IEU_WP_PARAM_DEFS_TL T
    where T.PARAM_ID = B.PARAM_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

PROCEDURE Load_Seed_Row (
  p_upload_mode       IN VARCHAR2,
  p_PARAM_ID          IN NUMBER,
  p_PARAM_NAME        IN VARCHAR2,
  p_DATA_TYPE         IN VARCHAR2,
  p_param_user_label  IN VARCHAR2,
  p_param_description IN VARCHAR2,
  p_last_update_date IN VARCHAR2,
  p_owner             IN VARCHAR2
)is
user_id                 number := FND_GLOBAL.USER_ID;
begin

if (p_upload_mode = 'NLS') then
  TRANSLATE_ROW (
    P_PARAM_ID,
    P_PARAM_USER_LABEL,
    P_PARAM_DESCRIPTION,
    P_LAST_UPDATE_DATE,
    P_OWNER);
else
  LOAD_ROW (
    P_PARAM_ID,
    P_PARAM_NAME,
    P_DATA_TYPE,
    P_PARAM_USER_LABEL,
    P_PARAM_DESCRIPTION,
    P_LAST_UPDATE_DATE,
    P_OWNER);

end if;

end Load_Seed_Row;


END IEU_WP_PARAM_DEFS_SEED_PKG;

/
