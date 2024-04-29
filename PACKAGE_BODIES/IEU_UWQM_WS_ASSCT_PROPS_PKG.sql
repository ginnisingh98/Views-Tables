--------------------------------------------------------
--  DDL for Package Body IEU_UWQM_WS_ASSCT_PROPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQM_WS_ASSCT_PROPS_PKG" as
/* $Header: IEUWRAPB.pls 120.1 2005/06/15 22:14:13 appldev  $ */

procedure insert_row(
x_rowid in out NOCOPY Varchar2,
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_tasks_rules_function IN varchar2
) is


  cursor C is select ROWID from IEU_UWQM_WS_ASSCT_PROPS
    where ws_association_prop_id = p_ws_association_prop_id;

--  l_ws_assoc_prop_id  number;

begin

--  select IEU_UWQM_WS_ASSCT_PROPS_S1.NEXTVAL into l_ws_assoc_prop_id from sys.dual;

  insert into IEU_UWQM_WS_ASSCT_PROPS(
  ws_association_prop_id,
  parent_ws_id,
  child_ws_id,
  dist_st_based_on_parent_flag,
  ws_id,
  tasks_rules_function,
  OBJECT_VERSION_NUMBER,
  CREATED_BY,
  CREATION_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN
  )
  VALUES(
  p_ws_association_prop_id,
  p_parent_ws_id,
  p_child_ws_id,
  p_dist_st_based_on_parent_flag,
  p_ws_id,
  p_tasks_rules_function,
  1,
  fnd_global.user_id,
  sysdate,
  fnd_global.user_id,
  sysdate,
  fnd_global.login_id
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
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_tasks_rules_function IN varchar2,
p_object_version_number in number
) is
cursor c is select
  object_version_number,
  parent_ws_id,
  child_ws_id,
  dist_st_based_on_parent_flag,
  ws_id,
  tasks_rules_function
  from ieu_uwqm_ws_assct_props
  where ws_association_prop_id = p_ws_association_prop_id
  for update of ws_association_prop_id nowait;
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
      AND(recinfo.parent_ws_id = p_parent_ws_id)
      AND(recinfo.child_ws_id = p_child_ws_id)
      AND(recinfo.dist_st_based_on_parent_flag = p_dist_st_based_on_parent_flag)
      AND(recinfo.ws_id = p_ws_id)
      AND(recinfo.tasks_rules_function = p_tasks_rules_function))
  then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

END LOCK_ROW;

procedure update_row(
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_tasks_rules_function IN varchar2
) is
begin
   update ieu_uwqm_ws_assct_props set
   object_version_number = object_version_number+1,
   parent_ws_id = p_parent_ws_id,
   child_ws_id = p_child_ws_id,
   dist_st_based_on_parent_flag = p_dist_st_based_on_parent_flag,
   ws_id = p_ws_id,
   tasks_rules_function = p_tasks_rules_function,
   last_update_date = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.login_id
   where ws_association_prop_id = p_ws_association_prop_id;

   if (sql%notfound) then
      raise no_data_found;
   end if;

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;


procedure delete_row(
p_ws_association_prop_id in number
) is
begin
  delete from ieu_uwqm_ws_assct_props
  where ws_association_prop_id = p_ws_association_prop_id;

  if (sql%notfound) then
     raise no_data_found;
  end if;

END DELETE_ROW;


procedure load_row(
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_owner in varchar2,
p_tasks_rules_function IN varchar2
) is

  l_user_id number := 0;
  l_rowid varchar2(50);

begin
  if (p_owner = 'SEED') then
     l_user_id := 1;
  end if;

  begin
     update_row(
     p_ws_association_prop_id => p_ws_association_prop_id,
     p_parent_ws_id => p_parent_ws_id,
     p_child_ws_id => p_child_ws_id,
     p_dist_st_based_on_parent_flag => p_dist_st_based_on_parent_flag,
     p_ws_id => p_ws_id,
     p_tasks_rules_function => p_tasks_rules_function
     );

     if (sql%notfound) then
        raise no_data_found;
     end if;

     exception when no_data_found then
     insert_row(
      x_rowid => l_rowid,
      p_ws_association_prop_id => p_ws_association_prop_id,
      p_parent_ws_id => p_parent_ws_id,
      p_child_ws_id => p_child_ws_id,
      p_dist_st_based_on_parent_flag => p_dist_st_based_on_parent_flag,
      p_ws_id => p_ws_id,
      p_tasks_rules_function => p_tasks_rules_function
      );
  end;

END LOAD_ROW;

procedure load_seed_row(
p_upload_mode in varchar2,
p_ws_association_prop_id in number,
p_parent_ws_id in number,
p_child_ws_id in number,
p_dist_st_based_on_parent_flag in varchar2,
p_ws_id in number,
p_owner in varchar2,
p_tasks_rules_function IN varchar2
)is
begin

if (p_upload_mode = 'NLS') then
  null;
else
  load_row(
    p_ws_association_prop_id,
    p_parent_ws_id,
    p_child_ws_id,
    p_dist_st_based_on_parent_flag,
    p_ws_id,
    p_owner,
    p_tasks_rules_function);
end if;

end load_seed_row;



END IEU_UWQM_WS_ASSCT_PROPS_PKG;

/
