--------------------------------------------------------
--  DDL for Package Body AME_APPROVER_GROUP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_APPROVER_GROUP_API" as
/* $Header: amapgapi.pkb 120.1 2006/03/02 02:27 prasashe noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'AME_APPROVER_GROUP_API.';
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< REFRESH_GROUP_DEPENDENTS >--------------------|
-- ----------------------------------------------------------------------------
--
procedure refresh_group_dependents
(p_approval_group_id number
,p_delete_group boolean default false)
is

--
-- Get all the parent groups for grp p_grp_id
--

cursor c_parent_grps(p_grp_id number) is
  select distinct approval_group_id
    from ame_approval_group_items
   where parameter_name = 'OAM_group_id'
     and sysdate >= start_date and sysdate < end_date
     start with parameter = to_char(p_grp_id)
     connect by prior to_char(approval_group_id) = parameter
  union
  select to_number(p_grp_id) from dual;
--
-- given a group_id, this will find all members including the members within the nested groups too.
--
  cursor c_expanded_nested_grps(p_grp_id number) is
    select group_id
          ,param_name
          ,param
          ,ord_no
     from (select distinct
                  approval_group_id group_id
                 ,parameter_name    param_name
                 ,parameter         param
                 ,order_number      ord_no
             from (select *
                     from ame_approval_group_items
                    where sysdate between start_date
                           and nvl(end_date - (1/86400), sysdate)
                  )
            start with approval_group_id = p_grp_id
          connect by prior parameter     = to_char(approval_group_id)
          )
    where not exists ( select approval_group_id
                         from ame_approval_groups
                        where approval_group_id = param
                          and param_name = 'OAM_group_id'
                          and is_static = 'Y'
                          and sysdate between start_date
                               and nvl(end_date - (1/86400), sysdate)
                     )
    union
   select approval_group_id
         ,'OAM_group_id'
         ,to_char(approval_group_id)
         ,1
     from ame_approval_Groups
    where approval_group_id=p_grp_id
      and is_static = 'N'
      and sysdate between start_date and nvl(end_date - (1/86400), sysdate);

l_grp_id          number;
l_query_string    varchar2(4000);
l_orig_system     varchar2(100);
l_orig_system_id  number;
l_grp_id_list     ame_util.idList;
l_count           number;

begin

    /*
    For each parent group, delete the rows from group_members table and populate them again
    with correct info.
    */
    l_count :=1;
    for grp in c_parent_grps(p_approval_group_id) loop
        l_grp_id_list(l_count) := grp.approval_group_id;
        l_count :=l_count+1;
    end loop;

    if p_delete_group = true then
        delete
          from ame_approval_group_items
          where parameter = to_char(p_approval_group_id)
            and parameter_name = 'OAM_group_id'
            and sysdate >= start_date and sysdate < end_date;
    end if;

    for idx in 1 .. l_grp_id_list.count loop

--      delete from ame_approval_group_members where approval_group_id = l_grp_id_list(idx);

      if p_delete_group = false or  l_grp_id_list(idx) <> p_approval_group_id  then
        update ame_approval_group_members
           set approval_group_id = hr_api.g_number
           where approval_group_id = l_grp_id_list(idx);

        for r2 in c_expanded_nested_grps( l_grp_id_list(idx)) loop
          l_orig_system    := null;
          l_orig_system_id := null;
          l_query_string   := null;

          if r2.param_name = 'wf_roles_name' then
            begin
            select orig_system, orig_system_id
              into l_orig_system, l_orig_system_id
            from wf_roles
            where name = r2.param
              and status = 'ACTIVE'
              and (expiration_date is null or
                     sysdate < expiration_date)
              and rownum < 2;
            exception
              when no_data_found then
                select orig_system, orig_system_id
                  into l_orig_system, l_orig_system_id
                  from ame_approval_group_members
                  where approval_group_id = hr_api.g_number
                    and parameter_name = 'wf_roles_name'
                    and parameter =r2.param
                    and rownum <2;
            end;
          else
             select query_string
              into l_query_string
             from ame_approval_groups
              where to_char(approval_group_id) = r2.param
                and sysdate between start_date and nvl(end_date - ame_util.oneSecond, sysdate);
          end if;

          insert into ame_approval_group_members
          (
           approval_group_id
          ,parameter_name
          ,parameter
          ,query_string
          ,order_number
          ,security_group_id
          ,orig_system
          ,orig_system_id
          ) values
          (
            l_grp_id_list(idx)
          ,r2.param_name
          ,r2.param
          ,l_query_string
          ,r2.ord_no
          ,null
          ,l_orig_system
          ,l_orig_system_id
          );
        end loop;
        delete from ame_approval_group_members where approval_group_id = hr_api.g_number;
      else
        delete from ame_approval_group_members where approval_group_id = l_grp_id_list(idx);
      end if;
    end loop;
