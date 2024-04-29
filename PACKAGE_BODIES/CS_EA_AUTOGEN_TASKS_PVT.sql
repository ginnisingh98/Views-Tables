--------------------------------------------------------
--  DDL for Package Body CS_EA_AUTOGEN_TASKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_EA_AUTOGEN_TASKS_PVT" as
/* $Header: cseatskb.pls 120.7.12010000.3 2009/07/22 15:30:50 gasankar ship $ */
--------------------------------------------
/* this procedure get the task type present in new task table but not
   present in old task table
*/
FUNCTION  Are_task_Attributes_valid(p_task_type_id number,
                                    p_task_status_id number,
                                    p_task_priority_id number) return varchar2;
-- -----------------------------------------------------------------------------
-- Modification History:
-- Date     Name     Desc
-- ------- -------- ------------------------------------------------------------
-- 01/06/06 smisra   fixed bug 4871341
--                   to get task priority, type and status names,
--                   used respective _vl tables instead of using jtf_tasks_vl
--                   This was to avoid excessive shared memory used by sql
-- -----------------------------------------------------------------------------
PROCEDURE start_task_workflow (p_task_id             IN          NUMBER,
                               p_tsk_typ_attr_dep_id IN          NUMBER,
                               p_wf_process          IN          VARCHAR2,
                               p_workflow_type       IN          VARCHAR2,
                               p_task_name           in          varchar2,
                               p_task_desc           in          varchar2,
                               x_return_status       OUT  NOCOPY VARCHAR2,
                               x_msg_count           OUT  NOCOPY NUMBER,
                               x_msg_data            OUT  NOCOPY VARCHAR2
                               ) IS
   l_wf_process_id            NUMBER;
   l_itemkey                  wf_item_activity_statuses.item_key%TYPE;
   l_owner_user_name          fnd_user.user_name%TYPE;
   l_owner_code               jtf_tasks_b.owner_type_code%TYPE;
   l_owner_id                 jtf_tasks_b.owner_id%TYPE;
   l_task_number              jtf_tasks_b.task_number%TYPE;
   l_task_status_name         jtf_tasks_v.task_status%type ;
   l_task_type_name           jtf_tasks_v.task_type%type ;
   l_task_priority_name       jtf_tasks_v.task_priority%type ;
   l_task_status_id           jtf_tasks_b.task_status_id%type ;
   l_task_type_id             jtf_tasks_b.task_type_id%type ;
   l_task_priority_id         jtf_tasks_b.task_priority_id%type ;
   current_record             NUMBER;
   source_text                VARCHAR2(200);
   l_errname varchar2(60);
   l_errmsg varchar2(2000);
   l_errstack varchar2(4000);

   CURSOR c_wf_processs_id
   IS
   SELECT jtf_task_workflow_process_s.nextval
   FROM dual;

BEGIN
   SAVEPOINT start_task_workflow;
   x_return_status := fnd_api.g_ret_sts_success;

   OPEN c_wf_processs_id;
   FETCH c_wf_processs_id INTO l_wf_process_id;
   CLOSE c_wf_processs_id;
   l_itemkey := TO_CHAR (p_task_id) || '-' || TO_CHAR (l_wf_process_id);

   wf_engine.createprocess (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   process => p_wf_process
   );

   wf_engine.setitemuserkey (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   userkey => p_task_name
   );

   wf_engine.setitemattrtext (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'TASK_NAME',
   avalue => p_task_name
      );

   wf_engine.setitemattrtext (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'TASK_DESC',
   avalue => p_task_desc
   );

   select task_status_id, task_priority_id , task_type_id, task_number
     into l_task_status_id, l_task_priority_id  , l_task_type_id,
          l_task_number
     from jtf_tasks_b where task_id = p_task_id ;

   SELECT name
   INTO   l_task_type_name
   FROM   jtf_task_types_vl
   WHERE  task_type_id = l_task_type_id;

   SELECT name
   INTO   l_task_status_name
   FROM   jtf_task_statuses_vl
   WHERE  task_status_id = l_task_status_id;

   SELECT name
   INTO   l_task_priority_name
   FROM   jtf_task_priorities_vl
   WHERE  task_priority_id = l_task_priority_id;

   wf_engine.setitemattrtext (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'TASK_NUMBER',
   avalue => l_task_number
   );

   wf_engine.setitemattrtext (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'TASK_STATUS_NAME',
   avalue => l_task_status_name
   );

   wf_engine.setitemattrtext (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'TASK_PRIORITY_NAME',
   avalue => l_task_priority_name
   );

   wf_engine.setitemattrtext (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'TASK_TYPE_NAME',
   avalue => l_task_type_name
   );

   wf_engine.setitemattrtext (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'OWNER_ID',
   avalue => l_owner_user_name
   );

   wf_engine.setitemattrnumber (
   itemtype => p_workflow_type,
   itemkey => l_itemkey,
   aname => 'CUG_TASK_DEP_ID',
   avalue => p_tsk_typ_attr_dep_id
   );

   wf_engine.startprocess (
   itemtype => p_workflow_type,
   itemkey => l_itemkey
   );

   fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
   WHEN fnd_api.g_exc_unexpected_error THEN
     ROLLBACK TO start_task_workflow;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   ---
   WHEN OTHERS THEN
     ROLLBACK TO start_task_workflow ;
     wf_core.get_error(l_errname, l_errmsg, l_errstack);
     if (l_errname is not null) then
        fnd_message.set_name('FND', 'WF_ERROR');
        fnd_message.set_token('ERROR_MESSAGE', l_errmsg);
        fnd_message.set_token('ERROR_STACK', l_errstack);
        fnd_msg_pub.add;
     end if;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
END;
procedure get_new_task_types(
              p_task_tbl_old  in ea_task_table_type,
              p_task_tbl_new  in ea_task_table_type,
              x_task_types_tbl   OUT NOCOPY task_type_table_type) is
  l_indx1 number;
  l_indx2 number;
  l_indx3 number;
  l_matched_with_old_task varchar2(1);
begin
   l_indx3 := 0;
   --dbms_output.put_line('Number of New Task:'||to_char(p_task_tbl_new.count));
   --dbms_output.put_line('Number of Old Task:'||to_char(p_task_tbl_Old.count));
   for l_indx2 in 1..p_task_tbl_new.count loop
      l_matched_with_old_task := 'n';
      for l_indx1 in 1..p_task_tbl_old.count loop
          if (p_task_tbl_new(l_indx2).task_status_id =
                    p_task_tbl_old(l_indx1).task_status_id and
              nvl(p_task_tbl_new(l_indx2).private_flag,'xx') =
                    nvl(p_task_tbl_old(l_indx1).private_flag,'xx') and
              nvl(p_task_tbl_new(l_indx2).publish_flag,'xx') =
                    nvl(p_task_tbl_old(l_indx1).publish_flag,'xx') and
              nvl(p_task_tbl_new(l_indx2).task_priority_id,-1) =
                    nvl(p_task_tbl_old(l_indx1).task_priority_id,-1) and
              p_task_tbl_new(l_indx2).task_type_id =
                    p_task_tbl_old(l_indx1).task_type_id and
              p_task_tbl_new(l_indx2).task_name =
                    p_task_tbl_old(l_indx1).task_name and
              nvl(p_task_tbl_new(l_indx2).task_description,'x') =
                    nvl(p_task_tbl_old(l_indx1).task_description,'x')
             ) then
             l_matched_with_old_task := 'y';
             exit;
           end if;
      end loop; --- old task records loop
      if (l_matched_with_old_task = 'n') then -- match for new task not found
         l_indx3 := l_indx3 + 1;
         x_task_types_tbl(l_indx3) := p_task_tbl_new(l_indx2).task_type_id;
      end if;
   end loop; ------ new task records loop
