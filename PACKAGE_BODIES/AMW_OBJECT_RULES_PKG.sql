--------------------------------------------------------
--  DDL for Package Body AMW_OBJECT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_OBJECT_RULES_PKG" as
/* $Header: amwlobrb.pls 120.0 2005/05/31 20:57:32 appldev noship $ */
procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  cursor C is select ROWID from AMW_OBJECT_RULES
    where OBJECT_RULE_ID = X_OBJECT_RULE_ID
    ;
begin
  insert into AMW_OBJECT_RULES (
      OBJECT_RULE_ID,
    OBJECT_VERSION_NUMBER,
    APPROVAL_TYPE,
    RULE_USED_BY,
    OBJECT_TYPE,
    RULE_TYPE,
    API_TYPE,
    PACKAGE_NAME,
    PROCEDURE_NAME,
    SEEDED_FLAG,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_RULE_ID,
    X_OBJECT_VERSION_NUMBER,
    X_APPROVAL_TYPE,
    X_RULE_USED_BY,
    X_OBJECT_TYPE,
    X_RULE_TYPE,
    X_API_TYPE,
    X_PACKAGE_NAME,
    X_PROCEDURE_NAME,
    X_SEEDED_FLAG,
    X_APPLICATION_ID,
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

procedure LOCK_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER
  ) is
  cursor c is select
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID,
      APPROVAL_TYPE,
      RULE_USED_BY,
      OBJECT_TYPE,
      RULE_TYPE,
      API_TYPE,
      PACKAGE_NAME,
      PROCEDURE_NAME,
      SEEDED_FLAG,
      APPLICATION_ID
    from AMW_OBJECT_RULES
    where OBJECT_RULE_ID = X_OBJECT_RULE_ID
    for update of OBJECT_RULE_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if(((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      AND ((recinfo.APPROVAL_TYPE = X_APPROVAL_TYPE)
           OR ((recinfo.APPROVAL_TYPE is null) AND (X_APPROVAL_TYPE is null)))
      AND ((recinfo.RULE_USED_BY = X_RULE_USED_BY)
           OR ((recinfo.RULE_USED_BY is null) AND (X_RULE_USED_BY is null)))
      AND ((recinfo.OBJECT_TYPE = X_OBJECT_TYPE)
           OR ((recinfo.OBJECT_TYPE is null) AND (X_OBJECT_TYPE is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.RULE_TYPE = X_RULE_TYPE)
           OR ((recinfo.RULE_TYPE is null) AND (X_RULE_TYPE is null)))
      AND ((recinfo.API_TYPE = X_API_TYPE)
           OR ((recinfo.API_TYPE is null) AND (X_API_TYPE is null)))
      AND ((recinfo.PACKAGE_NAME = X_PACKAGE_NAME)
           OR ((recinfo.PACKAGE_NAME is null) AND (X_PACKAGE_NAME is null)))
      AND ((recinfo.PROCEDURE_NAME = X_PROCEDURE_NAME)
           OR ((recinfo.PROCEDURE_NAME is null) AND (X_PROCEDURE_NAME is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMW_OBJECT_RULES set
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    APPROVAL_TYPE = X_APPROVAL_TYPE,
    RULE_USED_BY = X_RULE_USED_BY,
    OBJECT_TYPE = X_OBJECT_TYPE,
    RULE_TYPE = X_RULE_TYPE,
    API_TYPE = X_API_TYPE,
    PACKAGE_NAME = X_PACKAGE_NAME,
    PROCEDURE_NAME = X_PROCEDURE_NAME,
    SEEDED_FLAG = X_SEEDED_FLAG,
    APPLICATION_ID = X_APPLICATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_RULE_ID = X_OBJECT_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_RULE_ID in NUMBER
) is
begin

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMW_OBJECT_RULES
  where OBJECT_RULE_ID = X_OBJECT_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;


procedure LOAD_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_OBJECT_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OWNER IN VARCHAR2
 )is
l_user_id number := 0;
l_objrule_id  number;
l_obj_verno number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

  cursor  c_obj_verno is
 select object_version_number
from    AMW_OBJECT_RULES
  where  OBJECT_RULE_ID =  X_OBJECT_RULE_ID;

  cursor c_chk_objrule_exists is
  select 'x'
  from    AMW_OBJECT_RULES
  where  OBJECT_RULE_ID =  X_OBJECT_RULE_ID;

  cursor c_get_objrule_id is
  select AMW_OBJECT_RULES_S.nextval
  from dual;

BEGIN
   if X_OWNER = 'SEED' then
      l_user_id := 1;
   end if;

   open c_chk_objrule_exists;
   fetch c_chk_objrule_exists into l_dummy_char;
   if c_chk_objrule_exists%notfound
   then
      close c_chk_objrule_exists;
      if X_OBJECT_RULE_ID is null
      then
         open c_get_objrule_id;
         fetch c_get_objrule_id into l_objrule_id;
         close c_get_objrule_id;
      else
         l_objrule_id := X_OBJECT_RULE_ID;
      end if;

      AMW_OBJECT_RULES_PKG.INSERT_ROW (
         X_ROWID => l_row_id,
         X_OBJECT_RULE_ID => l_objrule_id,
         X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
         X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
         X_APPROVAL_TYPE => X_APPROVAL_TYPE,
         X_RULE_USED_BY => X_RULE_USED_BY,
         X_OBJECT_TYPE => X_OBJECT_TYPE,
         X_RULE_TYPE => X_RULE_TYPE,
         X_API_TYPE => X_API_TYPE,
         X_PACKAGE_NAME => X_PACKAGE_NAME,
         X_PROCEDURE_NAME => X_PROCEDURE_NAME,
         X_SEEDED_FLAG => X_SEEDED_FLAG,
         X_APPLICATION_ID => X_APPLICATION_ID ,
         X_CREATION_DATE => sysdate,
         X_CREATED_BY => l_user_id,
         X_LAST_UPDATE_DATE => sysdate,
         X_LAST_UPDATED_BY => l_user_id,
         X_LAST_UPDATE_LOGIN => 0
         );
   else
      close c_chk_objrule_exists;
      open c_obj_verno;
      fetch c_obj_verno into l_obj_verno;
      close c_obj_verno;

       -- assigning value for l_user_status_id
      l_objrule_id := X_OBJECT_RULE_ID;
      AMW_OBJECT_RULES_PKG.UPDATE_ROW(
         X_OBJECT_RULE_ID => X_OBJECT_RULE_ID,
         X_OBJECT_VERSION_NUMBER => l_obj_verno,
         X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
         X_APPROVAL_TYPE => X_APPROVAL_TYPE,
         X_RULE_USED_BY => X_RULE_USED_BY,
         X_OBJECT_TYPE => X_OBJECT_TYPE,
         X_RULE_TYPE => X_RULE_TYPE,
         X_API_TYPE => X_API_TYPE,
         X_PACKAGE_NAME => X_PACKAGE_NAME,
         X_PROCEDURE_NAME => X_PROCEDURE_NAME,
         X_SEEDED_FLAG => X_SEEDED_FLAG,
         X_APPLICATION_ID => X_APPLICATION_ID,
         X_LAST_UPDATE_DATE => SYSDATE,
         X_LAST_UPDATED_BY => l_user_id,
         X_LAST_UPDATE_LOGIN => 0
         );
   END IF;

end LOAD_ROW;


end AMW_OBJECT_RULES_PKG;

/
