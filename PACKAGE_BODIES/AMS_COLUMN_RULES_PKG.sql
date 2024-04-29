--------------------------------------------------------
--  DDL for Package Body AMS_COLUMN_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_COLUMN_RULES_PKG" as
/* $Header: amslclrb.pls 120.1 2005/06/27 05:38:12 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in OUT NOCOPY VARCHAR2,
  X_COLUMN_RULE_ID in NUMBER,
  X_COLUMNS_METADATA_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ATTRIBUTE in VARCHAR2,
  X_AK_REGION_CODE in VARCHAR2,
  X_AK_ATTRIBUTE_CODE in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_HTML_FORM_PARAM in VARCHAR2,
  X_DB_TABLE_NAME in VARCHAR2,
  X_DB_COLUMN_NAME in VARCHAR2,
  X_SYSTEM_STATUS_CODE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
)is
begin
  insert into AMS_COLUMN_RULES (
    COLUMN_RULE_ID,
    COLUMNS_METADATA_ID,
    OBJECT_TYPE,
    OBJECT_ATTRIBUTE,
    AK_REGION_CODE,
    AK_ATTRIBUTE_CODE,
    ACTIVITY_TYPE_CODE,
    HTML_FORM_PARAM,
    DB_TABLE_NAME,
    DB_COLUMN_NAME,
    SYSTEM_STATUS_CODE,
    RULE_TYPE,
    SEEDED_FLAG,
    --SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER,
    APPLICATION_ID ,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE
  ) values (
    X_COLUMN_RULE_ID,
    X_COLUMNS_METADATA_ID,
    X_OBJECT_TYPE,
    X_OBJECT_ATTRIBUTE,
    X_AK_REGION_CODE,
    X_AK_ATTRIBUTE_CODE,
    X_ACTIVITY_TYPE_CODE,
    X_HTML_FORM_PARAM,
    X_DB_TABLE_NAME,
    X_DB_COLUMN_NAME,
    X_SYSTEM_STATUS_CODE,
    X_RULE_TYPE,
    X_SEEDED_FLAG,
    --X_SECURITY_GROUP_ID,
    X_OBJECT_VERSION_NUMBER,
    X_APPLICATION_ID,
    X_LAST_UPDATED_BY,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LAST_UPDATE_DATE
 );

end INSERT_ROW;

procedure LOCK_ROW (
  X_COLUMN_RULE_ID in NUMBER,
  X_COLUMNS_METADATA_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ATTRIBUTE in VARCHAR2,
  X_AK_REGION_CODE in VARCHAR2,
  X_AK_ATTRIBUTE_CODE in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_HTML_FORM_PARAM in VARCHAR2,
  X_DB_TABLE_NAME in VARCHAR2,
  X_DB_COLUMN_NAME in VARCHAR2,
  X_SYSTEM_STATUS_CODE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER
) is
  cursor c1 is select
      COLUMNS_METADATA_ID,
      OBJECT_TYPE,
      OBJECT_ATTRIBUTE,
      AK_REGION_CODE,
      AK_ATTRIBUTE_CODE,
      ACTIVITY_TYPE_CODE,
      HTML_FORM_PARAM,
      DB_TABLE_NAME,
      DB_COLUMN_NAME,
      SYSTEM_STATUS_CODE,
      RULE_TYPE,
      SEEDED_FLAG,
      SECURITY_GROUP_ID,
      OBJECT_VERSION_NUMBER,
      APPLICATION_ID,
      COLUMN_RULE_ID
     from AMS_COLUMN_RULES
    where COLUMN_RULE_ID = X_COLUMN_RULE_ID
    for update of COLUMN_RULE_ID nowait;
begin
  for tlinfo in c1 loop
      if (    (tlinfo.COLUMN_RULE_ID = X_COLUMN_RULE_ID)
          AND ((tlinfo.COLUMNS_METADATA_ID = X_COLUMNS_METADATA_ID)
               OR ((tlinfo.COLUMNS_METADATA_ID is null) AND (X_COLUMNS_METADATA_ID is null)))
          AND ((tlinfo.OBJECT_TYPE = X_OBJECT_TYPE)
               OR ((tlinfo.OBJECT_TYPE is null) AND (X_OBJECT_TYPE is null)))
          AND ((tlinfo.OBJECT_ATTRIBUTE = X_OBJECT_ATTRIBUTE)
               OR ((tlinfo.OBJECT_ATTRIBUTE is null) AND (X_OBJECT_ATTRIBUTE is null)))
          AND ((tlinfo.AK_REGION_CODE = X_AK_REGION_CODE)
               OR ((tlinfo.AK_REGION_CODE is null) AND (X_AK_REGION_CODE is null)))
          AND ((tlinfo.AK_ATTRIBUTE_CODE = X_AK_ATTRIBUTE_CODE)
               OR ((tlinfo.AK_ATTRIBUTE_CODE is null) AND (X_AK_ATTRIBUTE_CODE is null)))
          AND ((tlinfo.ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE)
               OR ((tlinfo.ACTIVITY_TYPE_CODE is null) AND (X_ACTIVITY_TYPE_CODE is null)))
          AND ((tlinfo.HTML_FORM_PARAM = X_HTML_FORM_PARAM)
               OR ((tlinfo.HTML_FORM_PARAM is null) AND (X_HTML_FORM_PARAM is null)))
          AND ((tlinfo.DB_TABLE_NAME = X_DB_TABLE_NAME)
               OR ((tlinfo.DB_TABLE_NAME is null) AND (X_DB_TABLE_NAME is null)))
          AND ((tlinfo.DB_COLUMN_NAME = X_DB_COLUMN_NAME)
               OR ((tlinfo.DB_COLUMN_NAME is null) AND (X_DB_COLUMN_NAME is null)))
          AND ((tlinfo.SYSTEM_STATUS_CODE = X_SYSTEM_STATUS_CODE)
               OR ((tlinfo.SYSTEM_STATUS_CODE is null) AND (X_SYSTEM_STATUS_CODE is null)))
          AND ((tlinfo.RULE_TYPE = X_RULE_TYPE)
               OR ((tlinfo.RULE_TYPE is null) AND (X_RULE_TYPE is null)))
          AND ((tlinfo.SEEDED_FLAG = X_SEEDED_FLAG)
               OR ((tlinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
          --AND ((tlinfo.SECURITY_GROUP_ID = X_SECURITY_GROUP_ID)
               --OR ((tlinfo.SECURITY_GROUP_ID is null) AND (X_SECURITY_GROUP_ID is null)))
          AND ((tlinfo.OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER)
               OR ((tlinfo.OBJECT_VERSION_NUMBER is null) AND (X_OBJECT_VERSION_NUMBER is null)))
          AND ((tlinfo.APPLICATION_ID = X_APPLICATION_ID)
               OR ((tlinfo.APPLICATION_ID is null) AND (X_APPLICATION_ID is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_COLUMN_RULE_ID in NUMBER,
  X_COLUMNS_METADATA_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ATTRIBUTE in VARCHAR2,
  X_AK_REGION_CODE in VARCHAR2,
  X_AK_ATTRIBUTE_CODE in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_HTML_FORM_PARAM in VARCHAR2,
  X_DB_TABLE_NAME in VARCHAR2,
  X_DB_COLUMN_NAME in VARCHAR2,
  X_SYSTEM_STATUS_CODE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
begin
  update AMS_COLUMN_RULES set
    COLUMNS_METADATA_ID = X_COLUMNS_METADATA_ID,
    OBJECT_TYPE = X_OBJECT_TYPE,
    OBJECT_ATTRIBUTE = X_OBJECT_ATTRIBUTE,
    AK_REGION_CODE = X_AK_REGION_CODE,
    AK_ATTRIBUTE_CODE = X_AK_ATTRIBUTE_CODE,
    ACTIVITY_TYPE_CODE = X_ACTIVITY_TYPE_CODE,
    HTML_FORM_PARAM = X_HTML_FORM_PARAM,
    DB_TABLE_NAME = X_DB_TABLE_NAME,
    DB_COLUMN_NAME = X_DB_COLUMN_NAME,
    SYSTEM_STATUS_CODE = X_SYSTEM_STATUS_CODE,
    RULE_TYPE = X_RULE_TYPE,
    SEEDED_FLAG = X_SEEDED_FLAG,
    --SECURITY_GROUP_ID = X_SECURITY_GROUP_ID,
    OBJECT_VERSION_NUMBER = X_OBJECT_VERSION_NUMBER,
    APPLICATION_ID = X_APPLICATION_ID ,
    COLUMN_RULE_ID = X_COLUMN_RULE_ID,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where COLUMN_RULE_ID = X_COLUMN_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_COLUMN_RULE_ID in NUMBER
) is
begin
  delete from AMS_COLUMN_RULES
  where COLUMN_RULE_ID = X_COLUMN_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

procedure LOAD_ROW (
  X_COLUMN_RULE_ID in NUMBER,
  X_COLUMNS_METADATA_ID in NUMBER,
  X_OBJECT_TYPE in VARCHAR2,
  X_OBJECT_ATTRIBUTE in VARCHAR2,
  X_AK_REGION_CODE in VARCHAR2,
  X_AK_ATTRIBUTE_CODE in VARCHAR2,
  X_ACTIVITY_TYPE_CODE in VARCHAR2,
  X_HTML_FORM_PARAM in VARCHAR2,
  X_DB_TABLE_NAME in VARCHAR2,
  X_DB_COLUMN_NAME in VARCHAR2,
  X_SYSTEM_STATUS_CODE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_SECURITY_GROUP_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_APPLICATION_ID in NUMBER,
  X_OWNER in VARCHAR2
 )is
l_user_id number := 0;
l_colrule_id  number;
l_obj_verno number;
l_dummy_char  varchar2(1);
l_row_id    varchar2(100);
l_id_exists  varchar2(1);


 cursor  c_obj_verno is
 select object_version_number, column_rule_id
  from    AMS_COLUMN_RULES
  where OBJECT_TYPE = X_OBJECT_TYPE
  and OBJECT_ATTRIBUTE = X_OBJECT_ATTRIBUTE
  and nvl(ACTIVITY_TYPE_CODE,0) = nvl(X_ACTIVITY_TYPE_CODE, 0)
  and HTML_FORM_PARAM = X_HTML_FORM_PARAM
  and APPLICATION_ID = X_APPLICATION_ID
  and nvl(SYSTEM_STATUS_CODE, 0)= nvl(X_SYSTEM_STATUS_CODE, 0)
  and RULE_TYPE =X_RULE_TYPE
  and COLUMNS_METADATA_ID = X_COLUMNS_METADATA_ID;

  cursor c_chk_colrule_exists is
  select 'x'
  from    AMS_COLUMN_RULES
  where OBJECT_TYPE = X_OBJECT_TYPE
  and OBJECT_ATTRIBUTE = X_OBJECT_ATTRIBUTE
  and nvl(ACTIVITY_TYPE_CODE, 0) = nvl(X_ACTIVITY_TYPE_CODE, 0)
  and HTML_FORM_PARAM = X_HTML_FORM_PARAM
  and APPLICATION_ID = X_APPLICATION_ID
  and nvl(SYSTEM_STATUS_CODE, 0)= nvl(X_SYSTEM_STATUS_CODE, 0)
  and RULE_TYPE =X_RULE_TYPE
  and COLUMNS_METADATA_ID = X_COLUMNS_METADATA_ID;

  --where  COLUMN_RULE_ID = X_COLUMN_RULE_ID;

  cursor c_get_colrule_id is
  select AMS_COLUMN_RULES_S.nextval
  from dual;

  cursor c_id_exists(id_in IN NUMBER) is
  select 'x'
  from AMS_COLUMN_RULES
  where  COLUMN_RULE_ID = id_in;

BEGIN
	if X_OWNER = 'SEED' then
		l_user_id := 1;
	end if;

	open c_chk_colrule_exists;
	fetch c_chk_colrule_exists into l_dummy_char;
	if c_chk_colrule_exists%notfound
	then
		close c_chk_colrule_exists;
/*		if X_COLUMN_RULE_ID is null
		then
			open c_get_colrule_id;
			fetch c_get_colrule_id into l_colrule_id;
			close c_get_colrule_id;
		else
			l_colrule_id := X_COLUMN_RULE_ID;
		end if;
*/
		l_id_exists := 'n';
		LOOP
			open c_get_colrule_id;
			fetch c_get_colrule_id into l_colrule_id;
			close c_get_colrule_id;

			open c_id_exists(l_colrule_id);
			fetch c_id_exists into l_id_exists;
			close c_id_exists;
			if l_id_exists <> 'x' then
				exit;
			end if;
		END LOOP;

		AMS_COLUMN_RULES_PKG.INSERT_ROW (
			X_ROWID => l_row_id,
			X_COLUMN_RULE_ID => l_colrule_id,
			X_COLUMNS_METADATA_ID => X_COLUMNS_METADATA_ID,
			X_OBJECT_TYPE => X_OBJECT_TYPE,
			X_OBJECT_ATTRIBUTE => X_OBJECT_ATTRIBUTE,
			X_AK_REGION_CODE => X_AK_REGION_CODE,
			X_AK_ATTRIBUTE_CODE => X_AK_ATTRIBUTE_CODE,
			X_ACTIVITY_TYPE_CODE => X_ACTIVITY_TYPE_CODE,
			X_HTML_FORM_PARAM => X_HTML_FORM_PARAM,
			X_DB_TABLE_NAME => X_DB_TABLE_NAME,
			X_DB_COLUMN_NAME => X_DB_COLUMN_NAME,
			X_SYSTEM_STATUS_CODE => X_SYSTEM_STATUS_CODE,
			X_RULE_TYPE => X_RULE_TYPE,
			X_SEEDED_FLAG => X_SEEDED_FLAG,
			X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
			X_OBJECT_VERSION_NUMBER => X_OBJECT_VERSION_NUMBER,
			X_APPLICATION_ID => X_APPLICATION_ID,
			X_CREATION_DATE => sysdate,
			X_CREATED_BY => l_user_id,
			X_LAST_UPDATE_DATE => sysdate,
			X_LAST_UPDATED_BY => l_user_id,
			X_LAST_UPDATE_LOGIN => 0
			);
	else
		close c_chk_colrule_exists;
		open c_obj_verno;
		fetch c_obj_verno into l_obj_verno,l_colrule_id;
		close c_obj_verno;
       -- assigning value for l_user_status_id
		--l_colrule_id := X_COLUMN_RULE_ID := l_colrule_id;
		AMS_COLUMN_RULES_PKG.UPDATE_ROW(
			X_COLUMN_RULE_ID => l_colrule_id,
			X_COLUMNS_METADATA_ID => X_COLUMNS_METADATA_ID,
			X_OBJECT_TYPE => X_OBJECT_TYPE,
			X_OBJECT_ATTRIBUTE => X_OBJECT_ATTRIBUTE,
			X_AK_REGION_CODE => X_AK_REGION_CODE,
			X_AK_ATTRIBUTE_CODE => X_AK_ATTRIBUTE_CODE,
			X_ACTIVITY_TYPE_CODE => X_ACTIVITY_TYPE_CODE,
			X_HTML_FORM_PARAM => X_HTML_FORM_PARAM,
			X_DB_TABLE_NAME => X_DB_TABLE_NAME,
			X_DB_COLUMN_NAME => X_DB_COLUMN_NAME,
			X_SYSTEM_STATUS_CODE => X_SYSTEM_STATUS_CODE,
			X_RULE_TYPE => X_RULE_TYPE,
			X_SEEDED_FLAG => X_SEEDED_FLAG,
			X_SECURITY_GROUP_ID => X_SECURITY_GROUP_ID,
			X_OBJECT_VERSION_NUMBER => l_obj_verno,
			X_APPLICATION_ID =>   X_APPLICATION_ID,
			X_LAST_UPDATE_DATE => sysdate,
			X_LAST_UPDATED_BY => l_user_id,
			X_LAST_UPDATE_LOGIN => 0
			);
	END IF;
end LOAD_ROW;

end AMS_COLUMN_RULES_PKG;

/
