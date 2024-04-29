--------------------------------------------------------
--  DDL for Package Body PAY_RETRO_STATUS_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RETRO_STATUS_INTERNAL" as
/* $Header: pyrtsbsi.pkb 120.8.12010000.3 2010/03/18 06:00:34 pgongada ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_retro_status_internal.';

g_update   varchar2(6) := 'UPDATE';
g_delete   varchar2(6) := 'DELETE';

--
-- Global Definitions
--
subtype t_retro_asg_rec is pay_retro_assignments%rowtype;
subtype t_retro_ent_rec is pay_retro_entries%rowtype;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< get_unprocessed_retro_asg >----------------------|
-- ----------------------------------------------------------------------------
--
function get_unprocessed_retro_asg
  (p_assignment_id                 in     number
  ) return number
is
  l_proc                varchar2(72) := g_package||'get_unprocessed_retro_asg';
  l_retro_assignment_id number;
  cursor csr_unproc_retro_asg
  is
    select pra.retro_assignment_id
    from   pay_retro_assignments  pra
    where  pra.assignment_id = p_assignment_id
    and    pra.retro_assignment_action_id is null
    and    pra.superseding_retro_asg_id is null
    and    approval_status in ('P','A','D');
    --'P' is used for backward compatibility.
begin
  l_retro_assignment_id := null;
  for l_rec in csr_unproc_retro_asg loop
    if l_retro_assignment_id is not null then
      --
      -- Multiple unprocessed retro assignments found.
      -- This should not happen.
      --
      pay_core_utils.assert_condition
        (l_proc||':too_many_rows', false);
    end if;
    l_retro_assignment_id := l_rec.retro_assignment_id;
  end loop;

  return l_retro_assignment_id;

end get_unprocessed_retro_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_element_name >---------------------------|
-- ----------------------------------------------------------------------------
--
function get_element_name
  (p_element_entry_id                 in     number
  ) return varchar2
is
  cursor csr_entry
  is
  select
    pettl.element_name
  from
    pay_element_entries_f      pee
   ,pay_element_links_f        pel
   ,pay_element_types_f_tl     pettl
  where
      pee.element_entry_id = p_element_entry_id
  and pel.element_link_id = pee.element_link_id
  and pee.effective_start_date between pel.effective_start_date
                                   and pel.effective_end_date
  and pettl.element_type_id = pel.element_type_id
  and pettl.language = userenv('lang')
  ;
  --
  l_rec csr_entry%rowtype;
begin
  open csr_entry;
  fetch csr_entry into l_rec;
  close csr_entry;
  --
  return l_rec.element_name;

end get_element_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_component_name >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_component_name
  (p_retro_component_id                 in     number
  ) return varchar2
is
  cursor csr_retro_component is
    select component_name
      from pay_retro_components
     where retro_component_id = p_retro_component_id
    ;
  --
  l_rec csr_retro_component%rowtype;
begin
  open csr_retro_component;
  fetch csr_retro_component into l_rec;
  close csr_retro_component;
  --
  return l_rec.component_name;

end get_component_name;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_retro_asg_creator_type >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns by which owner type this retro assignment was initially created.
--
--   As currently no owner type column is available on the retro assignments,
--   created by = -1 is checked similarly to the OAF UI.
--
--   1) If all retro entries are system types, this is system created.
--   2) If all retro entries are user types or no entry exists, this is
--      user created.
--   3) If it cannot be determined by 1 and 2, assume it as system creatd
--      when created-by is -1, otherwise take it as user created.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function get_retro_asg_creator_type
  (p_retro_assignment_id                in     number
  ,p_created_by                         in     number
  ) return varchar2
is
  l_proc                varchar2(72) := g_package||'get_retro_asg_creator_type';
  l_owner_type          varchar2(1);
  --
  -- Cursor to check what retro entry owner types exist under the
  -- initial retro assignment.
  --
  -- Value  Owner Type(s)
  -- Null   no retro entry
  -- 1      System
  -- 2      User
  -- 3      System, User
  -- 4      Merged
  -- 5      System, Merged
  -- 6      User, Merged
  -- 7      System, User, Merged
  --
  cursor csr_retro_ent_type
  is
  select sum(distinct decode(owner_type,'S',1, 'U',2, 'M',4, 1)) owntype_sum
  from pay_retro_entries
  where retro_assignment_id = p_retro_assignment_id
  ;
  --
  l_ownertype_sum number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check the owner type of all the retro entries.
  --
  open csr_retro_ent_type;
  fetch csr_retro_ent_type into l_ownertype_sum;
  close csr_retro_ent_type;
  --
  -- Determine the owner type.
  --
  if (l_ownertype_sum = 1) then
    hr_utility.set_location(l_proc, 20);
    l_owner_type := g_system;
  elsif (l_ownertype_sum is null) or (l_ownertype_sum = 2) then
    hr_utility.set_location(l_proc, 30);
    l_owner_type := g_user;
  else
    --
    -- Failed to judge it by the entry owner type.
    -- Temporarily determine it by the created_by value.
    --
    if p_created_by = -1 then
      hr_utility.set_location(l_proc, 40);
      l_owner_type := g_system;
    else
      hr_utility.set_location(l_proc, 50);
      l_owner_type := g_user;
    end if;
  end if;
  --
  return l_owner_type;

  hr_utility.set_location(' Leaving:'||l_proc, 90);
end get_retro_asg_creator_type;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_retro_ent_creator_type >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns by which owner type this retro entry was initially created.
--
--   As currently no owner type column is available on the retro assignments,
--   created by = -1 is checked similarly to the OAF UI.
--
--   1) If the current owner type is system type, this is system created.
--   2) If the current owner type is user type, this is user created.
--   3) If it cannot be determined by 1 and 2, assume it as system creatd
--      when created-by is -1, otherwise take it as user created.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function get_retro_ent_creator_type
  (p_old_owner_type                     in     varchar2
  ,p_old_created_by                     in     number
  ) return varchar2
is
  l_proc                varchar2(72) := g_package||'get_retro_ent_creator_type';
  l_owner_type          varchar2(1);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if (nvl(p_old_owner_type, g_system) = g_system) then
    l_owner_type := g_system;
  elsif p_old_owner_type = g_user then
    l_owner_type := g_user;
  elsif p_old_created_by = -1 then
    l_owner_type := g_system;
  else
    l_owner_type := g_user;
  end if;

  return l_owner_type;

  hr_utility.set_location(' Leaving:'||l_proc, 90);
end get_retro_ent_creator_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_assignment_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the employee assignment exists on the reprocess date.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_assignment_id
--   p_reprocess_date
--
-- Out Parameters:
--   p_business_group_id
--   p_payroll_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_assignment_id
  (p_assignment_id                 in     number
  ,p_reprocess_date                in     date
  ,p_business_group_id                out nocopy number
  ,p_payroll_id                       out nocopy number
  )
is
  --
  l_business_group_id number;
  l_payroll_id        number;
  --
  cursor csr_asg
  is
  select
    paf.business_group_id
   ,paf.payroll_id
  from
    per_all_assignments_f      paf
   ,per_periods_of_service     prd
  where
      paf.assignment_id = p_assignment_id
  and paf.payroll_id is not null
  and p_reprocess_date between paf.effective_start_date
                           and paf.effective_end_date
  and prd.period_of_service_id = paf.period_of_service_id;

  l_proc                varchar2(72) := g_package||'chk_assignment_id';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open csr_asg;
  fetch csr_asg into l_business_group_id, l_payroll_id;
  if csr_asg%notfound then
    close csr_asg;
    --
    -- A valid assignment does not exist on the reprocess date.
    --
    fnd_message.set_name('PAY','PAY_34300_RTS_ASG_NOT_EXISTS');
    fnd_message.set_token('EFFECTIVE_DATE', to_char(p_reprocess_date));
    fnd_message.raise_error;
    --
  end if;
  close csr_asg;
  --
  -- Set out variable.
  --
  p_business_group_id := l_business_group_id;
  p_payroll_id        := l_payroll_id;

  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_approval_status >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that a valid approval status is specified.
--   The available status are dependent on the lookup code
--   ADVANCE_RETRO_STATUS
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_business_group_id
--   p_approval_status
--   p_owner_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_approval_status
  (p_approval_status               in     varchar2
  ,p_insert_or_update              in     varchar2
  )
is
  l_inv_app_status      boolean:= false;
  l_proc                varchar2(72) := g_package||'chk_approval_status';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  /*Check if the provided status is available in lookups or not*/
  if hr_api.not_exists_in_hr_lookups
         (trunc(sysdate), 'ADVANCE_RETRO_STATUS', p_approval_status) then
      hr_utility.set_location(l_proc, 20);
      l_inv_app_status := true;
  else
      if p_insert_or_update = 'I' then
         /*If creation , then only two statuses A and D are allowed*/
         hr_utility.set_location(l_proc, 30);
         if p_approval_status not in ('A','D') then
            hr_utility.set_location(l_proc, 40);
            l_inv_app_status := true;
         end if;
      else
         /*If updation, then C and R are not allowed*/
         hr_utility.set_location(l_proc, 50);
         if p_approval_status in ('C','R') then
            hr_utility.set_location(l_proc, 60);
            l_inv_app_status := true;
         end if;
      end if;
  end if;
  if l_inv_app_status then
    fnd_message.set_name('PAY','PAY_34301_RTS_INV_APPRVL_STA');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 100);

