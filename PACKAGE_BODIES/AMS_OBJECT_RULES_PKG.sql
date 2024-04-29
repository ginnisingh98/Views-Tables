--------------------------------------------------------
--  DDL for Package Body AMS_OBJECT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_OBJECT_RULES_PKG" as
/* $Header: amslobrb.pls 120.1 2005/06/27 05:38:34 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_OBJECT_RULE_ID in NUMBER,
  X_PARAM15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_RULE_USED_BY_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_CLASS_NAME in VARCHAR2,
  X_METHOD_NAME in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_RELATED_OBJECT in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PARAM1 in VARCHAR2,
  X_PARAM2 in VARCHAR2,
  X_PARAM3 in VARCHAR2,
  X_PARAM4 in VARCHAR2,
  X_PARAM5 in VARCHAR2,
  X_PARAM6 in VARCHAR2,
  X_PARAM7 in VARCHAR2,
  X_PARAM8 in VARCHAR2,
  X_PARAM9 in VARCHAR2,
  X_PARAM10 in VARCHAR2,
  X_PARAM11 in VARCHAR2,
  X_PARAM12 in VARCHAR2,
  X_PARAM13 in VARCHAR2,
  X_PARAM14 in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

  cursor C is select ROWID from AMS_OBJECT_RULES_B
    where OBJECT_RULE_ID = X_OBJECT_RULE_ID
    ;
begin
  insert into AMS_OBJECT_RULES_B (
      OBJECT_RULE_ID,
    PARAM15,
    OBJECT_VERSION_NUMBER,
    --SECURITY_GROUP_ID,
    APPROVAL_TYPE,
    RULE_USED_BY,
    RULE_USED_BY_TYPE,
    RULE_TYPE,
    API_TYPE,
    PACKAGE_NAME,
    PROCEDURE_NAME,
    CLASS_NAME,
    METHOD_NAME,
    QUERY,
    RELATED_OBJECT,
    SEEDED_FLAG,
    PARAM1,
    PARAM2,
    PARAM3,
    PARAM4,
    PARAM5,
    PARAM6,
    PARAM7,
    PARAM8,
    PARAM9,
    PARAM10,
    PARAM11,
    PARAM12,
    PARAM13,
    PARAM14,
    APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_OBJECT_RULE_ID,
    X_PARAM15,
    X_OBJECT_VERSION_NUMBER,
    --X_SECURITY_GROUP_ID,
    X_APPROVAL_TYPE,
    X_RULE_USED_BY,
    X_RULE_USED_BY_TYPE,
    X_RULE_TYPE,
    X_API_TYPE,
    X_PACKAGE_NAME,
    X_PROCEDURE_NAME,
    X_CLASS_NAME,
    X_METHOD_NAME,
    X_QUERY,
    X_RELATED_OBJECT,
    X_SEEDED_FLAG,
    X_PARAM1,
    X_PARAM2,
    X_PARAM3,
    X_PARAM4,
    X_PARAM5,
    X_PARAM6,
    X_PARAM7,
    X_PARAM8,
    X_PARAM9,
    X_PARAM10,
    X_PARAM11,
    X_PARAM12,
    X_PARAM13,
    X_PARAM14,
    X_APPLICATION_ID,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into AMS_OBJECT_RULES_TL (
    OBJECT_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    --SECURITY_GROUP_ID,
    OBJECT_RULE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_OBJECT_RULE_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    --X_SECURITY_GROUP_ID,
    X_OBJECT_RULE_NAME,
    X_DESCRIPTION,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from AMS_OBJECT_RULES_TL T
    where T.OBJECT_RULE_ID = X_OBJECT_RULE_ID
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
  X_OBJECT_RULE_ID in NUMBER,
  X_PARAM15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_RULE_USED_BY_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_CLASS_NAME in VARCHAR2,
  X_METHOD_NAME in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_RELATED_OBJECT in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PARAM1 in VARCHAR2,
  X_PARAM2 in VARCHAR2,
  X_PARAM3 in VARCHAR2,
  X_PARAM4 in VARCHAR2,
  X_PARAM5 in VARCHAR2,
  X_PARAM6 in VARCHAR2,
  X_PARAM7 in VARCHAR2,
  X_PARAM8 in VARCHAR2,
  X_PARAM9 in VARCHAR2,
  X_PARAM10 in VARCHAR2,
  X_PARAM11 in VARCHAR2,
  X_PARAM12 in VARCHAR2,
  X_PARAM13 in VARCHAR2,
  X_PARAM14 in VARCHAR2,
  X_APPLICATION_ID in NUMBER
  ) is
  cursor c is select
      PARAM15,
      OBJECT_VERSION_NUMBER,
      SECURITY_GROUP_ID,
      APPROVAL_TYPE,
      RULE_USED_BY,
      RULE_USED_BY_TYPE,
      RULE_TYPE,
      API_TYPE,
      PACKAGE_NAME,
      PROCEDURE_NAME,
      CLASS_NAME,
      METHOD_NAME,
      QUERY,
      RELATED_OBJECT,
      SEEDED_FLAG,
      PARAM1,
      PARAM2,
      PARAM3,
      PARAM4,
      PARAM5,
      PARAM6,
      PARAM7,
      PARAM8,
      PARAM9,
      PARAM10,
      PARAM11,
      PARAM12,
      PARAM13,
      PARAM14,
      APPLICATION_ID
    from AMS_OBJECT_RULES_B
    where OBJECT_RULE_ID = X_OBJECT_RULE_ID
    for update of OBJECT_RULE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      OBJECT_RULE_ID,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from AMS_OBJECT_RULES_TL
    where OBJECT_RULE_ID = X_OBJECT_RULE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of OBJECT_RULE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.PARAM15 = X_PARAM15)
           OR ((recinfo.PARAM15 is null) AND (X_PARAM15 is null)))
      AND ((recinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
           OR ((recinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
      --AND ((recinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
           --OR ((recinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
      AND ((recinfo.APPROVAL_TYPE = X_APPROVAL_TYPE)
           OR ((recinfo.APPROVAL_TYPE is null) AND (X_APPROVAL_TYPE is null)))
      AND ((recinfo.RULE_USED_BY = X_RULE_USED_BY)
           OR ((recinfo.RULE_USED_BY is null) AND (X_RULE_USED_BY is null)))
      AND ((recinfo.RULE_USED_BY_TYPE = X_RULE_USED_BY_TYPE)
           OR ((recinfo.RULE_USED_BY_TYPE is null) AND (X_RULE_USED_BY_TYPE is null)))
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
      AND ((recinfo.CLASS_NAME = X_CLASS_NAME)
           OR ((recinfo.CLASS_NAME is null) AND (X_CLASS_NAME is null)))
      AND ((recinfo.METHOD_NAME = X_METHOD_NAME)
           OR ((recinfo.METHOD_NAME is null) AND (X_METHOD_NAME is null)))
      AND ((recinfo.QUERY = X_QUERY)
           OR ((recinfo.QUERY is null) AND (X_QUERY is null)))
      AND ((recinfo.RELATED_OBJECT = X_RELATED_OBJECT)
           OR ((recinfo.RELATED_OBJECT is null) AND (X_RELATED_OBJECT is null)))
      AND ((recinfo.PARAM1 = X_PARAM1)
           OR ((recinfo.PARAM1 is null) AND (X_PARAM1 is null)))
      AND ((recinfo.PARAM2 = X_PARAM2)
           OR ((recinfo.PARAM2 is null) AND (X_PARAM2 is null)))
      AND ((recinfo.PARAM3 = X_PARAM3)
           OR ((recinfo.PARAM3 is null) AND (X_PARAM3 is null)))
      AND ((recinfo.PARAM4 = X_PARAM4)
           OR ((recinfo.PARAM4 is null) AND (X_PARAM4 is null)))
      AND ((recinfo.PARAM5 = X_PARAM5)
           OR ((recinfo.PARAM5 is null) AND (X_PARAM5 is null)))
      AND ((recinfo.PARAM6 = X_PARAM6)
           OR ((recinfo.PARAM6 is null) AND (X_PARAM6 is null)))
      AND ((recinfo.PARAM7 = X_PARAM7)
           OR ((recinfo.PARAM7 is null) AND (X_PARAM7 is null)))
      AND ((recinfo.PARAM8 = X_PARAM8)
           OR ((recinfo.PARAM8 is null) AND (X_PARAM8 is null)))
      AND ((recinfo.PARAM9 = X_PARAM9)
           OR ((recinfo.PARAM9 is null) AND (X_PARAM9 is null)))
      AND ((recinfo.PARAM10 = X_PARAM10)
           OR ((recinfo.PARAM10 is null) AND (X_PARAM10 is null)))
      AND ((recinfo.PARAM11 = X_PARAM11)
           OR ((recinfo.PARAM11 is null) AND (X_PARAM11 is null)))
      AND ((recinfo.PARAM12 = X_PARAM12)
           OR ((recinfo.PARAM12 is null) AND (X_PARAM12 is null)))
      AND ((recinfo.PARAM13 = X_PARAM13)
           OR ((recinfo.PARAM13 is null) AND (X_PARAM13 is null)))
      AND ((recinfo.PARAM14 = X_PARAM14)
           OR ((recinfo.PARAM14 is null) AND (X_PARAM14 is null)))
      AND ((recinfo.APPLICATION_ID = X_APPLICATION_ID)
           OR ((recinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.OBJECT_RULE_ID = X_OBJECT_RULE_ID)
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
  X_OBJECT_RULE_ID in NUMBER,
  X_PARAM15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_RULE_USED_BY_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_CLASS_NAME in VARCHAR2,
  X_METHOD_NAME in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_RELATED_OBJECT in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PARAM1 in VARCHAR2,
  X_PARAM2 in VARCHAR2,
  X_PARAM3 in VARCHAR2,
  X_PARAM4 in VARCHAR2,
  X_PARAM5 in VARCHAR2,
  X_PARAM6 in VARCHAR2,
  X_PARAM7 in VARCHAR2,
  X_PARAM8 in VARCHAR2,
  X_PARAM9 in VARCHAR2,
  X_PARAM10 in VARCHAR2,
  X_PARAM11 in VARCHAR2,
  X_PARAM12 in VARCHAR2,
  X_PARAM13 in VARCHAR2,
  X_PARAM14 in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_OBJECT_RULES_B set
    PARAM15 = X_PARAM15,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    --SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    APPROVAL_TYPE = X_APPROVAL_TYPE,
    RULE_USED_BY = X_RULE_USED_BY,
    RULE_USED_BY_TYPE = X_RULE_USED_BY_TYPE,
    RULE_TYPE = X_RULE_TYPE,
    API_TYPE = X_API_TYPE,
    PACKAGE_NAME = X_PACKAGE_NAME,
    PROCEDURE_NAME = X_PROCEDURE_NAME,
    CLASS_NAME = X_CLASS_NAME,
    METHOD_NAME = X_METHOD_NAME,
    QUERY = X_QUERY,
    RELATED_OBJECT = X_RELATED_OBJECT,
    SEEDED_FLAG = X_SEEDED_FLAG,
    PARAM1 = X_PARAM1,
    PARAM2 = X_PARAM2,
    PARAM3 = X_PARAM3,
    PARAM4 = X_PARAM4,
    PARAM5 = X_PARAM5,
    PARAM6 = X_PARAM6,
    PARAM7 = X_PARAM7,
    PARAM8 = X_PARAM8,
    PARAM9 = X_PARAM9,
    PARAM10 = X_PARAM10,
    PARAM11 = X_PARAM11,
    PARAM12 = X_PARAM12,
    PARAM13 = X_PARAM13,
    PARAM14 = X_PARAM14,
    APPLICATION_ID = X_APPLICATION_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where OBJECT_RULE_ID = X_OBJECT_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update AMS_OBJECT_RULES_TL set
    OBJECT_RULE_ID = X_OBJECT_RULE_ID,
    OBJECT_RULE_NAME = X_OBJECT_RULE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where OBJECT_RULE_ID = X_OBJECT_RULE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_OBJECT_RULE_ID in NUMBER
) is
begin
  delete from AMS_OBJECT_RULES_TL
  where OBJECT_RULE_ID = X_OBJECT_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from AMS_OBJECT_RULES_B
  where OBJECT_RULE_ID = X_OBJECT_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure TRANSLATE_ROW(
   X_OBJECT_RULE_ID  in NUMBER,
   X_OBJECT_RULE_NAME       in VARCHAR2,
   X_DESCRIPTION          in VARCHAR2,
   X_OWNER      in VARCHAR2
) IS
  begin
     update AMS_OBJECT_RULES_TL set
     object_rule_name = nvl(x_object_rule_name, object_rule_name),
     description = nvl(x_description, description),
     source_lang = userenv('LANG'),
     last_update_date = sysdate,
     last_updated_by = decode(x_owner, 'SEED', 1, 0),
     last_update_login = 0
     where  OBJECT_RULE_ID = X_OBJECT_RULE_ID
     and      userenv('LANG') in (language, source_lang);
  end TRANSLATE_ROW;

procedure LOAD_ROW (
  X_OBJECT_RULE_ID in NUMBER,
  X_PARAM15 in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_SECURITY_GROUP_ID in NUMBER,
  X_APPROVAL_TYPE in VARCHAR2,
  X_RULE_USED_BY in VARCHAR2,
  X_RULE_USED_BY_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_API_TYPE in VARCHAR2,
  X_PACKAGE_NAME in VARCHAR2,
  X_PROCEDURE_NAME in VARCHAR2,
  X_CLASS_NAME in VARCHAR2,
  X_METHOD_NAME in VARCHAR2,
  X_QUERY in VARCHAR2,
  X_RELATED_OBJECT in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_PARAM1 in VARCHAR2,
  X_PARAM2 in VARCHAR2,
  X_PARAM3 in VARCHAR2,
  X_PARAM4 in VARCHAR2,
  X_PARAM5 in VARCHAR2,
  X_PARAM6 in VARCHAR2,
  X_PARAM7 in VARCHAR2,
  X_PARAM8 in VARCHAR2,
  X_PARAM9 in VARCHAR2,
  X_PARAM10 in VARCHAR2,
  X_PARAM11 in VARCHAR2,
  X_PARAM12 in VARCHAR2,
  X_PARAM13 in VARCHAR2,
  X_PARAM14 in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_OBJECT_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_OWNER IN VARCHAR2
 )is
l_user_id number := 0;
l_objrule_id  number;
l_obj_verno number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);

  cursor  c_obj_verno is
 select object_version_number
from    AMS_OBJECT_RULES_B
  where  OBJECT_RULE_ID =  X_OBJECT_RULE_ID;

  cursor c_chk_objrule_exists is
  select 'x'
  from    AMS_OBJECT_RULES_B
  where  OBJECT_RULE_ID =  X_OBJECT_RULE_ID;

  cursor c_get_objrule_id is
  select AMS_OBJECT_RULES_B_S.nextval
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

		AMS_OBJECT_RULES_PKG.INSERT_ROW (
			X_ROWID => l_row_id,
			X_OBJECT_RULE_ID => l_objrule_id,
			X_PARAM15 => X_PARAM15,
			X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
			X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
			X_APPROVAL_TYPE => X_APPROVAL_TYPE,
			X_RULE_USED_BY => X_RULE_USED_BY,
			X_RULE_USED_BY_TYPE => X_RULE_USED_BY_TYPE,
			X_RULE_TYPE => X_RULE_TYPE,
			X_API_TYPE => X_API_TYPE,
			X_PACKAGE_NAME => X_PACKAGE_NAME,
			X_PROCEDURE_NAME => X_PROCEDURE_NAME,
			X_CLASS_NAME => X_CLASS_NAME,
			X_METHOD_NAME => X_METHOD_NAME,
			X_QUERY => X_QUERY,
			X_RELATED_OBJECT => X_RELATED_OBJECT,
			X_SEEDED_FLAG => X_SEEDED_FLAG,
			X_PARAM1 => X_PARAM1,
			X_PARAM2 => X_PARAM2,
			X_PARAM3 => X_PARAM3,
			X_PARAM4 => X_PARAM4,
			X_PARAM5 => X_PARAM5,
			X_PARAM6 => X_PARAM6,
			X_PARAM7 => X_PARAM7,
			X_PARAM8 => X_PARAM8,
			X_PARAM9 => X_PARAM9,
			X_PARAM10 => X_PARAM10,
			X_PARAM11 => X_PARAM11,
			X_PARAM12 => X_PARAM12,
			X_PARAM13 => X_PARAM13,
			X_PARAM14 => X_PARAM14,
			X_APPLICATION_ID => X_APPLICATION_ID ,
			X_OBJECT_RULE_NAME => X_OBJECT_RULE_NAME,
			X_DESCRIPTION => X_DESCRIPTION,
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
		AMS_OBJECT_RULES_PKG.UPDATE_ROW(
			X_OBJECT_RULE_ID => X_OBJECT_RULE_ID,
			X_PARAM15 => X_PARAM15,
			X_OBJECT_VERSION_NUMBER => l_obj_verno,
			X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
			X_APPROVAL_TYPE => X_APPROVAL_TYPE,
			X_RULE_USED_BY => X_RULE_USED_BY,
			X_RULE_USED_BY_TYPE => X_RULE_USED_BY_TYPE,
			X_RULE_TYPE => X_RULE_TYPE,
			X_API_TYPE => X_API_TYPE,
			X_PACKAGE_NAME => X_PACKAGE_NAME,
			X_PROCEDURE_NAME => X_PROCEDURE_NAME,
			X_CLASS_NAME => X_CLASS_NAME,
			X_METHOD_NAME => X_METHOD_NAME,
			X_QUERY => X_QUERY,
			X_RELATED_OBJECT => X_RELATED_OBJECT,
			X_SEEDED_FLAG => X_SEEDED_FLAG,
			X_PARAM1 => X_PARAM1,
			X_PARAM2 => X_PARAM2,
			X_PARAM3 => X_PARAM3,
			X_PARAM4 => X_PARAM4,
			X_PARAM5 => X_PARAM5,
			X_PARAM6 => X_PARAM6,
			X_PARAM7 => X_PARAM7,
			X_PARAM8 => X_PARAM8,
			X_PARAM9 => X_PARAM9,
			X_PARAM10 => X_PARAM10,
			X_PARAM11 => X_PARAM11,
			X_PARAM12 => X_PARAM12,
			X_PARAM13 => X_PARAM13,
			X_PARAM14 => X_PARAM14,
			X_APPLICATION_ID => X_APPLICATION_ID,
			X_OBJECT_RULE_NAME => X_OBJECT_RULE_NAME,
			X_DESCRIPTION => X_DESCRIPTION,
			X_LAST_UPDATE_DATE => SYSDATE,
			X_LAST_UPDATED_BY => l_user_id,
			X_LAST_UPDATE_LOGIN => 0
			);
	END IF;

end LOAD_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from AMS_OBJECT_RULES_TL T
  where not exists
    (select NULL
    from AMS_OBJECT_RULES_B B
    where B.OBJECT_RULE_ID = T.OBJECT_RULE_ID
    );

  update AMS_OBJECT_RULES_TL T set (
      OBJECT_RULE_ID
    ) = (select
      B.OBJECT_RULE_ID
    from AMS_OBJECT_RULES_TL B
    where B.OBJECT_RULE_ID = T.OBJECT_RULE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.OBJECT_RULE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.OBJECT_RULE_ID,
      SUBT.LANGUAGE
    from AMS_OBJECT_RULES_TL SUBB, AMS_OBJECT_RULES_TL SUBT
    where SUBB.OBJECT_RULE_ID = SUBT.OBJECT_RULE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.OBJECT_RULE_ID <> SUBT.OBJECT_RULE_ID
  ));

  insert into AMS_OBJECT_RULES_TL (
    OBJECT_RULE_ID,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    SECURITY_GROUP_ID,
    OBJECT_RULE_NAME,
    DESCRIPTION,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.OBJECT_RULE_ID,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SECURITY_GROUP_ID,
    B.OBJECT_RULE_NAME,
    B.DESCRIPTION,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from AMS_OBJECT_RULES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from AMS_OBJECT_RULES_TL T
    where T.OBJECT_RULE_ID = B.OBJECT_RULE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end AMS_OBJECT_RULES_PKG;

/