end;
--------------------------------------------
/* this procedure gets a list of task that need to be created for a
   service request type, extended attribute code and value.
   There may be more than one task associated with sr type, attr code
   and valuei, that is why this procedure appends the needed task to
   task table and increase the task count acordingly
*/
-- -----------------------------------------------------------------------------
-- Modification History:
-- Date     Name     Desc
-- ------- -------- ------------------------------------------------------------
-- 07/26/05 smisra   fixed bug 4272460.
--                   Retrieved owner id and owner type from SR Type, Task Type
--                   mapping.
-- ------- -------- ------------------------------------------------------------
procedure get_tasks_for_sr_attribute(
              p_incident_type_id      number,
              p_sr_ea_attr_code       varchar2,
              p_sr_ea_attr_val        varchar2,
              p_taskrec_table  in out nocopy ea_task_table_type,
              p_task_count     in out nocopy number) is
  --
  l_task_type_id jtf_task_types_b.task_type_id % type;
  l_sr_attr_op           cug_tsk_typ_attr_deps_vl.sr_attribute_operator % type;
  l_sr_attr_val_for_Task cug_tsk_typ_attr_deps_vl.sr_attribute_value    % type;
  l_sr_attr_val_for_Task1 cug_tsk_typ_attr_deps_vl.sr_attribute_value    % type;
  cursor c_sr_attr_tasks is
    select task_type_id,
           sr_attribute_operator,
           sr_attribute_value,
           tsk_typ_attr_dep_id
      from cug_tsk_typ_attr_deps_vl
     where incident_type_id = p_incident_type_id
       and nvl(sr_attribute_code,'-909') = nvl(p_sr_ea_attr_code,'-909')
       and trunc(sysdate) between nvl(start_date_active,sysdate-1)
                              and nvl(end_date_active  ,sysdate+1)
    ;
  cursor c_lookup_code is
   select 1 from fnd_lookups
    where description = p_sr_ea_attr_val
      and lookup_code = l_sr_attr_val_for_task
      and lookup_type in (select sr_attribute_list_name
                           from cug_sr_type_attr_maps_b
                          where incident_type_id = p_incident_type_id
                            and sr_attribute_code = p_sr_ea_attr_code);
  --
  -- Cursor to get planned effort and UOM
  l_rule                jtf_task_types_b.rule          % type;
  l_planned_effort      jtf_tasks_b.planned_effort     % type;
  l_planned_effort_uom  jtf_tasks_b.planned_effort_uom % type;
  l_workflow            jtf_task_types_b.workflow           % type;
  l_workflow_type       jtf_task_types_b.workflow_type      % type;
  cursor c_planned_effort is
    select planned_effort, planned_effort_uom, rule, workflow, nvl(workflow_type,'JTFTASK')
      from jtf_task_types_b
     where task_type_id = l_task_type_id
      /* and trunc(sysdate) between nvl(start_date_active,sysdate-1)
                              and nvl(end_date_active  ,sysdate+1)*/
    ;
  --
  -- cursor to task attributes
  l_tsk_typ_attr_dep_id cug_sr_task_type_dets_b.tsk_typ_attr_dep_id % type;
  l_task_status_id    jtf_tasks_b.task_status_id   % type;
  l_task_priority_id  jtf_tasks_b.task_priority_id % type;
  l_task_name         jtf_tasks_tl.task_name       % type;
  l_task_desc         jtf_tasks_tl.description     % type;
  l_publish_flag      jtf_tasks_b.publish_flag    % type;
  l_private_flag      jtf_tasks_b.private_flag    % type;
  CURSOR c_task_attributes IS
    SELECT
      task_status_id
    , task_priority_id
    , task_name
    , description
    , publish_flag
    , private_flag
    , owner_type_code
    , owner_id
    , assignee_type_code --5686743
    , assigned_by_id     --5686743
    FROM cug_sr_task_type_dets_vl
    WHERE tsk_typ_attr_dep_id = l_tsk_typ_attr_dep_id;
  l_match_found varchar2(1);
  l_sr_attr_found varchar2(1);
  l_sr_attr_task_found varchar2(1);
  l_dummy              fnd_lookups.lookup_type % type;
  l_owner_type_code    cug_sr_task_type_dets_vl.owner_type_code % TYPE;
  l_owner_id           cug_sr_task_type_dets_vl.owner_id        % TYPE;
  l_assignee_type_code cug_sr_task_type_dets_vl.owner_type_code % TYPE; --5686743
  l_assignee_id        cug_sr_task_type_dets_vl.owner_id        % TYPE; --5686743
begin
  open c_sr_attr_tasks;
  l_sr_attr_task_found := 'n';
  loop
    fetch c_sr_attr_tasks into l_task_type_id,
         l_sr_attr_op, l_sr_attr_val_for_task,
         l_tsk_typ_attr_dep_id;
    if c_sr_attr_tasks % notfound then
       exit;
    end if;
    -- No matching task are found
    l_match_found := 'n';
    l_sr_attr_task_found := 'y';
    -- This code is needed because cug_tsk_type_attr_deps_vl stores llokup_code
    -- in tl table instead of meaning. so checking existance of lookup_code meaning
    -- pair in lookup table.
    if (l_sr_attr_val_for_task is not null) then
       open c_lookup_code;
       fetch c_lookup_code into l_dummy;
       if c_lookup_code %notfound then
          l_sr_attr_val_for_task := '-99';
          --dbms_output.put_line('No match found for, code:'||l_sr_attr_val_for_task);
          --dbms_output.put_line('............. ...Meaning:'||p_sr_ea_attr_val);
       else
          l_sr_attr_val_for_task := p_sr_ea_attr_val;
          --dbms_output.put_line('match found.. ...Meaning:'||p_sr_ea_attr_val);
       end if;
       close c_lookup_code;
    end if;
    --
    if ((l_sr_attr_op = 'EQ' and
        nvl(p_sr_ea_attr_val,'x') = nvl(l_sr_attr_val_for_task,'x')) or
        l_sr_attr_val_for_task is null) then
        -- there exists a task type for input sr type, attr code and value
        -- this may lead to task creation
        l_match_found := 'y';
    -- add code for all other operators
    end if;
    if (l_match_found = 'y') then
       OPEN c_task_attributes;
       FETCH c_task_attributes
       INTO
         l_task_status_id
       , l_task_priority_id
       , l_task_name
       , l_task_desc
       , l_publish_flag
       , l_private_flag
       , l_owner_type_code
       , l_owner_id
       , l_assignee_type_code --5686743
       , l_assignee_id --5686743
       ;
       if (c_task_attributes%notfound) then
          --add a error message
          -- This should never happen because form force this validation
          fnd_message.set_name ('CS', 'CS_EA_NO_TASK_ATTRIBUTES');
          fnd_msg_pub.add;
          close c_task_attributes;
          close c_sr_attr_tasks;
          raise fnd_api.g_exc_unexpected_error;
       end if;
       close c_task_attributes;
       p_task_count := p_task_count + 1;
       p_taskrec_table(p_task_count).task_name           := l_task_name;
       p_taskrec_table(p_task_count).task_description    := l_task_desc;
       p_taskrec_table(p_task_count).task_type_id        := l_task_type_id;
       p_taskrec_table(p_task_count).task_status_id      := l_task_status_id;
       p_taskrec_table(p_task_count).task_priority_id    := l_task_priority_id;
       p_taskrec_table(p_task_count).publish_flag        := l_publish_flag;
       p_taskrec_table(p_task_count).private_flag        := l_private_flag;
       p_taskrec_table(p_task_count).tsk_typ_attr_dep_id := l_tsk_typ_attr_dep_id;
       p_taskrec_table(p_task_count).owner_type_code     := l_owner_type_code;
       p_taskrec_table(p_task_count).owner_id            := l_owner_id;
       p_taskrec_table(p_task_count).assignee_type_code  := l_assignee_type_code; --5686743
       p_taskrec_table(p_task_count).assignee_id         := l_assignee_id; --5686743

       p_taskrec_table(p_task_count).source_object_type_code := 'SR';
       --p_taskrec_table(p_task_count).source_object_id        := p_request_id;
       --p_taskrec_table(p_task_count).source_object_name      := p_incident_number;
          -- get planned fields
          open c_planned_effort;
          fetch c_planned_effort into l_planned_effort,
                                      l_planned_effort_uom, l_rule, l_workflow, l_workflow_type;
          if (c_planned_effort%notfound) then
             fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_TYPE_ID');
             fnd_message.set_token('P_TASK_TYPE_ID',l_task_type_id);
             fnd_msg_pub.add;
             close c_planned_effort;
             close c_sr_attr_tasks;
             raise fnd_api.g_exc_unexpected_error;
          end if;
          close c_planned_effort;
          p_taskrec_table(p_task_count).workflow  := l_workflow;
          p_taskrec_table(p_task_count).workflow_type  := l_workflow_type;
          -- add planned fields to task record
          p_taskrec_table(p_task_count).planned_start_date  := sysdate;
          p_taskrec_table(p_task_count).planned_effort     := l_planned_effort;
          p_taskrec_table(p_task_count).planned_effort_uom :=
                                                          l_planned_effort_uom;
       if (l_rule = 'DISPATCH') then
          p_taskrec_table(p_task_count).field_service_task_flag  := 'Y';
       else
          p_taskrec_table(p_task_count).field_service_task_flag  := 'N';
       end if;
       --dbms_output.put_line('Status:'||to_char(l_task_status_id));
       --dbms_output.put_line('type:'||to_char(l_task_type_id));
       --dbms_output.put_line('priority:'||to_char(l_task_priority_id));
       --dbms_output.put_line('Desc:'||to_char(l_task_desc));
       --dbms_output.put_line('name:'||to_char(l_task_name));
       --dbms_output.put_line('Planned Eff:'||to_char(l_planned_effort));
       --dbms_output.put_line('Planned EffUOM:'||to_char(l_planned_effort_uom));
    else
        null;
       --dbms_output.put_line('No Match found');
