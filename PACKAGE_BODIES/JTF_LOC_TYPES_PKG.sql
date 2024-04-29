--------------------------------------------------------
--  DDL for Package Body JTF_LOC_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_TYPES_PKG" as
/* $Header: jtfllotb.pls 120.2 2005/08/18 23:07:59 stopiwal ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_LOCATION_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_LOCATION_TYPE_NAME in VARCHAR2,
  X_LOCATION_TYPE_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is
  cursor C is select ROWID from JTF_LOC_TYPES_B
    where LOCATION_TYPE_ID = X_LOCATION_TYPE_ID
    ;
begin
  insert into JTF_LOC_TYPES_B (
    LOCATION_TYPE_ID,
    OBJECT_VERSION_NUMBER,
    LOCATION_TYPE_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOCATION_TYPE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_LOCATION_TYPE_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_LOC_TYPES_TL (
    LOCATION_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOCATION_TYPE_NAME,
    LOCATION_TYPE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOCATION_TYPE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LOCATION_TYPE_NAME,
    X_LOCATION_TYPE_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_LOC_TYPES_TL T
    where T.LOCATION_TYPE_ID = X_LOCATION_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure UPDATE_ROW (
  X_LOCATION_TYPE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_LOCATION_TYPE_NAME in VARCHAR2,
  X_LOCATION_TYPE_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_LOC_TYPES_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    LOCATION_TYPE_CODE = X_LOCATION_TYPE_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOCATION_TYPE_ID = X_LOCATION_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_LOC_TYPES_TL set
    LOCATION_TYPE_NAME = X_LOCATION_TYPE_NAME,
    LOCATION_TYPE_DESCRIPTION = X_LOCATION_TYPE_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOCATION_TYPE_ID = X_LOCATION_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure ADD_LANGUAGE
is
begin
  delete from JTF_LOC_TYPES_TL T
  where not exists
    (select NULL
    from JTF_LOC_TYPES_B B
    where B.LOCATION_TYPE_ID = T.LOCATION_TYPE_ID
    );

  update JTF_LOC_TYPES_TL T set (
      LOCATION_TYPE_NAME,
      LOCATION_TYPE_DESCRIPTION
    ) = (select
      B.LOCATION_TYPE_NAME,
      B.LOCATION_TYPE_DESCRIPTION
    from JTF_LOC_TYPES_TL B
    where B.LOCATION_TYPE_ID = T.LOCATION_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOCATION_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LOCATION_TYPE_ID,
      SUBT.LANGUAGE
    from JTF_LOC_TYPES_TL SUBB, JTF_LOC_TYPES_TL SUBT
    where SUBB.LOCATION_TYPE_ID = SUBT.LOCATION_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOCATION_TYPE_NAME <> SUBT.LOCATION_TYPE_NAME
      or SUBB.LOCATION_TYPE_DESCRIPTION <> SUBT.LOCATION_TYPE_DESCRIPTION
      or (SUBB.LOCATION_TYPE_DESCRIPTION is null and SUBT.LOCATION_TYPE_DESCRIPTION is not null)
      or (SUBB.LOCATION_TYPE_DESCRIPTION is not null and SUBT.LOCATION_TYPE_DESCRIPTION is null)
  ));

  insert into JTF_LOC_TYPES_TL (
    LOCATION_TYPE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOCATION_TYPE_NAME,
    LOCATION_TYPE_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOCATION_TYPE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LOCATION_TYPE_NAME,
    B.LOCATION_TYPE_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_LOC_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_LOC_TYPES_TL T
    where T.LOCATION_TYPE_ID = B.LOCATION_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
       X_LOCATION_TYPE_ID    IN NUMBER
     , X_LOCATION_TYPE_NAME  IN VARCHAR2
     , X_LOCATION_TYPE_DESCRIPTION    IN VARCHAR2
     , X_OWNER   IN VARCHAR2
 ) is
 begin
    update JTF_LOC_TYPES_TL set
       location_type_name = nvl(x_location_type_name, location_type_name),
       location_type_description = nvl(X_LOCATION_TYPE_DESCRIPTION, location_type_description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  location_type_id = x_location_type_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure  LOAD_ROW(
  X_LOCATION_TYPE_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_LOCATION_TYPE_NAME in VARCHAR2,
  X_LOCATION_TYPE_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_type_id   number;

cursor  c_obj_verno is
  select object_version_number
  from    JTF_LOC_TYPES_B
  where  LOCATION_TYPE_ID =  X_LOCATION_TYPE_ID;

cursor c_chk_type_exists is
  select 'x'
  from   JTF_LOC_TYPES_B
  where  LOCATION_TYPE_ID = X_LOCATION_TYPE_ID;

cursor c_get_typeid is
   select JTF_LOC_TYPES_B_S.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_type_exists;
 fetch c_chk_type_exists into l_dummy_char;
 if c_chk_type_exists%notfound
 then
    close c_chk_type_exists;
    if x_location_type_id is null
    then
      open c_get_typeid;
      fetch c_get_typeid into l_type_id;
      close c_get_typeid;
    else
       l_type_id := X_LOCATION_TYPE_ID;
    end if;
    l_obj_verno := 1;
    JTF_LOC_TYPES_PKG.INSERT_ROW(
    X_ROWID		=>   l_row_id,
    X_LOCATION_TYPE_ID	 =>  l_type_id,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno,
    X_LOCATION_TYPE_CODE => X_LOCATION_TYPE_CODE,
    X_LOCATION_TYPE_NAME => X_LOCATION_TYPE_NAME,
    X_LOCATION_TYPE_DESCRIPTION => X_LOCATION_TYPE_DESCRIPTION,
    X_CREATION_DATE	=>  SYSDATE,
    X_CREATED_BY	=>  l_user_id,
    X_LAST_UPDATE_DATE	=>  SYSDATE,
    X_LAST_UPDATED_BY	=>  l_user_id,
    X_LAST_UPDATE_LOGIN	=>  0
  );
else
   close c_chk_type_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
    JTF_LOC_TYPES_PKG.UPDATE_ROW(
    X_LOCATION_TYPE_ID	 =>  X_LOCATION_TYPE_ID,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno + 1,
    X_LOCATION_TYPE_CODE => X_LOCATION_TYPE_CODE,
    X_LOCATION_TYPE_NAME => X_LOCATION_TYPE_NAME,
    X_LOCATION_TYPE_DESCRIPTION => X_LOCATION_TYPE_DESCRIPTION,
    X_LAST_UPDATE_DATE	=>  SYSDATE,
    X_LAST_UPDATED_BY	=>  l_user_id,
    X_LAST_UPDATE_LOGIN	=>  0
  );
end if;
END LOAD_ROW;

end JTF_LOC_TYPES_PKG;

/