end chk_approval_status;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_asg_rep_date_updatable >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the reprocess date is updatable.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_assignment_id
--   p_created_by
--   p_reprocess_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_asg_rep_date_updatable
  (p_retro_assignment_id                in     number
  ,p_created_by                         in     number
  ,p_owner_type                         in     varchar2
  )
is
  l_proc                varchar2(72) := g_package||'chk_asg_rep_date_updatable';
  l_owner_type          varchar2(10);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_owner_type = g_user then

    l_owner_type := get_retro_asg_creator_type
                      (p_retro_assignment_id => p_retro_assignment_id
                      ,p_created_by          => p_created_by
                      );

    if l_owner_type = g_system then
      --
      -- You cannot update the reprocess date of the retro assignment
      -- that was created by the system.
      --
      fnd_message.set_name('PAY','PAY_34302_RTS_INV_REP_DATE');
      fnd_message.raise_error;
      --
    end if;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_asg_rep_date_updatable;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_retro_asg_reprocess_date >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the reprocess date specified for the retro assignment
--   is earlier than the reprocess date of any child retro entries.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_assignment_id
--   p_reprocess_date
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_retro_asg_reprocess_date
  (p_retro_assignment_id           in     number
  ,p_reprocess_date                in     date
  )
is
  l_proc                varchar2(72) := g_package||'chk_retro_asg_reprocess_date';
  l_dummy               number;
  --
  cursor csr_chk_rep_date
  is
    select 1
    from pay_retro_entries
    where
        retro_assignment_id = p_retro_assignment_id
    and reprocess_date < p_reprocess_date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open csr_chk_rep_date;
  fetch csr_chk_rep_date into l_dummy;
  if csr_chk_rep_date%found then
    close csr_chk_rep_date;
    --
    fnd_message.set_name('PAY','PAY_34288_RET_ASG_DAT_ERR');
    fnd_message.raise_error;
    --
  end if;
  close csr_chk_rep_date;

  hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_retro_asg_reprocess_date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_retro_asg_updatable >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the specified retro assignment is user updatable.
--   The retro assignment is updatable/deletable when the following conditions
--   are all satisfied.
--   1) The retro assignment is not processed by retropay.
--   2) The retro assignment is not superseded by another retro assignment.
--   3) The approval status was A (confirmed) and the status is not being
--      changed.
--   4) No system retro entry exists when deleting.A
--   5) When the user really want to delete the system created retro assignment
--      so he has to pass Y in p_delete_sys_retro_asg. In this case we bypass
--      the check of system created entries.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_assignment_id
--   p_retro_assignment_action_id
--   p_superseding_retro_asg_id
--   p_old_approval_status
--   p_new_approval_status
--   p_owner_type
--   p_dml_mode
--   p_delete_sys_retro_asg
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_retro_asg_updatable
  (p_retro_assignment_id           in     number
  ,p_retro_assignment_action_id    in     number
  ,p_superseding_retro_asg_id      in     number
  ,p_old_approval_status           in     varchar2
  ,p_new_approval_status           in     varchar2
  ,p_owner_type                    in     varchar2
  ,p_dml_mode                      in     varchar2
  ,p_delete_sys_retro_asg          in     varchar2 default 'N'
  )
is
  l_proc                varchar2(72) := g_package||'chk_retro_asg_updatable';
  l_dummy               number;
  --
  cursor csr_sys_ent_exists
  is
  select 1 from pay_retro_entries
  where retro_assignment_id = p_retro_assignment_id
  and nvl(owner_type, g_system) <> g_user;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_owner_type = g_user then

    hr_utility.set_location(l_proc, 20);

    if (p_retro_assignment_action_id is not null) or
       (p_superseding_retro_asg_id is not null) or
       (p_old_approval_status not in ('A','D','P')) then
       --We are still keeping 'P' for backward compatibility.
       --It will be removed in the future.
      --
      -- The retro assignment has been processed or is superseded.
      --
      fnd_message.set_name('PAY','PAY_34303_RTS_RT_ASG_UNAVAIL');
      fnd_message.raise_error;
      --
    elsif p_old_approval_status = 'A' and
          p_new_approval_status is null then
      --
      -- The retro assignment has been confirmed. The retro assignment
      -- and retro entries cannot be changed unless the status is changed
      -- or reconfirmed.
      --
      fnd_message.set_name('PAY','PAY_34313_RTS_ASG_CONFIRMED');
      fnd_message.raise_error;
      --
    elsif p_dml_mode = g_delete then
      --
      -- Check to see if any system generated retro entry exists.
      -- Checking it only when the user doesn't want to delete the system
      -- created retro assignments. Bug#6892796.
      if (nvl(p_delete_sys_retro_asg,'N') <> 'Y') then
        open csr_sys_ent_exists;
        fetch csr_sys_ent_exists into l_dummy;
        if csr_sys_ent_exists%found then
          close csr_sys_ent_exists;
          --
          -- system generated entry found.
          --
          fnd_message.set_name('PAY','PAY_34289_RET_ASG_DEL_ERR');
          fnd_message.raise_error;
        --
        end if;
        close csr_sys_ent_exists;
      end if;
    end if;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_retro_asg_updatable;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_ent_reprocess_date >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the specified retro entry reprocess date is valid.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_assignment_id
--   p_element_entry_id
--   p_reprocess_date
--   p_old_reprocess_date
--   p_system_reprocess_date
--   p_asg_reprocess_date
--   p_asg_owner_type
--   p_created_by
--   p_old_owner_type
--   p_owner_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_ent_reprocess_date
  (p_retro_assignment_id           in     number
  ,p_element_entry_id              in     number
  ,p_reprocess_date                in     date
  ,p_old_reprocess_date            in     date
  ,p_system_reprocess_date         in     date
  ,p_asg_reprocess_date            in     date
  ,p_asg_owner_type                in     varchar2
  ,p_created_by                    in     number
  ,p_old_owner_type                in     varchar2
  ,p_owner_type                    in     varchar2
  )