/*
***/
    end if; -- if match found
    --dbms_output.put_line('=======================================');
  end loop;
  close c_sr_attr_tasks;
   /* 10/28/2003
      this may happen for check of task types with null attributes.
  if (l_sr_attr_task_found = 'n') then
     fnd_message.set_name ('CS', 'CS_EA_NO_CONFIGURED_TASKS');
     fnd_message.set_token('P_SR_TYPE',p_incident_type_id);
     fnd_message.set_token('P_EA_CODE',p_sr_ea_attr_code);
     fnd_msg_pub.add;
  end if;
   */
end get_tasks_for_sr_attribute;
--------------------------------------------
procedure get_affected_tasks (
      p_api_version           in         number,
      p_init_msg_list         in         varchar2 ,
      p_incident_type_id_old  in         number,
      p_incident_type_id_new  in         number,
      p_ea_sr_attr_tbl        in         extended_attribute_table_type,
      x_tasks_affected_flag   out nocopy varchar2,
      x_task_type_tbl         out nocopy task_type_table_type,
      x_return_status         out nocopy varchar2,
      x_msg_count             out nocopy number,
      x_msg_data              out nocopy varchar2
   ) is
  l_task_tbl_new    ea_task_table_type;
  l_task_tbl_old    ea_task_table_type;
  l_task_count_new  number;
  l_task_count_old  number;
begin
  --
  -- initialize message list
  if fnd_api.to_boolean (p_init_msg_list) then
     fnd_msg_pub.initialize;
  end if;
  --
  -- check API version
  if (p_api_version <> 1) then
     fnd_message.set_name ('CS', 'CS_EA_US_INVALID_API_VER');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;
  --
  -- check old incident type ID
  if (p_incident_type_id_old is null) then
     fnd_message.set_name ('CS', 'CS_EA_NULL_OLD_INCIDENT_TYPE');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;
  --
  -- check new incident type ID
  if (p_incident_type_id_new is null) then
     fnd_message.set_name ('CS', 'CS_EA_NULL_NEW_INCIDENT_TYPE');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;
  ----------------------------------------------------------
  l_task_count_new  := 0;
  l_task_count_old  := 0;
  /** 11/18/2003 smisra
  As per requirement from UI team, disabling this part.
  Now this procedure will always return tasks needed for passed
  attribute code - value pairs

  if (p_incident_type_id_old = p_incident_type_id_new) then
    for l_indx in 1..p_ea_sr_attr_tbl.count loop
        --dbms_output.put_line('Inside Get Affected Task:'||to_char(l_indx));
        if (nvl(p_ea_sr_attr_tbl(l_indx).sr_attribute_value_old,'x') <>
                 nvl(p_ea_sr_attr_tbl(l_indx).sr_attribute_value_new,'x') ) then
           get_tasks_for_sr_attribute(
                   p_incident_type_id_old,
                   p_ea_sr_attr_tbl(l_indx).sr_attribute_code_old,
                   p_ea_sr_attr_tbl(l_indx).sr_attribute_value_old,
                   l_task_tbl_old,
                   l_task_count_old);
           get_tasks_for_sr_attribute(
                   p_incident_type_id_new,
                   p_ea_sr_attr_tbl(l_indx).sr_attribute_code_new,
                   p_ea_sr_attr_tbl(l_indx).sr_attribute_value_new,
                   l_task_tbl_new,
                   l_task_count_new);
        end if;
    end loop;
    **/
    /*
    no need to call get_tasks_for_sr_attributes with null value for code and value
    as such task are independed on attrbiure values. we are trying to find out
    task needs due to change in attribute code values
    *************************************/
  --else
    for l_indx in 1..p_ea_sr_attr_tbl.count loop
       if (p_ea_sr_attr_tbl(l_indx).sr_attribute_code_new is not null) then
           get_tasks_for_sr_attribute(
                   p_incident_type_id_new,
                   p_ea_sr_attr_tbl(l_indx).sr_attribute_code_new,
                   p_ea_sr_attr_tbl(l_indx).sr_attribute_value_new,
                   l_task_tbl_new,
                   l_task_count_new);
       end if;
    end loop;
    -- this call will get all configured tasks that have attribute as null
    -- such tasks are to be created whenever an SR of particular type is created
    get_tasks_for_sr_attribute(
       p_incident_type_id_new,
       null,
       null,
       l_task_tbl_new,
       l_task_count_new);
  --end if;
  --dbms_output.put_line('Getting the new tasks type..');
  get_new_task_types(
              l_task_tbl_old  ,
              l_task_tbl_new  ,
              x_task_type_tbl   ) ;
   if (x_task_type_tbl.count > 0 ) then
       x_tasks_affected_flag := 'Y';
   else
       x_tasks_affected_flag := 'N';
   end if;
/*****
  dbms_output.put_line('total new task types:'|| to_char(x_task_type_tbl.count));
  for l_indx in 1..x_task_type_tbl.count loop
    dbms_output.put_line(to_char(x_task_type_tbl(l_indx)));
  end loop;
****/
  --
  -- Exception handling
  --
EXCEPTION
WHEN fnd_api.g_exc_unexpected_error THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
WHEN OTHERS THEN
   fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
   fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
end get_affected_tasks;
--------------------------------------------
procedure get_extnd_attr_tasks (
      p_api_version       in number,
      p_init_msg_list     in varchar2 ,
      p_sr_rec            in CS_ServiceRequest_pub.service_request_rec_type,
      p_request_id        in number ,
      p_incident_number   in varchar2 ,
      p_sr_attributes_tbl in EA_SR_ATTR_TABLE_TYPE,
      x_return_status out nocopy varchar2,
      x_msg_count     out nocopy number,
      x_msg_data      out nocopy varchar2,
      x_task_rec_table out nocopy EA_task_table_type) is
  -- local variables
  l_sr_attr_code  cug_incidnt_attr_vals_vl.sr_attribute_code % type;
  l_sr_attr_val   cug_incidnt_attr_vals_vl.sr_attribute_value% type;
  --
  l_sr_attr_found varchar2(1);
  l_indx      number;
begin
  --
  -- initialize message list
  if fnd_api.to_boolean (p_init_msg_list) then
     fnd_msg_pub.initialize;
  end if;
  --
  -- check API version
  if (p_api_version <> 1) then
     fnd_message.set_name ('CS', 'CS_EA_US_INVALID_API_VER');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;
  --
  -- Check Service request id
  if (p_request_id is null) then
     fnd_message.set_name ('CS', 'CS_EA_NULL_REQUEST_ID');
     fnd_msg_pub.add;
     raise fnd_api.g_exc_unexpected_error;
  end if;
  -- Get Service Extended Attributes
  l_sr_attr_found := 'n';
  l_indx := 0;
  --dbms_output.put_line('Total Attr:'||to_char(p_sr_attributes_tbl.count));
  if (p_sr_attributes_tbl.count > 0) then
  for l_loop_indx in p_sr_attributes_tbl.first..p_sr_attributes_tbl.last loop
    --dbms_output.put_line('loop indx:' ||to_char(l_loop_indx));
    l_sr_attr_code := p_sr_attributes_tbl(l_loop_indx).sr_attribute_code;
    l_sr_attr_val  := p_sr_attributes_tbl(l_loop_indx).sr_attribute_value;
    get_tasks_for_sr_attribute(p_sr_rec.type_id,
                               l_sr_attr_code, l_sr_attr_val,
                               x_task_rec_table, l_indx);
    --dbms_output.put_line('Index Out,loop indx:'||to_char(l_indx) ||',' ||to_char(l_loop_indx));
  end loop;
  end if;
  -- There may be some tasks configured with attrbiute code as NULL.
  -- get all the task that have NULL attribute code.
  -- These tasks are to be created irrespective of attribute codes and values
  -- These tasks are basically depends on SR Type
  -- Get the count of message and message into out variables
  --dbms_output.put_line('before get_task_for_sr_attribute call');
  get_tasks_for_sr_attribute(p_sr_rec.type_id,
                             null, null,
                             x_task_rec_table, l_indx);
  --dbms_output.put_line('After get_task_for_sr_attribute call');
  x_return_status := fnd_api.g_ret_sts_success;
  fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
  --
  -- Exception handling
  --
