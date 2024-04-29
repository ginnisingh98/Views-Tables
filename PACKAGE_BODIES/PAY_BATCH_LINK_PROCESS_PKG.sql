--------------------------------------------------------
--  DDL for Package Body PAY_BATCH_LINK_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BATCH_LINK_PROCESS_PKG" AS
/* $Header: pybatlnk.pkb 120.6 2007/03/21 10:34:47 thabara noship $ */

g_package constant varchar2(31):= 'pay_batch_link_process_pkg.';
--
-- Global Types
--
type t_number_tab is table of number index by binary_integer;

type t_element_link_rec is record
  (element_link_id           number
  ,element_type_id           number
  ,effective_start_date      date
  ,effective_end_date        date
  ,link_to_all_payrolls_flag pay_element_links_f.link_to_all_payrolls_flag%type
  ,payroll_id                number
  ,job_id                    number
  ,grade_id                  number
  ,position_id               number
  ,organization_id           number
  ,location_id               number
  ,pay_basis_id              number
  ,employment_category       pay_element_links_f.employment_category%type
  ,people_group_id           number
  );
--
type t_element_link_tab is table of t_element_link_rec
  index by binary_integer;

type t_payroll_action_rec is record
  (payroll_action_id    number
  ,business_group_id    number
  ,effective_date       date
  -- Batch Link Specific Parameters
  ,gen_link_type        varchar2(30) -- generate type. A(All) or S(Single)
  ,bat_link_id          number -- batch element link id
  ,ele_link_id          number -- element link id
  );

--
-- Global Variables
--
g_standard_links              t_element_link_tab;
g_pg_links                    pay_asg_link_usages_pkg.t_pg_link_tab;
g_link_initialized            boolean:= false;
g_pact_rec                    t_payroll_action_rec;
g_err_batch_link_id           number;
g_batch_links                 t_number_tab;
g_lock_timeout                number;
g_lock_interval               number;
g_max_lock_count     constant number:= 20;

--
-- ---------------------------------------------------------------------------
-- lock_wait
--
-- Description
-- Returns true if the current time is before the lock timeout.
-- If p_start_time is null, sysdate is set and returned.
--
-- ---------------------------------------------------------------------------
function lock_wait
  (p_start_time           in out nocopy date
  ,p_count                in out nocopy number
  ,p_lock_timeout         in            number default null
  ) return boolean
is
  l_current_time             date;
  l_lock_timeout             number;
  --
  l_proc               varchar2(72):= g_package||'lock_wait';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  l_lock_timeout := nvl(p_lock_timeout, g_lock_timeout);
  --
  -- Continue only when valid timeout is set.
  --
  if nvl(l_lock_timeout, 0) <= 0 then
    hr_utility.trace('Lock timeout is not set.');
    return false;
  end if;
  --
  -- Increment the count.
  --
  p_count := nvl(p_count, 0)+1;
  --
  if p_count > g_max_lock_count then
    hr_utility.trace('Lock count exceeded the max count.');
    return false;
  end if;
  --
  select sysdate into l_current_time
  from dual;
  --
  if p_start_time is null then
    --
    p_start_time := l_current_time;
    hr_utility.trace('Setting the lock start time: '
                   ||to_char(p_start_time,'yyyy/mm/dd hh24:mi:ss'));
  end if;

  if ((l_current_time - p_start_time)*86400 < l_lock_timeout) then
    --
    return true;
  end if;

  return false;

end lock_wait;
--
-- ---------------------------------------------------------------------------
-- lock_sleep
--
-- Description
-- Wrapper call to dbms_lock.sleep.
--
-- ---------------------------------------------------------------------------
procedure lock_sleep
  (p_seconds in number default null
  )
is
  l_seconds number;
  --
  l_proc               varchar2(72):= g_package||'lock_sleep';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  l_seconds := nvl(p_seconds, g_lock_interval);

  if l_seconds > 0 then
    hr_utility.trace('Sleep '||to_char(l_seconds));
    dbms_lock.sleep(l_seconds);
  end if;
end lock_sleep;
--
-- ---------------------------------------------------------------------------
-- load_element_link
--
-- Description
-- Creates element link from the batch element link record.
-- ---------------------------------------------------------------------------
procedure load_element_link
  (p_payroll_action_id     in            number
  ,p_batch_element_link_id in            number
  ,p_element_link_id          out nocopy number
  )
