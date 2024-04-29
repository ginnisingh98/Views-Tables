--------------------------------------------------------
--  DDL for Package Body AME_GPI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_GPI_BUS" as
/* $Header: amgpirhi.pkb 120.4 2006/03/01 03:10 pvelugul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ame_gpi_bus.';  -- Global package name

--


--
-- ----------------------------------------------------------------------------
-- |-------------------------< IS_NESTING_ALLOWED >---------------|
-- ----------------------------------------------------------------------------
--(Start of Comments)
--This procedure finds if the group p_nest can be nested inside the group
--p_group by finding all ancestors and descendents of p_group and ensuring
--that p_nest is not in the generated list. The ancestors are found in order
--to ensure that the nesting will not form a loop. The descendents are found
--in order to ensure that the  p_nest is not already present in p_group.
--
function is_nesting_allowed(p_group in number
                           ,p_nest  in number) return boolean as
  --The following cursor finds all ancestors and descendants of
  --p_group. The first part of the cursor will find all
  --descendants of p_group. The second part finds all ancestors of
  --p_group.
  cursor CSel1 is
    select grp from
     (
      select distinct to_number(parameter) grp
        from (select *
                from ame_approval_group_items
                where sysdate >= start_date
                  and sysdate < (end_date -  ame_util.oneSecond)
              )
        where parameter_name = 'OAM_group_id'
        start with approval_group_id =p_group
        connect by prior decode(parameter_name,'OAM_group_id',parameter,null)
                               = to_char(approval_group_id)

      union

      select distinct approval_group_id grp
        from (select *
                from  ame_approval_group_items
                where sysdate >= start_date
                  and sysdate < (end_date -  ame_util.oneSecond)
              )
        where parameter_name = 'OAM_group_id'
        start with parameter = to_char(p_group)
        connect by prior to_char(approval_group_id) = parameter
     );
begin
  if p_group = p_nest then
    return false;
  end if;
  for rec in CSel1
  loop
    if rec.grp = p_nest then
      return false;
    end if;
  end loop;
  return true;
end is_nesting_allowed;


--
-- ----------------------------------------------------------------------------
-- |-------------------------< GROUP_IS_IN_GROUP >---------------|
-- ----------------------------------------------------------------------------
--

function group_is_in_group(p_approval_group_id in number,
                          possiblyNestedGroupIdIn in number) return boolean as
    cursor groupMemberCursor(approvalGroupIdIn in number) is
      select
        parameter,
        parameter_name
        from ame_approval_group_items
        where
          approval_group_id = approvalGroupIdIn and
          sysdate between start_date and (end_date -  ame_util.oneSecond);
    l_proc   varchar2(72) := g_package||'group_is_in_group';
    tempGroupId number;
    begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      for tempGroup in groupMemberCursor(approvalGroupIdIn => p_approval_group_id) loop
        if(tempGroup.parameter_name = ame_util.approverOamGroupId) then
          tempGroupId := to_number(tempGroup.parameter);
          if(tempGroupId = possiblyNestedGroupIdIn) then
            return(true);
          elsif(group_is_in_group(p_approval_group_id => tempGroupId,
                               possiblyNestedGroupIdIn => possiblyNestedGroupIdIn)) then
            return(true);
          end if;
        end if;
      end loop;
      return(false);
      hr_utility.set_location(' Leaving:'||l_proc, 70);
    end group_is_in_group;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< GET_ALLOWED_NESTED_GROUPS >---------------|
-- ----------------------------------------------------------------------------
--
 procedure get_allowed_nested_groups
                (p_approval_group_id        in  number
                ,allowedNestedGroupIdsOut   out nocopy ame_util.stringList
                ,allowedNestedGroupNamesOut out nocopy ame_util.stringList) as
    cursor groupCursor is
      select
         approval_group_id
        ,name
        from ame_approval_groups
        where
          sysdate between start_date and (end_date -  ame_util.oneSecond);
    l_proc   varchar2(72) := g_package||'get_allowed_nested_groups';
    tempIndex number;
    begin
      hr_utility.set_location('Entering:'|| l_proc, 10);
      tempIndex := 0; /* pre-increment */
      for tempGroup in groupCursor loop
        /*
          Check whether the group identified by groupIdIn G is nested in
          the group identified by tempGroup P.  If so, we would have a loop in
          the groups:  P contains G, and G would contain P, which would then
          contain G, . . .  Also check whether P is already in G.
        */
        if(p_approval_group_id <> tempGroup.approval_group_id and
           not group_is_in_group(p_approval_group_id => tempGroup.approval_group_id,
                              possiblyNestedGroupIdIn => p_approval_group_id) and
           not group_is_in_group(p_approval_group_id => p_approval_group_id,
                              possiblyNestedGroupIdIn => tempGroup.approval_group_id)) then
          tempIndex := tempIndex + 1;
          allowedNestedGroupIdsOut(tempIndex) := to_char(tempGroup.approval_group_id);
          allowedNestedGroupNamesOut(tempIndex) := tempGroup.name;
        end if;
      end loop;
      hr_utility.set_location(' Leaving:'||l_proc, 70);
    end get_allowed_nested_groups;

