--------------------------------------------------------
--  DDL for Package Body IEU_WP_UI_COMP_DATATYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_WP_UI_COMP_DATATYPES_PKG" as
/* $Header: IEUVCDTB.pls 120.1 2005/06/20 01:06:21 appldev ship $ */

procedure insert_row(
x_rowid in out nocopy Varchar2,
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_object_version_number in number,
p_created_by in number,
p_creation_date in date,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_data_type in varchar2
) is
  cursor C is select ROWID from IEU_WP_UI_COMP_DATATYPES
    where UI_COMP_DATATYPE_MAP_ID = P_UI_COMP_DATATYPE_MAP_ID;

begin
  insert into IEU_WP_UI_COMP_DATATYPES (
  UI_COMP_DATATYPE_MAP_ID,
  UI_COMP_ID ,
  OBJECT_VERSION_NUMBER,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  DATA_TYPE
 )
  VALUES(
  p_ui_comp_datatype_map_id,
  p_ui_comp_id,
  p_object_version_number,
  p_created_by,
  p_creation_date,
  p_last_updated_by,
  p_last_update_date,
  p_last_update_login,
  p_data_type
  );

  open c;
  fetch c into x_rowid;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

END INSERT_ROW;


procedure lock_row(
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_object_version_number in number,
p_data_type in varchar2
) is
cursor c is select
  object_version_number,
  data_type
  from ieu_wp_ui_comp_datatypes
  where ui_comp_datatype_map_id = p_ui_comp_datatype_map_id
  for update of ui_comp_datatype_map_id nowait;
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

  if ((recinfo.object_version_number = p_object_version_number)
      AND(recinfo.data_type = p_data_type))
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

END LOCK_ROW;

procedure update_row(
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_last_updated_by in number,
p_last_update_date in date,
p_last_update_login in number,
p_data_type in varchar2
) is
begin
   update IEU_WP_UI_COMP_DATATYPES set
   object_version_number = object_version_number+1,
   data_type = p_data_type,
   ui_comp_id = p_ui_comp_id,
   last_update_date = p_last_update_date,
   last_updated_by = p_last_updated_by,
   last_update_login = p_last_update_login
   where ui_comp_datatype_map_id = p_ui_comp_datatype_map_id;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;


procedure delete_row(
p_ui_comp_datatype_map_id in number
) is
begin
  delete from IEU_WP_UI_COMP_DATATYPES
  where ui_comp_datatype_map_id = p_ui_comp_datatype_map_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

END DELETE_ROW;



procedure load_row(
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_data_type in varchar2,
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
     p_ui_comp_datatype_map_id => p_ui_comp_datatype_map_id,
     p_ui_comp_id => p_ui_comp_id,
     --p_last_updated_by => l_user_id,
     p_last_updated_by => fnd_load_util.owner_id(p_owner),
     p_last_update_date => sysdate,
     p_last_update_login => 0,
     p_data_type => p_data_type
     );

     if (sql%notfound) then
        raise no_data_found;
     end if;

   exception when no_data_found then
     insert_row(
      x_rowid => l_rowid,
      p_ui_comp_datatype_map_id => p_ui_comp_datatype_map_id,
      p_ui_comp_id => p_ui_comp_id,
      p_object_version_number => 1,
      --p_created_by => l_user_id,
      p_created_by => fnd_load_util.owner_id(p_owner),
      p_creation_date => sysdate,
      --p_last_updated_by => l_user_id,
      p_last_updated_by => fnd_load_util.owner_id(p_owner),
      p_last_update_date => sysdate,
      p_last_update_login => 0,
      p_data_type => p_data_type
      );
  end;

END LOAD_ROW;

procedure load_seed_row(
p_upload_mode in varchar2,
p_ui_comp_datatype_map_id in number,
p_ui_comp_id in number,
p_data_type in varchar2,
p_owner in varchar2
) is
begin

if (p_upload_mode = 'NLS') then
  NULL;
else
  load_row(
    p_ui_comp_datatype_map_id,
    p_ui_comp_id,
    p_data_type,
    p_owner);
end if;

end load_seed_row;

END IEU_WP_UI_COMP_DATATYPES_PKG;

/