is
  --
  cursor csr_bat
  is
  select *
  from pay_batch_element_links
  where batch_element_link_id = p_batch_element_link_id;
  --
  l_bat_rec            csr_bat%rowtype;
  l_link_rec           t_element_link_rec;
  l_ovn                number;
  l_comment_id         number;
  l_message            varchar2(240);
  l_proc               varchar2(72):= g_package||'load_element_link';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  open csr_bat;
  fetch csr_bat into l_bat_rec;
  close csr_bat;
  --
  -- Set the status of this record
  --
  pay_batch_object_status_pkg.set_status
    (p_object_type       => 'BEL'
    ,p_object_id         => p_batch_element_link_id
    ,p_object_status     => 'P'
    ,p_payroll_action_id => p_payroll_action_id
    );

  --
  pay_element_link_internal.create_element_link
    (p_effective_date               => l_bat_rec.effective_date
    ,p_element_type_id              => l_bat_rec.element_type_id
    ,p_business_group_id            => l_bat_rec.business_group_id
    ,p_costable_type                => l_bat_rec.costable_type
    ,p_payroll_id                   => l_bat_rec.payroll_id
    ,p_job_id                       => l_bat_rec.job_id
    ,p_position_id                  => l_bat_rec.position_id
    ,p_people_group_id              => l_bat_rec.people_group_id
    ,p_cost_allocation_keyflex_id   => l_bat_rec.cost_allocation_keyflex_id
    ,p_organization_id              => l_bat_rec.organization_id
    ,p_location_id                  => l_bat_rec.location_id
    ,p_grade_id                     => l_bat_rec.grade_id
    ,p_balancing_keyflex_id         => l_bat_rec.balancing_keyflex_id
    ,p_element_set_id               => l_bat_rec.element_set_id
    ,p_pay_basis_id                 => l_bat_rec.pay_basis_id
    ,p_link_to_all_payrolls_flag    => l_bat_rec.link_to_all_payrolls_flag
    ,p_standard_link_flag           => l_bat_rec.standard_link_flag
    ,p_transfer_to_gl_flag          => l_bat_rec.transfer_to_gl_flag
    ,p_comments                     => null
    ,p_employment_category          => l_bat_rec.employment_category
    ,p_qualifying_age               => l_bat_rec.qualifying_age
    ,p_qualifying_length_of_service => l_bat_rec.qualifying_length_of_service
    ,p_qualifying_units             => l_bat_rec.qualifying_units
    ,p_attribute_category           => l_bat_rec.attribute_category
    ,p_attribute1                   => l_bat_rec.attribute1
    ,p_attribute2                   => l_bat_rec.attribute2
    ,p_attribute3                   => l_bat_rec.attribute3
    ,p_attribute4                   => l_bat_rec.attribute4
    ,p_attribute5                   => l_bat_rec.attribute5
    ,p_attribute6                   => l_bat_rec.attribute6
    ,p_attribute7                   => l_bat_rec.attribute7
    ,p_attribute8                   => l_bat_rec.attribute8
    ,p_attribute9                   => l_bat_rec.attribute9
    ,p_attribute10                  => l_bat_rec.attribute10
    ,p_attribute11                  => l_bat_rec.attribute11
    ,p_attribute12                  => l_bat_rec.attribute12
    ,p_attribute13                  => l_bat_rec.attribute13
    ,p_attribute14                  => l_bat_rec.attribute14
    ,p_attribute15                  => l_bat_rec.attribute15
    ,p_attribute16                  => l_bat_rec.attribute16
    ,p_attribute17                  => l_bat_rec.attribute17
    ,p_attribute18                  => l_bat_rec.attribute18
    ,p_attribute19                  => l_bat_rec.attribute19
    ,p_attribute20                  => l_bat_rec.attribute20
    --
    ,p_cost_concat_segments         => null
    ,p_balance_concat_segments      => null
    ,p_element_link_id              => l_link_rec.element_link_id
    ,p_comment_id                   => l_comment_id
    ,p_object_version_number        => l_ovn
    ,p_effective_start_date         => l_link_rec.effective_start_date
    ,p_effective_end_date           => l_link_rec.effective_end_date
    );
  --
  -- Update the values that were bypassed in creating the link.
  --
  if (l_bat_rec.comment_id is not null) then
    --
    update pay_element_links_f
    set comment_id                 = l_bat_rec.comment_id
    where
        element_link_id      = l_link_rec.element_link_id
    and effective_start_date = l_link_rec.effective_start_date
    and effective_end_date   = l_link_rec.effective_end_date
    ;
  end if;
  --
  -- If this is a standard link or people group link then
  -- further processing needs to be done in batch mode.
  --
  if     (l_bat_rec.standard_link_flag = 'Y')
     or  (l_bat_rec.people_group_id is not null) then
    --
    -- Set the batch object status
    --
    pay_batch_object_status_pkg.set_status
      (p_object_type       => 'EL'
      ,p_object_id         => l_link_rec.element_link_id
      ,p_object_status     => 'U'
      ,p_payroll_action_id => p_payroll_action_id
      );

  end if;
  --
  -- Update the batch record as complete.
  --
  pay_batch_object_status_pkg.set_status
    (p_object_type       => 'BEL'
    ,p_object_id         => p_batch_element_link_id
    ,p_object_status     => 'C'
    ,p_payroll_action_id => p_payroll_action_id
    );
  --
  -- Update the batch link
  --
  update pay_batch_element_links
  set element_link_id = l_link_rec.element_link_id
  where batch_element_link_id = p_batch_element_link_id;

  --
  -- Set out variable
  --
  p_element_link_id := l_link_rec.element_link_id;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