exception
when others then
  --this point can be reached when group_members table too does not contain the approver detail
  fnd_message.set_name('PER','AME_400631_GRP_INVALID_MEMBERS');
  fnd_message.raise_error;
end refresh_group_dependents;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_AME_APPROVER_GROUP >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_approver_group
                       (p_validate                 in    boolean default false
                       ,p_language_code            in    varchar2 default
                                                         hr_api.userenv_lang
                       ,p_name                     in    varchar2
                       ,p_description              in    varchar2
                       ,p_is_static                in    varchar2
                       ,p_query_string             in    varchar2 default null
                       ,p_approval_group_id         out nocopy   number
                       ,p_start_date            out nocopy   date
                       ,p_end_date              out nocopy   date
                       ,p_object_version_number out nocopy   number
                       ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72)
                                := g_package||'create_ame_approver_group';
  l_swi_pkg_name               varchar2(72) := 'AME_APPROVER_GROUP_SWI';
  l_approval_group_id          number;
  l_object_version_number      number;
  l_object_version_number_conf number;
  l_object_version_number_act  number;
  l_start_date                 date;
  l_start_date_conf            date;
  l_start_date_act             date;
  l_end_date                   date;
  l_end_date_conf              date;
  l_end_date_act               date;
  l_action_id                  number;
  --
  --Cursor to find all application ids
  --
  Cursor C_Sel1 is
      select action_type_id
            ,name
        from ame_action_types
        where name in ( ame_util.preApprovalTypeName
                       ,ame_util.postApprovalTypeName
                       ,ame_util.groupChainApprovalTypeName
                      )
          and sysdate >= start_date and sysdate < end_date;

  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint create_ame_approver_group;
    --
    -- Remember IN OUT parameter IN values. None here.
    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk1.create_ame_approver_group_b
                         (p_name                     => p_name
                         ,p_description              => p_description
                         ,p_is_static                => p_is_static
                         ,p_query_string             => p_query_string
                         );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                (p_module_name => 'create_ame_approver_group'
                ,p_hook_type   => 'BP'
                );
    end;

    --
    -- Process Logic
    --
    ame_apg_ins.ins(p_effective_date          => sysdate
                   ,p_name                    => p_name
                   ,p_description             => p_description
                   ,p_query_string            => p_query_string
                   ,p_is_static               => p_is_static
                   ,p_security_group_id       => null
                   ,p_approval_group_id             => l_approval_group_id
                   ,p_object_version_number         => l_object_version_number
                   ,p_start_date                    => l_start_date
                   ,p_end_date                      => l_end_date
                   );
    ame_agl_ins.ins_tl
      (p_language_code              => p_language_code
      ,p_approval_group_id          => l_approval_group_id
      ,p_user_approval_group_name   => p_name
      ,p_description                => p_description
      );
    --
    -- Create group based actions.
    --
    for rec in C_Sel1
    loop
      if(rec.name = ame_util.preApprovalTypeName) then
        fnd_message.set_name('PER', 'AME_400571_PRE_APG_ACT_DESC');
      elsif (rec.name = ame_util.postApprovalTypeName) then
        fnd_message.set_name('PER', 'AME_400572_POST_APG_ACT_DESC');
      elsif (rec.name = ame_util.groupChainApprovalTypeName) then
        fnd_message.set_name('PER', 'AME_400573_COA_APG_ACT_DESC');
      end if;
      fnd_message.set_token('GROUP_NAME', p_name);
      ame_action_api.create_ame_action
      (p_action_type_id            => rec.action_type_id
      ,p_parameter                 => to_char(l_approval_group_id)
      ,p_description               => fnd_message.get
      ,p_parameter_two             => null
      ,p_action_id                        => l_action_id
      ,p_object_version_number            => l_object_version_number
      ,p_start_date                       => l_start_date
      ,p_end_date                         => l_end_date
      );
    end loop;

    --
    --if the created group is dynamic, then we have to update the
    --ame_approval_group_members table using refresh_group_dependents
    --
    if p_is_static = 'N' then
      refresh_group_dependents(p_approval_group_id => l_approval_group_id);
    end if;

    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk1.create_ame_approver_group_a
                   (p_name                   => p_name
                   ,p_description            => p_description
                   ,p_is_static              => p_is_static
                   ,p_query_string           => p_query_string
                   ,p_approval_group_id      => l_approval_group_id
                   ,p_object_version_number  => l_object_version_number
                   ,p_start_date             => l_start_date
                   ,p_end_date               => l_end_date
                   );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                (p_module_name => 'create_ame_approver_group'
                ,p_hook_type   => 'AP'
                );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values
    --
    p_approval_group_id             := l_approval_group_id;
    p_object_version_number         := l_object_version_number;
    p_start_date                    := l_start_date;
    p_end_date                      := l_end_date;

    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to create_ame_approver_group;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      p_approval_group_id         := null;
      p_object_version_number     := null;
      p_start_date                := null;
      p_end_date                  := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to create_ame_approver_group;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_approval_group_id         := null;
      p_object_version_number     := null;
      p_start_date                := null;
      p_end_date                  := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end create_ame_approver_group;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_AME_APPROVER_GROUP >-------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_approver_group
  (p_validate                    in     boolean  default false
  ,p_approval_group_id           in     number
  ,p_language_code               in     varchar2 default
                                                 hr_api.userenv_lang
  ,p_description                 in     varchar2 default hr_api.g_varchar2
  ,p_is_static                   in     varchar2 default hr_api.g_varchar2
  ,p_query_string                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number       in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc       varchar2(72) := g_package||'update_ame_approver_group';
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  l_old_is_static             varchar2(1);
  l_object_version_number_item number;
  l_start_date_item            date;
  l_end_date_item              date;
--cursor to find if the group has static members.
  cursor Csel1 is
    select is_static
      from ame_approval_groups
      where approval_group_id = p_approval_group_id
        and sysdate >= start_date and sysdate < end_date;
--cursor to find the group's members.
  cursor CSel3 is
         select approval_group_item_id
               ,object_version_number
           from ame_approval_group_items
           where approval_group_id = p_approval_group_id
             and sysdate >= start_date and sysdate < end_date;

  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_ame_approver_group;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk2.update_ame_approver_group_b
        (p_approval_group_id        => p_approval_group_id
        ,p_language_code            => p_language_code
        ,p_description              => p_description
        ,p_is_static                => p_is_static
        ,p_query_string             => p_query_string
        ,p_object_version_number    => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                    (p_module_name => 'update_ame_approver_group'
                    ,p_hook_type   => 'BP'
                    );
    end;
    --
    -- Process Logic
    --
    --find the current is_static value.
    open Csel1;
    fetch Csel1 into l_old_is_static;
    close Csel1;
    --call row handler update procedure
    ame_apg_upd.upd(p_effective_date        => sysdate
                   ,p_datetrack_mode        => hr_api.g_update
                   ,p_approval_group_id     => p_approval_group_id
                   ,p_object_version_number => p_object_version_number
                   ,p_description           => p_description
                   ,p_is_static             => p_is_static
                   ,p_query_string          => p_query_string
                   ,p_security_group_id     => hr_api.g_number
                   ,p_start_date            => l_start_date
                   ,p_end_date              => l_end_date
                   );
   --call tl table update procedure
   ame_agl_upd.upd_tl
              (p_approval_group_id         => p_approval_group_id
              ,p_language_code             => p_language_code
              ,p_description               => p_description
              );

  --
  -- When is_static is changed from 'Y' to 'N',
  -- delete all static members of the group from ame_approval_group_items
  --
    if l_old_is_static ='Y' and  p_is_static = 'N' and instrb(DBMS_UTILITY.FORMAT_CALL_STACK,'AME_APPROVER_GROUP_SWI') = 0 then
    for rec in CSel3
      loop
        l_object_version_number_item := rec.object_version_number;
        ame_gpi_del.del
                (p_effective_date          => sysdate
                ,p_datetrack_mode          => hr_api.g_delete
                ,p_approval_group_item_id  => rec.approval_group_item_id
                ,p_object_version_number   => l_object_version_number_item
                ,p_start_date              => l_start_date_item
                ,p_end_date                => l_end_date_item
                );
      end loop;
    end if;
    --
    --since we are updating the group, values like query_string,
    --need to be updated in ame_approval_group_members table also.
    --Also in case a static group is updated into a dynamic group,
    --we need to update members table.
    --
    refresh_group_dependents(p_approval_group_id => p_approval_group_id);

    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk2.update_ame_approver_group_a
        (p_approval_group_id        => p_approval_group_id
        ,p_language_code            => p_language_code
        ,p_description              => p_description
        ,p_is_static                => p_is_static
        ,p_query_string             => p_query_string
        ,p_object_version_number    => p_object_version_number
        ,p_start_date               => l_start_date
        ,p_end_date                 => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                  (p_module_name => 'update_ame_approver_group'
                  ,p_hook_type   => 'AP'
                  );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date   := l_start_date;
    p_end_date     := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_ame_approver_group;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_ame_approver_group;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number  := l_object_version_number;
      p_start_date             := null;
      p_end_date               := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end update_ame_approver_group;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_AME_APPROVER_GROUP >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_approver_group
              (p_validate              in     boolean  default false
              ,p_approval_group_id     in     number
              ,p_object_version_number in out nocopy   number
              ,p_start_date               out nocopy   date
              ,p_end_date                 out nocopy   date
              ) is
  --
  -- Declare cursors and local variables
  Cursor C_Sel2 is
      select act.action_id
            ,act.action_type_id
            ,act.object_version_number
        from ame_actions act
            ,ame_action_types aty
        where aty.name in ( ame_util.preApprovalTypeName
                           ,ame_util.postApprovalTypeName
                           ,ame_util.groupChainApprovalTypeName
                          )
          and act.action_type_id = aty.action_type_id
          and act.parameter = to_char(p_approval_group_id)
          and sysdate >= act.start_date and sysdate < act.end_date
          and sysdate >= aty.start_date and sysdate < aty.end_date;
--cursor to find all members for this approval group.
  cursor CSel3 is
         select approval_group_item_id
               ,object_version_number
           from ame_approval_group_items
           where approval_group_id = p_approval_group_id
             and sysdate >= start_date  and sysdate < end_date;
--cursor to find the number of rules using the group(01-03-2005)
  cursor CSel4 is
    select count(*)
      from ame_action_usages actu
          ,ame_actions act
          ,ame_action_types acty
      where act.parameter = to_char(p_approval_group_id)
        and  actu.action_id = act.action_id
        and  act.action_type_id = acty.action_type_id
        and  acty.name in (
                            'approval-group chain of authority'
                           ,'pre-chain-of-authority approvals'
                           ,'post-chain-of-authority approvals')
        and sysdate between actu.start_date and
              nvl(actu.end_Date,sysdate)
        and sysdate between act.start_date and
              nvl(act.end_date-(1/86400),sysdate)
        and sysdate between acty.start_date and
              nvl(acty.end_date-(1/86400),sysdate);

  l_swi_pkg_name               varchar2(72) := 'AME_APPROVER_GROUP_SWI';
  l_proc                 varchar2(72) := g_package||'delete_ame_approver_group';
  l_object_version_number     number;
  l_start_date                date;
  l_end_date                  date;
  l_object_version_number_conf number;
  l_start_date_conf           date;
  l_end_date_conf             date;
  l_rule_count                number;
  l_config_count              number;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint delete_approver_group;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk3.delete_ame_approver_group_b
        (p_approval_group_id        => p_approval_group_id
        ,p_object_version_number    => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                        (p_module_name => 'delete_ame_approver_group'
                        ,p_hook_type   => 'BP'
                        );
    end;
    --
    -- Process Logic
    --
    --check needs to be done if any rule is using this group
    open CSel4;
    fetch CSel4 into l_rule_count;
    close CSel4;
    if(l_rule_count <> 0) then
     --there are rules using actions on this group
      fnd_message.set_name('PER', 'AME_400558_RULES_EXIST_FOR_APG');
      fnd_message.raise_error;
     end if;

    --throw an error if config is existing for this group
     select count(*)
       into l_config_count
       from ame_approval_group_config a
           ,ame_calling_apps aca
      where a.approval_group_id = p_approval_group_id
        and a.application_id = aca.application_id
        and sysdate between aca.start_date and nvl(aca.end_date  - (1/86400), sysdate)
        and sysdate between a.start_date and nvl(a.end_date - (1/86400), sysdate);
    if(l_config_count <> 0) then
      fnd_message.set_name('PER', 'AME_400559_CFG_EXIST_FOR_APG');
      fnd_message.raise_error;
    end if;

   --delete group actions for group related action_types
      for rec in C_Sel2
      loop
        ame_action_api.delete_ame_action
        (p_action_id                 => rec.action_id
        ,p_action_type_id            => rec.action_type_id
        ,p_object_version_number     => rec.object_version_number
        ,p_start_date                => l_start_date
        ,p_end_date                  => l_end_date
        );
      end loop;
   --
   --delete items from ame_approval_group_items if this group is static.
   --
      for rec in CSel3
      loop
        l_object_version_number_conf :=rec.object_version_number;
         ame_gpi_del.del
                (p_effective_date          => sysdate
                ,p_datetrack_mode          => hr_api.g_delete
                ,p_approval_group_item_id  => rec.approval_group_item_id
                ,p_object_version_number   => l_object_version_number_conf
                ,p_start_date              => l_start_date_conf
                ,p_end_date                => l_end_date_conf
                );
      end loop;
      ame_apg_del.del(p_effective_date          => sysdate
                     ,p_datetrack_mode          => hr_api.g_delete
                     ,p_approval_group_id       => p_approval_group_id
                     ,p_object_version_number   => p_object_version_number
                     ,p_start_date              => l_start_date
                     ,p_end_date                => l_end_date
                     );
     --if this group is used as a nested group by other groups
     --delete the entry from items table and also refresh
     --members table.
     refresh_group_dependents(p_approval_group_id =>  p_approval_group_id
                          ,p_delete_group       =>  true
                          );

    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk3.delete_ame_approver_group_a
      (p_approval_group_id            => p_approval_group_id
      ,p_object_version_number        => p_object_version_number
      ,p_start_date                   => l_start_date
      ,p_end_date                     => l_end_date
      );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                              (p_module_name => 'delete_ame_approver_group'
                              ,p_hook_type   => 'AP'
                              );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date  := l_start_date;
    p_end_date    := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to delete_approver_group;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to delete_approver_group;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;
  end delete_ame_approver_group;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_APPROVER_GROUP_CONFIG >--------------------|
-- ----------------------------------------------------------------------------
--


  procedure create_approver_group_config
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_id      in     number
                ,p_application_id         in     number
                ,p_voting_regime          in     varchar2
                ,p_order_number           in     number   default null
                ,p_object_version_number     out  nocopy  number
                ,p_start_date                out  nocopy  date
                ,p_end_date                  out  nocopy  date
                ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_approver_group_config';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint add_approver_group_config;
    --
    -- Remember IN OUT parameter IN values
    --

    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk4.create_approver_group_config_b
        (p_approval_group_id     => p_approval_group_id
        ,p_application_id        => p_application_id
        ,p_voting_regime         => p_voting_regime
        ,p_order_number          => p_order_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                          (p_module_name => 'create_approver_group_config'
                          ,p_hook_type   => 'BP'
                          );
    end;
    --
    -- Process Logic
    --
    ame_gcf_ins.ins(p_effective_date         => sysdate
                   ,p_approval_group_id      => p_approval_group_id
                   ,p_application_id         => p_application_id
                   ,p_voting_regime          => p_voting_regime
                   ,p_order_number           => p_order_number
                   ,p_object_version_number      => l_object_version_number
                   ,p_start_date                 => l_start_date
                   ,p_end_date                   => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk4.create_approver_group_config_a
        (p_approval_group_id      => p_approval_group_id
        ,p_application_id         => p_application_id
        ,p_voting_regime          => p_voting_regime
        ,p_order_number           => p_order_number
        ,p_object_version_number   => l_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error(p_module_name => 'create_approver_group_config'
                                          ,p_hook_type   => 'AP'
                                          );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date            := l_start_date;
    p_end_date              := l_end_date;
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to add_approver_group_config;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := null;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to add_approver_group_config;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := null;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;

 end create_approver_group_config;

--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_APPROVER_GROUP_CONFIG >---------------|
-- ----------------------------------------------------------------------------
--

  procedure delete_approver_group_config
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_id      in     number
                ,p_application_id         in     number
                ,p_object_version_number  in out  nocopy  number
                ,p_start_date                out  nocopy  date
                ,p_end_date                  out  nocopy  date
                ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_approver_group_config';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint remove_approver_group_config;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk5.delete_approver_group_config_b
        (p_approval_group_id     => p_approval_group_id
        ,p_application_id        => p_application_id
        ,p_object_version_number => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                          (p_module_name => 'delete_approver_group_config'
                          ,p_hook_type   => 'BP'
                          );
    end;
    --
    -- Process Logic
    --
    ame_gcf_del.del(p_effective_date         => sysdate
                   ,p_datetrack_mode         => hr_api.g_delete
                   ,p_approval_group_id      => p_approval_group_id
                   ,p_application_id         => p_application_id
                   ,p_object_version_number      => p_object_version_number
                   ,p_start_date                 => l_start_date
                   ,p_end_date                   => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk5.delete_approver_group_config_a
        (p_approval_group_id      => p_approval_group_id
        ,p_application_id         => p_application_id
        ,p_object_version_number   => p_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                    (p_module_name => 'delete_approver_group_config'
                    ,p_hook_type   => 'AP'
                    );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date            := l_start_date;
    p_end_date              := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to remove_approver_group_config;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to remove_approver_group_config;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;

 end delete_approver_group_config;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_APPROVER_GROUP_CONFIG >---------------|
-- ----------------------------------------------------------------------------
--
  procedure update_approver_group_config
            (
             p_validate               in     boolean  default false
            ,p_approval_group_id      in     number
            ,p_application_id         in     number
            ,p_voting_regime          in     varchar2 default hr_api.g_varchar2
            ,p_order_number           in     varchar2 default hr_api.g_number
            ,p_object_version_number  in  out  nocopy  number
            ,p_start_date                 out  nocopy  date
            ,p_end_date                   out  nocopy  date
            ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'update_approver_group_config';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_approver_group_config;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk6.update_approver_group_config_b
        (p_approval_group_id     => p_approval_group_id
        ,p_application_id        => p_application_id
        ,p_voting_regime         => p_voting_regime
        ,p_order_number          => p_order_number
        ,p_object_version_number =>p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                          (p_module_name => 'update_approver_group_config'
                          ,p_hook_type   => 'BP'
                          );
    end;
    --
    -- Process Logic
    --
    ame_gcf_upd.upd(p_effective_date         => sysdate
                   ,p_datetrack_mode         => hr_api.g_update
                   ,p_approval_group_id      => p_approval_group_id
                   ,p_application_id         => p_application_id
                   ,p_voting_regime          => p_voting_regime
                   ,p_order_number           => p_order_number
                   ,p_object_version_number      => p_object_version_number
                   ,p_start_date                 => l_start_date
                   ,p_end_date                   => l_end_date
                   );
    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk6.update_approver_group_config_a
        (p_approval_group_id      => p_approval_group_id
        ,p_application_id         => p_application_id
        ,p_voting_regime          => p_voting_regime
        ,p_order_number           => p_order_number
        ,p_object_version_number   => p_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                    (p_module_name => 'update_approver_group_config'
                    ,p_hook_type   => 'AP'
                    );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date            := l_start_date;
    p_end_date              := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_approver_group_config;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_approver_group_config;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;

 end update_approver_group_config;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_APPROVER_GROUP_ITEM >---------------|
-- ----------------------------------------------------------------------------
--
procedure create_approver_group_item
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_id      in     number
                ,p_parameter_name         in     varchar2
                ,p_parameter              in     varchar2
                ,p_order_number           in     number
                ,p_approval_group_item_id    out  nocopy  number
                ,p_object_version_number     out  nocopy  number
                ,p_start_date                out  nocopy  date
                ,p_end_date                  out  nocopy  date
                ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc         varchar2(72) := g_package||'create_approver_group_item';
  l_object_version_number       number;
  l_start_date                  date;
  l_end_date                    date;
  l_parameter_allowed           boolean;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint add_approver_group_item;
    --
    -- Remember IN OUT parameter IN values
    --

    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk7.create_approver_group_item_b
        (p_approval_group_id     => p_approval_group_id
        ,p_parameter_name        => p_parameter_name
        ,p_parameter             => p_parameter
        ,p_order_number          => p_order_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                          (p_module_name => 'create_approver_group_item'
                          ,p_hook_type   => 'BP'
                          );
    end;
    --
    -- Process Logic
    --

    ame_gpi_ins.ins(p_effective_date         => sysdate
                   ,p_approval_group_id      => p_approval_group_id
                   ,p_parameter_name         => p_parameter_name
                   ,p_parameter              => p_parameter
                   ,p_order_number           => p_order_number
                   ,p_approval_group_item_id     => p_approval_group_item_id
                   ,p_object_version_number      => l_object_version_number
                   ,p_start_date                 => l_start_date
                   ,p_end_date                   => l_end_date
                   );
    refresh_group_dependents(p_approval_group_id => p_approval_group_id);
    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk7.create_approver_group_item_a
        (p_approval_group_id      => p_approval_group_id
        ,p_parameter_name         => p_parameter_name
        ,p_parameter              => p_parameter
        ,p_order_number           => p_order_number
        ,p_object_version_number   => l_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                    (p_module_name => 'create_approver_group_item'
                    ,p_hook_type   => 'AP'
                    );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date            := l_start_date;
    p_end_date              := l_end_date;
    p_object_version_number := l_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to add_approver_group_item;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := null;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to add_approver_group_item;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := null;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;

 end create_approver_group_item;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_APPROVER_GROUP_ITEM >---------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_approver_group_item
                (
                 p_validate               in     boolean  default false
                ,p_approval_group_item_id in     number
                ,p_object_version_number  in out  nocopy  number
                ,p_start_date                out  nocopy  date
                ,p_end_date                  out  nocopy  date
                ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'delete_approver_group_item';
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;
  l_approval_group_id      number;

  cursor Csel1 is
    select approval_group_id
      from ame_approval_group_items
      where approval_group_item_id = p_approval_group_item_id
        and sysdate >= start_date and sysdate < end_date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint remove_approver_group_item;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk8.delete_approver_group_item_b
        (p_approval_group_item_id     => p_approval_group_item_id
        ,p_object_version_number      => p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                          (p_module_name => 'delete_approver_group_item'
                          ,p_hook_type   => 'BP'
                          );
    end;
    --
    -- Process Logic
    --
    open Csel1;
    fetch Csel1 into l_approval_group_id;
    --handle case where item_id is invalid
    if Csel1%notfound then
      close Csel1;
      fnd_message.set_name('PER', 'AME_400560_APG_ITEM_IS_INVALID');
      fnd_message.raise_error;
    else
      close Csel1;
    end if;
    ame_gpi_del.del(p_effective_date         => sysdate
                   ,p_datetrack_mode         => hr_api.g_delete
                   ,p_approval_group_item_id => p_approval_group_item_id
                   ,p_object_version_number      => p_object_version_number
                   ,p_start_date                 => l_start_date
                   ,p_end_date                   => l_end_date
                   );
    --
    --Update all dependent groups of p_approval_group_id
    --
    refresh_group_dependents(p_approval_group_id => l_approval_group_id);
    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk8.delete_approver_group_item_a
        (p_approval_group_item_id  => p_approval_group_item_id
        ,p_object_version_number   => p_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                    (p_module_name => 'delete_approver_group_item'
                    ,p_hook_type   => 'AP'
                    );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date            := l_start_date;
    p_end_date              := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to remove_approver_group_item;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to remove_approver_group_item;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;

 end delete_approver_group_item;

--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_APPROVER_GROUP_ITEM >---------------|
-- ----------------------------------------------------------------------------
--
  procedure update_approver_group_item
            (
             p_validate               in     boolean  default false
            ,p_approval_group_item_id in     number
            ,p_order_number           in     varchar2 default hr_api.g_number
            ,p_object_version_number  in  out  nocopy  number
            ,p_start_date                 out  nocopy  date
            ,p_end_date                   out  nocopy  date
            ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'update_approver_group_item';
  l_approval_group_id      number;
  l_object_version_number  number;
  l_start_date             date;
  l_end_date               date;

  cursor Csel1 is
    select approval_group_id
      from ame_approval_group_items
      where approval_group_item_id = p_approval_group_item_id
        and sysdate between start_date and end_date;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint update_approver_group_item;
    --
    -- Remember IN OUT parameter IN values
    --
    l_object_version_number := p_object_version_number;
    --
    -- Call Before Process User Hook
    --
    begin
      ame_approver_group_bk9.update_approver_group_item_b
        (p_approval_group_item_id => p_approval_group_item_id
        ,p_order_number          => p_order_number
        ,p_object_version_number =>p_object_version_number
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                          (p_module_name => 'update_approver_group_item'
                          ,p_hook_type   => 'BP'
                          );
    end;
    --
    -- Process Logic
    --
    open Csel1;
    fetch Csel1 into l_approval_group_id;
    --handle case when item_id is invalid
    if Csel1%notfound then
      close Csel1;
      fnd_message.set_name('PER', 'AME_400560_APG_ITEM_IS_INVALID');
      fnd_message.raise_error;
    else
      close Csel1;
    end if;
    ame_gpi_upd.upd(p_effective_date         => sysdate
                   ,p_datetrack_mode         => hr_api.g_update
                   ,p_approval_group_item_id => p_approval_group_item_id
                   ,p_order_number           => p_order_number
                   ,p_object_version_number      => p_object_version_number
                   ,p_start_date                 => l_start_date
                   ,p_end_date                   => l_end_date
                   );
    --update ame_approval_Group_members table to update order_number
    --of dependent groups

    refresh_group_dependents(p_approval_group_id => l_approval_group_id);
    --
    -- Call After Process User Hook
    --
    begin
      ame_approver_group_bk9.update_approver_group_item_a
        (p_approval_group_item_id  => p_approval_group_item_id
        ,p_order_number            => p_order_number
        ,p_object_version_number   => p_object_version_number
        ,p_start_date              => l_start_date
        ,p_end_date                => l_end_date
        );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
                    (p_module_name => 'update_approver_group_item'
                    ,p_hook_type   => 'AP'
                    );
    end;
    --
    -- When in validation only mode raise the Validate_Enabled exception
    --
    if p_validate then
      raise hr_api.validate_enabled;
    end if;
    --
    -- Set all IN OUT and OUT parameters with out values.
    --
    p_start_date            := l_start_date;
    p_end_date              := l_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      rollback to update_approver_group_item;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    when others then
      --
      -- A validation or unexpected error has occured
      --
      rollback to update_approver_group_item;
      --
      -- Reset IN OUT parameters and set all
      -- OUT parameters, including warnings, to null
      --
      p_object_version_number := l_object_version_number;
      p_start_date            := null;
      p_end_date              := null;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 90);
      raise;

 end update_approver_group_item;

end AME_APPROVER_GROUP_API;

/