EXCEPTION
WHEN fnd_api.g_exc_unexpected_error THEN
   --dbms_output.put_line('get_extnd g_exc_unexpected error');
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
WHEN OTHERS THEN
   --dbms_output.put_line('get_extnd others error');
   fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
   fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
end get_extnd_attr_tasks;

-- -----------------------------------------------------------------------------
-- Modification History:
-- Date     Name     Desc
-- ------- -------- ------------------------------------------------------------
-- 07/26/05 smisra   fixed bug 4477767.
--                   passed p_date_selected as NULL to task API. If this
--                   parameter is 'D' then it may cause certain task validations
--                   to fail and auto task process in not in a position to pass
--                   those details
-- 07/26/05 smisra   fixed bug 4272460.
--                   used owner id, owner type from SR Type, Task Type mapping
--                   if assignment manager can not determine task owner
-- 08/19/05 smisra   Fixed bug 4272460                                                              |
--                   put call to auto tak assignment under comment.
--                   when decision to use Assignment is manager is made, that
--                   call can be uncommneted.
-- 07/12/06 romehrot  Bug 5686743
--                    Added to code to populate assignee information from setup form.

-- -----------------------------------------------------------------------------
procedure create_extnd_attr_tasks (
      p_api_version       in number,
      p_init_msg_list     in varchar2 ,
      p_commit            in varchar2 ,
      p_sr_rec            in CS_ServiceRequest_pub.service_request_rec_type,
      p_sr_attributes_tbl in EA_SR_ATTR_TABLE_TYPE,
      p_request_id        in number ,
      p_incident_number   in varchar2 ,
      x_return_status              OUT NOCOPY varchar2,
      x_msg_count                  OUT NOCOPY number,
      x_msg_data                   OUT NOCOPY varchar2,
      x_auto_task_gen_attempted    OUT NOCOPY varchar2,
      x_field_service_Task_created OUT NOCOPY varchar2) is
  l_task_rec_tbl ea_task_table_type;
  l_task_attr_rec cs_sr_task_autoassign_pkg.Sr_Task_rec_type;
  l_indx         number;
  l_task_id      jtf_tasks_b.task_id % type;
  l_login_id  jtf_notes_b.last_update_login % type;
  l_user_id   jtf_notes_b.last_updated_by   % type;
  l_obj_version cs_incidents_all_b.object_version_number % type;
  l_owner_type  cs_incidents_all_b.resource_type % type;
  l_owner_id    cs_incidents_all_b.incident_owner_id % type;
  l_owner_group_id cs_incidents_all_b.owner_group_id % type;
  l_last_updated_by cs_incidents_all_b.last_updated_by % type;
  l_group_type   varchar2(50);
  l_sr_rec       cs_servicerequest_pub.service_request_rec_type ;
  l_task_owner_type jtf_tasks_b.owner_type_code % type;
  l_task_owner_id   jtf_tasks_b.owner_id%type;
  l_location_id     cs_incidents_all_b.incident_location_id % type;
  l_dummy varchar2(80);
  l_address_id      NUMBER;
  l_customer_id     NUMBER := p_sr_rec.customer_id;
  l_task_assignment_id Number; --5686743
  -- Simplex
  -- local variable and exception declarations for Simplex Enhancement
 l_prof_val		VARCHAR(1);
 l_date_selected	VARCHAR2(1) := null;
 l_temp			NUMBER(20,4);
 l_api_name             VARCHAR2(100) := 'cs_ea_autogen_tasks_pvt.create_extnd_attr_tasks';
 l_conv_rate            NUMBER(30,6);
 l_planned_effort       NUMBER(30,6):= 0;
 l_task_type_name       VARCHAR2(100) := null;
 l_planned_uom_value                     varchar2(30); -- 12.1.2 SHACHOUD
 l_planned_effort_value                  number; -- 12.1.2 SHACHOUD

  e_date_pair_exception      EXCEPTION ;
  e_planned_effort_val_exception EXCEPTION ;
  e_party_site_exception     EXCEPTION;

  cursor c_task_type_name(l_task_type_id IN NUMBER) IS
  select name
  from jtf_task_types_vl
  where task_type_id = l_task_type_id;

 -- end Simplex

 l_planned_end_date	DATE; -- 12.1.2 SR TASK ENHANCEMENTS PROJECT
 l_owner_territory_id  NUMBER;  -- 12.1.3 Task Enh Proj