exception
  when others then
    --
    -- Remember the batch element link ID
    --
    g_err_batch_link_id := p_batch_element_link_id;
    --
    raise;

end load_element_link;
--
-- ---------------------------------------------------------------------------
-- init_ppa
--
-- Description
-- Initialises payroll action.
-- ---------------------------------------------------------------------------
procedure init_ppa
  (p_payroll_action_id in number)
is
  l_legislative_parameters pay_payroll_actions.legislative_parameters%type;
  --
  l_null_ppa  t_payroll_action_rec;
  --
  cursor csr_ppa
  is
  select
    payroll_action_id
   ,business_group_id
   ,effective_date
   ,legislative_parameters
   ,pay_core_utils.get_parameter
      ('GEN_LINK_TYPE', legislative_parameters) gen_link_type
   ,pay_core_utils.get_parameter
      ('ELE_LINK_ID', legislative_parameters) ele_link_id
   ,pay_core_utils.get_parameter
      ('BAT_LINK_ID', legislative_parameters) bat_link_id
  from pay_payroll_actions ppa
  where payroll_action_id = p_payroll_action_id;
  --
  l_ppa_rec csr_ppa%rowtype;
  --
  l_timeout_char       pay_action_parameters.parameter_value%type;
  l_timeout_found      boolean;
  l_interval_char      pay_action_parameters.parameter_value%type;
  l_interval_found     boolean;
  --
  l_proc               varchar2(72):= g_package||'init_ppa';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Check to see if the payroll action has been initialized.
  --
  if g_pact_rec.payroll_action_id = p_payroll_action_id then
    return;
  end if;
  --
  -- Reset the payroll action global record.
  --
  g_pact_rec := l_null_ppa;

  --
  -- Get payroll action info.
  --
  open csr_ppa;
  fetch csr_ppa into l_ppa_rec;
  close csr_ppa;
  --
  pay_core_utils.assert_condition
      (l_proc||':1'
      ,l_ppa_rec.payroll_action_id is not null);
  --
  g_pact_rec.payroll_action_id := p_payroll_action_id;
  g_pact_rec.business_group_id := l_ppa_rec.business_group_id;
  g_pact_rec.effective_date    := l_ppa_rec.effective_date;
  g_pact_rec.gen_link_type     := l_ppa_rec.gen_link_type;
  g_pact_rec.bat_link_id       := l_ppa_rec.bat_link_id;
  g_pact_rec.ele_link_id       := l_ppa_rec.ele_link_id;

  --
  -- Get action parameters.
  --
  pay_core_utils.get_action_parameter
    ('BEE_LOCK_MAX_WAIT_SEC', l_timeout_char, l_timeout_found);

  if l_timeout_found then
    g_lock_timeout := fnd_number.canonical_to_number(l_timeout_char);
  else
    g_lock_timeout := 0;
  end if;
  --
  pay_core_utils.get_action_parameter
    ('BEE_LOCK_INTERVAL_WAIT_SEC', l_interval_char, l_interval_found);

  if l_interval_found then
    g_lock_interval := fnd_number.canonical_to_number(l_interval_char);
  else
    g_lock_interval := 0;
  end if;

  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end init_ppa;
--
-- ---------------------------------------------------------------------------
-- transfer_batch_links
--
-- Description
-- Transfers the batch element links to element links.
-- ---------------------------------------------------------------------------
procedure transfer_batch_links
  (p_pact_rec        in         t_payroll_action_rec
  )
