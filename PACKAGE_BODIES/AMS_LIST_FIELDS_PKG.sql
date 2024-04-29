--------------------------------------------------------
--  DDL for Package Body AMS_LIST_FIELDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LIST_FIELDS_PKG" AS
/* $Header: amsllfdb.pls 115.3 2000/01/09 17:37:58 pkm ship    $ */
procedure INSERT_ROW (
  X_ROWID in out VARCHAR2,
  X_LIST_FIELD_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_COLUMN_DATA_TYPE in VARCHAR2,
  X_COLUMN_DATA_LENGTH in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LIST_TYPE_FIELD_APPLY_ON in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from AMS_LIST_FIELDS_B
    where LIST_FIELD_ID = X_LIST_FIELD_ID
    ;
begin
  insert into AMS_LIST_FIELDS_B (
    LIST_FIELD_ID,
    OBJECT_VERSION_NUMBER,
    FIELD_TABLE_NAME,
    FIELD_COLUMN_NAME,
    COLUMN_DATA_TYPE,
    COLUMN_DATA_LENGTH,
    ENABLED_FLAG,
    LIST_TYPE_FIELD_APPLY_ON,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LIST_FIELD_ID,
    X_OBJECT_VERSION_NUMBER,
    X_FIELD_TABLE_NAME,
    X_FIELD_COLUMN_NAME,
    X_COLUMN_DATA_TYPE,
    X_COLUMN_DATA_LENGTH,
    X_ENABLED_FLAG,
    X_LIST_TYPE_FIELD_APPLY_ON,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_LIST_FIELDS_TL (
    LIST_FIELD_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LIST_FIELD_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
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
    from AMS_LIST_FIELDS_TL T
    where T.LIST_FIELD_ID = X_LIST_FIELD_ID
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
  X_LIST_FIELD_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_COLUMN_DATA_TYPE in VARCHAR2,
  X_COLUMN_DATA_LENGTH in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LIST_TYPE_FIELD_APPLY_ON in VARCHAR2,
  X_DESCRIPTION in VARCHAR2
) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      FIELD_TABLE_NAME,
      FIELD_COLUMN_NAME,
      COLUMN_DATA_TYPE,
      COLUMN_DATA_LENGTH,
      ENABLED_FLAG,
      LIST_TYPE_FIELD_APPLY_ON
    from AMS_LIST_FIELDS_B
    where LIST_FIELD_ID = X_LIST_FIELD_ID
    for update of LIST_FIELD_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_LIST_FIELDS_TL
    where LIST_FIELD_ID = X_LIST_FIELD_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of LIST_FIELD_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND (recinfo.FIELD_TABLE_NAME = X_FIELD_TABLE_NAME)
      AND (recinfo.FIELD_COLUMN_NAME = X_FIELD_COLUMN_NAME)
      AND (recinfo.COLUMN_DATA_TYPE = X_COLUMN_DATA_TYPE)
      AND (recinfo.COLUMN_DATA_LENGTH = X_COLUMN_DATA_LENGTH)
      AND (recinfo.ENABLED_FLAG = X_ENABLED_FLAG)
      AND ((recinfo.LIST_TYPE_FIELD_APPLY_ON = X_LIST_TYPE_FIELD_APPLY_ON)
           OR ((recinfo.LIST_TYPE_FIELD_APPLY_ON is null) AND (X_LIST_TYPE_FIELD_APPLY_ON is null)))
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
  X_LIST_FIELD_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_COLUMN_DATA_TYPE in VARCHAR2,
  X_COLUMN_DATA_LENGTH in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LIST_TYPE_FIELD_APPLY_ON in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_LIST_FIELDS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    FIELD_TABLE_NAME = X_FIELD_TABLE_NAME,
    FIELD_COLUMN_NAME = X_FIELD_COLUMN_NAME,
    COLUMN_DATA_TYPE = X_COLUMN_DATA_TYPE,
    COLUMN_DATA_LENGTH = X_COLUMN_DATA_LENGTH,
    ENABLED_FLAG = X_ENABLED_FLAG,
    LIST_TYPE_FIELD_APPLY_ON = X_LIST_TYPE_FIELD_APPLY_ON,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LIST_FIELD_ID = X_LIST_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_LIST_FIELDS_TL set
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LIST_FIELD_ID = X_LIST_FIELD_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LIST_FIELD_ID in NUMBER
) is
begin
  delete from AMS_LIST_FIELDS_TL
  where LIST_FIELD_ID = X_LIST_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_LIST_FIELDS_B
  where LIST_FIELD_ID = X_LIST_FIELD_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_LIST_FIELDS_TL T
  where not exists
    (select NULL
    from AMS_LIST_FIELDS_B B
    where B.LIST_FIELD_ID = T.LIST_FIELD_ID
    );

  update AMS_LIST_FIELDS_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from AMS_LIST_FIELDS_TL B
    where B.LIST_FIELD_ID = T.LIST_FIELD_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LIST_FIELD_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LIST_FIELD_ID,
      SUBT.LANGUAGE
    from AMS_LIST_FIELDS_TL SUBB, AMS_LIST_FIELDS_TL SUBT
    where SUBB.LIST_FIELD_ID = SUBT.LIST_FIELD_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into AMS_LIST_FIELDS_TL (
    LIST_FIELD_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LIST_FIELD_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_LIST_FIELDS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_LIST_FIELDS_TL T
    where T.LIST_FIELD_ID = B.LIST_FIELD_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
       x_list_field_id    in NUMBER
     , x_description    in VARCHAR2
     , x_owner   in VARCHAR2
 )
IS
BEGIN
    update ams_list_fields_tl set
       description = nvl(x_description, description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  list_field_id = x_list_field_id
    and      userenv('LANG') in (language, source_lang);
END Translate_Row;

PROCEDURE Load_Row (
  X_LIST_FIELD_ID in NUMBER,
  X_FIELD_TABLE_NAME in VARCHAR2,
  X_FIELD_COLUMN_NAME in VARCHAR2,
  X_COLUMN_DATA_TYPE in VARCHAR2,
  X_COLUMN_DATA_LENGTH in NUMBER,
  X_ENABLED_FLAG in VARCHAR2,
  X_LIST_TYPE_FIELD_APPLY_ON in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  x_OWNER IN VARCHAR2
)
IS
   l_user_id   number := 0;
   l_obj_verno  number;
   l_dummy_char  varchar2(1);
   l_row_id    varchar2(100);
   l_list_field_id   number;

   CURSOR  c_obj_verno IS
     SELECT object_version_number
     FROM   ams_list_fields_b
     WHERE  list_field_id =  X_LIST_FIELD_ID;

   CURSOR c_chk_lfd_exists is
     SELECT 'x'
     FROM   ams_list_fields_b
     WHERE  list_field_id = x_list_field_id;

   CURSOR c_get_lfd_id is
      SELECT ams_list_fields_b_s.NEXTVAL
      FROM DUAL;
BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   OPEN c_chk_lfd_exists;
   FETCH c_chk_lfd_exists INTO l_dummy_char;
   IF c_chk_lfd_exists%notfound THEN
      CLOSE c_chk_lfd_exists;
	 IF x_list_field_id IS NULL THEN
         OPEN c_get_lfd_id;
         FETCH c_get_lfd_id INTO l_list_field_id;
         CLOSE c_get_lfd_id;
      ELSE
	    l_list_field_id := x_list_field_id;
	 END IF;

      l_obj_verno := 1;

      AMS_List_Fields_PKG.Insert_Row (
         X_ROWID                 => l_row_id,
         X_LIST_FIELD_ID         => l_list_field_id,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_FIELD_TABLE_NAME      => x_field_table_name,
         X_FIELD_COLUMN_NAME     => x_field_column_name,
         X_COLUMN_DATA_TYPE      => x_column_data_type,
         X_COLUMN_DATA_LENGTH    => x_column_data_length,
         X_ENABLED_FLAG          => x_enabled_flag,
         X_LIST_TYPE_FIELD_APPLY_ON => x_list_type_field_apply_on,
         X_DESCRIPTION           => x_description,
         X_CREATION_DATE		   =>  SYSDATE,
         X_CREATED_BY			   =>  l_user_id,
         X_LAST_UPDATE_DATE	   =>  SYSDATE,
         X_LAST_UPDATED_BY		   =>  l_user_id,
         X_LAST_UPDATE_LOGIN	   =>  0
      );
   ELSE
      CLOSE c_chk_lfd_exists;
      OPEN c_obj_verno;
      FETCH c_obj_verno INTO l_obj_verno;
      CLOSE c_obj_verno;

      AMS_List_Fields_PKG.Update_Row (
         x_list_field_id         => x_list_field_id,
         x_object_version_number => l_obj_verno,
         x_field_table_name      => x_field_table_name,
         x_field_column_name     => x_field_column_name,
         x_column_data_type      => x_column_data_type,
         x_column_data_length    => x_column_data_length,
         x_enabled_flag          => x_enabled_flag,
         x_list_type_field_apply_on => x_list_type_field_apply_on,
         x_description           => x_description,
         x_last_update_date      => SYSDATE,
         x_last_updated_by       => l_user_id,
         x_last_update_login     => 0
      );
   END IF;
END Load_Row;

end AMS_LIST_FIELDS_PKG;

/
