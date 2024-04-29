--------------------------------------------------------
--  DDL for Package Body IEU_WP_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_PROPERTIES_PKG" as
/* $Header: IEUVPROB.pls 120.1 2005/06/20 01:19:35 appldev ship $ */

procedure insert_row(
x_rowid in out nocopy Varchar2,
p_property_id in number,
p_object_version_number in number,
p_created_by in number,
p_creation_date in date,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2
) is
  cursor C is select ROWID from IEU_WP_PROPERTIES_B
    where PROPERTY_ID = P_property_id;

begin
  insert into IEU_WP_PROPERTIES_B (
  PROPERTY_ID,
  OBJECT_VERSION_NUMBER,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  PROPERTY_SET_TYPE_CODE,
  PROPERTY_SET_TYPE_ID,
  PROPERTY_NAME,
  PROPERTY_DEFAULT_VALUE,
  VALUE_OVERRIDE_FLAG,
  VALUE_TRANSLATABLE_FLAG,
  FORM_ITEM_PROPERTY_FLAG,
  NOT_VALID_FLAG
  )   VALUES(
  P_PROPERTY_ID,
  P_OBJECT_VERSION_NUMBER,
  P_CREATED_BY,
  P_CREATION_DATE,
  P_LAST_UPDATED_BY,
  P_LAST_UPDATE_DATE,
  P_LAST_UPDATE_LOGIN,
  P_PROPERTY_SET_TYPE_CODE,
  P_PROPERTY_SET_TYPE_ID,
  P_PROPERTY_NAME,
  P_PROPERTY_DEFAULT_VALUE,
  P_VALUE_OVERRIDE_FLAG,
  P_VALUE_TRANSLATABLE_FLAG,
  P_FORM_ITEM_PROPERTY_FLAG,
  P_NOT_VALID_FLAG
  );

  insert into IEU_WP_PROPERTIES_TL (
  PROPERTY_ID,
  OBJECT_VERSION_NUMBER,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  PROPERTY_LABEL,
  PROPERTY_DESCRIPTION,
  LANGUAGE,
  SOURCE_LANG
  ) select
  P_PROPERTY_ID,
  P_OBJECT_VERSION_NUMBER,
  P_CREATED_BY,
  P_CREATION_DATE,
  P_LAST_UPDATED_BY,
  P_LAST_UPDATE_DATE,
  P_LAST_UPDATE_LOGIN,
  P_PROPERTY_LABEL,
  P_PROPERTY_DESCRIPTION,
  l.language_code,
  userenv('LANG')
  from fnd_languages l
  where l.installed_flag in ('I', 'B')
  and not exists
  (select null from ieu_wp_properties_tl t
   where t.property_id = p_property_id
   and t.language = l.language_code);

  open c;
  fetch c into x_rowid;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;


procedure lock_row(
p_property_id in number,
p_object_version_number in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2
) is
cursor c is select
  object_version_number,
  property_set_type_code,
  PROPERTY_SET_TYPE_ID,
  PROPERTY_NAME,
  PROPERTY_DEFAULT_VALUE,
  VALUE_OVERRIDE_FLAG,
  VALUE_TRANSLATABLE_FLAG,
  FORM_ITEM_PROPERTY_FLAG,
  NOT_VALID_FLAG
  from ieu_wp_properties_b
  where property_id = p_property_id
  for update of property_id nowait;
recinfo c%rowtype;

cursor c1 is select
  PROPERTY_LABEL,
  PROPERTY_DESCRIPTION,
  decode(language, userenv('LANG'), 'Y', 'N') BASELANG
  from ieu_wp_properties_tl
  where property_id = p_property_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  for update of property_id nowait;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if ((recinfo.object_version_number = p_object_version_number)
       AND(recinfo.property_set_type_code =p_property_set_type_code)
       AND(recinfo.property_set_type_id =p_property_set_type_id)
       AND(recinfo.property_name =p_property_name)
       AND(recinfo.property_default_value =p_property_default_value)
       AND(recinfo.value_override_flag = p_value_override_flag)
       AND(recinfo.value_translatable_flag = p_value_translatable_flag)
       AND(recinfo.form_item_property_flag = p_form_item_property_flag)
       AND(recinfo.not_valid_flag = p_not_valid_flag))
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
       if ((tlinfo.PROPERTY_LABEL = p_property_label)
           AND(tlinfo.PROPERTY_DESCRIPTION =p_property_description))
       then
          null;
       else
          fnd_message.set_name('FND','FORM_RECORD_CHANGED');
          app_exception.raise_exception;
       end if;
    end if;
  end loop;
  return;

END LOCK_ROW;

procedure update_row(
p_property_id in number,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2
) is
begin
   update IEU_WP_PROPERTIES_B set
   object_version_number = object_version_number+1,
   last_update_date = p_last_update_date,
   last_updated_by = p_last_updated_by,
   last_update_login = p_last_update_login,
   PROPERTY_SET_TYPE_CODE =p_property_set_type_code,
   PROPERTY_SET_TYPE_ID=p_property_set_type_id,
   PROPERTY_NAME = p_property_name,
   PROPERTY_DEFAULT_VALUE = p_property_default_value,
   VALUE_OVERRIDE_FLAG = p_value_override_flag,
   VALUE_TRANSLATABLE_FLAG = p_value_translatable_flag,
   FORM_ITEM_PROPERTY_FLAG = p_form_item_property_flag,
   NOT_VALID_FLAG = p_not_valid_flag
   where property_id = p_property_id;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   update IEU_WP_PROPERTIES_TL set
   property_label = p_property_label,
   property_description = p_property_description,
   last_update_date = p_last_update_date,
   last_updated_by = p_last_updated_by,
   last_update_login = p_last_update_login,
   object_version_number = object_version_number+1,
   source_lang = userenv('LANG')
   where property_id = p_property_id
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;