is
  --
  -- Batch links to lock
  --
  cursor csr_batlink(p_gen_link_type varchar2
                    ,p_batlink_id    number
                    ,p_bgid          number
                    )
  is
  select
    bat.batch_element_link_id
  from
    pay_batch_element_links bat
  where
      bat.business_group_id = p_bgid
  and (bat.batch_element_link_id = p_batlink_id
       or (    p_gen_link_type = 'A'
           and p_batlink_id is null
           and nvl(pay_batch_object_status_pkg.get_status
                     ('BEL',bat.batch_element_link_id)
                  ,'U') <> 'C')
      )
  and bat.element_link_id is null
  --
  -- Ensure element type exists.
  --
  and exists
        (select 1 from pay_element_types_f pet
         where pet.element_type_id = bat.element_type_id)
  order by
    bat.element_type_id
   ,bat.effective_date
  for update nowait
  ;
  --
  l_bat_link_id        number;
  l_link_id_out        number;
  l_proc               varchar2(72):= g_package||'transfer_batch_links';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  g_err_batch_link_id := null;
  g_batch_links.delete;
  --
  if (p_pact_rec.gen_link_type = 'A') or
     (p_pact_rec.gen_link_type = 'S' and p_pact_rec.bat_link_id is not null)
  then
    --
    -- Lock batch links.
    --
    begin
      open csr_batlink
             (p_pact_rec.gen_link_type
             ,p_pact_rec.bat_link_id
             ,p_pact_rec.business_group_id);
      fetch csr_batlink bulk collect into g_batch_links;
      close csr_batlink;

    exception
      when hr_api.object_locked then
        --
        -- Failed to lock the batch link.
        --
        hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
        hr_utility.set_message_token('TABLE_NAME', 'pay_batch_element_links');
        hr_utility.raise_error;
    end;
    --
    -- Load batch element links
    --
    for i in 1..g_batch_links.count loop

      l_bat_link_id := g_batch_links(i);
      --
      load_element_link
        (p_pact_rec.payroll_action_id
        ,l_bat_link_id
        ,l_link_id_out
        );
    end loop;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end transfer_batch_links;
--
-- ---------------------------------------------------------------------------
-- init_links
--
-- Description
-- Initialises element links.
-- p_phase should be 1 - Payroll action level initialization.
--                or 2 - Assignment action level initialization.
-- ---------------------------------------------------------------------------
procedure init_links
  (p_pact_rec        in         t_payroll_action_rec
  ,p_phase           in         number
  )
