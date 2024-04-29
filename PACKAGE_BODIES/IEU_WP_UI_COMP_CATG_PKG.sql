--------------------------------------------------------
--  DDL for Package Body IEU_WP_UI_COMP_CATG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_UI_COMP_CATG_PKG" as
/* $Header: IEUVCCAB.pls 120.1 2005/06/20 01:02:17 appldev ship $ */

procedure insert_row(
x_rowid in out nocopy Varchar2,
p_ui_comp_catg_id in number,
p_object_version_number in number,
p_created_by in number,
p_creation_date in date,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_ui_comp_catg_code in varchar2,
p_ui_comp_catg_label in varchar2,
p_ui_comp_catg_desc in varchar2
) is
  cursor C is select ROWID from IEU_WP_UI_COMP_CATG_B
    where UI_COMP_CATG_ID = P_UI_COMP_CATG_ID;

begin
  insert into IEU_WP_UI_COMP_CATG_B (
  UI_COMP_CATG_ID,
  OBJECT_VERSION_NUMBER,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  UI_COMP_CATG_CODE
  )
  VALUES(
  p_ui_comp_catg_id,
  p_object_version_number,
  p_created_by,
  p_creation_date,
  p_last_updated_by,
  p_last_update_date,
  p_last_update_login,
  p_ui_comp_catg_code
  );

  insert into IEU_WP_UI_COMP_CATG_TL (
  UI_COMP_CATG_ID,
  OBJECT_VERSION_NUMBER,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  UI_COMP_CATG_LABEL,
  UI_COMP_CATG_DESC,
  LANGUAGE,
  SOURCE_LANG
  ) select
  p_ui_comp_catg_id,
  p_object_version_number,
  p_created_by,
  p_creation_date,
  p_last_updated_by,
  p_last_update_date,
  p_last_update_login,
  p_ui_comp_catg_label,
  p_ui_comp_catg_desc,
  l.language_code,
  userenv('LANG')
  from fnd_languages l
  where l.installed_flag in ('I', 'B')
  and not exists
  (select null from ieu_wp_ui_comp_catg_tl t
   where t.ui_comp_catg_id = p_ui_comp_catg_id
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
p_ui_comp_catg_id in number,
p_object_version_number in number,
p_ui_comp_catg_code in varchar2,
p_ui_comp_catg_label in varchar2,
p_ui_comp_catg_desc in varchar2
) is
cursor c is select
  object_version_number,
  ui_comp_catg_code
  from ieu_wp_ui_comp_catg_b
  where ui_comp_catg_id = p_ui_comp_catg_id
  for update of ui_comp_catg_id nowait;
recinfo c%rowtype;

cursor c1 is select
  ui_comp_catg_label,
  ui_comp_catg_desc,
  decode(language, userenv('LANG'), 'Y', 'N') BASELANG
  from ieu_wp_ui_comp_catg_tl
  where ui_comp_catg_id = p_ui_comp_catg_id
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
  for update of ui_comp_catg_id nowait;

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
      AND (recinfo.ui_comp_catg_code = p_ui_comp_catg_code))
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
       if ((tlinfo.ui_comp_catg_label = p_ui_comp_catg_label)
           and (tlinfo.ui_comp_catg_desc = p_ui_comp_catg_desc))
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
p_ui_comp_catg_id in number,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_ui_comp_catg_code in varchar2,
p_ui_comp_catg_label in varchar2,
p_ui_comp_catg_desc in varchar2
) is
begin
   update IEU_WP_UI_COMP_CATG_B set
   object_version_number = object_version_number+1,
   ui_comp_catg_code = p_ui_comp_catg_code,
   last_update_date = p_last_update_date,
   last_updated_by = p_last_updated_by,
   last_update_login = p_last_update_login
   where ui_comp_catg_id = p_ui_comp_catg_id;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   update IEU_WP_UI_COMP_CATG_TL set
   ui_comp_catg_label = p_ui_comp_catg_label,
   ui_comp_catg_desc = p_ui_comp_catg_desc,
   last_update_date = p_last_update_date,
   last_updated_by = p_last_updated_by,
   last_update_login = p_last_update_login,
   object_version_number = object_version_number+1,
   source_lang = userenv('LANG')
   where ui_comp_catg_id = p_ui_comp_catg_id
   and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;


procedure delete_row(
p_ui_comp_catg_id in number
) is
begin
  delete from IEU_WP_UI_COMP_CATG_TL
  where ui_comp_catg_id = p_ui_comp_catg_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

  delete from ieu_wp_ui_comp_catg_b
  where ui_comp_catg_id = p_ui_comp_catg_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

END DELETE_ROW;


procedure add_language is