procedure delete_row(
p_property_id in number
) is
begin
  delete from IEU_WP_PROPERTIES_TL
  where property_id = p_property_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

  delete from ieu_wp_properties_b
  where property_id = p_property_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

END DELETE_ROW;


procedure add_language is

begin
  delete from IEU_WP_PROPERTIES_TL t
  where not exists
     (select null
      from ieu_wp_properties_b b
       where b.property_id = t.property_id);

  update ieu_wp_properties_tl t
  set (property_label, property_description)
      = (select b.property_label,
         b.property_description
         from ieu_wp_properties_tl b
         where b.property_id = t.property_id
         and b.language= t.source_lang)
   where ( t.property_id, t.language )
   in (select subt.property_id, subt.language
       from ieu_wp_properties_tl subb, ieu_wp_properties_tl subt
       where subb.property_id = subt.property_id
        and subb.language = subt.source_lang
        and (subb.property_label <> subt.property_label
            or subb.property_description <> subt.property_description));

   insert into ieu_wp_properties_tl(
    property_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    property_LABEL,
    property_DESCription,
    LANGUAGE,
    SOURCE_LANG
    ) select /*+ ORDERED */
    b.property_id,
    b.object_version_number,
    b.created_by,
    b.creation_date,
    b.last_updated_by,
    b.last_update_date,
    b.last_update_login,
    b.property_label,
    b.property_description,
    l.language_code,
    b.source_lang
    from ieu_wp_properties_tl b, fnd_languages l
    where l.installed_flag in ('I', 'B')
    and b.language= userenv('LANG')
    and not exists
        (select null from ieu_wp_properties_tl t
         where t.property_id = b.property_id
        and t.language = l.language_code);

END ADD_LANGUAGE;


procedure load_row(
p_property_id in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2,
p_owner in varchar2
) is

  l_user_id number := 0;
  l_rowid varchar2(50);

begin
  if (p_owner = 'SEED') then
     l_user_id := 1;
  end if;

  begin
     update_row(
     p_property_id => p_property_id,
     --p_last_updated_by => l_user_id,
     p_last_updated_by => fnd_load_util.owner_id(p_owner),
     p_last_update_date => sysdate,
     p_last_update_login => 0,
     p_property_set_type_code => p_property_set_type_code,
     p_property_set_type_id => p_property_set_type_id,
     p_property_name => p_property_name,
     p_property_default_value => p_property_default_value,
     p_value_override_flag => p_value_override_flag,
     p_value_translatable_flag => p_value_translatable_flag,
     p_form_item_property_flag => p_form_item_property_flag,
     p_not_valid_flag => p_not_valid_flag,
     p_property_label => p_property_label,
     p_property_description => p_property_description);

     if (sql%notfound) then
        raise no_data_found;
     end if;

   exception when no_data_found then
     insert_row(
     x_rowid => l_rowid,
     p_property_id => p_property_id,
     p_object_version_number => 1,
     --p_created_by => l_user_id,
     p_created_by => fnd_load_util.owner_id(p_owner),
     p_creation_date => sysdate,
     --p_last_updated_by => l_user_id,
     p_last_updated_by => fnd_load_util.owner_id(p_owner),
     p_last_update_date => sysdate,
     p_last_update_login => 0,
     p_property_set_type_code => p_property_set_type_code,
     p_property_set_type_id => p_property_set_type_id,
     p_property_name => p_property_name,
     p_property_default_value => p_property_default_value,
     p_value_override_flag => p_value_override_flag,
     p_value_translatable_flag => p_value_translatable_flag,
     p_form_item_property_flag => p_form_item_property_flag,
     p_not_valid_flag => p_not_valid_flag,
     p_property_label => p_property_label,
     p_property_description => p_property_description);
  end;

END LOAD_ROW;

procedure translate_row(
p_property_id in number,
p_property_label in varchar2,
p_property_description in varchar2,
p_owner in varchar2
) is
begin
  update IEU_WP_PROPERTIES_TL
  set source_lang = userenv('LANG'),
  property_label = p_property_label,
  property_description = p_property_description,
  last_update_date = sysdate,
  --last_updated_by = decode(p_owner, 'SEED', 1, 0),
  last_updated_by = fnd_load_util.owner_id(p_owner),
  last_update_login = 0
  where (property_id = p_property_id)
  and (userenv('LANG') IN (LANGUAGE, SOURCE_LANG));

  if (sql%notfound) then
     raise no_data_found;
  end if;

END TRANSLATE_ROW;

procedure load_seed_row(
p_upload_mode in varchar2,
p_property_id in number,
p_property_set_type_code in varchar2,
p_property_set_type_id in number,
p_property_name in varchar2,
p_property_default_value in varchar2,
p_value_override_flag in varchar2,
p_value_translatable_flag in varchar2,
p_form_item_property_flag in varchar2,
p_not_valid_flag in varchar2,
p_property_label in varchar2,
p_property_description in varchar2,
p_owner in varchar2
) is
begin

if (p_upload_mode = 'NLS') then
  translate_row(
    p_property_id,
    p_property_label,
    p_property_description,
    p_owner);
else
  load_row(
    p_property_id,
    p_property_set_type_code,
    p_property_set_type_id,
    p_property_name,
    p_property_default_value,
    p_value_override_flag,
    p_value_translatable_flag,
    p_form_item_property_flag,
    p_not_valid_flag,
    p_property_label,
    p_property_description,
    p_owner);
end if;

end load_seed_row;

END IEU_WP_PROPERTIES_PKG;

/