is
  l_legislative_parameters pay_payroll_actions.legislative_parameters%type;
  --
  l_link      t_element_link_rec;
  l_pg_link   pay_asg_link_usages_pkg.t_pg_link_rec;
  --
  cursor csr_elelink
    (p_gen_link_type varchar2
    ,p_elelink_id    number
    ,p_bgid          number
    ,p_pact_id       number
    ,p_phase         number)
  is
  --
  -- element links to process
  --
  select
    pel.element_link_id
   ,pel.element_type_id
   ,min(pel.effective_start_date) effective_start_date
   ,max(pel.effective_end_date)   effective_end_date
   ,pel.link_to_all_payrolls_flag
   ,pel.payroll_id
   ,pel.job_id
   ,pel.grade_id
   ,pel.position_id
   ,pel.organization_id
   ,pel.location_id
   ,pel.pay_basis_id
   ,pel.employment_category
   ,pel.people_group_id
   ,pel.standard_link_flag
   --
   ,bos.payroll_action_id
   ,bos.object_status
  from
    pay_element_links_f     pel
   ,pay_batch_object_status bos
  where
      p_phase = 1
  and (   pel.element_link_id = p_elelink_id
       or (    p_gen_link_type = 'A'
           and bos.object_status <> 'C'))
  and pel.business_group_id = p_bgid
  and (pel.standard_link_flag = 'Y'
       or pel.people_group_id is not null)
  and bos.object_type = 'EL'
  and bos.object_id   = pel.element_link_id
  -- not processed by this payroll action
  and nvl(bos.payroll_action_id, -999) <> p_pact_id
  and (nvl(bos.object_status, 'C') <> 'P'
       or not exists
            (select null from pay_payroll_actions
             where payroll_action_id = bos.payroll_action_id))
  group by
    pel.element_link_id
   ,pel.element_type_id
   ,pel.link_to_all_payrolls_flag
   ,pel.payroll_id
   ,pel.job_id
   ,pel.grade_id
   ,pel.position_id
   ,pel.organization_id
   ,pel.location_id
   ,pel.pay_basis_id
   ,pel.employment_category
   ,pel.people_group_id
   ,pel.standard_link_flag
   --
   ,bos.payroll_action_id
   ,bos.object_status
  --
  UNION ALL
  --
  -- element links being processed
  --
  select
    pel.element_link_id
   ,pel.element_type_id
   ,min(pel.effective_start_date) effective_start_date
   ,max(pel.effective_end_date)   effective_end_date
   ,pel.link_to_all_payrolls_flag
   ,pel.payroll_id
   ,pel.job_id
   ,pel.grade_id
   ,pel.position_id
   ,pel.organization_id
   ,pel.location_id
   ,pel.pay_basis_id
   ,pel.employment_category
   ,pel.people_group_id
   ,pel.standard_link_flag
   --
   ,bos.payroll_action_id
   ,bos.object_status
  from
    pay_batch_object_status bos
   ,pay_element_links_f     pel
  where
      bos.payroll_action_id = p_pact_id
  and bos.object_type = 'EL'
  and pel.element_link_id = bos.object_id
  and pel.business_group_id = p_bgid
  and (pel.standard_link_flag = 'Y'
       or pel.people_group_id is not null)
  group by
    pel.element_link_id
   ,pel.element_type_id
   ,pel.link_to_all_payrolls_flag
   ,pel.payroll_id
   ,pel.job_id
   ,pel.grade_id
   ,pel.position_id
   ,pel.organization_id
   ,pel.location_id
   ,pel.pay_basis_id
   ,pel.employment_category
   ,pel.people_group_id
   ,pel.standard_link_flag
   --
   ,bos.payroll_action_id
   ,bos.object_status
  order by
    people_group_id
   ,element_link_id
  ;
  --
  l_idx                number:=0;
  l_proc               varchar2(72):= g_package||'init_links';
  --

  --
  -- This procedure sets the Processing status for the specified
  -- element link and commit immediately within this process so
  -- it can be reflected to multi-threads.
  --
  procedure set_processing_status
    (p_element_link_id   in number
    ,p_payroll_action_id in number
    )
  is
    pragma autonomous_transaction;
  begin
    --
    pay_batch_object_status_pkg.set_status
      (p_object_type       => 'EL'
      ,p_object_id         => p_element_link_id
      ,p_object_status     => 'P'
      ,p_payroll_action_id => p_payroll_action_id
      );
    --
    commit;
    --
  end set_processing_status;
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Check to see if the link info has been initialized.
  --
  if g_link_initialized then
    return;
  end if;
  --
  -- Initialise globals
  --
  g_standard_links.delete;
  g_pg_links.delete;
  --
  for l_rec in csr_elelink
                 (p_pact_rec.gen_link_type
                 ,p_pact_rec.ele_link_id
                 ,p_pact_rec.business_group_id
                 ,p_pact_rec.payroll_action_id
                 ,p_phase)
  loop

    if l_rec.standard_link_flag = 'Y' then
      --
      -- Add a standard link record.
      --
      l_link.element_link_id           := l_rec.element_link_id;
      l_link.element_type_id           := l_rec.element_type_id;
      l_link.effective_start_date      := l_rec.effective_start_date;
      l_link.effective_end_date        := l_rec.effective_end_date;
      l_link.link_to_all_payrolls_flag := l_rec.link_to_all_payrolls_flag;
      l_link.payroll_id                := l_rec.payroll_id;
      l_link.job_id                    := l_rec.job_id;
      l_link.grade_id                  := l_rec.grade_id;
      l_link.position_id               := l_rec.position_id;
      l_link.organization_id           := l_rec.organization_id;
      l_link.location_id               := l_rec.location_id;
      l_link.pay_basis_id              := l_rec.pay_basis_id;
      l_link.employment_category       := l_rec.employment_category;
      l_link.people_group_id           := l_rec.people_group_id;

      g_standard_links(g_standard_links.count+1) := l_link;

    end if;
    --
    if l_rec.people_group_id is not null then
      --
      -- Add a people group link record.
      --
      l_pg_link.people_group_id        := l_rec.people_group_id;
      l_pg_link.element_link_id        := l_rec.element_link_id;
      l_pg_link.effective_start_date   := l_rec.effective_start_date;
      l_pg_link.effective_end_date     := l_rec.effective_end_date;

      g_pg_links(g_pg_links.count+1) := l_pg_link;

    end if;
    --
    -- Now lock this record.
    --
    if     l_rec.object_status = 'P'
       and l_rec.payroll_action_id = p_pact_rec.payroll_action_id then
      --
      -- The status has already been set.
      --
      null;

    elsif p_phase = 1 then
      --
      pay_batch_object_status_pkg.set_status
        (p_object_type       => 'EL'
        ,p_object_id         => l_rec.element_link_id
        ,p_object_status     => 'P'
        ,p_payroll_action_id => p_pact_rec.payroll_action_id
        );
    elsif p_phase = 2 then
      --
      -- The process reaches here only when rerunning.
      -- We need commit for multi-threads environment.
      --
      set_processing_status
        (p_element_link_id   => l_rec.element_link_id
        ,p_payroll_action_id => p_pact_rec.payroll_action_id
        );
    end if;
    --
  end loop;
  --
  g_link_initialized    := true;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