-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPROVER_TYPE >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure checks if the group item to be added has a member of
--  approver type ,which is not allowed in one or more transaction types using
--  the approver group
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_approval_group_id
--   p_parameter_name
--   p_parameter
--
-- Post Success:
--   Processing continues if a valid approval_group_id is existing for the item.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_approver_type(p_approval_group_id     in   number
                           ,p_parameter_name        in   varchar2
                           ,p_parameter             in   varchar2
                           ) IS
--
  l_proc             varchar2(72) := g_package || 'CHK_APPROVER_TYPE';
  l_count            number;
  l_config_value     ame_config_vars.variable_value%type;
  l_application_id   number;
  --
  -- cursor to find the transaction types using the approver group
  --
  cursor C_Sel1 is
    select apgc.application_id
      from ame_approval_group_config apgc
          ,ame_calling_apps aca
     where approval_group_id = p_approval_group_id
       and aca.application_id = apgc.application_id
       and sysdate between apgc.start_date and
           nvl(apgc.end_date-ame_util.oneSecond,SYSDATE)
       and sysdate between aca.start_date and
           nvl(aca.end_date-ame_util.oneSecond,SYSDATE);
  --
  -- cursor to find the value of allowAllApproverTypes config variable for the
  -- current transaction type.
  --
  cursor C_Sel2 is
    select variable_value
      from ame_config_vars
     where variable_name like 'allowAllApproverTypes'
       and application_id = l_application_id
       and sysdate between start_date and
           nvl(end_date-ame_util.oneSecond,SYSDATE);

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPROVAL_GROUP_ID'
                              ,p_argument_value     => p_approval_group_id
                              );
    -- Check if the group item has members of approver type other than 'PER'
    -- and 'FND_USR'
    if p_parameter_name = 'wf_roles_name' then
      select count(*) into l_count
        from wf_roles
       where name=p_parameter
         and orig_system not in ('PER','FND_USR')
         and sysdate between nvl(start_date,sysdate) and
             nvl(expiration_date,sysdate);
    elsif p_parameter_name = 'OAM_group_id' then
      select count(*) into l_count
        from ame_approval_group_members
       where approval_group_id = p_parameter
         and orig_system not in ('FND_USR','PER');
    end if;
    -- If group item has members of approver type other than 'PER' and 'FND_USR'
    -- then find if any transaction type using the approver group has the config
    -- variable allowAllApproverTypes set to 'no'
    if l_count <> 0 then
      open C_Sel1;
      loop
      fetch C_Sel1 into l_application_id;
      exit when C_Sel1%NOTFOUND;
        -- find the value of config variable allowAllApproverTypes for the current
        -- transaction type
        open C_Sel2;
        fetch C_Sel2 into l_config_value;
        if C_Sel2%notfound then
          -- if the config variable is not defined for the current transaction type
          -- use the global value
          select variable_value into l_config_value
            from ame_config_vars
           where variable_name like 'allowAllApproverTypes'
             and application_id = 0
             and sysdate between start_date and
                 nvl(end_date-ame_util.oneSecond,SYSDATE);
        end if;
        close C_Sel2;
        -- if all approver types are allowed for the current transaction ,then return
        if l_config_value = 'no' then
          fnd_message.set_name('PER','AME_400618_INV_APG_MEM_TXNTYP');
          fnd_message.raise_error;
        end if;
       end loop;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_ITEMS.APPROVAL_GROUP_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_approver_type;

