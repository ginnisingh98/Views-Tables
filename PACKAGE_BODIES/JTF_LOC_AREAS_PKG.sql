--------------------------------------------------------
--  DDL for Package Body JTF_LOC_AREAS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_AREAS_PKG" as
/* $Header: jtflloab.pls 120.2 2005/08/18 23:07:42 stopiwal ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_LOCATION_AREA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_LOCATION_AREA_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_ORIG_SYSTEM_REF in VARCHAR2,
  X_ORIG_SYSTEM_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_LOCATION_AREA_CODE in VARCHAR2,
  X_LOCATION_AREA_NAME in VARCHAR2,
  X_LOCATION_AREA_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from JTF_LOC_AREAS_B
    where LOCATION_AREA_ID = X_LOCATION_AREA_ID
    ;
begin
  insert into JTF_LOC_AREAS_B (
    LOCATION_AREA_ID,
    OBJECT_VERSION_NUMBER,
    PARENT_LOCATION_AREA_ID,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    ORIG_SYSTEM_REF,
    ORIG_SYSTEM_ID,
    LOCATION_TYPE_CODE,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    LOCATION_AREA_CODE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOCATION_AREA_ID,
    X_OBJECT_VERSION_NUMBER,
    X_PARENT_LOCATION_AREA_ID,
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    X_ORIG_SYSTEM_REF,
    X_ORIG_SYSTEM_ID,
    X_LOCATION_TYPE_CODE,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_LOCATION_AREA_CODE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into JTF_LOC_AREAS_TL (
    LOCATION_AREA_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOCATION_AREA_NAME,
    LOCATION_AREA_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_LOCATION_AREA_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LOCATION_AREA_NAME,
    X_LOCATION_AREA_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from JTF_LOC_AREAS_TL T
    where T.LOCATION_AREA_ID = X_LOCATION_AREA_ID
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
  X_LOCATION_AREA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_LOCATION_AREA_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_ORIG_SYSTEM_REF in VARCHAR2,
  X_ORIG_SYSTEM_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_LOCATION_AREA_CODE in VARCHAR2,
  X_LOCATION_AREA_NAME in VARCHAR2,
  X_LOCATION_AREA_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_LOC_AREAS_B set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    PARENT_LOCATION_AREA_ID = X_PARENT_LOCATION_AREA_ID,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    ORIG_SYSTEM_REF = X_ORIG_SYSTEM_REF,
    ORIG_SYSTEM_ID = X_ORIG_SYSTEM_ID,
    LOCATION_TYPE_CODE = X_LOCATION_TYPE_CODE,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    LOCATION_AREA_CODE = X_LOCATION_AREA_CODE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOCATION_AREA_ID = X_LOCATION_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update JTF_LOC_AREAS_TL set
    LOCATION_AREA_NAME = X_LOCATION_AREA_NAME,
    LOCATION_AREA_DESCRIPTION = X_LOCATION_AREA_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where LOCATION_AREA_ID = X_LOCATION_AREA_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure UPDATE_ROW (
  X_LOCATION_AREA_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_PARENT_LOCATION_AREA_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_ORIG_SYSTEM_REF in VARCHAR2,
  X_ORIG_SYSTEM_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_LOCATION_AREA_CODE in VARCHAR2,
  X_LOCATION_AREA_NAME in VARCHAR2,
  X_LOCATION_AREA_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_RETURN_STATUS OUT NOCOPY /* file.sql.39 change */ varchar2,
  X_MSG_COUNT     OUT NOCOPY /* file.sql.39 change */ number,
  X_MSG_DATA      OUT NOCOPY /* file.sql.39 change */ varchar2
) is
CURSOR child_end_date IS
SELECT end_Date_active
FROM jtf_loc_areas_b
WHERE parent_location_area_id = x_location_area_id;

Cursor locationName is
select location_Area_name
from jtf_loc_Areas_vl
where location_Area_id = x_location_Area_id;