exception
  when hr_api.object_locked then
    --
    -- Failed to lock element link.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_links_f');
    hr_utility.raise_error;
end init_links;
--
-- ---------------------------------------------------------------------------
-- action_archinit
--
-- Description
-- Assignment action level initialization.
-- ---------------------------------------------------------------------------
procedure action_archinit
  (p_payroll_action_id in number)
is
  l_start_time         date;
  l_lock_count         number:= 0;
  l_proc               varchar2(72):= g_package||'action_archinit';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Initialize payroll action info.
  --
  init_ppa(p_payroll_action_id);

  --
  -- Loop until timeout setting allows for locking.
  --
  loop
    --
    begin
      --
      -- Issue a savepoint
      --
      savepoint action_archinit_sp;
      --
      -- Initialize element link info.
      --
      init_links(g_pact_rec, 2);
      --
      -- If succeeded, exit the loop.
      --
      exit;
    exception
      when hr_api.object_locked then
        --
        if lock_wait(l_start_time, l_lock_count) then
          --
          rollback to action_archinit_sp;
          lock_sleep;
        else
          raise;
        end if;
        --
      when others then
        hr_message.provide_error;
        if (hr_message.last_message_name = 'HR_7165_OBJECT_LOCKED') and
           lock_wait(l_start_time, l_lock_count) then
          --
          rollback to action_archinit_sp;
          lock_sleep;
        else
          raise;
        end if;
    end;
    --
  end loop;

  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end action_archinit;
--
-- ---------------------------------------------------------------------------
-- action_range_cursor
--
-- Description
-- Creates element links from the saved batch element links,
-- then returns the sql statement for the people processed.
--
-- ---------------------------------------------------------------------------
procedure action_range_cursor
  (p_payroll_action_id in         number
  ,p_sqlstr            out nocopy varchar2
  )
is
  l_start_time         date;
  l_lock_count         number:= 0;
  l_sql                varchar2(32000);
  l_link_id            number;
  l_proc               varchar2(72):= g_package||'action_range_cursor';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  --
  -- Initialize payroll action info.
  --
  init_ppa(p_payroll_action_id);

  --
  -- Loop until timeout setting allows for locking.
  --
  loop
    --
    begin
      --
      -- Issue a savepoint
      --
      savepoint action_range_cursor_sp;
      --
      -- Load the batch element links.
      --
      transfer_batch_links(g_pact_rec);
      --
      -- Initialize element link info and lock the element links.
      --
      init_links(g_pact_rec, 1);
      --
      -- If succeeded, exit the loop.
      --
      exit;
    exception
      when hr_api.object_locked then
        --
        if lock_wait(l_start_time, l_lock_count) then
          --
          rollback to action_range_cursor_sp;
          lock_sleep;
        else
          raise;
        end if;
        --
      when others then
        hr_message.provide_error;
        if (hr_message.last_message_name = 'HR_7165_OBJECT_LOCKED') and
           lock_wait(l_start_time, l_lock_count) then
          --
          rollback to action_range_cursor_sp;
          lock_sleep;
        else
          raise;
        end if;
    end;
    --
  end loop;

  --
  -- Create assignment actions only when there are element links
  -- to process.
  --
  if g_standard_links.count = 0 and
     g_pg_links.count = 0       then

    l_sql := 'select nvl(1,:payroll_action_id) from dual where 1 = 0';

  elsif g_pg_links.count > 0 then
    -- include non-emp assignments for ALUs.
    l_sql :=
'select distinct asg.person_id
 from
   pay_payroll_actions    ppa
  ,per_all_assignments_f  asg
 where
     ppa.payroll_action_id = :payroll_action_id
 and asg.business_group_id = ppa.business_group_id
 and (asg.assignment_type = ''E''
      or (asg.people_group_id is not null
          and asg.assignment_type not in (''A'',''O'')))
 order by asg.person_id';

  else
    l_sql :=
'select distinct asg.person_id
 from
   pay_payroll_actions    ppa
  ,per_all_assignments_f  asg
  ,per_periods_of_service pos
 where
     ppa.payroll_action_id = :payroll_action_id
 and asg.business_group_id = ppa.business_group_id
 and pos.person_id         = asg.person_id
 and pos.period_of_service_id = asg.period_of_service_id
 and pos.business_group_id = ppa.business_group_id
 order by asg.person_id';
  --
  end if;

  p_sqlstr := l_sql;

  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end action_range_cursor;