is
  l_proc                varchar2(72) := g_package||'chk_ent_reprocess_date';
  l_element_name        pay_element_types_f_tl.element_name%type;
  l_owner_type          varchar2(10);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_owner_type = g_user then

    if p_reprocess_date <> p_old_reprocess_date then
      hr_utility.set_location(l_proc, 20);
      --
      -- Check the existing owner type.
      --
      l_owner_type := get_retro_ent_creator_type
                        (p_old_owner_type => p_old_owner_type
                        ,p_old_created_by => p_created_by
                        );
      --
      if (p_asg_owner_type = g_system) and (l_owner_type = g_system) then
        --
        -- If the system has initially generated the retro assignment
        -- and this entry, the reprocess date cannot be updated.
        --
        l_element_name := get_element_name(p_element_entry_id);
        fnd_message.set_name('PAY','PAY_34304_RTS_RT_ENT_UNAVAIL');
        fnd_message.set_token('ELEMENT_NAME', l_element_name);
        fnd_message.raise_error;
        --
      elsif nvl(p_system_reprocess_date, p_reprocess_date) < p_reprocess_date then
        --
        -- The reprocess date cannot be later than the system reprocess date.
        --
        l_element_name := get_element_name(p_element_entry_id);
        fnd_message.set_name('PAY','PAY_34285_RET_REC_DATE_ETRY');
        fnd_message.set_token('ELEMENT_NAME', l_element_name);
        fnd_message.raise_error;
        --
      end if;
    end if;
    hr_utility.set_location(l_proc, 30);
    --
    if (p_reprocess_date <> p_old_reprocess_date) or
       (p_old_reprocess_date is null)                then
      --
      hr_utility.set_location(l_proc, 40);
      if p_reprocess_date < p_asg_reprocess_date then
        --
        -- The reprocess date cannot be earlier than the asg reprocess date.
        --
        l_element_name := get_element_name(p_element_entry_id);
        fnd_message.set_name('PAY','PAY_33182_RET_RECALC_DATE_ERR');
        fnd_message.set_token('ELEMENT_NAME', l_element_name);
        fnd_message.raise_error;
        --
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_ent_reprocess_date;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_retro_entry_deletable >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the specified retro entry is user deletable.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_element_entry_id
--   p_old_owner_type
--   p_owner_type
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_retro_entry_deletable
  (p_element_entry_id              in     number
  ,p_old_owner_type                in     varchar2
  ,p_owner_type                    in     varchar2
  )
is
  l_proc                varchar2(72) := g_package||'chk_retro_entry_deletable';
  l_owner_type          varchar2(10);
  l_element_name        pay_element_types_f_tl.element_name%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  if p_owner_type = g_user then

    if nvl(p_old_owner_type, g_system) <> g_user then
      --
      -- User cannot delete system generated retro entry.
      --
      l_element_name := get_element_name(p_element_entry_id);

      fnd_message.set_name('PAY','PAY_34314_RTS_ENT_NO_DEL');
      fnd_message.set_token('ELEMENT_NAME', l_element_name);
      fnd_message.raise_error;
    end if;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 40);
end chk_retro_entry_deletable;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_element_entry_id >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the element entry exists.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_element_entry_id
--   p_assignment_id
--
-- Out Parameters:
--   p_element_type_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_element_entry_id
  (p_element_entry_id              in     number
  ,p_assignment_id                 in     number
  ,p_element_type_id                  out nocopy number
  )
is
  l_proc                varchar2(72) := g_package||'chk_element_entry_id';
  --
  cursor csr_entry
  is
  select
    pel.element_type_id
  from
    pay_element_entries_f      pee
   ,pay_element_links_f        pel
   ,pay_element_types_f_tl     pettl
  where
      pee.element_entry_id = p_element_entry_id
  and pee.assignment_id = nvl(p_assignment_id, pee.assignment_id)
  and pee.creator_type in ('A', 'F', 'H', 'Q', 'SP', 'UT', 'M', 'S')
  and pel.element_link_id = pee.element_link_id
  and pee.effective_start_date between pel.effective_start_date
                                   and pel.effective_end_date
  and pettl.element_type_id = pel.element_type_id
  and pettl.language = userenv('lang')
  ;
  --
  l_rec csr_entry%rowtype;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open csr_entry;
  fetch csr_entry into l_rec;
  if csr_entry%notfound then
    close csr_entry;
    --
    fnd_message.set_name('PAY','PAY_34305_RTS_INV_ENT_ID');
    fnd_message.set_token('ELEMENT_ENTRY_ID', to_char(p_element_entry_id));
    fnd_message.raise_error;
    --
  end if;
  close csr_entry;

  --
  -- Set out variables.
  --
  p_element_type_id := l_rec.element_type_id;

  hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_element_entry_id;
--
-- -------------------------------------------------------------------------
-- |-------------------< get_default_retro_component_id >------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the default retro component ID for the element
--   type.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_element_entry_id
--   p_reprocess_date
--   p_element_type_id
--   p_assignment_id
--
-- Returns:
--   retro_component_id
--
-- Post Success:
--   Processing continues if default component is found.
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   default retro component id is not found.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function get_default_retro_component_id
  (p_element_entry_id   in     number
  ,p_reprocess_date     in     date
  ,p_element_type_id    in     number
  ,p_assignment_id      in     number
  ) return number
is
  --
  -- Declare local variables
  --
  l_proc             varchar2(72) := g_package||'get_default_retro_component_id';

  l_retro_component_id number;
  l_element_name       pay_element_types_f_tl.element_name%type;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Call another package to obtain the default component.
  -- Note that p_ef_date is not currently used in the other package,
  -- hence passing it just as a dummy date.
  --
  l_retro_component_id
    := pay_retro_utils_pkg.get_retro_component_id
         (p_element_entry_id  => p_element_entry_id
         ,p_ef_date           => p_reprocess_date
         ,p_element_type_id   => p_element_type_id
         ,p_asg_id            => p_assignment_id
         );

  --
  -- Note: if no default is found in get_retro_component_id,
  --       it returns -1.
  --
  if nvl(l_retro_component_id, -1) = -1 then
    --
    -- No default component is defined for this element type.
    --
    l_element_name := get_element_name(p_element_entry_id);

    fnd_message.set_name('PAY','PAY_34306_RTS_NO_DEF_CMP_AVL');
    fnd_message.set_token('ELEMENT_NAME', l_element_name);
    fnd_message.raise_error;
  end if;

  --
  -- Set out variable.
  --
  return l_retro_component_id;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end get_default_retro_component_id;
--
-- -------------------------------------------------------------------------
-- |----------------------< chk_retro_component_id >-----------------------|
-- -------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the retro component id exists in pay_retro_components.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   p_retro_component_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues if the retro component id is valid.
--
--
-- Post Failure:
--   An application error is raised and processing is terminated if the
--   retro component id is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_retro_component_id
  (p_retro_component_id in     number
  ,p_business_group_id  in     number
  )