begin

  savepoint create_extnd_attr_task_pvt;
  l_sr_rec       := p_sr_rec;
  x_auto_task_gen_attempted := 'N';
  x_field_service_task_created := 'N';

  --dbms_output.put_line('Before get_extnd_attrtask');
  get_extnd_attr_tasks (
      p_api_version       => p_api_version,
      p_init_msg_list     => p_init_msg_list,
      p_sr_rec            => p_sr_rec,
      p_request_id        => p_request_id,
      p_incident_number   => p_incident_number,
      p_sr_attributes_tbl => p_sr_attributes_tbl,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      x_task_rec_table     => l_task_rec_tbl);
   --dbms_output.put_line('Return Status(get_extnd_attr_tasks):'||x_return_status|| ':');
   -- Create Tasks

   if (x_return_status = fnd_api.g_ret_sts_success) then
   --l_login_id := fnd_global.login_id;
   --l_user_id  := fnd_global.user_id ;
   -- Task api does not take user ids as parameter

   -- Simplex
   -- Get the value for the profile option 'Service : Apply State Restriction on Tasks'
   -- to decide the enabling/disabling of task state restrictions

   --   in order to fix 4477767, task restriction can not be applied to auto tasks
   --   FND_PROFILE.Get('CS_SR_ENABLE_TASK_STATE_RESTRICTIONS',l_prof_val);

   -- end of simplex


   for l_indx in 1..l_task_rec_tbl.count loop
     --dbms_output.put_line('Going through the task table:'||to_char(l_indx));
     -- do validations for field service task

     if (Are_Task_Attributes_valid(l_task_rec_tbl(l_indx).task_type_id,
                                   l_task_rec_tbl(l_indx).task_status_id,
                                   l_task_rec_tbl(l_indx).task_priority_id) = 'Y') then
	-- commented the following code for 12.1.2 SR task Enhancement project
         --l_task_rec_tbl(l_indx).planned_end_date := nvl(p_sr_rec.obligation_date,sysdate);

     if (l_task_rec_tbl(l_indx).field_service_task_flag = 'Y') then
         -- no need to validate type id, status, task_name as these are not null
         -- in database
         -- 1st check: Location as party site  -- Removed  -- Modified to ensure incident location is NOT NULL

         IF (l_task_rec_tbl(l_indx).field_service_task_flag = 'Y') THEN

            IF p_sr_rec.incident_location_id IS NULL THEN
               RAISE e_party_site_exception ;
            END IF ;

         END IF ;


        -- 2nd check: Planed End Date
        /*
        if (p_sr_rec.obligation_date is null) then
          fnd_message.set_name ('CS', 'CS_EA_NO_PLANNED_END_DATE');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
          raise fnd_api.g_exc_error;
        else
        */
        --end if;
        -- 3rd check: Planned Effort
        if (l_task_rec_tbl(l_indx).planned_effort is null) then
          fnd_message.set_name ('CS', 'CS_EA_NO_PLANNED_EFFORT');
          fnd_message.set_token('P_TYPE_ID',l_task_rec_tbl(l_indx).task_type_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
          raise fnd_api.g_exc_error;
        end if;

        -- 4th check: Planned Effort UOM
        if (l_task_rec_tbl(l_indx).planned_effort_uom is null) then
          fnd_message.set_name ('CS', 'CS_EA_NO_PLANNED_EFFORT_UOM');
          fnd_message.set_token('P_TYPE_ID',l_task_rec_tbl(l_indx).task_type_id);
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
          raise fnd_api.g_exc_error;
        end if;
        -- no need to check task name, status, type and planned start date
        -- as these can not be null. these are not null in respective
        -- source tables. planned_start_date is always set to sysdate

     end if;
     -- end of field service task validation
     -- Get Resource_id for new tasks.
     l_task_attr_rec.task_type_id := l_task_rec_tbl(l_indx).task_type_id;
     l_task_attr_rec.task_status_id := l_task_rec_tbl(l_indx).task_status_id;
     l_task_attr_rec.task_priority_id := l_task_rec_tbl(l_indx).task_priority_id;
     l_task_owner_type := l_task_rec_tbl(l_indx).owner_type_code;
     l_task_owner_id   := l_task_rec_tbl(l_indx).owner_id;

     /**********************************************************************
     task assignment will be based on SR Type, Task Type setup only for time being
     when decision to use task assignment based on territory is made */

 -- 12.1.3 Task Enh Proj
     If l_task_owner_type is null or l_task_owner_id is null then
        l_sr_rec.type_id := null;
        cs_sr_task_autoassign_pkg.assign_task_resource(
            p_api_version           => 1,
            p_init_msg_list         => fnd_api.g_false,
            p_commit                => fnd_api.g_false,
            p_incident_id           => p_request_id,
            p_service_request_rec   => l_sr_rec,
            p_task_attribute_rec    => l_task_attr_rec,
            x_owner_group_id        => l_owner_group_id,
            x_owner_type            => l_owner_type,
            x_group_type            => l_group_type,
            x_owner_id              => l_owner_id,
	    x_territory_id          => l_owner_territory_id ,
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   fnd_msg_pub.set_search_name('CS','CS_SR_TASK_NO_OWNER');
           fnd_msg_pub.set_search_token('API_NAME','CS_SR_TASK_AUTOASSIGN_PKG.Assign_Task_Resource');
           fnd_message.set_name ('CS', 'CS_EA_ASSIGN_TASK_ERROR');
           fnd_message.set_token('TASK_NAME',l_task_rec_tbl(l_indx).task_name);
           l_dummy := fnd_msg_pub.change_msg;
           raise fnd_api.g_exc_error;

        ELSE
           IF (l_owner_type is null) then
              l_task_owner_type := l_group_type;
              l_task_owner_id   := l_owner_group_id;
           ELSE
              l_task_owner_type := l_owner_type;
              l_task_owner_id   := l_owner_id;
           END IF;
        END IF;
     END IF;
     -- End 12.1.3 Task enh proj
/******************************************************************************/

     x_auto_task_gen_attempted := 'Y';
     -- Since location id can be null for task but task takes only
     -- party sites. so if location type is not party site, set location to null
     if (nvl(p_sr_rec.incident_location_type,'x') = 'HZ_PARTY_SITE' ) then
        l_address_id := p_sr_rec.incident_location_id;
        l_customer_id := p_sr_rec.customer_id ;
     elsif (nvl(p_sr_rec.incident_location_type,'x')) = 'HZ_LOCATION' THEN
        l_location_id := p_sr_rec.incident_location_id;
        l_customer_id := null;
     else
        l_address_id  := null;
        l_location_id := null;
        l_customer_id := p_sr_rec.customer_id;
     end if;

      -- Simplex
     -- The below validations should be done every tasks in the task template group and
     -- hence the validations are inside the loop

     -- Enable task state restrictions depending on the profile value
     -- 'Service : Apply State Restriction on Tasks'
     --
     --IF ( l_prof_val = 'Y') THEN
     --  l_date_selected := 'D';
     --END IF;

	-- 12.1.2 SR Task Enhancement project
	-- Get the Planned End date based on the Profile
	l_planned_uom_value := l_task_rec_tbl(l_indx).planned_effort_uom;
        l_planned_effort_value := l_task_rec_tbl(l_indx).planned_effort;

         if ( l_planned_uom_value = 'DAY') then
          l_planned_effort_value := l_planned_effort_value +1;
         end if;
	 CS_AutoGen_Task_PVT.Default_Planned_End_Date(p_sr_rec.obligation_date,
						      p_sr_rec.exp_resolution_date,
						      l_planned_uom_value,
						      l_planned_effort_value,
						      l_planned_end_date);

	l_task_rec_tbl(l_indx).planned_end_date   := l_planned_end_date;
	-- End of 12.1.2 project code

     -- The palnned start date and planned end date should appear in pair.
     -- If not,exception is thrown
     IF ( (  (l_task_rec_tbl(l_indx).planned_start_date IS NOT NULL AND
	              l_task_rec_tbl(l_indx).planned_start_date <> FND_API.G_MISS_DATE)
		      AND
		      (l_task_rec_tbl(l_indx).planned_end_date IS NULL OR
		      l_task_rec_tbl(l_indx).planned_end_date = FND_API.G_MISS_DATE)
		   )
		   OR
                   (  (l_task_rec_tbl(l_indx).planned_end_date IS NOT NULL AND
	               l_task_rec_tbl(l_indx).planned_end_date <> FND_API.G_MISS_DATE)
		       AND
		       (l_task_rec_tbl(l_indx).planned_start_date IS NULL OR
		        l_task_rec_tbl(l_indx).planned_start_date = FND_API.G_MISS_DATE)
		    )
		  )THEN

                     open c_task_type_name(l_task_rec_tbl(l_indx).task_type_id);
		     fetch c_task_type_name into l_task_type_name;
		     close c_task_type_name;

		     fnd_message.set_name ('CS', 'CS_EA_DATE_PAIR_ERROR');
                     fnd_message.set_token('TASK_TYPE',l_task_type_name);
                     fnd_message.set_token('API_NAME',l_api_name);
                     fnd_msg_pub.add;
                     x_return_status := fnd_api.g_ret_sts_error;
                     raise fnd_api.g_exc_error;
      END IF;

      -- no validations for scheduled and actual dates as the parameters are not passed


     -- The enabling/disabling of state restrictions is based on tke profile option
     -- 'Service : Apply State Restriction on Tasks' and the value is stored in the
     -- local variable l_date_selected

     jtf_tasks_pub.create_task (
        p_api_version       => 1.0,
        p_init_msg_list     => fnd_api.g_false,
        p_commit            => fnd_api.g_false,
        p_task_name         => l_task_rec_tbl(l_indx).task_name,
        p_description       => l_task_rec_tbl(l_indx).task_description,
	p_task_type_id      => l_task_rec_tbl(l_indx).task_type_id,
        p_task_status_id    => l_task_rec_tbl(l_indx).task_status_id,
        p_task_priority_id  => l_task_rec_tbl(l_indx).task_priority_id,
        p_owner_id          => l_task_owner_id,
        p_owner_type_code   => l_task_owner_type,
        p_planned_start_date => l_task_rec_tbl(l_indx).planned_start_date,
        p_planned_end_date   => l_task_rec_tbl(l_indx).planned_end_date,
        p_planned_effort     => l_task_rec_tbl(l_indx).planned_effort,
        p_planned_effort_uom => l_task_rec_tbl(l_indx).planned_effort_uom,
        p_customer_id        => l_customer_id , --p_sr_rec.customer_id,
        p_address_id         => l_address_id,
        p_category_id        => NULL,
	p_source_object_id   => p_request_id,
	p_source_object_name => p_incident_number,
	p_source_object_type_code => 'SR',
        p_date_selected    => l_date_selected, -- simplex  'D',
        p_private_flag     => l_task_rec_tbl(l_indx).private_flag,
        p_publish_flag     => l_task_rec_tbl(l_indx).publish_flag,
        p_location_id        => l_location_id,
        x_return_status    => x_return_status,
	x_msg_count        => x_msg_count,
	x_msg_data         => x_msg_data,
        x_task_id          => l_task_id)
        ;
     --dbms_output.put_line('after Create Task:'||x_return_status);
        if (x_return_status <> fnd_api.g_ret_sts_success) then
           /***
           dbms_output.put_line(l_task_rec_tbl(l_indx).task_name);
           dbms_output.put_line(l_task_rec_tbl(l_indx).task_description);
           dbms_output.put_line(l_task_rec_tbl(l_indx).task_type_id);
           dbms_output.put_line(l_task_rec_tbl(l_indx).task_status_id);
           dbms_output.put_line(l_task_rec_tbl(l_indx).task_priority_id);
           dbms_output.put_line(to_char(l_task_rec_tbl(l_indx).planned_start_date,'dd-mon-yyyy hh24:mi:ss'));
           dbms_output.put_line(to_char(l_task_rec_tbl(l_indx).planned_end_date,'dd-mon-yyyy hh24:mi:ss'));
           dbms_output.put_line(l_task_rec_tbl(l_indx).planned_effort);
           dbms_output.put_line(l_task_rec_tbl(l_indx).planned_effort_uom);
           dbms_output.put_line(p_sr_rec.incident_location_id);
           dbms_output.put_line(p_request_id);
           dbms_output.put_line(p_incident_number);
           dbms_output.put_line(l_task_rec_tbl(l_indx).private_flag);
           dbms_output.put_line(l_task_rec_tbl(l_indx).publish_flag);
           dbms_output.put_line(':'||to_char(l_owner_id));
           dbms_output.put_line('Owner Type:'||l_owner_type||':');
           dbms_output.put_line(':'||to_char(l_owner_group_id));
           dbms_output.put_line('Owner Type:'||l_group_type||':');
           dbms_output.put_line('====');
           fnd_message.set_name ('CS', 'CS_EA_CREATE_TASK_API_ERROR');
           fnd_msg_pub.add;
           *****/
           raise fnd_api.g_exc_error;
        end if;
        if (l_task_rec_tbl(l_indx).field_service_task_flag = 'Y') then
           x_field_service_task_created := 'Y';
        end if;
        /* Start : 5686743 */
        If l_task_rec_tbl(l_indx).assignee_id IS NOT NULL Then
           jtf_task_assignments_pub.create_task_assignment(
                                       p_api_version          => 1.0,
                                       p_init_msg_list        => cs_core_util.get_g_true,
                                       p_commit               => cs_core_util.get_g_false,
                                       p_task_id              => l_task_id,
                                       p_resource_type_code   => l_task_rec_tbl(l_indx).assignee_type_code,
                                       p_resource_id          => l_task_rec_tbl(l_indx).assignee_id,
                                       p_assignment_status_id => fnd_profile.value('JTF_TASK_DEFAULT_ASSIGNEE_STATUS'),
                                       x_return_status        => x_return_status,
                                       x_msg_count            => x_msg_count,
                                       x_msg_data             => x_msg_data,
                                       x_task_assignment_id   => l_task_assignment_id);

           If (x_return_status <> fnd_api.g_ret_sts_success) Then
              raise fnd_api.g_exc_error;
           End if;
	End If;
        /* End : 5686743 */
	if (l_task_rec_tbl(l_indx).workflow is not null) then
           start_task_workflow (l_task_id             ,
                                l_task_rec_tbl(l_indx).tsk_typ_attr_dep_id ,
                                l_task_rec_tbl(l_indx).workflow ,
                                l_task_rec_tbl(l_indx).workflow_type ,
                                l_task_rec_tbl(l_indx).task_name,
                                l_task_rec_tbl(l_indx).task_description,
                                x_return_status       ,
                                x_msg_count           ,
                                x_msg_data            );
           if (x_return_status <> fnd_api.g_ret_sts_success) then
              fnd_message.set_name ('CS', 'CS_EA_START_WORKFLOW_ERROR');
              fnd_msg_pub.add;
              raise fnd_api.g_exc_error;
           end if;
        end if;
        else
           fnd_msg_pub.initialize;
        end if; -- check for validity of task attributes such as type, status, priority
   end loop;
   end if;
   -- All task created
  if fnd_api.to_boolean (p_commit) then
     commit;
  end if;
  --
  -- Exception handling
  --
  --raise_application_error(-20001,'For testing msg JTF_TASK_UNKNOWN_ERROR');
EXCEPTION
     WHEN e_party_site_exception THEN
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                    p_data  => x_msg_data );
          FND_MESSAGE.SET_NAME('CS','CS_EA_NO_PARTY_SITE');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR ;
WHEN fnd_api.g_exc_error THEN
   rollback to create_extnd_attr_task_pvt;
   x_return_status := fnd_api.g_ret_sts_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
WHEN fnd_api.g_exc_unexpected_error THEN
   rollback to create_extnd_attr_task_pvt;
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
WHEN OTHERS THEN
   rollback to create_extnd_attr_task_pvt;
   fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
   fnd_message.set_token ('P_TEXT', SQLERRM);
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
end create_extnd_attr_tasks;
--------------------------------------------------
FUNCTION  Are_task_Attributes_valid(p_task_type_id number,
                                    p_task_status_id number,
                                    p_task_priority_id number) return varchar2 is
  l_type           jtf_tasks_v.task_type     % type;
  l_status         jtf_tasks_v.task_status   % type;
  l_priority       jtf_tasks_v.task_priority % type;
  l_type_id        number;
  l_status_id      number;
  l_priority_id    number;
  x_return_status  varchar2(10);
BEGIN
  jtf_task_utl.validate_task_type ( p_task_type_id   => p_task_type_id,
                                    p_task_type_name => l_type,
                                    x_return_status  => x_return_status,
                                    x_task_type_id   => l_type_id
                                  );

IF x_return_status <> fnd_api.g_ret_sts_success THEN
   return 'N';
END IF;

IF l_type_id IS NULL THEN
   return 'N';
END IF;

-------
-------	Validate Task Status
-------
IF l_type_id = '22' THEN
   l_type := 'ESCALATION';
ELSE
   l_type := 'TASK';
END IF;

jtf_task_utl.validate_task_status ( p_task_status_id   => p_task_status_id,
                                    p_task_status_name => l_status,
                                    p_validation_type  => l_type,
                                    x_return_status    => x_return_status,
                                    x_task_status_id   => l_status_id);

IF x_return_status <> fnd_api.g_ret_sts_success THEN
   return 'N';
END IF;
-------
jtf_task_utl.validate_task_priority ( p_task_priority_id   => p_task_priority_id,
                                      p_task_priority_name => l_priority,
                                      x_return_status      => x_return_status,
                                      x_task_priority_id   => l_priority_id);
IF x_return_status <> fnd_api.g_ret_sts_success THEN
   return 'N';
END IF;
-- All task attrributes are valid
return 'Y';

Exception when others then
    return 'N';
END;
/**** not used anymore 9/30/2003
procedure create_ea_tasks_isupp (
      p_api_version       in number,
      p_init_msg_list     in varchar2 := fnd_api.g_false,
      p_commit            in varchar2 := fnd_api.g_false,
      p_sr_attributes_tbl in EA_SR_ATTR_TABLE_TYPE,
      p_request_id        in number ,
      x_return_status              OUT NOCOPY varchar2,
      x_msg_count                  OUT NOCOPY number,
      x_msg_data                   OUT NOCOPY varchar2,
      x_auto_task_gen_attempted    OUT NOCOPY varchar2,
      x_field_service_Task_created OUT NOCOPY varchar2) is
  i number;
  l_prof_value fnd_profile_option_values.profile_option_value % type;
  l_err        varchar2(4000);
  l_msg_index_out number;
  l_msg_data varchar2(2000);
  l_note_id number;
  l_note_type jtf_notes_b.note_type % type;
  l_login_id  jtf_notes_b.last_update_login % type;
  l_user_id   jtf_notes_b.last_updated_by   % type;
  l_sr_rec    CS_ServiceRequest_pub.service_request_rec_type;
  l_incident_number cs_incidents_all_b.incident_number % type;
  cursor c_sr is
    select * from cs_incidents_all_b
     where incident_id = p_request_id;
begin
  l_prof_value := fnd_profile.value('AUTO GENERATE TASKS ON SR CREATE');
  if (l_prof_value = 'Task type Attribute configuration' or 1 =1) then
     for l_rec in c_sr loop
         l_sr_rec.type_id              := l_rec.incident_type_id;
         l_sr_rec.status_id            := l_rec.incident_status_id;
         l_sr_rec.urgency_id           := l_rec.incident_urgency_id;
         l_sr_rec.severity_id          := l_rec.incident_severity_id;
         l_sr_rec.obligation_date      := l_rec.obligation_date;
         l_sr_rec.problem_code         := l_rec.problem_code;
         l_sr_rec.inventory_item_id    := l_rec.inventory_item_id;
         l_sr_rec.inventory_org_id     := l_rec.inv_organization_id;
         l_sr_rec.customer_id          := l_rec.customer_id;
         l_sr_rec.customer_number      := l_rec.customer_number;
         l_sr_rec.category_id          := l_rec.category_id;
         l_sr_rec.category_set_id      := l_rec.category_set_id;
         l_sr_rec.incident_location_id := l_rec.incident_location_id;
         l_sr_rec.request_date                := l_rec.incident_date;
         l_sr_rec.type_id                     := l_rec.incident_type_id;
         l_sr_rec.status_id                   := l_rec.incident_status_id;
         l_sr_rec.severity_id                 := l_rec.incident_severity_id;
         l_sr_rec.urgency_id                  := l_rec.incident_urgency_id;
         l_sr_rec.closed_date                 := l_rec.close_date;
         l_sr_rec.owner_id                    := l_rec.incident_owner_id;
         l_sr_rec.owner_group_id              := l_rec.owner_group_id;
         l_sr_rec.publish_flag                := l_rec.publish_flag;
         l_sr_rec.caller_type                 := l_rec.caller_type;
         l_sr_rec.customer_id                 := l_rec.customer_id;
         l_sr_rec.customer_number             := l_rec.customer_number;
         l_sr_rec.employee_id                 := l_rec.employee_id;
         --l_sr_rec.employee_number             := l_rec.employee_number;
         --l_sr_rec.verify_cp_flag              := l_rec.verify_cp_flag;
         l_sr_rec.customer_product_id         := l_rec.customer_product_id;
         l_sr_rec.platform_id                 := l_rec.platform_id;
         l_sr_rec.platform_version	 := l_rec.platform_version;
         l_sr_rec.db_version		 := l_rec.db_version;
         l_sr_rec.platform_version_id         := l_rec.platform_version_id;
         l_sr_rec.cp_component_id             := l_rec.cp_component_id;
         l_sr_rec.cp_component_version_id     := l_rec.cp_component_version_id;
         l_sr_rec.cp_subcomponent_id          := l_rec.cp_subcomponent_id;
         l_sr_rec.cp_subcomponent_version_id  := l_rec.cp_subcomponent_version_id;
         l_sr_rec.language_id                 := l_rec.language_id;
         --l_sr_rec.language                    := l_rec.language;
         --l_sr_rec.cp_ref_number               := l_rec.cp_ref_number;
         l_sr_rec.inventory_item_id           := l_rec.inventory_item_id;
         l_sr_rec.inventory_org_id            := l_rec.inv_organization_id;
         l_sr_rec.current_serial_number       := l_rec.current_serial_number;
         l_sr_rec.original_order_number       := l_rec.original_order_number;
         --l_sr_rec.purchase_order_num          := l_rec.purchase_order_number;
         l_sr_rec.problem_code                := l_rec.problem_code;
         l_sr_rec.exp_resolution_date         := l_rec.expected_resolution_date;
         l_sr_rec.install_site_use_id         := l_rec.install_site_use_id;
         l_sr_rec.request_attribute_1         := l_rec.incident_attribute_1;
         l_sr_rec.request_attribute_2         := l_rec.incident_attribute_2;
         l_sr_rec.request_attribute_3         := l_rec.incident_attribute_3;
         l_sr_rec.request_attribute_4         := l_rec.incident_attribute_4;
         l_sr_rec.request_attribute_5         := l_rec.incident_attribute_5;
         l_sr_rec.request_attribute_6         := l_rec.incident_attribute_6;
         l_sr_rec.request_attribute_7         := l_rec.incident_attribute_7;
         l_sr_rec.request_attribute_8         := l_rec.incident_attribute_8;
         l_sr_rec.request_attribute_9         := l_rec.incident_attribute_9;
         l_sr_rec.request_attribute_10        := l_rec.incident_attribute_10;
         l_sr_rec.request_attribute_11        := l_rec.incident_attribute_11;
         l_sr_rec.request_attribute_12        := l_rec.incident_attribute_12;
         l_sr_rec.request_attribute_13        := l_rec.incident_attribute_13;
         l_sr_rec.request_attribute_14        := l_rec.incident_attribute_14;
         l_sr_rec.request_attribute_15        := l_rec.incident_attribute_15;
         --l_sr_rec.request_context             := l_rec.request_context;
         l_sr_rec.external_attribute_1        := l_rec.external_attribute_1;
         l_sr_rec.external_attribute_2        := l_rec.external_attribute_2;
         l_sr_rec.external_attribute_3        := l_rec.external_attribute_3;
         l_sr_rec.external_attribute_4        := l_rec.external_attribute_4;
         l_sr_rec.external_attribute_5        := l_rec.external_attribute_5;
         l_sr_rec.external_attribute_6        := l_rec.external_attribute_6;
         l_sr_rec.external_attribute_7        := l_rec.external_attribute_7;
         l_sr_rec.external_attribute_8        := l_rec.external_attribute_8;
         l_sr_rec.external_attribute_9        := l_rec.external_attribute_9;
         l_sr_rec.external_attribute_10       := l_rec.external_attribute_10;
         l_sr_rec.external_attribute_11       := l_rec.external_attribute_11;
         l_sr_rec.external_attribute_12       := l_rec.external_attribute_12;
         l_sr_rec.external_attribute_13       := l_rec.external_attribute_13;
         l_sr_rec.external_attribute_14       := l_rec.external_attribute_14;
         l_sr_rec.external_attribute_15       := l_rec.external_attribute_15;
         l_sr_rec.external_context            := l_rec.external_context;
         l_sr_rec.bill_to_site_use_id         := l_rec.bill_to_site_use_id;
         l_sr_rec.bill_to_contact_id          := l_rec.bill_to_contact_id;
         l_sr_rec.ship_to_site_use_id         := l_rec.ship_to_site_use_id;
         l_sr_rec.ship_to_contact_id          := l_rec.ship_to_contact_id;
         l_sr_rec.resolution_code             := l_rec.resolution_code;
         l_sr_rec.act_resolution_date         := l_rec.actual_resolution_date;
         --l_sr_rec.public_comment_flag         := l_rec.public_comment_flag;
         --l_sr_rec.parent_interaction_id       := l_rec.parent_iteaction_id;
         l_sr_rec.contract_service_id         := l_rec.contract_service_id;
         --l_sr_rec.contract_service_number     := l_rec.contract_service_number;
         l_sr_rec.contract_id                 := l_rec.contract_id;
         l_sr_rec.project_number              := l_rec.project_number;
         l_sr_rec.qa_collection_plan_id       := l_rec.qa_collection_id;
         l_sr_rec.account_id                  := l_rec.account_id;
         l_sr_rec.resource_type               := l_rec.resource_type;
         l_sr_rec.resource_subtype_id         := l_rec.resource_subtype_id;
         --l_sr_rec.cust_po_number              := l_rec.cust_po_number;
         --l_sr_rec.cust_ticket_number          := l_rec.cust_ticket_number;
         l_sr_rec.sr_creation_channel         := l_rec.sr_creation_channel;
         l_sr_rec.obligation_date             := l_rec.obligation_date;
         l_sr_rec.time_zone_id                := l_rec.time_zone_id;
         l_sr_rec.time_difference             := l_rec.time_difference;
         l_sr_rec.site_id                     := l_rec.site_id;
         l_sr_rec.customer_site_id            := l_rec.customer_site_id;
         l_sr_rec.territory_id                := l_rec.territory_id;
         --l_sr_rec.initialize_flag             := l_rec.initialize_flag;
         l_sr_rec.cp_revision_id              := l_rec.cp_revision_id;
         l_sr_rec.inv_item_revision           := l_rec.inv_item_revision;
         l_sr_rec.inv_component_id            := l_rec.inv_component_id;
         l_sr_rec.inv_component_version       := l_rec.inv_component_version;
         l_sr_rec.inv_subcomponent_id         := l_rec.inv_subcomponent_id;
         l_sr_rec.inv_subcomponent_version    := l_rec.inv_subcomponent_version;
         ------jngeorge---------------07/12/01
         l_sr_rec.tier                        := l_rec.tier;
         l_sr_rec.tier_version                := l_rec.tier_version;
         l_sr_rec.operating_system            := l_rec.operating_system;
         l_sr_rec.operating_system_version    := l_rec.operating_system_version;
         l_sr_rec.database                    := l_rec.database;
         l_sr_rec.cust_pref_lang_id           := l_rec.cust_pref_lang_id;
         l_sr_rec.category_id                 := l_rec.category_id;
         l_sr_rec.group_type                  := l_rec.group_type;
         l_sr_rec.group_territory_id          := l_rec.group_territory_id;
         l_sr_rec.inv_platform_org_id         := l_rec.inv_platform_org_id;
         l_sr_rec.component_version           := l_rec.component_version;
         l_sr_rec.subcomponent_version        := l_rec.subcomponent_version;
         --l_sr_rec.product_revision            := l_rec.product_version;
         l_sr_rec.comm_pref_code              := l_rec.comm_pref_code;
         ---- Added for Post 11.5.6 Enhancement
         l_sr_rec.cust_pref_lang_code         := l_rec.cust_pref_lang_code;
         -- Changed the width from 1 to 30 for last_update_channel for bug 2688856
         -- shijain 3rd dec 2002
         l_sr_rec.last_update_channel         := l_rec.last_update_channel;
         l_sr_rec.category_set_id             := l_rec.category_set_id;
         l_sr_rec.external_reference          := l_rec.external_reference;
         l_sr_rec.system_id                   := l_rec.system_id;
         ------jngeorge---------------07/12/0 := l_rec.
         l_sr_rec.error_code                  := l_rec.error_code;
         l_sr_rec.incident_occurred_date      := l_rec.incident_occurred_date;
         l_sr_rec.incident_resolved_date      := l_rec.incident_resolved_date;
         l_sr_rec.inc_responded_by_date       := l_rec.inc_responded_by_date;
         --l_sr_rec.resolution_summary          := l_rec.resolution_summary;
         l_sr_rec.incident_location_id        := l_rec.incident_location_id;
         l_sr_rec.incident_address            := l_rec.incident_address;
         l_sr_rec.incident_city               := l_rec.incident_city;
         l_sr_rec.incident_state              := l_rec.incident_state;
         l_sr_rec.incident_country            := l_rec.incident_country;
         l_sr_rec.incident_province           := l_rec.incident_province;
         l_sr_rec.incident_postal_code        := l_rec.incident_postal_code;
         l_sr_rec.incident_county             := l_rec.incident_country;
         -- Added for Enh# 221666 := l_rec.
         --l_sr_rec.owner                       := l_rec.ARCHAR2(360),
         --l_sr_rec.group_owner                 := l_rec.ARCHAR2(60),
         -- Added for Credit Card ER# 2255263 (UI ER#2208078)
         l_sr_rec.cc_number                   := l_rec.credit_card_number;
         l_sr_rec.cc_expiration_date          := l_rec.credit_card_expiration_date;
         l_sr_rec.cc_type_code                := l_rec.credit_card_type_code;
         l_sr_rec.cc_first_name               := l_rec.credit_card_holder_fname;
         l_sr_rec.cc_last_name                := l_rec.credit_card_holder_lname;
         l_sr_rec.cc_middle_name              := l_rec.credit_card_holder_mname;
         l_sr_rec.cc_id                       := l_rec.credit_card_id;
         l_sr_rec.bill_to_account_id          := l_rec.bill_to_account_id;
         l_sr_rec.ship_to_account_id          := l_rec.ship_to_account_id;
         l_sr_rec.customer_phone_id   	 := l_rec.customer_phone_id;
         l_sr_rec.customer_email_id   	 := l_rec.customer_email_id;
         -- Added for source changes for 1159 by shijain oct 11 2002
         l_sr_rec.creation_program_code       := l_rec.creation_program_code;
         l_sr_rec.last_update_program_code    := l_rec.last_update_program_code;
         -- Bill_to_party, ship_to_party
         l_sr_rec.bill_to_party_id            := l_rec.bill_to_party_id;
         l_sr_rec.ship_to_party_id            := l_rec.ship_to_party_id;
         -- Conc request related fields
         l_sr_rec.program_id                  := l_rec.program_id;
         l_sr_rec.program_application_id      := l_rec.program_application_id;
         --l_sr_rec.conc_request_id            NUMBER, -- Renamed so that it doesn't clash with SR id
         l_sr_rec.program_login_id            := l_rec.program_login_id;
         -- Bill_to_site, ship_to_site
         l_sr_rec.bill_to_site_id            := l_rec.bill_to_site_id;
         l_sr_rec.ship_to_site_id            := l_rec.ship_to_site_id;
         l_sr_rec.incident_point_of_interest         := l_rec.incident_point_of_interest;
         l_sr_rec.incident_cross_street              := l_rec.incident_cross_street;
         l_sr_rec.incident_direction_qualifier       := l_rec.incident_direction_qualifier;
         l_sr_rec.incident_distance_qualifier        := l_rec.incident_distance_qualifier;
         l_sr_rec.incident_distance_qual_uom         := l_rec.incident_distance_qual_uom;
         l_sr_rec.incident_address2                  := l_rec.incident_address2;
         l_sr_rec.incident_address3                  := l_rec.incident_address3;
         l_sr_rec.incident_address4                  := l_rec.incident_address4;
         l_sr_rec.incident_address_style             := l_rec.incident_address_style;
         l_sr_rec.incident_addr_lines_phonetic       := l_rec.incident_addr_lines_phonetic;
         l_sr_rec.incident_po_box_number             := l_rec.incident_po_box_number;
         l_sr_rec.incident_house_number              := l_rec.incident_house_number;
         l_sr_rec.incident_street_suffix             := l_rec.incident_street_suffix;
         l_sr_rec.incident_street                    := l_rec.incident_street;
         l_sr_rec.incident_street_number             := l_rec.incident_street_number;
         l_sr_rec.incident_floor                     := l_rec.incident_floor;
         l_sr_rec.incident_suite                     := l_rec.incident_suite;
         l_sr_rec.incident_postal_plus4_code         := l_rec.incident_postal_plus4_code;
         l_sr_rec.incident_position                  := l_rec.incident_position;
         l_sr_rec.incident_location_directions       := l_rec.incident_location_directions;
         l_sr_rec.incident_location_description      := l_rec.incident_location_description;
         l_sr_rec.install_site_id                    := l_rec.install_site_id;

         --
         l_incident_number    := l_rec.incident_number;
     end loop;
     create_extnd_attr_tasks (
         p_api_version       ,
         p_init_msg_list     ,
         p_commit            ,
         l_sr_rec            ,
         p_sr_attributes_tbl ,
         p_request_id         ,
         l_incident_number    ,
         x_return_status              ,
         x_msg_count                  ,
         x_msg_data                   ,
         x_auto_task_gen_attempted    ,
         x_field_service_Task_created );
      --dbms_output.put_line('Return Message(isupp):'||x_return_status||':');
      if (x_return_status <> 'S') then
         for i in 1..x_msg_count loop
             FND_MSG_PUB.Get(p_msg_index=>i,
                        p_encoded=>'F',
                        p_data=>l_msg_data,
                        p_msg_index_out=>l_msg_index_out);
             l_err := l_err || l_msg_data || ',';
         end loop;
         l_note_type := fnd_profile.value('CS_SR_TASK_ERROR_NOTE_TYPE');
         if (l_note_type is null) then
            fnd_message.set_name ('CS', 'CS_EA_NULL_NOTE_TYPE');
            fnd_msg_pub.add;
            raise fnd_api.g_exc_unexpected_error;
         end if;
         l_login_id := fnd_global.login_id;
         l_user_id  := fnd_global.user_id ;
         jtf_notes_pub.create_note(
             p_api_version        => 1,
             p_init_msg_list      => p_init_msg_list,
             p_commit             => p_commit,
             p_validation_level   => fnd_api.g_valid_level_full,
             x_return_status      => x_return_status,
             x_msg_count          => x_msg_count,
             x_msg_data           => x_msg_data,
             p_entered_by         => l_user_id,
             p_entered_date       => sysdate,
             p_last_update_date   => sysdate,
             p_last_updated_by    => l_user_id,
             p_creation_date      => sysdate,
             p_created_by         => l_user_id,
             p_last_update_login  => l_login_id,
             p_source_object_id   => p_request_id,
             p_source_object_code => 'SR',
             p_notes              => l_err,
             p_notes_detail       => l_err,
             p_note_type          => l_note_type,
             p_note_status        => 'P',
             x_jtf_note_id        => l_note_id
);
      --dbms_output.put_line('Return Message(note):'||x_return_status||':');
      end if; -- check for errors returned by autogen api
  end if; -- profile option check
EXCEPTION
WHEN fnd_api.g_exc_unexpected_error THEN
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
WHEN OTHERS THEN
   fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
   fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
   fnd_msg_pub.add;
   x_return_status := fnd_api.g_ret_sts_unexp_error;
   fnd_msg_pub.count_and_get (
      p_count => x_msg_count,
      p_data => x_msg_data);
end ;
***** 9/30/2003 *******/
end cs_ea_autogen_tasks_pvt;

/
