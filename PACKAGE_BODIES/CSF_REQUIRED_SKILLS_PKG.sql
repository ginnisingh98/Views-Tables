--------------------------------------------------------
--  DDL for Package Body CSF_REQUIRED_SKILLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_REQUIRED_SKILLS_PKG" AS
/* $Header: CSFPRQSB.pls 120.1.12010000.4 2009/09/04 11:32:15 ramchint ship $ */


FUNCTION task_tpl_exists (p_task_tpl_id in number
                                   , p_task_tpl_grp_id number)
RETURN boolean
IS
  Cursor c_tpl is
    Select 1
    From jtf_task_templates_b
    Where task_template_id = p_task_tpl_id
    and task_group_id = p_task_tpl_grp_id;
  l_dummy_var number;
BEGIN
   /* Check if the task exists. */
   Open c_tpl;
   Fetch c_tpl into l_dummy_var;
   If c_tpl%notfound then
     Close c_tpl;
     Return false ;
   end if;
   close c_tpl;
   return true;
END task_tpl_exists;

FUNCTION task_exists (p_task_id in number)
RETURN boolean
IS
  Cursor c_task is
    Select 1
    From jtf_tasks_b
    Where task_id = p_task_id;
  l_dummy_var number;
BEGIN
   /* Check if the task exists. */
   Open c_task;
   Fetch c_task into l_dummy_var;
   If c_task%notfound then
     Close c_task;
     Return false ;
   end if;
   close c_task;
   return true;
END task_exists;

--Bug fixed 3560830

FUNCTION required_skill_exists ( p_task_id        in number
                               , p_skill_id       in number
                               , p_skill_type_id  in number)
RETURN boolean IS
  cursor c_reqSkill is
    select 1
    from csf_required_skills_b
    where skill_id       = p_skill_id
    and   skill_type_id  = p_skill_type_id
    and   has_skill_type = 'TASK'
    and   sysdate        >= trunc(start_date_active)
    and   (sysdate       <= trunc(end_date_active)+1 or end_date_active is null)
    and   has_skill_id   = p_task_id;

  l_dummy_var number := null;
BEGIN
  open c_reqSkill;
  fetch c_reqSkill into l_dummy_var;
  if l_dummy_var is not null then
     return true;  -- means i exist.
  end if;
  return false; -- means it didn't exist.
END required_skill_exists;


FUNCTION skill_exists ( p_skill_type_id in number
                      , p_skill_id      in number)
RETURN boolean
IS
    cursor c_obj ( p_skill_type_id varchar2 )
    is
      select 'SELECT '||name_number_column||', '||data_column||
             ' FROM '||from_clause||
             ' WHERE '||where_clause||' AND '||key_column||' = :b_skill_id'
      from csf_skill_types_b
      where skill_type_id = p_skill_type_id;

    l_qry  varchar2(2000);
    l_cur  integer;
    l_name varchar2(2000) := null;
    l_desc varchar2(2000) := null;
    l_cnt  integer;

BEGIN
    open c_obj ( p_skill_type_id );
    fetch c_obj into l_qry;
    if c_obj%notfound
    then
      close c_obj;
      return false;
    end if;
    close c_obj;

    -- declare a cursor for dynamic SQL
    l_cur := dbms_sql.open_cursor;
    -- parse query (constant 1 = dbms_sql.native)
    dbms_sql.parse(l_cur,l_qry,1);
    -- bind query input value
    dbms_sql.bind_variable(l_cur,'b_skill_id', p_skill_id);
    l_cnt := dbms_sql.execute_and_fetch(l_cur,false);
    dbms_sql.close_cursor(l_cur);
    if l_cnt <> 1
    then
      return false;
    end if;
    return true;
END skill_exists;

FUNCTION skill_level_exists ( p_skill_level_id in number)
RETURN boolean
IS
  Cursor c_skill_lvl is
    Select 1
    From csf_skill_levels_b
    Where skill_level_id = p_skill_level_id
    and (sysdate <= trunc(end_date_active)+1
         or end_date_active is null);
  l_dummy_var number;