is
  --
  -- Declare local variables
  --
  l_proc             varchar2(72) := g_package||'chk_retro_component_id';
  l_exists           number;
  l_legislation_code pay_retro_component_usages.legislation_code%type;

  --
  -- Cursor to check that a retro component exists.
  --
  cursor csr_retro_component is
    select 1
      from pay_retro_components
     where retro_component_id = p_retro_component_id
       and nvl(legislation_code, l_legislation_code) = l_legislation_code
    ;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'retro_component_id'
    ,p_argument_value => p_retro_component_id
    );
  --
  -- Set the legislation code
  --
  l_legislation_code
     := hr_api.return_legislation_code(p_business_group_id);
  --
  -- Check if the retro component exists.
  --
  hr_utility.set_location(l_proc, 20);
  open csr_retro_component;
  fetch csr_retro_component into l_exists;
  if csr_retro_component%notfound then
    close csr_retro_component;

    fnd_message.set_name('PAY','PAY_33167_RCU_INV_RETRO_COMP');
    fnd_message.raise_error;

  end if;
  close csr_retro_component;

  hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_retro_component_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_retro_comp_usage >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that the element component usage is defined
--   for the corresponding element type with the retro component.
--
-- Prerequisites:
--   chk_entry_exists and chk_retro_component_id have already been passed.
--
-- In Parameters:
--   p_element_type_id
--   p_retro_component_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error is raised.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_retro_comp_usage
  (p_element_type_id               in     number
  ,p_retro_component_id            in     number
  )
is
  l_dummy number;
  l_element_name       pay_element_types_f_tl.element_name%type;
  l_component_name     pay_retro_components.component_name%type;
  --
  cursor csr_rcu
  is
  select 1
  from
    pay_retro_component_usages rcu
  where
      rcu.creator_id = p_element_type_id
  and rcu.creator_type = 'ET'
  and rcu.retro_component_id = p_retro_component_id
  ;
  --
  cursor csr_ele
  is
  select
    pettl.element_name
  from
    pay_element_types_f_tl     pettl
  where
      pettl.element_type_id = p_element_type_id
  and pettl.language = userenv('lang')
  ;

  l_proc                varchar2(72) := g_package||'chk_retro_comp_usage';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open csr_rcu;
  fetch csr_rcu into l_dummy;
  if csr_rcu%notfound then
    --
    -- The retro component is not defined for this element type.
    --
    open csr_ele;
    fetch csr_ele into l_element_name;
    close csr_ele;
    l_component_name := get_component_name(p_retro_component_id);

    fnd_message.set_name('PAY','PAY_34307_RTS_INV_RTR_CMP_USG');
    fnd_message.set_token('ELEMENT_NAME', l_element_name);
    fnd_message.set_token('COMPONENT_NAME', l_component_name);
    fnd_message.raise_error;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 40);

end chk_retro_comp_usage;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< lock_retro_asg >----------------------------|
-- ----------------------------------------------------------------------------
procedure lock_retro_asg
  (p_retro_assignment_id           in     number
  ,p_old_rec                          out nocopy t_retro_asg_rec
  )
is
  l_proc                varchar2(72) := g_package||'lock_retro_asg';
  l_old_rec             t_retro_asg_rec;
  --
  cursor csr_lock_retro_asg
  is
  select *
  from pay_retro_assignments
  where retro_assignment_id = p_retro_assignment_id
  for update nowait;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  open csr_lock_retro_asg;
  fetch csr_lock_retro_asg into l_old_rec;
  if csr_lock_retro_asg%notfound then
    close csr_lock_retro_asg;
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;
  close csr_lock_retro_asg;
  --
  hr_utility.set_location(l_proc, 20);

  p_old_rec := l_old_rec;

  hr_utility.set_location(' Leaving:'||l_proc, 40);
Exception
  When HR_Api.Object_Locked then
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pay_retro_assignments');
    fnd_message.raise_error;
end lock_retro_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< decode_default >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to override the passed value with a specific value
--   when the passed value was the same as the default value.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
function decode_default
  (p_passed_value     in varchar2
  ,p_default_value    in varchar2
  ,p_override_value   in varchar2
  ) return varchar2
is
begin
  if p_passed_value = p_default_value then
    return p_override_value;
  elsif (p_passed_value is null) and (p_default_value is null) then
    return p_override_value;
  else
    return p_passed_value;
  end if;
end decode_default;
--
-- Number variable version.
--
function decode_default
  (p_passed_value     in number
  ,p_default_value    in number
  ,p_override_value   in number
  ) return number
is
begin
  if p_passed_value = p_default_value then
    return p_override_value;
  elsif (p_passed_value is null) and (p_default_value is null) then
    return p_override_value;
  else
    return p_passed_value;
  end if;
end decode_default;
--
-- Date variable version.
--
function decode_default
  (p_passed_value     in date
  ,p_default_value    in date
  ,p_override_value   in date
  ) return date
is
begin
  if p_passed_value = p_default_value then
    return p_override_value;
  elsif (p_passed_value is null) and (p_default_value is null) then
    return p_override_value;
  else
    return p_passed_value;
  end if;
end decode_default;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_super_retro_asg >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_super_retro_asg
  (p_assignment_id                 in     number
  ,p_reprocess_date                in     date
  ,p_start_date                    in     date     default null
  ,p_approval_status               in     varchar2 default null
  ,p_owner_type                    in     varchar2 default g_user
  ,p_retro_assignment_id              out nocopy   number
  )
