--------------------------------------------------------
--  DDL for Package Body AMS_DS_TCA_ENTITY_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DS_TCA_ENTITY_COLS_PKG" as
/* $Header: amsltecb.pls 120.0 2005/05/31 13:59:07 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENTITY_COLUMN_ID in NUMBER,
  X_SOURCE_CATEGORY in VARCHAR2,
  X_ENTITY_ID in NUMBER,
  X_COLUMN_NAME in VARCHAR2,
  X_DATATYPE in VARCHAR2,
  X_FIELD_SIZE in VARCHAR2,
  X_RECORD_STUCTURE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_DS_TCA_ENTITY_COLS
    where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID
    ;
begin
  insert into AMS_DS_TCA_ENTITY_COLS (
    SOURCE_CATEGORY,
    ENTITY_COLUMN_ID,
    ENTITY_ID,
    COLUMN_NAME,
    DATATYPE,
    FIELD_SIZE,
    RECORD_STUCTURE,
    ENABLED_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_SOURCE_CATEGORY,
    X_ENTITY_COLUMN_ID,
    X_ENTITY_ID,
    X_COLUMN_NAME,
    X_DATATYPE,
    X_FIELD_SIZE,
    X_RECORD_STUCTURE,
    X_ENABLED_FLAG,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_DS_TCA_ENTITY_COLS_TL (
    LAST_UPDATED_BY,
    ENTITY_COLUMN_ID,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LAST_UPDATED_BY,
    X_ENTITY_COLUMN_ID,
    X_LAST_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_DS_TCA_ENTITY_COLS_TL T
    where T.ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ENTITY_COLUMN_ID in NUMBER,
  X_SOURCE_CATEGORY in VARCHAR2,
  X_ENTITY_ID in NUMBER,
  X_COLUMN_NAME in VARCHAR2,
  X_DATATYPE in VARCHAR2,
  X_FIELD_SIZE in VARCHAR2,
  X_RECORD_STUCTURE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      SOURCE_CATEGORY,
      ENTITY_ID,
      COLUMN_NAME,
      DATATYPE,
      FIELD_SIZE,
      RECORD_STUCTURE,
      ENABLED_FLAG
    from AMS_DS_TCA_ENTITY_COLS
    where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID
    for update of ENTITY_COLUMN_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_DS_TCA_ENTITY_COLS_TL
    where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ENTITY_COLUMN_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.SOURCE_CATEGORY = X_SOURCE_CATEGORY)
           OR ((recinfo.SOURCE_CATEGORY is null) AND (X_SOURCE_CATEGORY is null)))
      AND (recinfo.ENTITY_ID = X_ENTITY_ID)
      AND (recinfo.COLUMN_NAME = X_COLUMN_NAME)
      AND ((recinfo.DATATYPE = X_DATATYPE)
           OR ((recinfo.DATATYPE is null) AND (X_DATATYPE is null)))
      AND ((recinfo.FIELD_SIZE = X_FIELD_SIZE)
           OR ((recinfo.FIELD_SIZE is null) AND (X_FIELD_SIZE is null)))
      AND ((recinfo.RECORD_STUCTURE = X_RECORD_STUCTURE)
           OR ((recinfo.RECORD_STUCTURE is null) AND (X_RECORD_STUCTURE is null)))
      AND ((recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
           OR ((recinfo.ENABLED_FLAG is null) AND (X_ENABLED_FLAG is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
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

procedure UPDATE_ROW (
  X_ENTITY_COLUMN_ID in NUMBER,
  X_SOURCE_CATEGORY in VARCHAR2,
  X_ENTITY_ID in NUMBER,
  X_COLUMN_NAME in VARCHAR2,
  X_DATATYPE in VARCHAR2,
  X_FIELD_SIZE in VARCHAR2,
  X_RECORD_STUCTURE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_DS_TCA_ENTITY_COLS set
    SOURCE_CATEGORY = X_SOURCE_CATEGORY,
    ENTITY_ID = X_ENTITY_ID,
    COLUMN_NAME = X_COLUMN_NAME,
    DATATYPE = X_DATATYPE,
    FIELD_SIZE = X_FIELD_SIZE,
    RECORD_STUCTURE = X_RECORD_STUCTURE,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_DS_TCA_ENTITY_COLS_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_ENTITY_COLUMN_ID in NUMBER
) is
begin
  delete from AMS_DS_TCA_ENTITY_COLS_TL
  where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_DS_TCA_ENTITY_COLS
  where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_ENTITY_COLUMN_ID in NUMBER,
  X_SOURCE_CATEGORY in VARCHAR2,
  X_ENTITY_ID in NUMBER,
  X_COLUMN_NAME in VARCHAR2,
  X_DATATYPE in VARCHAR2,
  X_FIELD_SIZE in VARCHAR2,
  X_RECORD_STUCTURE in VARCHAR2,
  X_ENABLED_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2,
  x_custom_mode IN VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
  ) IS

l_user_id number := 0;
l_colmap_id  number;
l_obj_verno number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_db_luby_id   number;

 cursor c_chk_col_exists is
  select 'x'
  from   AMS_DS_TCA_ENTITY_COLS
  where  ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID;

  cursor c_get_col_mapping_id is
  select AMS_DS_TCA_ENTITY_COLS_s.nextval
  from dual;

  cursor c_get_luby is
          select last_updated_by
          from AMS_DS_TCA_ENTITY_COLS
          where ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID;

BEGIN
    if X_OWNER = 'SEED' then
        l_user_id := 1;
    elsif X_OWNER = 'ORACLE' then
     	l_user_id := 2;
    elsif X_OWNER = 'SYSADMIN' then
    	l_user_id := 0;

    end if;
    open c_chk_col_exists;
    fetch c_chk_col_exists into l_dummy_char;
    if c_chk_col_exists%notfound
    then
        close c_chk_col_exists;
        if X_ENTITY_COLUMN_ID is null
        then
            open c_get_col_mapping_id;
            fetch c_get_col_mapping_id into l_colmap_id;
            close c_get_col_mapping_id;
        else
            l_colmap_id := X_ENTITY_COLUMN_ID;
        end if;
        AMS_DS_TCA_ENTITY_COLS_PKG.INSERT_ROW (
                        X_ROWID              => l_row_id,
			X_ENTITY_COLUMN_ID   => l_colmap_id,
			X_SOURCE_CATEGORY    => X_SOURCE_CATEGORY,
                        X_ENTITY_ID          => X_ENTITY_ID,
			X_COLUMN_NAME        => X_COLUMN_NAME,
                        X_DATATYPE           => X_DATATYPE,
			X_FIELD_SIZE	     => X_FIELD_SIZE,
			X_RECORD_STUCTURE    => X_RECORD_STUCTURE,
			X_ENABLED_FLAG       => X_ENABLED_FLAG,
                        X_DESCRIPTION        => X_DESCRIPTION,
                        X_CREATION_DATE      => X_CREATION_DATE, -- sysdate,
                        X_CREATED_BY         => l_user_id,
                        X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE, -- sysdate,
                        X_LAST_UPDATED_BY    => l_user_id,
                        X_LAST_UPDATE_LOGIN  => 1);

    else
        close c_chk_col_exists;

         OPEN c_get_luby;
         FETCH c_get_luby INTO  l_db_luby_id;
         CLOSE c_get_luby;


	 if (l_db_luby_id IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
   	then


        l_colmap_id := X_ENTITY_COLUMN_ID ;
        AMS_DS_TCA_ENTITY_COLS_PKG.UPDATE_ROW (
			X_ENTITY_COLUMN_ID   => X_ENTITY_COLUMN_ID,
			X_SOURCE_CATEGORY    => X_SOURCE_CATEGORY,
                        X_ENTITY_ID          => X_ENTITY_ID,
			X_COLUMN_NAME        => X_COLUMN_NAME,
                        X_DATATYPE           => X_DATATYPE,
			X_FIELD_SIZE	     => X_FIELD_SIZE,
			X_RECORD_STUCTURE    => X_RECORD_STUCTURE,
			X_ENABLED_FLAG       => X_ENABLED_FLAG,
                        X_DESCRIPTION        => X_DESCRIPTION,
                        X_LAST_UPDATE_DATE   => X_LAST_UPDATE_DATE, -- sysdate,
                        X_LAST_UPDATED_BY    => l_user_id,
                        X_LAST_UPDATE_LOGIN  => 1
                        );

        end if;
    end if;

end LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_DS_TCA_ENTITY_COLS_TL T
  where not exists
    (select NULL
    from AMS_DS_TCA_ENTITY_COLS B
    where B.ENTITY_COLUMN_ID= T.ENTITY_COLUMN_ID
    );

  update AMS_DS_TCA_ENTITY_COLS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from AMS_DS_TCA_ENTITY_COLS_TL B
    where B.ENTITY_COLUMN_ID= T.ENTITY_COLUMN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ENTITY_COLUMN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.ENTITY_COLUMN_ID,
      SUBT.LANGUAGE
    from AMS_DS_TCA_ENTITY_COLS_TL SUBB, AMS_DS_TCA_ENTITY_COLS_TL SUBT
    where SUBB.ENTITY_COLUMN_ID= SUBT.ENTITY_COLUMN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (
      SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_DS_TCA_ENTITY_COLS_TL (
    LAST_UPDATED_BY,
    ENTITY_COLUMN_ID,
    LAST_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LAST_UPDATED_BY,
    B.ENTITY_COLUMN_ID,
    B.LAST_UPDATE_DATE,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_LANGUAGES L, AMS_DS_TCA_ENTITY_COLS_TL  B
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_DS_TCA_ENTITY_COLS_TL T
    where T.ENTITY_COLUMN_ID = B.ENTITY_COLUMN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW (
  X_ENTITY_COLUMN_ID        IN NUMBER,
  X_DESCRIPTION             IN VARCHAR2,
  X_OWNER                   IN VARCHAR2,
  x_custom_mode 	    IN VARCHAR2
) IS

 cursor c_last_updated_by is
       select last_updated_by
       from AMS_DS_TCA_ENTITY_COLS_TL
       where ENTITY_COLUMN_ID = x_ENTITY_COLUMN_ID
       and  USERENV('LANG') = LANGUAGE;

       l_luby number; --last updated by

BEGIN
    -- only UPDATE rows that have not been altered by user
   open c_last_updated_by;
   fetch c_last_updated_by into l_luby;
   close c_last_updated_by;

   if (l_luby IN (0, 1, 2) or NVL(x_custom_mode, 'PRESERVE')='FORCE')
   then

    UPDATE AMS_DS_TCA_ENTITY_COLS_TL
    SET
        DESCRIPTION = NVL(X_DESCRIPTION, DESCRIPTION),
        SOURCE_LANG = userenv('LANG'),
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATED_BY = decode(x_owner, 'SEED', 1,  'ORACLE', 2, 'SYSADMIN', 0, -1),
        LAST_UPDATE_LOGIN = 0
    WHERE ENTITY_COLUMN_ID = X_ENTITY_COLUMN_ID
    AND   userenv('LANG') IN (language, source_lang);

    end if;
END TRANSLATE_ROW;

end AMS_DS_TCA_ENTITY_COLS_PKG;

/