l_loc_area_name varchar2(240);
begin

  X_Return_Status   :=  FND_API.G_RET_STS_SUCCESS;

  if x_end_date_active is not NULL then
    for i in child_end_date loop
      if i.end_date_Active is null or i.end_Date_Active > x_end_Date_active then
         x_return_Status := FND_API.G_RET_STS_ERROR;

         -- get the location name
         Open locationName;
         Fetch locationName into l_loc_area_name;
         if (locationName%notfound) then
            raise no_data_found;
         end if;
         Close locationName;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('JTF', 'JTF_DELETE_LOC_AREA');
           FND_MESSAGE.Set_Token('AREA', l_loc_area_name, FALSE);
           FND_MSG_PUB.ADD;
         END IF;
      end if;
      exit;
    end loop;

      FND_MSG_PUB.Count_And_Get(
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
  end if;

  if   X_Return_Status  =  FND_API.G_RET_STS_SUCCESS then

    UPDATE_ROW (
      X_LOCATION_AREA_ID,
      X_OBJECT_VERSION_NUMBER ,
      X_PARENT_LOCATION_AREA_ID ,
      X_REQUEST_ID ,
      X_PROGRAM_APPLICATION_ID,
      X_PROGRAM_ID ,
      X_PROGRAM_UPDATE_DATE ,
      X_ORIG_SYSTEM_REF ,
      X_ORIG_SYSTEM_ID ,
      X_LOCATION_TYPE_CODE ,
      X_START_DATE_ACTIVE ,
      X_END_DATE_ACTIVE ,
      X_LOCATION_AREA_CODE ,
      X_LOCATION_AREA_NAME ,
      X_LOCATION_AREA_DESCRIPTION ,
      X_LAST_UPDATE_DATE ,
      X_LAST_UPDATED_BY ,
      X_LAST_UPDATE_LOGIN);
  end if;
end UPDATE_ROW;



procedure DELETE_ROW (
  X_LOCATION_AREA_ID in NUMBER
) is
begin
  delete from JTF_LOC_AREAS_TL
  where LOCATION_AREA_ID = X_LOCATION_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from JTF_LOC_AREAS_B
  where LOCATION_AREA_ID = X_LOCATION_AREA_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from JTF_LOC_AREAS_TL T
  where not exists
    (select NULL
    from JTF_LOC_AREAS_B B
    where B.LOCATION_AREA_ID = T.LOCATION_AREA_ID
    );

  update JTF_LOC_AREAS_TL T set (
      LOCATION_AREA_NAME,
      LOCATION_AREA_DESCRIPTION
    ) = (select
      B.LOCATION_AREA_NAME,
      B.LOCATION_AREA_DESCRIPTION
    from JTF_LOC_AREAS_TL B
    where B.LOCATION_AREA_ID = T.LOCATION_AREA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.LOCATION_AREA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.LOCATION_AREA_ID,
      SUBT.LANGUAGE
    from JTF_LOC_AREAS_TL SUBB, JTF_LOC_AREAS_TL SUBT
    where SUBB.LOCATION_AREA_ID = SUBT.LOCATION_AREA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.LOCATION_AREA_NAME <> SUBT.LOCATION_AREA_NAME
      or SUBB.LOCATION_AREA_DESCRIPTION <> SUBT.LOCATION_AREA_DESCRIPTION
      or (SUBB.LOCATION_AREA_DESCRIPTION is null and SUBT.LOCATION_AREA_DESCRIPTION is not null)
      or (SUBB.LOCATION_AREA_DESCRIPTION is not null and SUBT.LOCATION_AREA_DESCRIPTION is null)
  ));

  insert into JTF_LOC_AREAS_TL (
    LOCATION_AREA_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LOCATION_AREA_NAME,
    LOCATION_AREA_DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.LOCATION_AREA_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.LOCATION_AREA_NAME,
    B.LOCATION_AREA_DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from JTF_LOC_AREAS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from JTF_LOC_AREAS_TL T
    where T.LOCATION_AREA_ID = B.LOCATION_AREA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

procedure TRANSLATE_ROW(
       X_LOCATION_AREA_ID    in NUMBER
     , X_LOCATION_AREA_NAME  in VARCHAR2
     , X_LOCATION_AREA_DESCRIPTION    in VARCHAR2
     , X_OWNER   IN VARCHAR2
 ) is
 begin
    update JTF_LOC_AREAS_TL set
       location_area_name = nvl(x_location_area_name, location_area_name),
       location_area_description = nvl(x_location_area_description, location_area_description),
       source_lang = userenv('LANG'),
       last_update_date = sysdate,
       last_updated_by = decode(x_owner, 'SEED', 1, 0),
       last_update_login = 0
    where  location_area_id = x_location_area_id
    and      userenv('LANG') in (language, source_lang);
end TRANSLATE_ROW;

procedure  LOAD_ROW(
  X_LOCATION_AREA_ID in NUMBER,
  X_PARENT_LOCATION_AREA_ID in NUMBER,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_ORIG_SYSTEM_REF in VARCHAR2,
  X_ORIG_SYSTEM_ID in NUMBER,
  X_LOCATION_TYPE_CODE in VARCHAR2,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_LOCATION_AREA_CODE in VARCHAR2,
  X_LOCATION_AREA_NAME in VARCHAR2,
  X_LOCATION_AREA_DESCRIPTION in VARCHAR2,
  X_OWNER in VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_area_id   number;

cursor  c_obj_verno is
  select object_version_number
  from    JTF_LOC_AREAS_B
  where  location_area_id =  X_LOCATION_AREA_ID;

cursor c_chk_area_exists is
  select 'x'
  from   JTF_LOC_AREAS_B
  where  location_area_id = X_LOCATION_AREA_ID;

cursor c_get_areaid is
   select JTF_LOC_AREAS_B_S.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_area_exists;
 fetch c_chk_area_exists into l_dummy_char;
 if c_chk_area_exists%notfound
 then
    close c_chk_area_exists;
    if X_LOCATION_AREA_ID is null
    then
      open c_get_areaid;
      fetch c_get_areaid into l_area_id;
      close c_get_areaid;
    else
       l_area_id := X_LOCATION_AREA_ID;
    end if;
    l_obj_verno := 1;
    JTF_LOC_AREAS_PKG.INSERT_ROW(
    X_ROWID		=>   l_row_id,
    X_LOCATION_AREA_ID	 =>  l_area_id,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno,
    X_PARENT_LOCATION_AREA_ID => X_PARENT_LOCATION_AREA_ID,
    X_REQUEST_ID => X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID => X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE => X_PROGRAM_UPDATE_DATE,
    X_ORIG_SYSTEM_REF => X_ORIG_SYSTEM_REF,
    X_ORIG_SYSTEM_ID => X_ORIG_SYSTEM_ID,
    X_LOCATION_TYPE_CODE => X_LOCATION_TYPE_CODE,
    X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
    X_LOCATION_AREA_CODE => X_LOCATION_AREA_CODE,
    X_LOCATION_AREA_NAME => X_LOCATION_AREA_NAME,
    X_LOCATION_AREA_DESCRIPTION => X_LOCATION_AREA_DESCRIPTION,
    X_CREATION_DATE	=>  SYSDATE,
    X_CREATED_BY	=>  l_user_id,
    X_LAST_UPDATE_DATE	=>  SYSDATE,
    X_LAST_UPDATED_BY	=>  l_user_id,
    X_LAST_UPDATE_LOGIN	=>  0
  );
else
   close c_chk_area_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
    JTF_LOC_AREAS_PKG.UPDATE_ROW(
    X_LOCATION_AREA_ID	 =>  X_LOCATION_AREA_ID,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno + 1,
    X_PARENT_LOCATION_AREA_ID => X_PARENT_LOCATION_AREA_ID,
    X_REQUEST_ID => X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID => X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID => X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE => X_PROGRAM_UPDATE_DATE,
    X_ORIG_SYSTEM_REF => X_ORIG_SYSTEM_REF,
    X_ORIG_SYSTEM_ID => X_ORIG_SYSTEM_ID,
    X_LOCATION_TYPE_CODE => X_LOCATION_TYPE_CODE,
    X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
    X_LOCATION_AREA_CODE => X_LOCATION_AREA_CODE,
    X_LOCATION_AREA_NAME => X_LOCATION_AREA_NAME,
    X_LOCATION_AREA_DESCRIPTION => X_LOCATION_AREA_DESCRIPTION,
    X_LAST_UPDATE_DATE	=>  SYSDATE,
    X_LAST_UPDATED_BY	=>  l_user_id,
    X_LAST_UPDATE_LOGIN	=>  0
  );
end if;
END LOAD_ROW;

end JTF_LOC_AREAS_PKG;

/