BEGIN
   Open c_skill_lvl;
   Fetch c_skill_lvl into l_dummy_var;
   If c_skill_lvl %notfound then
     Close c_skill_lvl;
     Return false ;
   end if;
   close c_skill_lvl;
   return true;
END skill_level_exists;

PROCEDURE create_row
( p_api_version      in  number
, p_init_msg_list    in  varchar2
, p_commit           in  varchar2
, p_validation_level in  number
, x_return_status    out nocopy varchar2
, x_msg_count        out nocopy number
, x_msg_data         out nocopy varchar2
, p_task_id          in  number
, p_skill_type_id    in  number
, p_skill_id         in  number
, p_skill_level_id   in  number
, p_disabled_flag    in varchar2 default null) --new parameter added to forward port for bug 6978751

IS
    l_api_name    constant varchar2(30) := 'create_row';
    l_api_version constant number         := 1.0;
    l_req_skill_id number;
BEGIN
    -- standard call to check for call compatibility
    if not fnd_api.compatible_api_call (
                                         l_api_version
                                       , p_api_version
                                       , l_api_name
                                       , g_package_name
                                       )
    then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- initialize message list if p_init_msg_list is set to true
    if fnd_api.to_boolean(p_init_msg_list)
    then
      fnd_msg_pub.initialize;
    end if;

  /*  Check if  a required skill to be inserted does exist for a
     particular task (has_skill_id with has_skill_type = TASKS). If it
     does not exist then proceed to insert the record. Otherwise, DO NOT
     INSERT!!!!!!
  */
  if not required_skill_exists ( p_task_id
                               , p_skill_id
                               , p_skill_type_id)
  then

   /* Checks if task exist in JTF_TASK_B table. */
   If not task_exists (p_task_id) then
     X_return_status :=  fnd_api.g_ret_sts_error;
     X_msg_count     := 1;
     X_msg_data      := 'Task Id ('||to_char(p_task_id)||
                               ') does not exist in JTF_TASKS_B table.';
     return;
   end if;

   /* Checks if skill type and id exist. */
   If not skill_exists (p_skill_type_id, p_skill_id) then
     X_return_status :=  fnd_api.g_ret_sts_error;
     X_msg_count     := 1;
     X_msg_data      := 'Combination of skill id ('||p_skill_id||') '||
                               'and skill type id ('||p_skill_type_id||') '||
                               'does not exist in CSF_SKILLS_B table.';
     return;
   end if;

   /* Checks if skill level exists in CSF_SKILL_LEVELS_B. */
   If not skill_level_exists (p_skill_level_id) then
     X_return_status :=  fnd_api.g_ret_sts_error;
     X_msg_count     := 1;
     X_msg_data      := 'Skill level id ('||p_skill_level_id||') '||
                               'does not exist in CSF_SKILL_LEVELS_B table.';
     return;
   end if;

   /* When all checks are ok, insert record
      into CSF_REQUIRED_SKILLS table. */

    select csf_required_skills_b_s1.nextval
    into l_req_skill_id
    from dual;

    insert into csf_required_skills_b
    ( required_skill_id
    , skill_type_id
    , skill_id
    , has_skill_type
    , has_skill_id
    , skill_level_id
    , skill_required_flag
    , level_required_flag
    , disabled_flag
    , start_date_active
    , end_date_active
    , object_version_number
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , attribute1
    , attribute2
    , attribute3
    , attribute4
    , attribute5
    , attribute6
    , attribute7
    , attribute8
    , attribute9
    , attribute10
    , attribute11
    , attribute12
    , attribute13
    , attribute14
    , attribute15
    , attribute_category)
    values
    ( l_req_skill_id
    , p_skill_type_id
    , p_skill_id
    , 'TASK'
    , p_task_id
    , p_skill_level_id
    , null
    , null
    , p_disabled_flag
    , sysdate
    , null
    , 1
    , fnd_global.user_id
    , sysdate
    , fnd_global.user_id
    , sysdate
    , fnd_global.login_id
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null
    , null);

  if fnd_api.to_boolean(p_commit)
  then
       commit;
  end if;

     x_return_status := fnd_api.g_ret_sts_success;