is
  l_retro_assignment_id number;
  l_old_retro_asg_id    number;
  l_old_ra_rec          t_retro_asg_rec;
  l_new_ra_rec          t_retro_asg_rec;
  l_business_group_id   number;
  l_payroll_id          number;
  l_reprocess_date      date;
  l_old_approval_status pay_retro_assignments.approval_status%type;
  l_approval_status     pay_retro_assignments.approval_status%type;
  l_new_approval_status pay_retro_assignments.approval_status%type;
  l_new_reprocess_date  date;
  l_new_start_date      date;
  --
  cursor csr_app_status(p_retro_asg_id in number)
  is
  select approval_status
  from pay_retro_assignments
  where retro_assignment_id = p_retro_asg_id;

  l_proc                varchar2(72) := g_package||'create_super_retro_asg';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint rts_create_super_retro_asg;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ASSIGNMENT_ID'
    ,p_argument_value     => p_assignment_id
    );

  --
  -- Owner type must be either U or S.
  --
  pay_core_utils.assert_condition
    (l_proc||':owner_type', p_owner_type in (g_user, g_system));

  hr_utility.set_location(l_proc, 15);
  --
  -- Check to see if the previous version of retro assignment exists.
  --
  l_old_retro_asg_id := get_unprocessed_retro_asg(p_assignment_id);

  if l_old_retro_asg_id is null then
    --
    -- Reprocess Date is mandatory
    --
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'ASG REPROCESS_DATE'
      ,p_argument_value     => p_reprocess_date
      );
  else
    --
    -- Lock and obtain the old record info.
    --
    lock_retro_asg
      (p_retro_assignment_id           => l_old_retro_asg_id
      ,p_old_rec                       => l_old_ra_rec
      );
    --
    -- Check to see if this retro assignment is updatable.
    --
    chk_retro_asg_updatable
      (p_retro_assignment_id        => l_old_retro_asg_id
      ,p_retro_assignment_action_id => l_old_ra_rec.retro_assignment_action_id
      ,p_superseding_retro_asg_id   => l_old_ra_rec.superseding_retro_asg_id
      ,p_old_approval_status        => l_old_ra_rec.approval_status
      ,p_new_approval_status        => p_approval_status
      ,p_owner_type                 => p_owner_type
      ,p_dml_mode                   => g_update
      );

    --
    -- Check to see if reprocess date is updatable.
    --
    if p_reprocess_date <> l_old_ra_rec.reprocess_date then
      chk_asg_rep_date_updatable
        (p_retro_assignment_id        => l_old_retro_asg_id
        ,p_created_by                 => l_old_ra_rec.created_by
        ,p_owner_type                 => p_owner_type
        );
    end if;
  end if;
  --
  -- Set the reprocess date.
  --
  l_reprocess_date := nvl(p_reprocess_date, l_old_ra_rec.reprocess_date);

  --
  -- Insert validation.
  --
  hr_utility.set_location(l_proc, 20);
  chk_assignment_id
    (p_assignment_id                 => p_assignment_id
    ,p_reprocess_date                => l_reprocess_date
    ,p_business_group_id             => l_business_group_id
    ,p_payroll_id                    => l_payroll_id
    );

  if p_approval_status is not null then

    chk_approval_status
      (p_approval_status               => p_approval_status
      ,p_insert_or_update              => 'I');

  end if;

  hr_utility.set_location(l_proc, 30);
  --
  -- Create superseding retro assignment.
  --
  pay_retro_utils_pkg.create_super_retro_asg
    (p_asg_id         => p_assignment_id
    ,p_payroll_id     => l_payroll_id
    ,p_reprocess_date => l_reprocess_date
    ,p_retro_asg_id   => l_retro_assignment_id
    );

  hr_utility.set_location(l_proc, 40);
  --
  -- If this is the user type, we might need to change automatically
  -- adjusted values.
  --
  if (p_owner_type = g_user) then
    --
    -- Relock the new record.
    --
    lock_retro_asg
      (p_retro_assignment_id           => l_retro_assignment_id
      ,p_old_rec                       => l_new_ra_rec
      );

    hr_utility.set_location(l_proc, 45);
    --
    -- Check the reprocess date.
    --
    if (p_reprocess_date <> l_new_ra_rec.reprocess_date) then
      hr_utility.set_location(l_proc, 50);
      --
      -- Check to see if this reprocess date is valid.
      --
      chk_retro_asg_reprocess_date
        (p_retro_assignment_id           => l_retro_assignment_id
        ,p_reprocess_date                => p_reprocess_date
        );
      --
      -- Set the new reprocess date.
      --
      l_new_reprocess_date := p_reprocess_date;

    end if;
    --
    -- Check the start date.
    --
    if    (p_start_date is null)
       or (p_start_date <> l_new_ra_rec.start_date)  then
      hr_utility.set_location(l_proc, 55);
      --
      -- Set the new start date.
      --
      l_new_start_date := decode_default(p_start_date
                                        ,null
                                        ,p_reprocess_date);
    end if;

    hr_utility.set_location(l_proc, 60);
    --
    -- As the above procedure doesn't accept approval status at the moment,
    -- we might need override the default one if necessary.
    --
    hr_utility.set_location(l_proc, 70);
    --
    l_old_approval_status := l_old_ra_rec.approval_status;
    l_approval_status     := l_new_ra_rec.approval_status;

    hr_utility.trace('Old status: '||l_old_approval_status);
    hr_utility.trace('Default status: '||l_approval_status);
    hr_utility.trace('Specified status: '||p_approval_status);
    --
    -- Identify the expected new approval status.
    --
    if (p_approval_status <> l_approval_status) then
      --
      -- Approval status is specified.
      --
      l_new_approval_status := p_approval_status;
    elsif (p_approval_status is null) and
          (l_approval_status <> l_old_approval_status) then
      --
      -- The approval status should be inherited.
      --
      l_new_approval_status := l_old_approval_status;
    end if;
    --
    -- Override the values if any outstanding change exists.
    --
    if    (l_new_reprocess_date is not null)
       or (l_new_start_date is not null)
       or (l_new_approval_status is not null) then
      hr_utility.set_location(l_proc, 80);
      --
      update pay_retro_assignments
      set
        reprocess_date = nvl(l_new_reprocess_date, reprocess_date)
       ,start_date = nvl(l_new_start_date, start_date)
       ,approval_status = nvl(l_new_approval_status, approval_status)
      where retro_assignment_id = l_retro_assignment_id;
      --
    end if;
  end if;

  hr_utility.set_location(l_proc, 90);
  --
  -- Set out variable.
  --
  p_retro_assignment_id := l_retro_assignment_id;

  hr_utility.set_location(' Leaving:'||l_proc, 100);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to rts_create_super_retro_asg;
    hr_utility.set_location(' Leaving:'||l_proc, 120);
    raise;
end create_super_retro_asg;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_retro_asg >---------------------------|
-- ----------------------------------------------------------------------------
procedure update_retro_asg
  (p_retro_assignment_id           in     number
  ,p_reprocess_date                in     date     default hr_api.g_date
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_approval_status               in     varchar2 default hr_api.g_varchar2
  ,p_owner_type                    in     varchar2 default g_user
  )
is
  l_proc                varchar2(72) := g_package||'update_retro_asg';
  l_old_rec             t_retro_asg_rec;
  l_new_rec             t_retro_asg_rec;
  l_business_group_id   number;
  l_payroll_id          number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint rts_update_retro_asg;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RETRO_ASSIGNMENT_ID'
    ,p_argument_value     => p_retro_assignment_id
    );

  --
  -- Owner type must be either U or S.
  --
  pay_core_utils.assert_condition
    (l_proc||':owner_type', p_owner_type in (g_user, g_system));

  hr_utility.set_location(l_proc, 20);
  --
  -- Lock the existing retro assignment.
  --
  lock_retro_asg
    (p_retro_assignment_id           => p_retro_assignment_id
    ,p_old_rec                       => l_old_rec
    );

  hr_utility.set_location(l_proc, 30);
  --
  -- Copy the changed values.
  --
  l_new_rec := l_old_rec;
  --
  l_new_rec.reprocess_date  := decode_default(p_reprocess_date
                                             ,hr_api.g_date
                                             ,l_old_rec.reprocess_date);
  l_new_rec.start_date      := decode_default(p_start_date
                                             ,hr_api.g_date
                                             ,l_old_rec.start_date);
  l_new_rec.approval_status := decode_default(p_approval_status
                                             ,hr_api.g_varchar2
                                             ,l_old_rec.approval_status);
  hr_utility.set_location(l_proc, 40);
  --
  -- Update validation.
  --
  chk_retro_asg_updatable
    (p_retro_assignment_id           => p_retro_assignment_id
    ,p_retro_assignment_action_id    => l_old_rec.retro_assignment_action_id
    ,p_superseding_retro_asg_id      => l_old_rec.superseding_retro_asg_id
    ,p_old_approval_status           => l_old_rec.approval_status
     --
     -- setting null if approval status is defaulted.
     --
    ,p_new_approval_status           => decode_default
                                          (p_approval_status
                                          ,hr_api.g_varchar2
                                          ,null)
    ,p_owner_type                    => p_owner_type
    ,p_dml_mode                      => g_update
    );

  chk_assignment_id
    (p_assignment_id                 => l_new_rec.assignment_id
    ,p_reprocess_date                => l_new_rec.reprocess_date
    ,p_business_group_id             => l_business_group_id
    ,p_payroll_id                    => l_payroll_id
    );

  if l_old_rec.approval_status <> l_new_rec.approval_status then
    hr_utility.set_location(l_proc, 45);
    chk_approval_status
      (p_approval_status               => l_new_rec.approval_status
      ,p_insert_or_update              => 'U');
  end if;

  if l_old_rec.reprocess_date <> l_new_rec.reprocess_date then
    hr_utility.set_location(l_proc, 50);
    chk_asg_rep_date_updatable
      (p_retro_assignment_id        => p_retro_assignment_id
      ,p_created_by                 => l_old_rec.created_by
      ,p_owner_type                 => p_owner_type
      );

    chk_retro_asg_reprocess_date
      (p_retro_assignment_id           => p_retro_assignment_id
      ,p_reprocess_date                => l_new_rec.reprocess_date
      );
    --
    -- If the start date was not specified, change the start date
    -- as well.
    --
    l_new_rec.start_date    := decode_default(p_start_date
                                             ,hr_api.g_date
                                             ,l_new_rec.reprocess_date);
  end if;

  hr_utility.set_location(l_proc, 60);
  --
  -- Now update the retro assignment.
  --
  update pay_retro_assignments
  set reprocess_date  = l_new_rec.reprocess_date
     ,start_date      = l_new_rec.start_date
     ,approval_status = l_new_rec.approval_status
  where retro_assignment_id = p_retro_assignment_id;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to rts_update_retro_asg;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_retro_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< adjust_retro_asg_date >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This procedure adjusts the reprocess date and the start date of the retro
