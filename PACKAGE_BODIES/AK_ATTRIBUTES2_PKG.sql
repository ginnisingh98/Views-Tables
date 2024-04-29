--------------------------------------------------------
--  DDL for Package Body AK_ATTRIBUTES2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_ATTRIBUTES2_PKG" as
/* $Header: AKDATR2B.pls 120.2 2005/09/29 13:59:31 tshort ship $ */
--*****************************************************************************
procedure CHANGE_LOVS (
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_OLD_LOV_REGION_CODE in VARCHAR2,
  X_OLD_LOV_REGION_APPL_ID in NUMBER,
  X_NEW_LOV_REGION_CODE in VARCHAR2,
  X_NEW_LOV_REGION_APPL_ID in NUMBER,
  X_LOV_FOREIGN_KEY_NAME IN OUT NOCOPY VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
IS
/* local variables */
  L_UNIQUE_KEY_NAME varchar2(30);
  row_id varchar2(30);
/* cursor definition */
cursor cz is
  select foreign_key_name
  from   ak_foreign_key_mapping_v
  where  database_object_name = x_database_object_name
  and    foreign_application_id = x_attribute_application_id
  and    foreign_attribute_code = x_attribute_code
  and    unique_key_name = L_UNIQUE_KEY_NAME;
begin

  if X_OLD_LOV_REGION_CODE is null
   and X_NEW_LOV_REGION_CODE is null then
	return;
  end if;

  if X_NEW_LOV_REGION_CODE = 'CZ_ATTRIBUTE_LISTS_REGION' then
    L_UNIQUE_KEY_NAME := 'LIST_NAME';
  elsif X_NEW_LOV_REGION_CODE = 'CZ_ATTRIBUTE_LISTS_NBR_REGION' then
    L_UNIQUE_KEY_NAME := 'NUMBER_LIST_NAME';
  end if;

/*
  if X_OLD_LOV_REGION_CODE is null then
	AK_ATTRIBUTES2_PKG.NEW_FOREIGN_KEY (
	  X_FOREIGN_KEY_NAME => X_LOV_FOREIGN_KEY_NAME,
	  X_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
	  X_UNIQUE_KEY_NAME => L_UNIQUE_KEY_NAME,
	  X_APPLICATION_ID => 702,
	  X_ATTRIBUTE_APPLICATION_ID => 702,
	  X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
	  X_FROM_TO_NAME => 'CONFIGURATOR',
	  X_CREATION_DATE => x_creation_date,
	  X_CREATED_BY => x_created_by,
	  X_LAST_UPDATE_DATE => x_last_update_date,
	  X_LAST_UPDATED_BY => x_last_updated_by,
	  X_LAST_UPDATE_LOGIN => x_last_update_login);
  elsif X_NEW_LOV_REGION_CODE is null then
    open cz;
    fetch cz into X_LOV_FOREIGN_KEY_NAME;
    if (sql%notfound) then
	X_LOV_FOREIGN_KEY_NAME := null;
    end if;
    close cz;
    if X_LOV_FOREIGN_KEY_NAME is not null then
	AK_FOREIGN_KEYS_PKG.DELETE_AFKC_ROW(
	  X_FOREIGN_KEY_NAME => X_LOV_FOREIGN_KEY_NAME,
	  X_ATTRIBUTE_APPLICATION_ID => 702,
	  X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
	  X_FOREIGN_KEY_SEQUENCE => 1);
	AK_FOREIGN_KEYS_PKG.DELETE_ROW(
	  X_FOREIGN_KEY_NAME => X_LOV_FOREIGN_KEY_NAME);
	X_LOV_FOREIGN_KEY_NAME := NULL;
    end if;
  else
    open cz;
    fetch cz into X_LOV_FOREIGN_KEY_NAME;
    if (sql%notfound) then
	X_LOV_FOREIGN_KEY_NAME := null;
    end if;
    close cz;
    if X_LOV_FOREIGN_KEY_NAME is null then
	AK_ATTRIBUTES2_PKG.NEW_FOREIGN_KEY (
	  X_FOREIGN_KEY_NAME => X_LOV_FOREIGN_KEY_NAME,
	  X_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
	  X_UNIQUE_KEY_NAME => L_UNIQUE_KEY_NAME,
	  X_APPLICATION_ID => 702,
	  X_ATTRIBUTE_APPLICATION_ID => 702,
	  X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
	  X_FROM_TO_NAME => 'CONFIGURATOR',
	  X_CREATION_DATE => x_creation_date,
	  X_CREATED_BY => x_created_by,
	  X_LAST_UPDATE_DATE => x_last_update_date,
	  X_LAST_UPDATED_BY => x_last_updated_by,
	  X_LAST_UPDATE_LOGIN => x_last_update_login);
    else
	AK_FOREIGN_KEYS_PKG.UPDATE_ROW(
	  X_FOREIGN_KEY_NAME => X_LOV_FOREIGN_KEY_NAME,
	  X_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
	  X_UNIQUE_KEY_NAME => L_UNIQUE_KEY_NAME,
	  X_APPLICATION_ID => 702,
	  X_FROM_TO_NAME => 'CONFIGURATOR',
	  X_FROM_TO_DESCRIPTION => null,
	  X_TO_FROM_NAME => null,
	  X_TO_FROM_DESCRIPTION => null,
	  X_LAST_UPDATE_DATE => x_last_update_date,
	  X_LAST_UPDATED_BY => x_last_updated_by,
	  X_LAST_UPDATE_LOGIN => x_last_update_login,
	  X_ATTRIBUTE_CATEGORY => NULL,
	  X_ATTRIBUTE1 => NULL,
	  X_ATTRIBUTE2 => NULL,
	  X_ATTRIBUTE3 => NULL,
	  X_ATTRIBUTE4 => NULL,
	  X_ATTRIBUTE5 => NULL,
	  X_ATTRIBUTE6 => NULL,
	  X_ATTRIBUTE7 => NULL,
	  X_ATTRIBUTE8 => NULL,
	  X_ATTRIBUTE9 => NULL,
	  X_ATTRIBUTE10 => NULL,
	  X_ATTRIBUTE11 => NULL,
	  X_ATTRIBUTE12 => NULL,
	  X_ATTRIBUTE13 => NULL,
	  X_ATTRIBUTE14 => NULL,
	  X_ATTRIBUTE15 => NULL);
    end if;
  end if;
*/
end ;
--*****************************************************************************
/*
procedure NEW_FOREIGN_KEY (
  X_FOREIGN_KEY_NAME in out NOCOPY VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_UNIQUE_KEY_NAME in VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_FROM_TO_NAME in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
IS
  row_id varchar2(30);
  L_sequence integer;
begin
  select CZ_AUTOSELECTION_RANGES_S.NEXTVAL into L_sequence from dual;
  X_FOREIGN_KEY_NAME := 'CZ_'||to_char(L_sequence);
  AK_FOREIGN_KEYS_PKG.INSERT_ROW(
	  X_ROWID => row_id,
	  X_FOREIGN_KEY_NAME => X_FOREIGN_KEY_NAME,
	  X_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
	  X_UNIQUE_KEY_NAME => X_UNIQUE_KEY_NAME,
	  X_APPLICATION_ID => 702,
	  X_FROM_TO_NAME => 'CONFIGURATOR',
	  X_FROM_TO_DESCRIPTION => null,
	  X_TO_FROM_NAME => null,
	  X_TO_FROM_DESCRIPTION => null,
	  X_CREATION_DATE => x_creation_date,
	  X_CREATED_BY => x_created_by,
	  X_LAST_UPDATE_DATE => x_last_update_date,
	  X_LAST_UPDATED_BY => x_last_updated_by,
	  X_LAST_UPDATE_LOGIN => x_last_update_login,
	  X_ATTRIBUTE_CATEGORY => NULL,
	  X_ATTRIBUTE1 => NULL,
	  X_ATTRIBUTE2 => NULL,
	  X_ATTRIBUTE3 => NULL,
	  X_ATTRIBUTE4 => NULL,
	  X_ATTRIBUTE5 => NULL,
	  X_ATTRIBUTE6 => NULL,
	  X_ATTRIBUTE7 => NULL,
	  X_ATTRIBUTE8 => NULL,
	  X_ATTRIBUTE9 => NULL,
	  X_ATTRIBUTE10 => NULL,
	  X_ATTRIBUTE11 => NULL,
	  X_ATTRIBUTE12 => NULL,
	  X_ATTRIBUTE13 => NULL,
	  X_ATTRIBUTE14 => NULL,
	  X_ATTRIBUTE15 => NULL);

  AK_FOREIGN_KEYS_PKG.INSERT_AFKC_ROW(
	  X_ROWID => row_id,

	  X_FOREIGN_KEY_NAME => X_FOREIGN_KEY_NAME,
	  X_ATTRIBUTE_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
	  X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
	  X_FOREIGN_KEY_SEQUENCE => 1,
	  X_CREATION_DATE => x_creation_date,
	  X_CREATED_BY => x_created_by,
	  X_LAST_UPDATE_DATE => x_last_update_date,
	  X_LAST_UPDATED_BY => x_last_updated_by,
	  X_LAST_UPDATE_LOGIN => x_last_update_login,
	  X_ATTRIBUTE_CATEGORY => NULL,
	  X_ATTRIBUTE1 => NULL,
	  X_ATTRIBUTE2 => NULL,
	  X_ATTRIBUTE3 => NULL,
	  X_ATTRIBUTE4 => NULL,
	  X_ATTRIBUTE5 => NULL,
	  X_ATTRIBUTE6 => NULL,
	  X_ATTRIBUTE7 => NULL,
	  X_ATTRIBUTE8 => NULL,
	  X_ATTRIBUTE9 => NULL,
	  X_ATTRIBUTE10 => NULL,
	  X_ATTRIBUTE11 => NULL,
	  X_ATTRIBUTE12 => NULL,
	  X_ATTRIBUTE13 => NULL,
	  X_ATTRIBUTE14 => NULL,
	  X_ATTRIBUTE15 => NULL);

end NEW_FOREIGN_KEY;
*/


procedure ASSIGN_ATTRIBUTE (
  X_MODE in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_ATTRIBUTE_LABEL_LENGTH in NUMBER,
  X_BOLD in VARCHAR2,
  X_ITALIC in VARCHAR2,
  X_VERTICAL_ALIGNMENT in VARCHAR2,
  X_HORIZONTAL_ALIGNMENT in VARCHAR2,
  X_DEFAULT_VALUE_VARCHAR2 in VARCHAR2,
  X_DEFAULT_VALUE_NUMBER in NUMBER,
  X_DEFAULT_VALUE_DATE in DATE,
  X_LOV_REGION_CODE in VARCHAR2,
  X_LOV_REGION_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_LABEL_LONG in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_REGION_APPLICATION_ID in NUMBER,
  X_REGION_CODE in VARCHAR2,
  X_DISPLAY_VALUE_LENGTH in NUMBER,
  X_TABLE_NAME in VARCHAR2,
  X_OBJ_ATTR_SUCCESS in out NOCOPY VARCHAR2,
  x_data_source_type in VARCHAR2,
  x_data_storage_type in VARCHAR2
) IS
-- * local variables * --
  L_LOV_REGION_CODE varchar2(30)		:= null;
  L_LOV_REGION_APPLICATION_ID number	:= null;
  L_LOV_FOREIGN_KEY_NAME varchar2(30)	:= null;
  L_LOV_ATTRIBUTE_APPLICATION_ID number	:= null;
  L_LOV_ATTRIBUTE_CODE varchar2(30)		:= null;
  L_LOV_DEFAULT_FLAG VARCHAR2(1)		:= null;
  L_UNIQUE_KEY_NAME varchar2(30)		:= null;
dummy number;
row_id varchar2(30);
column_name_default varchar2(30);
-- * cursor definition * --
cursor c is
  select 1
  from   ak_object_attributes
  where  database_object_name = x_database_object_name
  and    attribute_application_id = x_attribute_application_id
  and    attribute_code = x_attribute_code;

cursor cz is
  select foreign_key_name
  from   ak_foreign_key_mapping_v
  where  database_object_name = x_database_object_name
  and    foreign_application_id = x_attribute_application_id
  and    foreign_attribute_code = x_attribute_code
  and    unique_key_name = L_UNIQUE_KEY_NAME;

 cursor uk is
	select unique_key_name from ak_unique_keys
	  where unique_key_name = L_UNIQUE_KEY_NAME;
begin

  if X_LOV_REGION_CODE is not null
   and X_MODE = 'CONFIGURATOR' then
    if X_LOV_REGION_CODE = 'CZ_ATTRIBUTE_LISTS_REGION' then
	L_UNIQUE_KEY_NAME := 'LIST_NAME';
    elsif X_LOV_REGION_CODE = 'CZ_ATTRIBUTE_LISTS_NBR_REGION' then
	L_UNIQUE_KEY_NAME := 'NUMBER_LIST_NAME';
    end if;
    if L_UNIQUE_KEY_NAME is not null then
      open uk;
      fetch uk into l_unique_key_name;
	if (sql%found) then
	  L_LOV_REGION_APPLICATION_ID := X_LOV_REGION_APPLICATION_ID;
	  L_LOV_REGION_CODE := X_LOV_REGION_CODE;
	  L_LOV_ATTRIBUTE_APPLICATION_ID := 702;
	  L_LOV_ATTRIBUTE_CODE := 'LIST_NAME';
	  L_LOV_DEFAULT_FLAG := 'Y';
	  -- * no need to insert foreign key if one already exists * --
	  open cz;
	  fetch cz into L_LOV_FOREIGN_KEY_NAME;
	  if (sql%notfound) then
	    L_LOV_FOREIGN_KEY_NAME := null;
	  end if;
	  close cz;
/*
	  if L_LOV_FOREIGN_KEY_NAME is not null then
	    AK_ATTRIBUTES2_PKG.NEW_FOREIGN_KEY (
	  	X_FOREIGN_KEY_NAME => L_LOV_FOREIGN_KEY_NAME,
	  	X_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
	  	X_UNIQUE_KEY_NAME => L_UNIQUE_KEY_NAME,
	  	X_APPLICATION_ID => 702,
	  	X_ATTRIBUTE_APPLICATION_ID => 702,
	  	X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
	  	X_FROM_TO_NAME => X_MODE,
	  	X_CREATION_DATE => x_creation_date,
	  	X_CREATED_BY => x_created_by,
	  	X_LAST_UPDATE_DATE => x_last_update_date,
	  	X_LAST_UPDATED_BY => x_last_updated_by,
	  	X_LAST_UPDATE_LOGIN => x_last_update_login);
	  end if;
*/
	end if;
 	close uk;
    end if;
  end if;


-- * no need to insert object attribute if one already exists * --
  open c;
  fetch c into dummy;
  if (NOT c%notfound) then
    close c;
    X_OBJ_ATTR_SUCCESS := 'N';
  end if;
  close c;

-- * insert row into ak_object_attributes * --
ak_object_attributes_pkg.insert_row(
  X_ROWID => row_id,
  X_DATABASE_OBJECT_NAME => x_database_object_name,
  X_ATTRIBUTE_APPLICATION_ID => x_attribute_application_id,
  X_ATTRIBUTE_CODE => x_attribute_code,
  X_COLUMN_NAME => column_name_default,
  X_ATTRIBUTE_LABEL_LENGTH => x_attribute_label_length,
  X_BOLD => x_bold,
  X_ITALIC => x_italic,
  X_VERTICAL_ALIGNMENT => x_vertical_alignment,
  X_HORIZONTAL_ALIGNMENT => x_horizontal_alignment,
  X_ATTRIBUTE_LABEL_LONG => x_attribute_label_long,
  X_DATA_SOURCE_TYPE => x_data_source_type,
  X_DATA_STORAGE_TYPE => x_data_storage_type,
  X_TABLE_NAME => x_table_name,
  X_BASE_TABLE_COLUMN_NAME => NULL,
  X_REQUIRED_FLAG => 'N',
  X_DISPLAY_VALUE_LENGTH => X_DISPLAY_VALUE_LENGTH,
  X_LOV_REGION_APPLICATION_ID => L_LOV_REGION_APPLICATION_ID,
  X_LOV_REGION_CODE => L_LOV_REGION_CODE,
  X_LOV_FOREIGN_KEY_NAME => L_LOV_FOREIGN_KEY_NAME,
  X_LOV_ATTRIBUTE_APPLICATION_ID => L_LOV_ATTRIBUTE_APPLICATION_ID,
  X_LOV_ATTRIBUTE_CODE => L_LOV_ATTRIBUTE_CODE,
  X_DEFAULTING_API_PKG => NULL,
  X_DEFAULTING_API_PROC => NULL,
  X_VALIDATION_API_PKG => NULL,
  X_VALIDATION_API_PROC => NULL,
  X_DEFAULT_VALUE_VARCHAR2 => X_DEFAULT_VALUE_VARCHAR2,
  X_DEFAULT_VALUE_NUMBER => X_DEFAULT_VALUE_NUMBER,
  X_DEFAULT_VALUE_DATE => X_DEFAULT_VALUE_DATE,
  X_CREATION_DATE => x_creation_date,
  X_CREATED_BY => x_created_by,
  X_LAST_UPDATE_DATE => x_last_update_date,
  X_LAST_UPDATED_BY => x_last_updated_by,
  X_LAST_UPDATE_LOGIN => x_last_update_login,
  X_ATTRIBUTE_CATEGORY => NULL,
  X_ATTRIBUTE1 => NULL,
  X_ATTRIBUTE2 => NULL,
  X_ATTRIBUTE3 => NULL,
  X_ATTRIBUTE4 => NULL,
  X_ATTRIBUTE5 => NULL,
  X_ATTRIBUTE6 => NULL,
  X_ATTRIBUTE7 => NULL,
  X_ATTRIBUTE8 => NULL,
  X_ATTRIBUTE9 => NULL,
  X_ATTRIBUTE10 => NULL,
  X_ATTRIBUTE11 => NULL,
  X_ATTRIBUTE12 => NULL,
  X_ATTRIBUTE13 => NULL,
  X_ATTRIBUTE14 => NULL,
  X_ATTRIBUTE15 => NULL
);

commit;
X_OBJ_ATTR_SUCCESS := 'Y';

-- * If region_code passed in is not null, insert * --
-- * a region_item record as well                 * --

if x_region_code is not null then
AK_OBJECT_ATTRIBUTES_PKG.ADD_REGION_ITEM (
  X_REGION_APPLICATION_ID => x_region_application_id,
  X_REGION_CODE => x_region_code,
  X_ATTRIBUTE_APPLICATION_ID => x_attribute_application_id,
  X_ATTRIBUTE_CODE => x_attribute_code,
  X_ATTRIBUTE_LABEL_LENGTH => x_attribute_label_length,
  X_BOLD => x_bold,
  X_ITALIC => x_italic,
  X_VERTICAL_ALIGNMENT => x_vertical_alignment,
  X_HORIZONTAL_ALIGNMENT => x_horizontal_alignment,
  X_DEFAULT_VALUE_VARCHAR2 => X_DEFAULT_VALUE_VARCHAR2,
  X_DEFAULT_VALUE_NUMBER => X_DEFAULT_VALUE_NUMBER,
  X_DEFAULT_VALUE_DATE => X_DEFAULT_VALUE_DATE,
  X_LOV_FOREIGN_KEY_NAME => L_LOV_FOREIGN_KEY_NAME,
  X_LOV_REGION_CODE => L_LOV_REGION_CODE,
  X_LOV_REGION_APPLICATION_ID => L_LOV_REGION_APPLICATION_ID,
  X_LOV_ATTRIBUTE_APPLICATION_ID => L_LOV_ATTRIBUTE_APPLICATION_ID,
  X_LOV_ATTRIBUTE_CODE => L_LOV_ATTRIBUTE_CODE,
  X_LOV_DEFAULT_FLAG => L_LOV_DEFAULT_FLAG,
  X_ATTRIBUTE_LABEL_LONG => x_attribute_label_long,
  X_CREATION_DATE => x_creation_date,
  X_CREATED_BY => x_created_by,
  X_LAST_UPDATE_DATE => x_last_update_date,
  X_LAST_UPDATED_BY => x_last_updated_by,
  X_LAST_UPDATE_LOGIN => x_last_update_login,
  x_display_value_length => x_display_value_length,
  X_COMMIT => 'Y'
);
end if;

end ASSIGN_ATTRIBUTE;

--*****************************************************************************

procedure CHANGE_OBJECT_ATTRIBUTE (
  X_MODE in VARCHAR2,
  X_DATABASE_OBJECT_NAME in VARCHAR2,
  X_ATTRIBUTE_APPLICATION_ID in NUMBER,
  X_ATTRIBUTE_CODE in VARCHAR2,
  X_ATTRIBUTE_LABEL_LENGTH in NUMBER,
  X_BOLD in VARCHAR2,
  X_ITALIC in VARCHAR2,
  X_VERTICAL_ALIGNMENT in VARCHAR2,
  X_HORIZONTAL_ALIGNMENT in VARCHAR2,
  X_DEFAULT_VALUE_VARCHAR2 in VARCHAR2,
  X_DEFAULT_VALUE_NUMBER in NUMBER,
  X_DEFAULT_VALUE_DATE in DATE,
  X_ATTRIBUTE_LABEL_LONG in VARCHAR2,
  X_OLD_LOV_REGION_CODE in VARCHAR2,
  X_OLD_LOV_REGION_APPL_ID in NUMBER,
  X_NEW_LOV_REGION_CODE in VARCHAR2,
  X_NEW_LOV_REGION_APPL_ID in NUMBER,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER)
IS
-- * local variables * --
  L_LOV_FOREIGN_KEY_NAME varchar2(30)	:= null;
  L_LOV_REGION_APPLICATION_ID number	:= null;
  L_LOV_REGION_CODE varchar2(30)		:= null;
  L_LOV_ATTRIBUTE_APPLICATION_ID number	:= null;
  L_LOV_ATTRIBUTE_CODE varchar2(30)		:= null;
  L_LOV_DEFAULT_FLAG VARCHAR2(1)		:= null;
  L_UNIQUE_KEY_NAME varchar2(30)		:= null;
  row_id varchar2(30);
  lang varchar2(30);
  L_REGION_APPLICATION_ID number(15);
  L_REGION_CODE varchar2(30);
-- * cursor definition * --
cursor c is
  select region_application_id,region_code
  from   ak_regions
  where  database_object_name = x_database_object_name;

 cursor uk is
	select unique_key_name from ak_unique_keys
	  where unique_key_name = L_UNIQUE_KEY_NAME;

begin
  lang := fnd_global.current_language;

  if X_NEW_LOV_REGION_CODE = 'CZ_ATTRIBUTE_LISTS_REGION' then
    L_UNIQUE_KEY_NAME := 'LIST_NAME';
  elsif X_NEW_LOV_REGION_CODE = 'CZ_ATTRIBUTE_LISTS_NBR_REGION' then
    L_UNIQUE_KEY_NAME := 'NUMBER_LIST_NAME';
  end if;

  if L_UNIQUE_KEY_NAME is not null then
      open uk;
      fetch uk into l_unique_key_name;
    if (sql%found) then
	L_LOV_REGION_APPLICATION_ID := X_NEW_LOV_REGION_APPL_ID;
	L_LOV_REGION_CODE := X_NEW_LOV_REGION_CODE;
	L_LOV_ATTRIBUTE_APPLICATION_ID := 702;
	L_LOV_ATTRIBUTE_CODE := 'LIST_NAME';
	L_LOV_DEFAULT_FLAG := 'Y';
-- The L_LOV_FOREIGN_KEY_NAME is returned from CHANGE_LOVS.
	AK_ATTRIBUTES2_PKG.CHANGE_LOVS(
	  X_DATABASE_OBJECT_NAME => X_DATABASE_OBJECT_NAME,
	  X_ATTRIBUTE_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
	  X_ATTRIBUTE_CODE => X_ATTRIBUTE_CODE,
	  X_OLD_LOV_REGION_CODE => X_OLD_LOV_REGION_CODE,
	  X_OLD_LOV_REGION_APPL_ID => X_OLD_LOV_REGION_APPL_ID,
	  X_NEW_LOV_REGION_CODE => X_NEW_LOV_REGION_CODE,
	  X_NEW_LOV_REGION_APPL_ID => X_NEW_LOV_REGION_APPL_ID,
	  X_LOV_FOREIGN_KEY_NAME => L_LOV_FOREIGN_KEY_NAME,
	  X_CREATION_DATE => x_creation_date,
	  X_CREATED_BY => x_created_by,
	  X_LAST_UPDATE_DATE => x_last_update_date,
	  X_LAST_UPDATED_BY => x_last_updated_by,
	  X_LAST_UPDATE_LOGIN => x_last_update_login);
    end if;
    close uk;
  end if;

  update ak_object_attributes set
	BOLD = X_BOLD,
	ITALIC = X_ITALIC,
	VERTICAL_ALIGNMENT = X_VERTICAL_ALIGNMENT,
	HORIZONTAL_ALIGNMENT = X_HORIZONTAL_ALIGNMENT,
	DEFAULT_VALUE_VARCHAR2 = X_DEFAULT_VALUE_VARCHAR2,
	DEFAULT_VALUE_NUMBER = X_DEFAULT_VALUE_NUMBER,
	DEFAULT_VALUE_DATE = X_DEFAULT_VALUE_DATE,
	ATTRIBUTE_LABEL_LENGTH = X_ATTRIBUTE_LABEL_LENGTH,
	LOV_FOREIGN_KEY_NAME = L_LOV_FOREIGN_KEY_NAME,
	LOV_REGION_APPLICATION_ID = L_LOV_REGION_APPLICATION_ID,
	LOV_REGION_CODE = L_LOV_REGION_CODE,
	LOV_ATTRIBUTE_APPLICATION_ID = L_LOV_ATTRIBUTE_APPLICATION_ID,
	LOV_ATTRIBUTE_CODE = L_LOV_ATTRIBUTE_CODE,
	LAST_UPDATE_DATE = x_last_update_date,
	LAST_UPDATED_BY = x_last_updated_by,
	LAST_UPDATE_LOGIN = x_last_update_login
    where DATABASE_OBJECT_NAME = x_database_object_name
	and ATTRIBUTE_APPLICATION_ID = x_attribute_application_id
	and ATTRIBUTE_CODE = x_attribute_code;
  if (sql%notfound) then
    null;
  end if;

  update ak_object_attributes_tl set
	ATTRIBUTE_LABEL_LONG = X_ATTRIBUTE_LABEL_LONG,
	LAST_UPDATE_DATE = x_last_update_date,
	LAST_UPDATED_BY = x_last_updated_by,
	LAST_UPDATE_LOGIN = x_last_update_login
    where DATABASE_OBJECT_NAME = X_DATABASE_OBJECT_NAME
	and ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
	and ATTRIBUTE_CODE = X_ATTRIBUTE_CODE
	and LANGUAGE = lang;
  if (sql%notfound) then
    null;
  end if;

  open c;
  fetch c into L_REGION_APPLICATION_ID, L_REGION_CODE;
  loop exit when c%notfound;
    update ak_region_items set
	  DEFAULT_VALUE_VARCHAR2 = X_DEFAULT_VALUE_VARCHAR2,
	  DEFAULT_VALUE_NUMBER = X_DEFAULT_VALUE_NUMBER,
	  DEFAULT_VALUE_DATE = X_DEFAULT_VALUE_DATE,
	  LOV_FOREIGN_KEY_NAME = L_LOV_FOREIGN_KEY_NAME,
	  LOV_REGION_APPLICATION_ID = L_LOV_REGION_APPLICATION_ID,
	  LOV_REGION_CODE = L_LOV_REGION_CODE,
	  LOV_ATTRIBUTE_APPLICATION_ID = L_LOV_ATTRIBUTE_APPLICATION_ID,
	  LOV_ATTRIBUTE_CODE = L_LOV_ATTRIBUTE_CODE,
	  LOV_DEFAULT_FLAG = L_LOV_DEFAULT_FLAG,
	  LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	  LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	where REGION_APPLICATION_ID = L_REGION_APPLICATION_ID
	  and REGION_CODE = L_REGION_CODE
	  and ATTRIBUTE_APPLICATION_ID = X_ATTRIBUTE_APPLICATION_ID
	  and ATTRIBUTE_CODE = X_ATTRIBUTE_CODE;
    if (sql%notfound) then
	null;
    end if;
    fetch c into L_REGION_APPLICATION_ID, L_REGION_CODE;
  end loop;
  close c;
end CHANGE_OBJECT_ATTRIBUTE;

end AK_ATTRIBUTES2_PKG;

/