--Bug Fixed 3884408
--When the required skill to be inserted into csf_required_skills_b table already  exist for
--the given task, Procedure create_row() must return status 'E' to calling function.
else
  if g_called_from_hook = 'T' then
     X_return_status :=  fnd_api.g_ret_sts_success;
  else
     X_return_status :=  fnd_api.g_ret_sts_error;
     X_msg_count     := 1;
     X_msg_data      := 'Combination of Skill id ('||p_skill_id||') and Skill type id ('||p_skill_type_id||') to be inserted does exist for Task ('||to_char(p_task_id)|| ') in  CSF_REQUIRED_SKILLS_B table';
  end if;
end if;
EXCEPTION
    when fnd_api.g_exc_error then
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.count_and_get ( p_count => x_msg_count
                                , p_data => x_msg_data );

    when fnd_api.g_exc_unexpected_error then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get ( p_count => x_msg_count
                                , p_data  => x_msg_data );

    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
      then
        fnd_msg_pub.add_exc_msg ( g_package_name, l_api_name );
      end if;
      fnd_msg_pub.count_and_get ( p_count => x_msg_count
                                , p_data  => x_msg_data );
END create_row;

PROCEDURE create_row_based_on_product ( x_return_status out nocopy varchar2 )
IS
   l_task_id number ;

   Cursor c_ProdSkill  is
     select mtl.inventory_item_id
     from jtf_tasks_b          tb
     ,    cs_incidents_all_b   sr
     ,    mtl_system_items_kfv mtl
     where mtl.organization_id = fnd_profile.value('CSF_INVENTORY_ORG')
     and sysdate between nvl(mtl.start_date_active,sysdate) and nvl(mtl.end_date_active,sysdate)
     and mtl.inventory_item_id = sr.inventory_item_id
     and sr.incident_id        = tb.source_object_id
     and tb.task_id            = l_task_id;

     cursor c_prod_cat_skill
     is
     SELECT c.category_id
      FROM mtl_category_set_valid_cats ic,
            mtl_categories_kfv c,
            mtl_category_sets_vl cs,
            mtl_categories_tl t,
            cs_incidents_all_b   sr,
            jtf_tasks_b tb
      WHERE ic.category_id = c.category_id
      AND t.category_id (+) = c.category_id
      AND t.language (+) = userenv('LANG')
      AND ic.category_set_id = cs.category_set_id
      AND ic.category_set_id =  fnd_profile.value('CS_SR_DEFAULT_CATEGORY_SET')
      AND Sysdate <= NVL(c.disable_date, Sysdate)
      AND c.category_id = sr.category_id
      AND sr.incident_id = tb.source_object_id
      and tb.task_id = l_task_id;

   l_api_name       constant varchar2(30) := 'create_row_based_on_product';
   l_return_status  varchar2(50);
   l_msg_count      number;
   l_msg_data       varchar2 (1000);

   l_skill_id       csf_skills_b.skill_id%type;
   l_skill_id1      csf_skills_b.skill_id%type;
   l_skill_level_id csf_skill_levels_b.skill_level_id%type;