-- ---------------------------------------------------------------------------
-- action_action_creation
--
-- Description:
--   Creates assignment actions.
--
-- ---------------------------------------------------------------------------
procedure action_action_creation
  (p_payroll_action_id in number
  ,p_start_person_id   in number
  ,p_end_person_id     in number
  ,p_chunk             in number
  )
is
  --
  l_asgact_id         number;
  l_creating_alu_flag varchar2(1);
  --
  cursor csr_asg
    (p_stperson          in number
    ,p_endperson         in number
    ,p_bgid              in number
    ,p_creating_alu_flag in varchar2
    )
  is
  select distinct
    paf.assignment_id
   ,paf.person_id
  from
    per_periods_of_service     pos
   ,per_all_assignments_f      paf
  where
      pos.person_id between p_stperson and p_endperson
  and pos.business_group_id = p_bgid
  and paf.period_of_service_id = pos.period_of_service_id
  and p_creating_alu_flag = 'N'
  --
  union all
  -- We should handle all assignment types for ALUs.
  select distinct
    paf.assignment_id
   ,paf.person_id
  from
    per_all_assignments_f      paf
  where
      paf.person_id between p_stperson and p_endperson
  and paf.business_group_id = p_bgid
  and (paf.assignment_type = 'E'
       or (paf.people_group_id is not null
           and paf.assignment_type not in ('A','O')))
  and p_creating_alu_flag = 'Y'
  order by 1, 2;
  --
  l_proc               varchar2(72):= g_package||'action_action_creation';
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Initialize payroll action info.
  --
  init_ppa(p_payroll_action_id);

  --
  -- Initialize element link info.
  --
  init_links(g_pact_rec, 2);

  if g_pg_links.count > 0 then
    l_creating_alu_flag := 'Y';
  else
    l_creating_alu_flag := 'N';
  end if;

  --
  for l_asg in csr_asg
                 (p_start_person_id
                 ,p_end_person_id
                 ,g_pact_rec.business_group_id
                 ,l_creating_alu_flag
                 )
  loop
    --
    select pay_assignment_actions_s.nextval into l_asgact_id
    from dual;
    --
    -- Create assignment action.
    --
    hr_nonrun_asact.insact
      (l_asgact_id
      ,l_asg.assignment_id
      ,p_payroll_action_id
      ,p_chunk
      ,null
      ,null
      ,'U'
      ,null);

    --
  end loop;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end action_action_creation;
--
-- ---------------------------------------------------------------------------
-- asg_action_main
--
-- Description:
-- Assignment action level main process.
-- Creates ALUs and standard link entries.
-- ---------------------------------------------------------------------------
procedure asg_action_main
  (p_assignment_id  in number
  )
is
  l_link  t_element_link_rec;
  l_proc               varchar2(72):= g_package||'asg_action_main';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  -- Populate ALUs
  --
  if g_pg_links.count > 0 then

    pay_asg_link_usages_pkg.create_alu_asg
      (p_assignment_id             => p_assignment_id
      ,p_pg_link_tab               => g_pg_links
      );
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Populate element entries
  --
  for i in 1..g_standard_links.count loop
    --
    l_link := g_standard_links(i);
    --
    hrentmnt.maintain_entries_el
      (p_business_group_id         => g_pact_rec.business_group_id
      ,p_element_link_id           => l_link.element_link_id
      ,p_element_type_id           => l_link.element_type_id
      ,p_effective_start_date      => l_link.effective_start_date
      ,p_effective_end_date        => l_link.effective_end_date
      ,p_payroll_id                => l_link.payroll_id
      ,p_link_to_all_payrolls_flag => l_link.link_to_all_payrolls_flag
      ,p_job_id                    => l_link.job_id
      ,p_grade_id                  => l_link.grade_id
      ,p_position_id               => l_link.position_id
      ,p_organization_id           => l_link.organization_id
      ,p_location_id               => l_link.location_id
      ,p_pay_basis_id              => l_link.pay_basis_id
      ,p_employment_category       => l_link.employment_category
      ,p_people_group_id           => l_link.people_group_id
      ,p_assignment_id             => p_assignment_id
      );

  end loop;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end asg_action_main;
--
-- ---------------------------------------------------------------------------
-- action_archive_data
--
-- Description:
--   Archiver assignment process.
--
-- ---------------------------------------------------------------------------
procedure action_archive_data
  (p_assactid       in number
  ,p_effective_date in date
  )
