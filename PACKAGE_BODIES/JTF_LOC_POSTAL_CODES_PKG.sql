--------------------------------------------------------
--  DDL for Package Body JTF_LOC_POSTAL_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_POSTAL_CODES_PKG" as
/* $Header: jtfllopb.pls 120.2 2005/08/18 23:07:51 stopiwal ship $ */
procedure INSERT_ROW (
  X_ROWID IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  X_LOCATION_POSTAL_CODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REF in VARCHAR2,
  X_ORIG_SYSTEM_ID in NUMBER,
  X_LOCATION_AREA_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_POSTAL_CODE_START in VARCHAR2,
  X_POSTAL_CODE_END in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER) is
  cursor c is select ROWID from JTF_LOC_POSTAL_CODES
    where LOCATION_POSTAL_CODE_ID = X_LOCATION_POSTAL_CODE_ID
    ;
begin
  insert into JTF_LOC_POSTAL_CODES (
    LOCATION_POSTAL_CODE_ID,
    OBJECT_VERSION_NUMBER,
    ORIG_SYSTEM_REF,
    ORIG_SYSTEM_ID,
    LOCATION_AREA_ID,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    POSTAL_CODE_START,
    POSTAL_CODE_END,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_LOCATION_POSTAL_CODE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_ORIG_SYSTEM_REF,
    X_ORIG_SYSTEM_ID,
    X_LOCATION_AREA_ID,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_POSTAL_CODE_START,
    X_POSTAL_CODE_END,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure UPDATE_ROW (
  X_LOCATION_POSTAL_CODE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_ORIG_SYSTEM_REF in VARCHAR2,
  X_ORIG_SYSTEM_ID in NUMBER,
  X_LOCATION_AREA_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_POSTAL_CODE_START in VARCHAR2,
  X_POSTAL_CODE_END in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update JTF_LOC_POSTAL_CODES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    ORIG_SYSTEM_REF = X_ORIG_SYSTEM_REF,
    ORIG_SYSTEM_ID = X_ORIG_SYSTEM_ID,
    LOCATION_AREA_ID = X_LOCATION_AREA_ID,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    POSTAL_CODE_START = X_POSTAL_CODE_START,
    POSTAL_CODE_END = X_POSTAL_CODE_END,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where LOCATION_POSTAL_CODE_ID = X_LOCATION_POSTAL_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_LOCATION_POSTAL_CODE_ID in NUMBER
) is
begin
  delete from JTF_LOC_POSTAL_CODES
  where LOCATION_POSTAL_CODE_ID = X_LOCATION_POSTAL_CODE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure  LOAD_ROW(
  X_LOCATION_POSTAL_CODE_ID in NUMBER,
  X_ORIG_SYSTEM_REF in VARCHAR2,
  X_ORIG_SYSTEM_ID in NUMBER,
  X_LOCATION_AREA_ID in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_POSTAL_CODE_START in VARCHAR2,
  X_POSTAL_CODE_END in VARCHAR2,
  X_OWNER in VARCHAR2
) is

l_user_id   number := 0;
l_obj_verno  number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_code_id   number;

cursor  c_obj_verno is
  select object_version_number
  from    JTF_LOC_POSTAL_CODES
  where  LOCATION_POSTAL_CODE_ID =  X_LOCATION_POSTAL_CODE_ID;

cursor c_chk_code_exists is
  select 'x'
  from   JTF_LOC_POSTAL_CODES
  where  LOCATION_POSTAL_CODE_ID = X_LOCATION_POSTAL_CODE_ID;

cursor c_get_codeid is
   select JTF_LOC_POSTAL_CODES_S.nextval
   from dual;

BEGIN

  if X_OWNER = 'SEED' then
     l_user_id := 1;
 end if;

 open c_chk_code_exists;
 fetch c_chk_code_exists into l_dummy_char;
 if c_chk_code_exists%notfound
 then
    close c_chk_code_exists;
    if X_LOCATION_POSTAL_CODE_ID is null
    then
      open c_get_codeid;
      fetch c_get_codeid into l_code_id;
      close c_get_codeid;
    else
       l_code_id := X_LOCATION_POSTAL_CODE_ID;
    end if;
    l_obj_verno := 1;
    JTF_LOC_POSTAL_CODES_PKG.INSERT_ROW(
    X_ROWID		=>   l_row_id,
    X_LOCATION_POSTAL_CODE_ID	 =>  l_code_id,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno,
    X_ORIG_SYSTEM_REF => X_ORIG_SYSTEM_REF,
    X_ORIG_SYSTEM_ID => X_ORIG_SYSTEM_ID,
    X_LOCATION_AREA_ID => X_LOCATION_AREA_ID,
    X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
    X_POSTAL_CODE_START => X_POSTAL_CODE_START,
    X_POSTAL_CODE_END => X_POSTAL_CODE_END,
    X_CREATION_DATE	=>  SYSDATE,
    X_CREATED_BY	=>  l_user_id,
    X_LAST_UPDATE_DATE	=>  SYSDATE,
    X_LAST_UPDATED_BY	=>  l_user_id,
    X_LAST_UPDATE_LOGIN	=>  0
  );
else
   close c_chk_code_exists;
   open c_obj_verno;
   fetch c_obj_verno into l_obj_verno;
   close c_obj_verno;
    JTF_LOC_POSTAL_CODES_PKG.UPDATE_ROW(
    X_LOCATION_POSTAL_CODE_ID	 =>  X_LOCATION_POSTAL_CODE_ID,
    X_OBJECT_VERSION_NUMBER  => l_obj_verno + 1,
    X_ORIG_SYSTEM_REF => X_ORIG_SYSTEM_REF,
    X_ORIG_SYSTEM_ID => X_ORIG_SYSTEM_ID,
    X_LOCATION_AREA_ID => X_LOCATION_AREA_ID,
    X_START_DATE_ACTIVE => X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE => X_END_DATE_ACTIVE,
    X_POSTAL_CODE_START => X_POSTAL_CODE_START,
    X_POSTAL_CODE_END => X_POSTAL_CODE_END,
    X_LAST_UPDATE_DATE	=>  SYSDATE,
    X_LAST_UPDATED_BY	=>  l_user_id,
    X_LAST_UPDATE_LOGIN	=>  0
  );
end if;
END LOAD_ROW;

end JTF_LOC_POSTAL_CODES_PKG;

/