-- assignment with the ealiest date of the child retro entries.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_retro_assignment_id          Yes  Number   Retro Assignment ID.
--
-- Post Success:
--   The procedure will set the following out parameters:
--   Name                           Type     Description
--
-- Post Failure:
--   The procedure will not update a retro assignment and raises an error.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure adjust_retro_asg_date
  (p_retro_assignment_id           in     number
  )
is
  l_proc                varchar2(72) := g_package||'adjust_retro_asg_date';
  l_reprocess_date      date;
  l_start_date          date;
  l_old_rec             t_retro_asg_rec;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  select
    min(reprocess_date)
   ,min(effective_date)
  into
    l_reprocess_date
   ,l_start_date
  from pay_retro_entries
  where
      retro_assignment_id = p_retro_assignment_id
  ;

  hr_utility.set_location(l_proc, 20);
  --
  -- Continue only when retro entry exists.
  --
  if l_reprocess_date is not null then
    hr_utility.set_location(l_proc, 30);
    --
    -- Lock the retro assignment.
    --
    lock_retro_asg
      (p_retro_assignment_id           => p_retro_assignment_id
      ,p_old_rec                       => l_old_rec
      );

    if    (l_reprocess_date < l_old_rec.reprocess_date)
       or (l_start_date < l_old_rec.start_date)         then
      --
      hr_utility.set_location(l_proc, 40);
      --
      update pay_retro_assignments
      set reprocess_date = least(l_reprocess_date, l_old_rec.reprocess_date)
         ,start_date     = least(l_start_date, l_old_rec.start_date)
      where retro_assignment_id = p_retro_assignment_id;
    end if;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
end adjust_retro_asg_date;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_sys_retro_asg >---------------------------|
-- ----------------------------------------------------------------------------
/*Bug#6892796 : We mark the system created retro assignment as 'Completed -
Deferred Forver. This make sure that this retro assignment will not get picked
up in the future. Respective Retro entries will stay in the db for future
reference. May need to consider to delete them in future.*/
procedure delete_sys_retro_asg
  (p_retro_assignment_id   in number) is
  l_proc        varchar2(72) := g_package||'delete_sys_retro_asg';
  l_count       number := 0;
--
  cursor csr_sys_retro_asgs is
  select null
  from pay_retro_assignments
  where retro_assignment_id = p_retro_assignment_id
  and   retro_assignment_action_id is null
  for update nowait;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  for csr_sys_rec in csr_sys_retro_asgs loop
    /*Updating the approval status and retro assignment action id to make sure
      that the retro assignments will not get picked up in the next retopay.*/
    hr_utility.set_location('Updating the record : '|| l_proc, 20);
    update pay_retro_assignments
    set    retro_assignment_action_id = -1,
           approval_status = 'F'
    where  current of csr_sys_retro_asgs;
    hr_utility.set_location('Updation has been done : '|| l_proc, 30);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_retro_asg >---------------------------|
-- ----------------------------------------------------------------------------
procedure delete_retro_asg
  (p_retro_assignment_id           in     number
  ,p_owner_type                    in     varchar2 default g_user
  ,p_delete_sys_retro_asg          in     varchar2 default 'N'
  ,p_replaced_retro_asg_id            out nocopy   number
  )
is
  l_proc                varchar2(72) := g_package||'delete_retro_asg';
  l_old_rec               t_retro_asg_rec;
  l_replaced_retro_asg_id number;
  --
  cursor csr_superseding_retro_asg
    (p_retro_asg_id number
    ,p_asg_id       number)
  is
  select retro_assignment_id
  from pay_retro_assignments
  where superseding_retro_asg_id = p_retro_asg_id
  ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint rts_delete_retro_asg;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RETRO_ASSIGNMENT_ID'
    ,p_argument_value     => p_retro_assignment_id
    );

  --
  -- Owner type must be either U or S.
  --
  pay_core_utils.assert_condition
    (l_proc||':owner_type', p_owner_type in (g_user, g_system));

  hr_utility.set_location(l_proc, 20);
  --
  -- Lock the existing retro assignment.
  --
  lock_retro_asg
    (p_retro_assignment_id           => p_retro_assignment_id
    ,p_old_rec                       => l_old_rec
    );

  hr_utility.set_location(l_proc, 30);
  --
  -- Delete validation.
  --
  chk_retro_asg_updatable
    (p_retro_assignment_id           => p_retro_assignment_id
    ,p_retro_assignment_action_id    => l_old_rec.retro_assignment_action_id
    ,p_superseding_retro_asg_id      => l_old_rec.superseding_retro_asg_id
    ,p_old_approval_status           => l_old_rec.approval_status
    ,p_new_approval_status           => null
    ,p_owner_type                    => p_owner_type
    ,p_dml_mode                      => g_delete
    ,p_delete_sys_retro_asg          => p_delete_sys_retro_asg
    );

  hr_utility.set_location(l_proc, 50);
  --Bug#6892796 : Deleting system created retro assignment.
  --We don't delete the retro entries associated with this retro assignment.
  if (nvl(p_delete_sys_retro_asg,'N') = 'Y') then
    hr_utility.set_location('Deleting system created retro assignments : '||l_proc, 60);
    delete_sys_retro_asg(p_retro_assignment_id => p_retro_assignment_id);
    hr_utility.set_location('Deleted system created retro assignments : '||l_proc, 70);
  else
    hr_utility.set_location(l_proc, 80);
    --
    --  Delete child retro entries.
    --
    delete from pay_retro_entries pre
    where retro_assignment_id = p_retro_assignment_id;
    hr_utility.set_location(l_proc, 90);
    --
    -- Reverse the child retro assignment superseded by this retro assignment.
    --
    for l_rec in csr_superseding_retro_asg(p_retro_assignment_id
                                          ,l_old_rec.assignment_id) loop
    --
        l_replaced_retro_asg_id := l_rec.retro_assignment_id;
        --
        update pay_retro_assignments
        set superseding_retro_asg_id = null
        where retro_assignment_id = l_replaced_retro_asg_id;

    end loop;
    hr_utility.set_location(l_proc, 100);
    --
    -- Delete this retro assignment.
    --
    delete from pay_retro_assignments
    where retro_assignment_id = p_retro_assignment_id;
    hr_utility.set_location(l_proc, 110);
    --
    -- Set out variable.
    --
    p_replaced_retro_asg_id := l_replaced_retro_asg_id;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 200);
  exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to rts_delete_retro_asg;
    hr_utility.set_location(' Leaving:'||l_proc, 1000);
    raise;
  end delete_retro_asg;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_retro_asg_cascade >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_retro_asg_cascade
  (p_retro_assignment_id           in     number
  ,p_owner_type                    in     varchar2 default g_user
  )