BEGIN
  -- Check if required skill based on product/inventroy item
  -- has to be created.
  l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;
  g_called_from_hook := 'T';
  if nvl(fnd_profile.value('CSF_SR_ITEM_TO_TASK_REQ'), 'N') = 'Y'
  then
    -- Takes the Product Skills from the inv table
    open   c_ProdSkill;
    fetch c_ProdSkill into  l_skill_id;
    close  c_ProdSkill;
    if l_skill_id is not null
    then
      -- retrieving default values for skill type and level.
      l_skill_level_id  := fnd_profile.value('CSF_DFLT_SKILL_LEVEL');

      -- when either skill level is null do not proceed.
      if nvl(l_skill_level_id, null) is not null
      then

        create_row
        ( p_api_version   => 1
        , p_init_msg_list         => FND_API.G_FALSE
        , p_commit                => FND_API.G_FALSE
        , p_validation_level => FND_API.G_VALID_LEVEL_FULL
        , x_return_status         => l_return_status
        , x_msg_count             => l_msg_count
        , x_msg_data              => l_msg_data
        , p_task_id               => l_task_id
        , p_skill_type_id         => 2  -- This is the id for Product Skills.
        , p_skill_id              => l_skill_id
        , p_skill_level_id        => l_skill_level_id);

      end if;
    end if;
    end if;
    if  nvl(fnd_profile.value('CSF_SR_ITEM_CAT_TO_TASK_REQ'), 'N') = 'Y'
    then
    open   c_Prod_cat_skill;
    fetch c_Prod_cat_Skill into  l_skill_id1;
    close  c_Prod_cat_Skill;

    if l_skill_id1 is not null
    then
      -- retrieving default values for skill type and level.
      l_skill_level_id  := fnd_profile.value('CSF_DFLT_SKILL_LEVEL');

      -- when either skill level is null do not proceed.
      if nvl(l_skill_level_id, null) is not null
      then

        create_row
        ( p_api_version   => 1
        , p_init_msg_list         => FND_API.G_FALSE
        , p_commit                => FND_API.G_FALSE
        , p_validation_level => FND_API.G_VALID_LEVEL_FULL
        , x_return_status         => l_return_status
        , x_msg_count             => l_msg_count
        , x_msg_data              => l_msg_data
        , p_task_id               => l_task_id
        , p_skill_type_id         => 3  -- This is the id for Product Skills.
        , p_skill_id              => l_skill_id1
        , p_skill_level_id        => l_skill_level_id);

      end if;
    end if;
  end if;
  g_called_from_hook := 'F';
  x_return_status  := nvl( l_return_status
                          ,fnd_api.g_ret_sts_success );
EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
      then
        fnd_msg_pub.add_exc_msg ( g_package_name, l_api_name );
      end if;
END create_row_based_on_product;


PROCEDURE create_row_from_tpl ( x_return_status out nocopy varchar2) IS
   l_task_id    number;
   l_tpl_id     number;
   l_tpl_grp_id number;

  Cursor c_skills is
    Select skill_type_id
    ,      skill_id
    ,      skill_level_id
    from csf_required_skills_b
    where has_skill_type = 'TASK TEMPLATE'
    and   has_skill_id   = l_tpl_id;

   l_api_name    constant varchar2(30) := 'create_row_from_tpl';
   l_return_status  varchar2(50);
   l_msg_count      number;
   l_msg_data        varchar2 (1000);

BEGIN
   /* Retrieve skills attached to the task template and
      call create_task_req_skill procedure to insert the
      record. */
   l_task_id    := jtf_tasks_pub.p_task_user_hooks.task_id;
   l_tpl_id     := jtf_tasks_pub.p_task_user_hooks.template_id;
   l_tpl_grp_id := jtf_tasks_pub.p_task_user_hooks.template_group_id;
   g_called_from_hook := 'T';


   for r_skills in c_skills loop
     create_row
     ( p_api_version	  => 1
     , p_init_msg_list	  => FND_API.G_FALSE
     , p_commit		  => FND_API.G_FALSE
     , p_validation_level => FND_API.G_VALID_LEVEL_FULL
     , x_return_status	  => l_return_status
     , x_msg_count     	  => l_msg_count
     , x_msg_data      	  => l_msg_data
     , p_task_id       	  => l_task_id
     , p_skill_type_id 	  => r_skills.skill_type_id
     , p_skill_id      	  => r_skills.skill_id
     , p_skill_level_id	  => r_skills.skill_level_id);

     If l_return_status = fnd_api.g_ret_sts_error -- there's an error.
     Then
       Exit;
     End if;
  end loop;
  g_called_from_hook := 'F';
  x_return_status  := nvl( l_return_status
                          ,fnd_api.g_ret_sts_success );