begin
  delete from IEU_WP_UI_COMP_CATG_TL t
  where not exists
     (select null
      from ieu_wp_ui_comp_catg_b b
       where b.ui_comp_catg_id = t.ui_comp_catg_id);

  update ieu_wp_ui_comp_catg_tl t
  set (ui_comp_catg_label, ui_comp_catg_desc)
      = (select b.ui_comp_catg_label,
         b.ui_comp_catg_desc
         from ieu_wp_ui_comp_catg_tl b
         where b.ui_comp_catg_id = t.ui_comp_catg_id
         and b.language= t.source_lang)
   where ( t.ui_comp_catg_id, t.language )
   in (select subt.ui_comp_catg_id, subt.language
       from ieu_wp_ui_comp_catg_tl subb, ieu_wp_ui_comp_catg_tl subt
       where subb.ui_comp_catg_id = subt.ui_comp_catg_id
        and subb.language = subt.source_lang
        and (subb.ui_comp_catg_label <> subt.ui_comp_catg_label
            or subb.ui_comp_catg_desc <> subt.ui_comp_catg_desc));

   insert into ieu_wp_ui_comp_catg_tl(
    UI_COMP_CATG_ID,
    OBJECT_VERSION_NUMBER,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    UI_COMP_CATG_LABEL,
    UI_COMP_CATG_DESC,
    LANGUAGE,
    SOURCE_LANG
    ) select /*+ ORDERED */
    b.ui_comp_catg_id,
    b.object_version_number,
    b.created_by,
    b.creation_date,
    b.last_updated_by,
    b.last_update_date,
    b.last_update_login,
    b.ui_comp_catg_label,
    b.ui_comp_catg_desc,
    l.language_code,
    b.source_lang
    from ieu_wp_ui_comp_catg_tl b, fnd_languages l
    where l.installed_flag in ('I', 'B')
    and b.language= userenv('LANG')
    and not exists
        (select null from ieu_wp_ui_comp_catg_tl t
         where t.ui_comp_catg_id = b.ui_comp_catg_id
        and t.language = l.language_code);

END ADD_LANGUAGE;


procedure load_row(
p_ui_comp_catg_id in number,
p_ui_comp_catg_code in varchar2,
p_ui_comp_catg_label in varchar2,
p_ui_comp_catg_desc in varchar2,
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
     p_ui_comp_catg_id => p_ui_comp_catg_id,
     --p_last_updated_by => l_user_id,
     p_last_updated_by => fnd_load_util.owner_id(p_owner),
     p_last_update_date => sysdate,
     p_last_update_login => 0,
     p_ui_comp_catg_code => p_ui_comp_catg_code,
     p_ui_comp_catg_label => p_ui_comp_catg_label,
     p_ui_comp_catg_desc => p_ui_comp_catg_desc);

     if (sql%notfound) then
        raise no_data_found;
     end if;

   exception when no_data_found then
     insert_row(
      x_rowid => l_rowid,
      p_ui_comp_catg_id => p_ui_comp_catg_id,
      p_object_version_number => 1,
      --p_created_by => l_user_id,
      p_created_by => fnd_load_util.owner_id(p_owner),
      p_creation_date => sysdate,
      --p_last_updated_by => l_user_id,
      p_last_updated_by => fnd_load_util.owner_id(p_owner),
      p_last_update_date => sysdate,
      p_last_update_login => 0,
      p_ui_comp_catg_code => p_ui_comp_catg_code,
      p_ui_comp_catg_label => p_ui_comp_catg_label,
      p_ui_comp_catg_desc => p_ui_comp_catg_desc);
  end;

END LOAD_ROW;

procedure translate_row(
p_ui_comp_catg_id in number,
p_ui_comp_catg_label in varchar2,
p_ui_comp_catg_desc in varchar2,
p_owner in varchar2
) is
begin
  update IEU_WP_UI_COMP_CATG_TL
  set source_lang = userenv('LANG'),
  ui_comp_catg_label = p_ui_comp_catg_label,
  ui_comp_catg_desc = p_ui_comp_catg_desc,
  last_update_date = sysdate,
  --last_updated_by = decode(p_owner, 'SEED', 1, 0),
  last_updated_by = fnd_load_util.owner_id(p_owner),
  last_update_login = 0
  where (ui_comp_catg_id = p_ui_comp_catg_id)
  and (userenv('LANG') IN (LANGUAGE, SOURCE_LANG));

  if (sql%notfound) then
     raise no_data_found;
  end if;

END TRANSLATE_ROW;

procedure load_seed_row(
p_upload_mode in varchar2,
p_ui_comp_catg_id in number,
p_ui_comp_catg_code in varchar2,
p_ui_comp_catg_label in varchar2,
p_ui_comp_catg_desc in varchar2,
p_owner in varchar2
)is
begin

if (p_upload_mode = 'NLS') then
  translate_row(
    p_ui_comp_catg_id,
    p_ui_comp_catg_label,
    p_ui_comp_catg_desc,
    p_owner);
else
  load_row(
    p_ui_comp_catg_id,
    p_ui_comp_catg_code,
    p_ui_comp_catg_label,
    p_ui_comp_catg_desc,
    p_owner);
end if;

end load_seed_row;

END IEU_WP_UI_COMP_CATG_PKG;

/