is
  l_proc                varchar2(72) := g_package||'delete_retro_asg_cascade';
  l_replaced_retro_asg_id number;
  l_retro_assignment_id   number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint rts_delete_retro_asg_cascade;
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RETRO_ASSIGNMENT_ID'
    ,p_argument_value     => p_retro_assignment_id
    );
  --
  l_retro_assignment_id := p_retro_assignment_id;
  --
  while (l_retro_assignment_id is not null) loop

    delete_retro_asg
      (p_retro_assignment_id           => l_retro_assignment_id
      ,p_owner_type                    => p_owner_type
      ,p_replaced_retro_asg_id         => l_replaced_retro_asg_id
      );
    l_retro_assignment_id := l_replaced_retro_asg_id;
  end loop;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to rts_delete_retro_asg_cascade;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_retro_asg_cascade;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< lock_retro_entry >---------------------------|
-- ----------------------------------------------------------------------------
procedure lock_retro_entry
  (p_retro_assignment_id           in     number
  ,p_element_entry_id              in     number
  ,p_old_rec                          out nocopy t_retro_ent_rec
  )
is
  l_proc                varchar2(72) := g_package||'lock_retro_entry';
  l_old_rec             t_retro_ent_rec;
  --
  cursor csr_lock_retro_ent
  is
  select *
  from pay_retro_entries
  where retro_assignment_id = p_retro_assignment_id
  and element_entry_id = p_element_entry_id
  for update nowait;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- NOTE: do not check no data found.
  --
  open csr_lock_retro_ent;
  fetch csr_lock_retro_ent into l_old_rec;
  close csr_lock_retro_ent;
  --
  hr_utility.set_location(l_proc, 20);

  p_old_rec := l_old_rec;

  hr_utility.set_location(' Leaving:'||l_proc, 40);
Exception
  When HR_Api.Object_Locked then
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pay_retro_entries');
    fnd_message.raise_error;
end lock_retro_entry;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< maintain_retro_entry >-------------------------|
-- ----------------------------------------------------------------------------
procedure maintain_retro_entry
  (p_retro_assignment_id           in     number
  ,p_element_entry_id              in     number
  ,p_reprocess_date                in     date
  ,p_effective_date                in     date     default null
  ,p_retro_component_id            in     number   default null
  ,p_owner_type                    in     varchar2 default g_user
  ,p_system_reprocess_date         in     date     default hr_api.g_eot
  ,p_entry_param_name              in     varchar2 default null
  )
is
  l_proc                varchar2(72) := g_package||'maintain_retro_entry';
  l_retro_asg_rec       t_retro_asg_rec;
  l_old_rec             t_retro_ent_rec;
  l_new_rec             t_retro_ent_rec;
  l_assignment_id       number;
  l_asg_owner_type      varchar2(10);
  l_element_type_id     number;
  l_element_name        pay_element_types_f_tl.element_name%type;
  l_business_group_id   number;
  l_legislation_code    per_business_groups.legislation_code%type;
  l_component_name      pay_retro_components.component_name%type;
  l_payroll_id          number;
  l_retro_component_id  number;
  l_reprocess_date      date;
  l_system_reprocess_date date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint rts_maintain_retro_entry;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RETRO_ASSIGNMENT_ID'
    ,p_argument_value     => p_retro_assignment_id
    );

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ELEMENT_ENTRY_ID'
    ,p_argument_value     => p_element_entry_id
    );

  --
  -- Owner type must be either U or S.
  --
  pay_core_utils.assert_condition
    (l_proc||':owner_type', p_owner_type in (g_user, g_system));

  hr_utility.set_location(l_proc, 20);
  --
  -- Lock the retro assignment.
  --
  lock_retro_asg
    (p_retro_assignment_id           => p_retro_assignment_id
    ,p_old_rec                       => l_retro_asg_rec
    );

  -- Copy the assignment ID.
  l_assignment_id := l_retro_asg_rec.assignment_id;

  --
  -- Try to find and lock the existing retro entry.
  --
  lock_retro_entry
    (p_retro_assignment_id           => p_retro_assignment_id
    ,p_element_entry_id              => p_element_entry_id
    ,p_old_rec                       => l_old_rec
    );

  hr_utility.set_location(l_proc, 50);
  --
  -- Insert and update validations
  --
  if l_old_rec.retro_assignment_id is null then
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => nvl(p_entry_param_name,'ENTRY')
                               ||' REPROCESS_DATE'
      ,p_argument_value     => p_reprocess_date
      );
  end if;

  chk_element_entry_id
    (p_element_entry_id              => p_element_entry_id
    ,p_assignment_id                 => l_assignment_id
    ,p_element_type_id               => l_element_type_id
    );
  --
  chk_assignment_id
    (p_assignment_id        => l_assignment_id
    ,p_reprocess_date       => nvl(p_reprocess_date, l_old_rec.reprocess_date)
    ,p_business_group_id    => l_business_group_id
    ,p_payroll_id           => l_payroll_id
    );
  --
  hr_utility.set_location(l_proc, 80);
  if p_owner_type = g_user then
    l_asg_owner_type := get_retro_asg_creator_type
                          (p_retro_assignment_id  => p_retro_assignment_id
                          ,p_created_by           => l_retro_asg_rec.created_by
                          );
    --
    chk_ent_reprocess_date
      (p_retro_assignment_id           => p_retro_assignment_id
      ,p_element_entry_id              => p_element_entry_id
      ,p_reprocess_date                => p_reprocess_date
      ,p_old_reprocess_date            => l_old_rec.reprocess_date
      ,p_system_reprocess_date         => l_old_rec.system_reprocess_date
      ,p_asg_reprocess_date            => l_retro_asg_rec.reprocess_date
      ,p_asg_owner_type                => l_asg_owner_type
      ,p_created_by                    => l_old_rec.created_by
      ,p_old_owner_type                => l_old_rec.owner_type
      ,p_owner_type                    => p_owner_type
      );
  end if;
  hr_utility.set_location(l_proc, 100);
  l_reprocess_date := nvl(p_reprocess_date, l_old_rec.reprocess_date);

  l_retro_component_id := p_retro_component_id;
  l_legislation_code := hr_api.return_legislation_code(l_business_group_id);
  --
  if p_retro_component_id is null then
    hr_utility.set_location(l_proc, 110);
    --
    -- We need derive the default value for retro component.
    --
    if (l_old_rec.retro_assignment_id is null) then
      --
      hr_utility.set_location(l_proc, 120);
      l_retro_component_id :=
        get_default_retro_component_id
          (p_element_entry_id             => p_element_entry_id
          ,p_reprocess_date               => l_reprocess_date
          ,p_element_type_id              => l_element_type_id
          ,p_assignment_id                => l_assignment_id
          );
    else
      hr_utility.set_location(l_proc, 130);
      --
      -- Inherit the previous value.
      --
      l_retro_component_id := l_old_rec.retro_component_id;

    end if;
  end if;
  --
  hr_utility.set_location(l_proc, 140);
  --
  if    (l_old_rec.retro_assignment_id is null)
     or (l_old_rec.retro_component_id <> l_retro_component_id) then
    --
    hr_utility.set_location(l_proc, 150);
    chk_retro_component_id
      (p_retro_component_id            => l_retro_component_id
      ,p_business_group_id             => l_business_group_id
      );
    --
    chk_retro_comp_usage
      (p_element_type_id               => l_element_type_id
      ,p_retro_component_id            => l_retro_component_id
      );
  end if;

  hr_utility.set_location(l_proc, 160);
  --
  -- If system reprocess date is set to null, override the value with
  -- the previous value, for null is available for user type entries.
  -- Note that if the value is EOT, it will be handled in
  -- pay_retro_pkg.maintain_retro_entry.
  --
  l_system_reprocess_date
    := nvl(p_system_reprocess_date, l_old_rec.system_reprocess_date);

  pay_retro_pkg.maintain_retro_entry
    (p_retro_assignment_id          => p_retro_assignment_id
    ,p_element_entry_id             => p_element_entry_id
    ,p_element_type_id              => l_element_type_id
    ,p_reprocess_date               => l_reprocess_date
    ,p_eff_date                     => nvl(p_effective_date, l_reprocess_date)
    ,p_retro_component_id           => l_retro_component_id
    ,p_owner_type                   => p_owner_type
    ,p_system_reprocess_date        => l_system_reprocess_date
    );

  --
  -- Ensure that the reprocess date is maintained appropriately.
  --
  if p_owner_type = g_user then
    --
    if l_old_rec.reprocess_date <> p_reprocess_date then
      hr_utility.set_location(l_proc, 180);
      lock_retro_entry
        (p_retro_assignment_id           => p_retro_assignment_id
        ,p_element_entry_id              => p_element_entry_id
        ,p_old_rec                       => l_new_rec
        );
      --
      if p_reprocess_date <> l_new_rec.reprocess_date then
        --
        hr_utility.set_location(l_proc, 190);
        --
        update pay_retro_entries
        set reprocess_date = p_reprocess_date
           ,effective_date = p_reprocess_date
        where
            retro_assignment_id = p_retro_assignment_id
        and element_entry_id = p_element_entry_id;
        --
      end if;
    end if;
  else
    hr_utility.set_location(l_proc, 200);
    adjust_retro_asg_date
      (p_retro_assignment_id          => p_retro_assignment_id
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 250);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to rts_maintain_retro_entry;
    hr_utility.set_location(' Leaving:'||l_proc, 260);
    raise;