EXCEPTION
    when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
      then
        fnd_msg_pub.add_exc_msg ( g_package_name, l_api_name );
      end if;
END create_row_from_tpl;


--
 --new procedure added for bug 6978751
 --
 PROCEDURE create_row_for_child_tasks ( x_return_status out nocopy varchar2 )
 IS

      cursor c_parent_task_id(p_task_id number)
      is
      select a.parent_task_id
      from jtf_tasks_b a, jtf_task_statuses_b b
      where a.task_id = p_task_id
      and a.task_status_id = b.task_status_id
      and nvl(task_split_flag, 'N') = 'D'
      and nvl(b.cancelled_flag, 'N') <> 'Y';

      cursor skills_to_create(p_task_id number)
      is
      select skill_type_id, skill_id, skill_level_id, disabled_flag
      from csf_required_skills_v
      where has_skill_id = p_task_id
      and skill_type_id <>2;

      l_api_name                 constant varchar2(30) := 'create_row_for_child_tasks';
      l_task_split_flag          jtf_tasks_b.task_split_flag%TYPE;
      l_task_id                  number ;
      l_parent_task_id           number;
      l_return_status            varchar2(50);
      l_msg_count                number;
      l_msg_data                 varchar2 (1000);
      l_skill_type_id            csf_required_skills_b.skill_type_id%type;
      l_skill_id                 csf_required_skills_b.skill_id%type;
      l_skill_level_id           csf_required_skills_b.skill_level_id%type;
      l_disabled_flag            csf_required_skills_b.disabled_flag%type;

 BEGIN

   l_task_id := jtf_tasks_pub.p_task_user_hooks.task_id;
   g_called_from_hook := 'T';

   open  c_parent_task_id(l_task_id);
   fetch c_parent_task_id into l_parent_task_id;
   if c_parent_task_id%FOUND
   then
     open skills_to_create(l_parent_task_id);
     loop
       fetch  skills_to_create into l_skill_type_id, l_skill_id, l_skill_level_id, l_disabled_flag;
       EXIT WHEN skills_to_create%NOTFOUND;
       -- retrieving default values for skill type and level.
       -- l_skill_level_id  := fnd_profile.value('CSF_DFLT_SKILL_LEVEL');
       create_row
         ( p_api_version           => 1
         , p_init_msg_list         => FND_API.G_FALSE
         , p_commit                => FND_API.G_FALSE
         , p_validation_level      => FND_API.G_VALID_LEVEL_FULL
         , x_return_status         => l_return_status
         , x_msg_count             => l_msg_count
         , x_msg_data              => l_msg_data
         , p_task_id               => l_task_id
         , p_skill_type_id         => l_skill_type_id
         , p_skill_id              => l_skill_id
         , p_skill_level_id        => l_skill_level_id
         , p_disabled_flag         => l_disabled_flag);
     end loop;
   end if;
   close c_parent_task_id;

   g_called_from_hook := 'F';
   x_return_status  := nvl( l_return_status ,fnd_api.g_ret_sts_success );
 EXCEPTION
     when others then
       x_return_status := fnd_api.g_ret_sts_unexp_error;
       if fnd_msg_pub.check_msg_level ( fnd_msg_pub.g_msg_lvl_unexp_error )
       then
         fnd_msg_pub.add_exc_msg ( g_package_name, l_api_name );
       end if;
 END create_row_for_child_tasks;


END CSF_REQUIRED_SKILLS_PKG;

/