is
  l_asgid              number;
  l_start_time         date;
  l_lock_count         number:= 0;
  l_proc               varchar2(72):= g_package||'action_archive_data';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  select assignment_id into l_asgid
  from pay_assignment_actions
  where assignment_action_id = p_assactid;

  --
  -- Loop until timeout setting allows for locking.
  --
  loop
    --
    begin
      --
      -- Issue a savepoint
      --
      savepoint action_archive_data_sp;
      --
      -- Asg action level main process
      --
      asg_action_main(l_asgid);
      --
      -- If succeeded, exit the loop.
      --
      exit;
    exception
      when hr_api.object_locked then
        --
        if lock_wait(l_start_time, l_lock_count) then
          --
          rollback to action_archive_data_sp;
          lock_sleep;
        else
          raise;
        end if;
        --
      when others then
        hr_message.provide_error;
        if hr_message.last_message_name = 'HR_7165_OBJECT_LOCKED' and
           lock_wait(l_start_time, l_lock_count) then
          --
          rollback to action_archive_data_sp;
          lock_sleep;
        else
          raise;
        end if;
    end;
    --
  end loop;
  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end action_archive_data;
--
-- ---------------------------------------------------------------------------
-- action_deinit
--
-- Description:
--   Deinitialize the payroll action.
--
-- ---------------------------------------------------------------------------
procedure action_deinit
  (p_payroll_action_id in number)
is
  --
  cursor csr_action_status
  is
  select 'I'
  from dual
  where exists
          (select null
           from pay_assignment_actions paa
           where paa.payroll_action_id = p_payroll_action_id
           and paa.action_status <> 'C')
  union all
  select ppa.action_status
  from pay_payroll_actions ppa
  where ppa.payroll_action_id = p_payroll_action_id
  ;
  --
  l_pact_id    number;
  l_status     varchar2(5);
  l_remove_act varchar2(30);
  l_count      number;
  --
  l_proc               varchar2(72):= g_package||'action_deinit';
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 5);
  --
  select
    pay_core_utils.get_parameter
      ('REMOVE_ACT', legislative_parameters) remove_act
  into l_remove_act
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id
  ;

  open csr_action_status;
  fetch csr_action_status into l_status;
  close csr_action_status;
  --
  pay_core_utils.assert_condition
      (l_proc||':1'
      ,(l_status in ('I','C','E'))
      );
  --
  l_pact_id := p_payroll_action_id;

  --
  -- Check batch transfer error
  --
  if g_err_batch_link_id is not null then
    --
    -- Reset the batch line status that were rolled back.
    --
    for i in 1..g_batch_links.count loop
      --
      begin
        if g_batch_links(i) = g_err_batch_link_id then
          pay_batch_object_status_pkg.set_status
            (p_object_type       => 'BEL'
            ,p_object_id         => g_err_batch_link_id
            ,p_object_status     => 'E'
            ,p_payroll_action_id => p_payroll_action_id
            );
        else
          pay_batch_object_status_pkg.set_status
            (p_object_type       => 'BEL'
            ,p_object_id         => g_batch_links(i)
            ,p_object_status     => 'U'
            ,p_payroll_action_id => p_payroll_action_id
            );
        end if;
      exception
        when others then
          -- Because the batch transfer might have failed due to
          -- locking, this update could fail in that case.
          -- We can ignore errors here.
          null;
      end;
    end loop;
    --
  end if;

  if l_status='C' and nvl(l_remove_act,'Y')='Y' then
    --
    pay_archive.remove_report_actions(p_payroll_action_id);

    --
    -- Delete the object status records.
    --
    delete from pay_batch_object_status
    where payroll_action_id = p_payroll_action_id
    and object_status in ('P', 'C')
    ;
    --
    -- Unset payroll action id for other status.
    --
    update pay_batch_object_status
    set payroll_action_id = null
    where payroll_action_id = p_payroll_action_id
    ;
  elsif l_status in ('C','I') then
    --
    -- Update the status for the processing records.
    --
    update pay_batch_object_status
    set object_status = l_status
    where payroll_action_id = p_payroll_action_id
    and object_status = 'P'
    ;
  else
    --
    -- Ensure there is no processing records just in case.
    --
    select count(1) into l_count
    from pay_batch_object_status
    where payroll_action_id = p_payroll_action_id
    and object_status = 'P'
    ;
    --
    pay_core_utils.assert_condition
        (l_proc||':2'
        ,(l_count = 0)
        );
  end if;

  --
  hr_utility.set_location('Leaving: '||l_proc, 100);
  --
end action_deinit;
--

end pay_batch_link_process_pkg;

/