-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_APPROVAL_GROUP_ID >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the approval_group_id and also makes sure that
--  the group has is_static = 'Y'.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_approval_group_id
--   p_effective_date
--
-- Post Success:
--   Processing continues if a valid approval_group_id is existing for the item.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_approval_group_id(p_approval_group_id     in   number
                               ,p_effective_date        in   date
                               ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_APPROVAL_GROUP_ID';
  l_count    number;
--
-- Cursor to find number of groups with approval_group_id = p_approval_Group_id and is_static='Y'
--
  Cursor C_Sel1 Is
    select count(t.approval_group_id)
      from ame_approval_groups t
     where t.approval_group_id = p_approval_group_id
       and p_effective_date between t.start_date
            and (t.end_date - ame_util.oneSecond);
  Cursor C_Sel2 Is
    select count(t.approval_group_id)
      from ame_approval_groups t
     where t.approval_group_id = p_approval_group_id
       and t.is_static = 'Y'
       and p_effective_date between t.start_date
            and (t.end_date -  ame_util.oneSecond);
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPROVAL_GROUP_ID'
                              ,p_argument_value     => p_approval_group_id
                              );
    -- Check if the approval_group exists
    open C_Sel1;
    fetch C_Sel1 into l_count;
    close C_Sel1;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400557_INVALID_APG_ID');
      fnd_message.raise_error;
    end if;
    -- Check if the approval_group exists and has is_static = 'Y'
    open C_Sel2;
    fetch C_Sel2 into l_count;
    close C_Sel2;
    if l_count = 0 then
      fnd_message.set_name('PER','AME_400801_INV_STATIC_APG');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_ITEMS.APPROVAL_GROUP_ID'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_approval_group_id;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_PARAMETER_NAME >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the parameter_name. Its value should be
--  in ('OAM_group_id','wf_roles_name') .
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_parameter_name
--
-- Post Success:
--   Processing continues if parameter_name has valid values
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parameter_name(p_parameter_name        in   varchar2
                            ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_PARAMETER_NAME';

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'PARAMETER_NAME'
                              ,p_argument_value     => p_parameter_name
                              );
    -- Check if the parameter_name is in ('OAM_group_id','wf_roles_name')
    if p_parameter_name not in ('OAM_group_id','wf_roles_name')  then
      fnd_message.set_name('PER','AME_400567_INV_APG_ITM_PAR_NAM');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_ITEMS.PARAMETER_NAME'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_parameter_name;