end maintain_retro_entry;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_retro_entry >--------------------------|
-- ----------------------------------------------------------------------------
procedure delete_retro_entry
  (p_retro_assignment_id           in     number
  ,p_element_entry_id              in     number
  ,p_owner_type                    in     varchar2 default g_user
  )
is
  l_proc                varchar2(72) := g_package||'delete_retro_entry';
  l_old_rec             t_retro_ent_rec;
  l_new_rec             t_retro_ent_rec;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint rts_delete_retro_entry;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'RETRO_ASSIGNMENT_ID'
    ,p_argument_value     => p_retro_assignment_id
    );

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ELEMENT_ENTRY_ID'
    ,p_argument_value     => p_element_entry_id
    );

  --
  -- Owner type must be either U or S.
  --
  pay_core_utils.assert_condition
    (l_proc||':owner_type', p_owner_type in (g_user, g_system));

  hr_utility.set_location(l_proc, 20);
  --
  -- Lock the existing retro entry.
  --
  lock_retro_entry
    (p_retro_assignment_id           => p_retro_assignment_id
    ,p_element_entry_id              => p_element_entry_id
    ,p_old_rec                       => l_old_rec
    );

  if l_old_rec.retro_assignment_id is null then
    hr_utility.set_location(l_proc, 30);
    --
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc, 50);
  --
  -- Delete validation.
  --
  chk_retro_entry_deletable
    (p_element_entry_id              => p_element_entry_id
    ,p_old_owner_type                => l_old_rec.owner_type
    ,p_owner_type                    => p_owner_type
    );

  hr_utility.set_location(l_proc, 60);

  delete from pay_retro_entries
  where retro_assignment_id = p_retro_assignment_id
  and element_entry_id = p_element_entry_id
  ;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to rts_delete_retro_entry;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_retro_entry;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_reprocess_date >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_reprocess_date(
p_assignment_id in number
,p_reprocess_date in date
,p_owner_type in varchar2 default g_user
,p_retro_asg_id out nocopy number) is

  l_retro_assignment_id number;
  l_old_retro_asg_id    number;
  l_old_ra_rec          t_retro_asg_rec;
  l_business_group_id   number;
  l_payroll_id          number;
  l_reprocess_date      date;
  l_old_approval_status pay_retro_assignments.approval_status%type;
  l_new_approval_status pay_retro_assignments.approval_status%type;
  l_new_reprocess_date  date;

  l_proc                varchar2(72) := g_package||'update_reprocess_date';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint rts_update_reprocess_date;

  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'ASSIGNMENT_ID'
    ,p_argument_value     => p_assignment_id
    );

  --
  -- Owner type must be either U or S.
  --
  pay_core_utils.assert_condition
    (l_proc||':owner_type', p_owner_type in (g_user, g_system));

  hr_utility.set_location('Getting the retro assignment '||l_proc, 15);
  --
  -- Check to see if the previous version of retro assignment exists.
  --
  l_old_retro_asg_id := get_unprocessed_retro_asg(p_assignment_id);

  if l_old_retro_asg_id is null then
    --
    --
    -- No unprocessed retro assignment is found.
    --
    hr_utility.set_location('No retro assignment found for this assignment : '||l_proc, 15);
    fnd_message.set_name('PAY','PAY_34312_RTS_NO_RTA_FOUND');
    fnd_message.raise_error;
    --
  else
    --
    hr_utility.set_location('Got retro assignment id and now locking : '||l_proc, 15);
    --
    -- Lock and obtain the old record info.
    --
    lock_retro_asg
      (p_retro_assignment_id           => l_old_retro_asg_id
      ,p_old_rec                       => l_old_ra_rec
      );
    --
    -- Check to see if this retro assignment is updatable.
    hr_utility.set_location('Calling chk_retro_asg_updatable : '||l_proc,20);
    chk_retro_asg_updatable
      (p_retro_assignment_id        => l_old_retro_asg_id
      ,p_retro_assignment_action_id => l_old_ra_rec.retro_assignment_action_id
      ,p_superseding_retro_asg_id   => l_old_ra_rec.superseding_retro_asg_id
      ,p_old_approval_status        => l_old_ra_rec.approval_status
      ,p_new_approval_status        => l_old_ra_rec.approval_status
      ,p_owner_type                 => p_owner_type
      ,p_dml_mode                   => g_update
      );

    --
    --Checking whether reprocess date is later than the existing reprocess date.
    chk_retro_asg_reprocess_date
    (p_retro_assignment_id          => l_old_retro_asg_id
    ,p_reprocess_date               => p_reprocess_date);
    --
    -- Insert validation.
    --
    hr_utility.set_location('Validates that the employee assignment exists on the reprocess date : '||l_proc, 25);
    chk_assignment_id
    (p_assignment_id                 => p_assignment_id
    ,p_reprocess_date                => p_reprocess_date
    ,p_business_group_id             => l_business_group_id
    ,p_payroll_id                    => l_payroll_id
    );


    hr_utility.set_location('Creating superseding retro assignment : '||l_proc, 30);
    --
    -- Create superseding retro assignment.
    --
    pay_retro_utils_pkg.create_super_retro_asg
    (p_asg_id         => p_assignment_id
    ,p_payroll_id     => l_payroll_id
    ,p_reprocess_date => p_reprocess_date
    ,p_retro_asg_id   => l_retro_assignment_id
    );
    p_retro_asg_id := l_retro_assignment_id;
    hr_utility.set_location('Leaving .... '||l_proc, 40);
    --
  end if;

  exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to rts_update_reprocess_date;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end;
end pay_retro_status_internal;

/