-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_PARAMETER >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates the parameter value. Its value should be
--  a valid approval_group if parameter_name is 'OAM_group_id'.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_parameter_name
--   p_parameter
--   p_effective_date
--
-- Post Success:
--   Processing continues if parameter has valid values
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_parameter(
                        p_approval_group_id     in   number
                       ,p_parameter_name        in   varchar2
                       ,p_parameter             in   varchar2
                       ,p_effective_date        in   date
                       ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_PARAMETER';
  l_count    number;
  l_parameter_allowed boolean;
  l_allowed_nested_group_ids    ame_util.stringList;
  l_allowed_nested_group_names  ame_util.stringList;
--
-- Cursor to find number of groups with approval_group_id = p_parameter
--
  Cursor C_Sel1 Is
    select count(t.approval_group_id)
    from   ame_approval_groups t
    where to_char(t.approval_group_id) = p_parameter
    and p_effective_date between t.start_date and (t.end_date -  ame_util.oneSecond);

  Cursor C_Sel2 Is
    select count(name)
      from wf_roles
      where name = p_parameter
        and status = 'ACTIVE'
        and (expiration_date is null or
              sysdate < expiration_date)
        and  rownum < 2;

  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'PARAMETER'
                              ,p_argument_value     => p_parameter
                              );
    -- Check if the parameter corresponds to a valid group in ame_approval_groups
    -- whenever parameter_name = 'OAM_group_id'
    -- If parameter_name = 'wf_roles_name' then validate the wf_roles_name.
    --
    if p_parameter_name = ame_util.approverOamGroupId  then
      open C_Sel1;
      fetch C_Sel1 into l_count;
      close C_Sel1;
      if (l_count = 0) then
        fnd_message.set_name('PER','AME_400568_INV_APG_ITM_PARAM');
        fnd_message.raise_error;
      end if;
      /*get_allowed_nested_groups
                   (
                    p_approval_group_id         => p_approval_group_id
                   ,allowedNestedGroupIdsOut    => l_allowed_nested_group_ids
                   ,allowedNestedGroupNamesOut  => l_allowed_nested_group_names
                   );
      l_parameter_allowed := false;
      for allowedGroupId in 1 .. l_allowed_nested_group_ids.count
      loop
         if l_allowed_nested_group_ids(allowedGroupId)
              = p_parameter then
           l_parameter_allowed := true;
           exit;
         end if;
      end loop;
      if l_parameter_allowed = false then
        hr_utility.set_location('Leaving:'|| l_proc, 20);
        fnd_message.set_name('AME','NESTED_GROUP_INVALID');
        fnd_message.raise_error;
      end if;
      */
      if not ( is_nesting_allowed(p_group  => p_approval_group_id
                            ,p_nest   => to_number(p_parameter)
                            )
              ) then
        hr_utility.set_location('Leaving:'|| l_proc, 20);
        fnd_message.set_name('PER','AME_400569_NEST_APG_NOT_ALLOW');
        fnd_message.raise_error;
      end if;

    elsif p_parameter_name = 'wf_roles_name' then
      open C_Sel2;
      fetch C_Sel2 into l_count;
      close C_Sel2;
      if (l_count = 0) then
        fnd_message.set_name('PER','AME_400568_INV_APG_ITM_PARAM');
        fnd_message.raise_error;
      end if;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_ITEMS.PARAMETER'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_parameter;
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_ORDER_NUMBER>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure validates order_number which should be positive integer.
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_order_number
--
-- Post Success:
--   Processing continues if order_number has valid value.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_order_number(
                           p_order_number   in   number
                          ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_ORDER_NUMBER';
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'ORDER_NUMBER'
                              ,p_argument_value     => p_order_number
                              );
    -- check if order_number is negative
    --
    if p_order_number <=0  then
      fnd_message.set_name('PER','AME_400565_INVALID_ORDER_NUM');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                (p_associated_column1 => 'AME_APPROVAL_GROUP_ITEMS.ORDER_NUMBER'
                 ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_order_number;
-- ----------------------------------------------------------------------------
-- |-------------------------< CHK_UNIQUE >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This procedure checks the uniqueness of approval_Group_id, parameter,parameter_name
--
-- Pre-Requisites:
--   None
--
-- In Parameters:
--   p_approval_group_id
--   p_parameter_name
--   p_parameter
--   p_effective_date
--
-- Post Success:
--   Processing continues if the row is unique.
--
-- Post Failure:
--   An application error is raised.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_unique(p_approval_group_id     in   number
                    ,p_parameter_name        in   varchar2
                    ,p_parameter             in   varchar2
                    ,p_effective_date        in   date
                    ) IS
--
  l_proc     varchar2(72) := g_package || 'CHK_UNIQUE';
  l_count    number;
--
-- Cursor to find if the item is already existing in the group
--
  Cursor C_Sel1 Is
    select count(t.approval_group_item_id)
    from   ame_approval_group_items t
    where t.approval_group_id = p_approval_group_id
    and   t.parameter_name  = p_parameter_name
    and   t.parameter = p_parameter
    and p_effective_date between t.start_date and (t.end_date -  ame_util.oneSecond);
  Begin
    hr_utility.set_location('Entering:'||l_proc,10);
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'APPROVAL_GROUP_ID'
                              ,p_argument_value     => p_approval_group_id
                              );
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'PARAMETER_NAME'
                              ,p_argument_value     => p_parameter_name
                              );
    hr_api.mandatory_arg_error(p_api_name           => l_proc
                              ,p_argument           => 'PARAMETER'
                              ,p_argument_value     => p_parameter
                              );
    -- check if the row represents a unique member for a group.
    open C_Sel1;
    fetch C_Sel1 into l_count;
    close C_Sel1;
    if (l_count <> 0) then
      fnd_message.set_name('PER','AME_400570_APG_ITM_NON_UNIQ');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,30);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                     (p_associated_column1 => 'AME_APPROVAL_GROUP_ITEMS.PARAMETER'
                     ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
      hr_utility.set_location( ' Leaving:'||l_proc,50 );
  End chk_unique;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_effective_date  in date
  ,p_rec             in ame_gpi_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_created_by          ame_approval_group_items.created_by%TYPE;
--
-- Cursor to find created_by value for the row
--
  Cursor C_Sel1 Is
    select t.created_by
    from   ame_approval_group_items t
    where t.approval_group_item_id = p_rec.approval_group_item_id
    and p_effective_date between t.start_date and (t.end_date -  ame_util.oneSecond);
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT ame_gpi_shd.api_updating
      (p_approval_group_item_id =>  p_rec.approval_group_item_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- EDIT_HERE: Add checks to ensure non-updateable args have
  --            not been updated.
  --
  -- If the group is seeded, do not allow updation of the group item's order number
  --
  open C_Sel1;
  fetch C_Sel1 into l_created_by;
  close C_Sel1;
  --
  -- ORDER_NUMBER is non-updateable if the group is seeded

   if ame_utility_pkg.is_seed_user(l_created_by) = ame_util.seededDataCreatedById and
       nvl(p_rec.order_number, hr_api.g_number) <>
       nvl(ame_gpi_shd.g_old_rec.order_number,hr_api.g_number)then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'ORDER_NUMBER'
          ,p_base_table => ame_gpi_shd.g_tab_nam
          );
  end if;
  -- APPROVAL_GROUP_ID is non-updateable.

   if  nvl(p_rec.approval_group_id, hr_api.g_number) <>
       nvl(ame_gpi_shd.g_old_rec.approval_group_id,hr_api.g_number)then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'APPROVAL_GROUP_ID'
          ,p_base_table => ame_gpi_shd.g_tab_nam
          );
  end if;

  -- PARAMETER_NAME is non-updateable.

   if  nvl(p_rec.parameter_name, hr_api.g_varchar2) <>
       nvl(ame_gpi_shd.g_old_rec.parameter_name,hr_api.g_varchar2)then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'PARAMETER_NAME'
          ,p_base_table => ame_gpi_shd.g_tab_nam
          );
  end if;

  -- PARAMETER is non-updateable.

   if  nvl(p_rec.parameter, hr_api.g_varchar2) <>
       nvl(ame_gpi_shd.g_old_rec.parameter,hr_api.g_varchar2)then
     hr_api.argument_changed_error
          (p_api_name   => l_proc
          ,p_argument   => 'PARAMETER'
          ,p_base_table => ame_gpi_shd.g_tab_nam
          );
  end if;



End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_update_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   parent entities when a datetrack update operation is taking place
--   and where there is no cascading of update defined for this entity.
--
-- Prerequisites:
--   This procedure is called from the update_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_validate
  (p_approval_group_id             in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
  ,p_validation_start_date         in date
  ,p_validation_end_date           in date
  ) Is
--
  l_proc  varchar2(72) := g_package||'dt_update_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Mode will be valid, as this is checked at the start of the upd.
  --
  -- Ensure the arguments are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_start_date'
    ,p_argument_value => p_validation_start_date
    );
  --
  /*hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );*/
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
End dt_update_validate;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< dt_delete_validate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used for referential integrity of datetracked
--   child entities when either a datetrack DELETE or ZAP is in operation
--   and where there is no cascading of delete defined for this entity.
--   For the datetrack mode of DELETE or ZAP we must ensure that no
--   datetracked child rows exist between the validation start and end
--   dates.
--
-- Prerequisites:
--   This procedure is called from the delete_validate.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a row exists by determining the returning Boolean value from the
--   generic dt_api.rows_exist function then we must supply an error via
--   the use of the local exception handler l_rows_exist.
--
-- Developer Implementation Notes:
--   This procedure should not need maintenance unless the HR Schema model
--   changes.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_delete_validate
  (p_approval_group_item_id           in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';
--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'datetrack_mode'
    ,p_argument_value => p_datetrack_mode
    );
  --
  -- Only perform the validation if the datetrack mode is either
  -- DELETE or ZAP
  --
  If (p_datetrack_mode = hr_api.g_delete or
      p_datetrack_mode = hr_api.g_zap) then
    --
    --
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_start_date'
      ,p_argument_value => p_validation_start_date
      );
    --
    /*hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );*/
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'approval_group_item_id'
      ,p_argument_value => p_approval_group_item_id
      );
    --
    --
    --
  End If;
  --
Exception
  When Others Then
    --
    -- An unhandled or unexpected error has occurred which
    -- we must report
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  --
End dt_delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in ame_gpi_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Dependent Attributes
  --
  --
  -- User Entered calls to validate procedures
  chk_approval_group_id (
                         p_approval_group_id   => p_rec.approval_group_id
                        ,p_effective_date      => p_effective_date
                        );

  chk_parameter_name (
                         p_parameter_name  => p_rec.parameter_name
                     );

  chk_parameter (
                 p_approval_group_id => p_rec.approval_group_id
                ,p_parameter       => p_rec.parameter
                ,p_parameter_name  => p_rec.parameter_name
                ,p_effective_date  => p_effective_date
                );

  chk_order_number (
                    p_order_number => p_rec.order_number
                   );

  chk_unique (
              p_approval_group_id   => p_rec.approval_group_id
             ,p_parameter           => p_rec.parameter
             ,p_parameter_name      => p_rec.parameter_name
             ,p_effective_date      => p_effective_date
             );

  chk_approver_type (
                     p_approval_group_id     => p_rec.approval_group_id
                    ,p_parameter_name        => p_rec.parameter_name
                    ,p_parameter             => p_rec.parameter
                    );

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in ame_gpi_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_approval_group_id              => p_rec.approval_group_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  --
  -- User Entered calls to validate procedures
  chk_order_number (
                    p_order_number => p_rec.order_number
                   );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in ame_gpi_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_approval_group_item_id =>  p_rec.approval_group_item_id
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end ame_gpi_bus;

/
