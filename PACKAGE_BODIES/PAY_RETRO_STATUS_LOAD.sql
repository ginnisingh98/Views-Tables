--------------------------------------------------------
--  DDL for Package Body PAY_RETRO_STATUS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RETRO_STATUS_LOAD" as
/* $Header: pyrtsupl.pkb 120.4.12010000.1 2008/11/19 09:02:48 nerao ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_retro_status_load.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< load_retro_asg_and_entries >----------------------|
-- ----------------------------------------------------------------------------
procedure load_retro_asg_and_entries
  (p_assignment_id                 in     number
  ,p_reprocess_date                in     date
  ,p_approval_status               in     varchar2 default null
  ,p_retro_entry_tab               in     t_retro_entry_tab
  ,p_retro_assignment_id              out nocopy   number
  )
is
  l_proc                varchar2(72) := g_package||'load_retro_asg_and_entries';
  l_retro_assignment_id number;
  l_retro_entry_rec     t_retro_entry_rec;
  l_idx                 binary_integer;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint load_retro_asg_and_entries;

  l_idx := p_retro_entry_tab.first;

  --
  -- Create a superseding retro assignment.
  --
  pay_retro_status_internal.create_super_retro_asg
    (p_assignment_id                 => p_assignment_id
    ,p_reprocess_date                => p_reprocess_date
    ,p_start_date                    => null
    ,p_approval_status               => p_approval_status
    ,p_owner_type                    => pay_retro_status_internal.g_user
    ,p_retro_assignment_id           => l_retro_assignment_id
    );

  loop
    exit when not p_retro_entry_tab.exists(l_idx);
    l_retro_entry_rec := p_retro_entry_tab(l_idx);
    --
    -- Create or update the retro entry.
    --
    pay_retro_status_internal.maintain_retro_entry
      (p_retro_assignment_id           => l_retro_assignment_id
      ,p_element_entry_id              => l_retro_entry_rec.element_entry_id
      ,p_reprocess_date                => l_retro_entry_rec.reprocess_date
      ,p_retro_component_id            => l_retro_entry_rec.retro_component_id
      ,p_owner_type                    => pay_retro_status_internal.g_user
      ,p_system_reprocess_date         => null
      ,p_entry_param_name              => 'ENTRY'||l_idx
      );

    l_idx := p_retro_entry_tab.next(l_idx);
  end loop;

  --
  -- Set out variables
  --
  p_retro_assignment_id := l_retro_assignment_id;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to load_retro_asg_and_entries;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end load_retro_asg_and_entries;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_assignment_id >---------------------------|
-- ----------------------------------------------------------------------------
function get_assignment_id
  (p_business_group_id             in     number
  ,p_assignment_number             in     varchar2
  ,p_full_name                     in     varchar2 default null
  ) return number
is
  l_assignment_id    number;
begin
  begin
    select distinct paf.assignment_id
    into l_assignment_id
    from
      per_all_assignments_f paf
     ,per_all_people_f      ppf
    where
        paf.assignment_number = p_assignment_number
    and paf.business_group_id+0 = p_business_group_id
    and ppf.person_id = paf.person_id
    and paf.effective_start_date between ppf.effective_start_date
                                     and ppf.effective_end_date
    and nvl(ppf.full_name, hr_api.g_varchar2)
         = nvl(p_full_name, nvl(ppf.full_name, hr_api.g_varchar2))
    ;
  exception
    when no_data_found then
      --
      -- No assignment found for this assignment number (and full name).
      --
      fnd_message.set_name('PAY','PAY_34308_RTS_NO_ASG_FOUND');
      fnd_message.raise_error;
      --
    when too_many_rows then
      --
      -- More than one assignment found for this assignment number.
      --
      fnd_message.set_name('PAY','PAY_34309_RTS_MANY_ASG_FOUND');
      fnd_message.raise_error;
      --
  end;
  --
  return l_assignment_id;

end get_assignment_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_retro_entry_rec >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_retro_entry_rec
  (p_entry_number                  in     number
  ,p_business_group_id             in     number
  ,p_assignment_id                 in     number
  ,p_element_name                  in     varchar2
  ,p_element_entry_id              in     number
  ,p_reprocess_date                in     date
  ,p_component_name                in     varchar2
  ,p_retro_entry_rec                  out nocopy   t_retro_entry_rec
  ,p_values_set                       out nocopy   boolean
  )
is
  l_proc                varchar2(72) := g_package||'get_retro_entry_rec';
  l_element_entry_id    number;
  l_retro_component_id  number;
  l_rec                 t_retro_entry_rec;
  l_leg_code            varchar2(5);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- If element_name and element_entry_id are both null, this record is ignored.
  -- Setting values_set flag to False and exit immediately.
  --
  if     (p_element_name is null)
     and (p_element_entry_id is null) then
    --
    hr_utility.set_location(l_proc, 20);
    p_values_set := false;
    return;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Identify element entry id.
  --
  l_leg_code := hr_api.return_legislation_code(p_business_group_id);

  if p_element_entry_id is not null then
    l_element_entry_id := p_element_entry_id;
  else
    --
    -- Derive the element entry id from the element name.
    --
    begin
      select distinct pee.element_entry_id
      into   l_element_entry_id
      from
        pay_element_types_f_tl pettl
       ,pay_element_types_f    pet
       ,pay_element_links_f    pel
       ,pay_element_entries_f  pee
      where
          pettl.element_name = p_element_name
      and pettl.language     = userenv('lang')
      and pet.element_type_id = pettl.element_type_id
      and nvl(pet.business_group_id, p_business_group_id) = p_business_group_id
      and nvl(pet.legislation_code, l_leg_code) = l_leg_code
      and pel.element_type_id = pet.element_type_id
      and pel.business_group_id+0 = p_business_group_id
      and pee.assignment_id       = p_assignment_id
      and pee.element_link_id     = pel.element_link_id
      and pee.creator_type in ('A', 'F', 'H', 'Q', 'SP', 'UT', 'M', 'S')
      ;

    exception
      when no_data_found then
        --
        -- No entry found for this assignment.
        --
        fnd_message.set_name('PAY','PAY_34310_RTS_NO_ENT_FOUND');
        fnd_message.set_token('ELEMENT_NAME', p_element_name);
        fnd_message.raise_error;
        --
      when too_many_rows then
        --
        -- More thant one entry found for this assignment.
        --
        fnd_message.set_name('PAY','PAY_34311_RTS_MANY_ENT_FOUND');
        fnd_message.set_token('ELEMENT_NAME', p_element_name);
        fnd_message.raise_error;
        --
    end;
  end if;
  --
  -- Identify retro component id.
  --
  if p_component_name is not null then
    begin
      select
        retro_component_id into l_retro_component_id
      from pay_retro_components
      where
          component_name = p_component_name
      and nvl(legislation_code, l_leg_code) = l_leg_code;
    exception
      when no_data_found then
        fnd_message.set_name('PAY','PAY_33167_RCU_INV_RETRO_COMP');
        fnd_message.raise_error;
    end;
  end if;
  --
  -- Set the retro entry record.
  --
  l_rec.element_entry_id     := l_element_entry_id;
  l_rec.reprocess_date       := p_reprocess_date;
  l_rec.retro_component_id   := l_retro_component_id;

  --
  -- Set out variables.
  --
  p_retro_entry_rec          := l_rec;
  p_values_set               := true;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
end get_retro_entry_rec;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_retro_entry_tab >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_retro_entry_tab
  (p_business_group_id             in     number
  ,p_assignment_id                 in     number
  --
  ,p_entry1_element_name           in     varchar2 default null
  ,p_entry1_element_entry_id       in     number   default null
  ,p_entry1_reprocess_date         in     date     default null
  ,p_entry1_component_name         in     varchar2 default null
  --
  ,p_entry2_element_name           in     varchar2 default null
  ,p_entry2_element_entry_id       in     number   default null
  ,p_entry2_reprocess_date         in     date     default null
  ,p_entry2_component_name         in     varchar2 default null
  --
  ,p_entry3_element_name           in     varchar2 default null
  ,p_entry3_element_entry_id       in     number   default null
  ,p_entry3_reprocess_date         in     date     default null
  ,p_entry3_component_name         in     varchar2 default null
  --
  ,p_entry4_element_name           in     varchar2 default null
  ,p_entry4_element_entry_id       in     number   default null
  ,p_entry4_reprocess_date         in     date     default null
  ,p_entry4_component_name         in     varchar2 default null
  --
  ,p_entry5_element_name           in     varchar2 default null
  ,p_entry5_element_entry_id       in     number   default null
  ,p_entry5_reprocess_date         in     date     default null
  ,p_entry5_component_name         in     varchar2 default null
  --
  ,p_entry6_element_name           in     varchar2 default null
  ,p_entry6_element_entry_id       in     number   default null
  ,p_entry6_reprocess_date         in     date     default null
  ,p_entry6_component_name         in     varchar2 default null
  --
  ,p_entry7_element_name           in     varchar2 default null
  ,p_entry7_element_entry_id       in     number   default null
  ,p_entry7_reprocess_date         in     date     default null
  ,p_entry7_component_name         in     varchar2 default null
  --
  ,p_entry8_element_name           in     varchar2 default null
  ,p_entry8_element_entry_id       in     number   default null
  ,p_entry8_reprocess_date         in     date     default null
  ,p_entry8_component_name         in     varchar2 default null
  --
  ,p_entry9_element_name           in     varchar2 default null
  ,p_entry9_element_entry_id       in     number   default null
  ,p_entry9_reprocess_date         in     date     default null
  ,p_entry9_component_name         in     varchar2 default null
  --
  ,p_entry10_element_name          in     varchar2 default null
  ,p_entry10_element_entry_id      in     number   default null
  ,p_entry10_reprocess_date        in     date     default null
  ,p_entry10_component_name        in     varchar2 default null
  --
  ,p_entry11_element_name          in     varchar2 default null
  ,p_entry11_element_entry_id      in     number   default null
  ,p_entry11_reprocess_date        in     date     default null
  ,p_entry11_component_name        in     varchar2 default null
  --
  ,p_entry12_element_name          in     varchar2 default null
  ,p_entry12_element_entry_id      in     number   default null
  ,p_entry12_reprocess_date        in     date     default null
  ,p_entry12_component_name        in     varchar2 default null
  --
  ,p_entry13_element_name          in     varchar2 default null
  ,p_entry13_element_entry_id      in     number   default null
  ,p_entry13_reprocess_date        in     date     default null
  ,p_entry13_component_name        in     varchar2 default null
  --
  ,p_entry14_element_name          in     varchar2 default null
  ,p_entry14_element_entry_id      in     number   default null
  ,p_entry14_reprocess_date        in     date     default null
  ,p_entry14_component_name        in     varchar2 default null
  --
  ,p_entry15_element_name          in     varchar2 default null
  ,p_entry15_element_entry_id      in     number   default null
  ,p_entry15_reprocess_date        in     date     default null
  ,p_entry15_component_name        in     varchar2 default null
  --
  ,p_retro_entry_tab                  out nocopy   t_retro_entry_tab
  )
is
  l_proc                varchar2(72) := g_package||'get_retro_entry_tab';
  l_retro_entry_rec     t_retro_entry_rec;
  l_retro_entry_tab     t_retro_entry_tab;
  l_values_set          boolean;
  l_idx                 number:= 0;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Entry 1
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 1
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry1_element_name
    ,p_element_entry_id              => p_entry1_element_entry_id
    ,p_reprocess_date                => p_entry1_reprocess_date
    ,p_component_name                => p_entry1_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(1) := l_retro_entry_rec;
  end if;

  --
  -- Entry 2
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 2
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry2_element_name
    ,p_element_entry_id              => p_entry2_element_entry_id
    ,p_reprocess_date                => p_entry2_reprocess_date
    ,p_component_name                => p_entry2_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(2) := l_retro_entry_rec;
  end if;

  --
  -- Entry 3
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 3
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry3_element_name
    ,p_element_entry_id              => p_entry3_element_entry_id
    ,p_reprocess_date                => p_entry3_reprocess_date
    ,p_component_name                => p_entry3_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(3) := l_retro_entry_rec;
  end if;

  --
  -- Entry 4
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 4
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry4_element_name
    ,p_element_entry_id              => p_entry4_element_entry_id
    ,p_reprocess_date                => p_entry4_reprocess_date
    ,p_component_name                => p_entry4_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(4) := l_retro_entry_rec;
  end if;

  --
  -- Entry 5
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 5
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry5_element_name
    ,p_element_entry_id              => p_entry5_element_entry_id
    ,p_reprocess_date                => p_entry5_reprocess_date
    ,p_component_name                => p_entry5_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(5) := l_retro_entry_rec;
  end if;

  --
  -- Entry 6
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 6
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry6_element_name
    ,p_element_entry_id              => p_entry6_element_entry_id
    ,p_reprocess_date                => p_entry6_reprocess_date
    ,p_component_name                => p_entry6_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(6) := l_retro_entry_rec;
  end if;

  --
  -- Entry 7
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 7
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry7_element_name
    ,p_element_entry_id              => p_entry7_element_entry_id
    ,p_reprocess_date                => p_entry7_reprocess_date
    ,p_component_name                => p_entry7_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(7) := l_retro_entry_rec;
  end if;

  --
  -- Entry 8
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 8
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry8_element_name
    ,p_element_entry_id              => p_entry8_element_entry_id
    ,p_reprocess_date                => p_entry8_reprocess_date
    ,p_component_name                => p_entry8_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(8) := l_retro_entry_rec;
  end if;

  --
  -- Entry 9
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 9
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry9_element_name
    ,p_element_entry_id              => p_entry9_element_entry_id
    ,p_reprocess_date                => p_entry9_reprocess_date
    ,p_component_name                => p_entry9_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(9) := l_retro_entry_rec;
  end if;

  --
  -- Entry 10
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 10
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry10_element_name
    ,p_element_entry_id              => p_entry10_element_entry_id
    ,p_reprocess_date                => p_entry10_reprocess_date
    ,p_component_name                => p_entry10_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(10) := l_retro_entry_rec;
  end if;

  --
  -- Entry 11
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 11
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry11_element_name
    ,p_element_entry_id              => p_entry11_element_entry_id
    ,p_reprocess_date                => p_entry11_reprocess_date
    ,p_component_name                => p_entry11_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(11) := l_retro_entry_rec;
  end if;

  --
  -- Entry 12
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 12
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry12_element_name
    ,p_element_entry_id              => p_entry12_element_entry_id
    ,p_reprocess_date                => p_entry12_reprocess_date
    ,p_component_name                => p_entry12_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(12) := l_retro_entry_rec;
  end if;

  --
  -- Entry 13
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 13
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry13_element_name
    ,p_element_entry_id              => p_entry13_element_entry_id
    ,p_reprocess_date                => p_entry13_reprocess_date
    ,p_component_name                => p_entry13_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(13) := l_retro_entry_rec;
  end if;

  --
  -- Entry 14
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 14
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry14_element_name
    ,p_element_entry_id              => p_entry14_element_entry_id
    ,p_reprocess_date                => p_entry14_reprocess_date
    ,p_component_name                => p_entry14_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(14) := l_retro_entry_rec;
  end if;

  --
  -- Entry 15
  --
  l_values_set := false;
  get_retro_entry_rec
    (p_entry_number                  => 15
    ,p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => p_assignment_id
    ,p_element_name                  => p_entry15_element_name
    ,p_element_entry_id              => p_entry15_element_entry_id
    ,p_reprocess_date                => p_entry15_reprocess_date
    ,p_component_name                => p_entry15_component_name
    ,p_retro_entry_rec               => l_retro_entry_rec
    ,p_values_set                    => l_values_set
    );
  if l_values_set then
    l_retro_entry_tab(15) := l_retro_entry_rec;
  end if;

  --
  -- Set out variable.
  --
  p_retro_entry_tab := l_retro_entry_tab;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
end get_retro_entry_tab;
--
-- ----------------------------------------------------------------------------
-- |----------------------< load_retro_asg_and_entries >----------------------|
-- ----------------------------------------------------------------------------
procedure load_retro_asg_and_entries
  (p_business_group_id             in     number
  ,p_assignment_number             in     varchar2
  ,p_full_name                     in     varchar2 default null
  ,p_reprocess_date                in     date
  ,p_approval_status               in     varchar2 default null
  --
  ,p_entry1_element_name           in     varchar2 default null
  ,p_entry1_element_entry_id       in     number   default null
  ,p_entry1_reprocess_date         in     date     default null
  ,p_entry1_component_name         in     varchar2 default null
  --
  ,p_entry2_element_name           in     varchar2 default null
  ,p_entry2_element_entry_id       in     number   default null
  ,p_entry2_reprocess_date         in     date     default null
  ,p_entry2_component_name         in     varchar2 default null
  --
  ,p_entry3_element_name           in     varchar2 default null
  ,p_entry3_element_entry_id       in     number   default null
  ,p_entry3_reprocess_date         in     date     default null
  ,p_entry3_component_name         in     varchar2 default null
  --
  ,p_entry4_element_name           in     varchar2 default null
  ,p_entry4_element_entry_id       in     number   default null
  ,p_entry4_reprocess_date         in     date     default null
  ,p_entry4_component_name         in     varchar2 default null
  --
  ,p_entry5_element_name           in     varchar2 default null
  ,p_entry5_element_entry_id       in     number   default null
  ,p_entry5_reprocess_date         in     date     default null
  ,p_entry5_component_name         in     varchar2 default null
  --
  ,p_entry6_element_name           in     varchar2 default null
  ,p_entry6_element_entry_id       in     number   default null
  ,p_entry6_reprocess_date         in     date     default null
  ,p_entry6_component_name         in     varchar2 default null
  --
  ,p_entry7_element_name           in     varchar2 default null
  ,p_entry7_element_entry_id       in     number   default null
  ,p_entry7_reprocess_date         in     date     default null
  ,p_entry7_component_name         in     varchar2 default null
  --
  ,p_entry8_element_name           in     varchar2 default null
  ,p_entry8_element_entry_id       in     number   default null
  ,p_entry8_reprocess_date         in     date     default null
  ,p_entry8_component_name         in     varchar2 default null
  --
  ,p_entry9_element_name           in     varchar2 default null
  ,p_entry9_element_entry_id       in     number   default null
  ,p_entry9_reprocess_date         in     date     default null
  ,p_entry9_component_name         in     varchar2 default null
  --
  ,p_entry10_element_name          in     varchar2 default null
  ,p_entry10_element_entry_id      in     number   default null
  ,p_entry10_reprocess_date        in     date     default null
  ,p_entry10_component_name        in     varchar2 default null
  --
  ,p_entry11_element_name          in     varchar2 default null
  ,p_entry11_element_entry_id      in     number   default null
  ,p_entry11_reprocess_date        in     date     default null
  ,p_entry11_component_name        in     varchar2 default null
  --
  ,p_entry12_element_name          in     varchar2 default null
  ,p_entry12_element_entry_id      in     number   default null
  ,p_entry12_reprocess_date        in     date     default null
  ,p_entry12_component_name        in     varchar2 default null
  --
  ,p_entry13_element_name          in     varchar2 default null
  ,p_entry13_element_entry_id      in     number   default null
  ,p_entry13_reprocess_date        in     date     default null
  ,p_entry13_component_name        in     varchar2 default null
  --
  ,p_entry14_element_name          in     varchar2 default null
  ,p_entry14_element_entry_id      in     number   default null
  ,p_entry14_reprocess_date        in     date     default null
  ,p_entry14_component_name        in     varchar2 default null
  --
  ,p_entry15_element_name          in     varchar2 default null
  ,p_entry15_element_entry_id      in     number   default null
  ,p_entry15_reprocess_date        in     date     default null
  ,p_entry15_component_name        in     varchar2 default null
  --
  ,p_retro_assignment_id              out nocopy   number
  )
is
  l_proc                varchar2(72) := g_package||'load_retro_asg_and_entries';
  l_retro_assignment_id number;
  l_assignment_id       number;
  l_retro_entry_tab     t_retro_entry_tab;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_number'
    ,p_argument_value => p_assignment_number
    );

  --
  -- Validate business group.
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_business_group_id
    );
  --
  -- Get assignment id.
  --
  l_assignment_id := get_assignment_id
                       (p_business_group_id => p_business_group_id
                       ,p_assignment_number => p_assignment_number
                       ,p_full_name         => p_full_name
                       );
  --
  -- Get the retro entry table.
  --
  get_retro_entry_tab
    (p_business_group_id             => p_business_group_id
    ,p_assignment_id                 => l_assignment_id
    --
    ,p_entry1_element_name           => p_entry1_element_name
    ,p_entry1_element_entry_id       => p_entry1_element_entry_id
    ,p_entry1_reprocess_date         => p_entry1_reprocess_date
    ,p_entry1_component_name         => p_entry1_component_name
    --
    ,p_entry2_element_name           => p_entry2_element_name
    ,p_entry2_element_entry_id       => p_entry2_element_entry_id
    ,p_entry2_reprocess_date         => p_entry2_reprocess_date
    ,p_entry2_component_name         => p_entry2_component_name
    --
    ,p_entry3_element_name           => p_entry3_element_name
    ,p_entry3_element_entry_id       => p_entry3_element_entry_id
    ,p_entry3_reprocess_date         => p_entry3_reprocess_date
    ,p_entry3_component_name         => p_entry3_component_name
    --
    ,p_entry4_element_name           => p_entry4_element_name
    ,p_entry4_element_entry_id       => p_entry4_element_entry_id
    ,p_entry4_reprocess_date         => p_entry4_reprocess_date
    ,p_entry4_component_name         => p_entry4_component_name
    --
    ,p_entry5_element_name           => p_entry5_element_name
    ,p_entry5_element_entry_id       => p_entry5_element_entry_id
    ,p_entry5_reprocess_date         => p_entry5_reprocess_date
    ,p_entry5_component_name         => p_entry5_component_name
    --
    ,p_entry6_element_name           => p_entry6_element_name
    ,p_entry6_element_entry_id       => p_entry6_element_entry_id
    ,p_entry6_reprocess_date         => p_entry6_reprocess_date
    ,p_entry6_component_name         => p_entry6_component_name
    --
    ,p_entry7_element_name           => p_entry7_element_name
    ,p_entry7_element_entry_id       => p_entry7_element_entry_id
    ,p_entry7_reprocess_date         => p_entry7_reprocess_date
    ,p_entry7_component_name         => p_entry7_component_name
    --
    ,p_entry8_element_name           => p_entry8_element_name
    ,p_entry8_element_entry_id       => p_entry8_element_entry_id
    ,p_entry8_reprocess_date         => p_entry8_reprocess_date
    ,p_entry8_component_name         => p_entry8_component_name
    --
    ,p_entry9_element_name           => p_entry9_element_name
    ,p_entry9_element_entry_id       => p_entry9_element_entry_id
    ,p_entry9_reprocess_date         => p_entry9_reprocess_date
    ,p_entry9_component_name         => p_entry9_component_name
    --
    ,p_entry10_element_name          => p_entry10_element_name
    ,p_entry10_element_entry_id      => p_entry10_element_entry_id
    ,p_entry10_reprocess_date        => p_entry10_reprocess_date
    ,p_entry10_component_name        => p_entry10_component_name
    --
    ,p_entry11_element_name          => p_entry11_element_name
    ,p_entry11_element_entry_id      => p_entry11_element_entry_id
    ,p_entry11_reprocess_date        => p_entry11_reprocess_date
    ,p_entry11_component_name        => p_entry11_component_name
    --
    ,p_entry12_element_name          => p_entry12_element_name
    ,p_entry12_element_entry_id      => p_entry12_element_entry_id
    ,p_entry12_reprocess_date        => p_entry12_reprocess_date
    ,p_entry12_component_name        => p_entry12_component_name
    --
    ,p_entry13_element_name          => p_entry13_element_name
    ,p_entry13_element_entry_id      => p_entry13_element_entry_id
    ,p_entry13_reprocess_date        => p_entry13_reprocess_date
    ,p_entry13_component_name        => p_entry13_component_name
    --
    ,p_entry14_element_name          => p_entry14_element_name
    ,p_entry14_element_entry_id      => p_entry14_element_entry_id
    ,p_entry14_reprocess_date        => p_entry14_reprocess_date
    ,p_entry14_component_name        => p_entry14_component_name
    --
    ,p_entry15_element_name          => p_entry15_element_name
    ,p_entry15_element_entry_id      => p_entry15_element_entry_id
    ,p_entry15_reprocess_date        => p_entry15_reprocess_date
    ,p_entry15_component_name        => p_entry15_component_name
    --
    ,p_retro_entry_tab               => l_retro_entry_tab
    );

  --
  -- Call the table version of procedure.
  --
  load_retro_asg_and_entries
    (p_assignment_id                 => l_assignment_id
    ,p_reprocess_date                => p_reprocess_date
    ,p_approval_status               => p_approval_status
    ,p_retro_entry_tab               => l_retro_entry_tab
    ,p_retro_assignment_id           => l_retro_assignment_id
    );

  --
  -- Set out variables
  --
  p_retro_assignment_id := l_retro_assignment_id;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
end load_retro_asg_and_entries;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_or_delete_retro_asg >----------------------|
-- ----------------------------------------------------------------------------
procedure update_or_delete_retro_asg
  (p_business_group_id             in     number
  ,p_assignment_number             in     varchar2
  ,p_full_name                     in     varchar2 default null
  ,p_reprocess_date                in     date     default null
  ,p_approval_status               in     varchar2 default null
  ,p_update_or_delete_mode         in     varchar2 default g_update_mode
  )
is
  l_proc                varchar2(72) := g_package||'update_or_delete_retro_asg';
  l_retro_assignment_id   number;
  l_replaced_retro_asg_id number;
  l_assignment_id         number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );

  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_number'
    ,p_argument_value => p_assignment_number
    );

  --
  -- Validate business group.
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_business_group_id
    );
  --
  -- Get assignment id.
  --
  l_assignment_id := get_assignment_id
                       (p_business_group_id => p_business_group_id
                       ,p_assignment_number => p_assignment_number
                       ,p_full_name         => p_full_name
                       );

  l_retro_assignment_id := pay_retro_status_internal.get_unprocessed_retro_asg
                             (p_assignment_id => l_assignment_id);

  if l_retro_assignment_id is null then
    --
    -- No unprocessed retro assignment is found.
    --
    fnd_message.set_name('PAY','PAY_34312_RTS_NO_RTA_FOUND');
    fnd_message.raise_error;
    --
  end if;

  if p_update_or_delete_mode = g_update_mode then
    --
    pay_retro_status_internal.update_retro_asg
      (p_retro_assignment_id  => l_retro_assignment_id
      ,p_reprocess_date       => nvl(p_reprocess_date, hr_api.g_date)
      ,p_approval_status      => nvl(p_approval_status, hr_api.g_varchar2)
      ,p_owner_type           => pay_retro_status_internal.g_user
      );
    --
  elsif p_update_or_delete_mode = g_delete_mode then
    --
    pay_retro_status_internal.delete_retro_asg
      (p_retro_assignment_id   => l_retro_assignment_id
      ,p_owner_type            => pay_retro_status_internal.g_user
      ,p_replaced_retro_asg_id => l_replaced_retro_asg_id
      );
  else
    --
    -- The upload mode is not either UPDATE or DELETE.
    -- Raise an assertion error.
    --
    pay_core_utils.assert_condition
      (l_proc||':chk_update_or_delete_mode' ,false);
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 80);
end update_or_delete_retro_asg;
--
procedure update_reprocess_date(
p_business_group_id               in     number
  ,p_assignment_number             in     varchar2
  ,p_full_name                     in     varchar2 default null
  ,p_reprocess_date                in     date
  ,p_new_retro_asg_id              out    nocopy number
  ) is

  --local variables.
  l_proc                varchar2(72) := g_package||'update_reprocess_date';
  l_assignment_id         number;

begin
  hr_utility.set_location('Entering : '|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_utility.set_location('Checking mandatory argument business_group_id : '|| l_proc, 15);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_business_group_id
    );

  hr_utility.set_location('Checking mandatory argument assignment_number : '|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'assignment_number'
    ,p_argument_value => p_assignment_number
    );
  hr_utility.set_location('Checking mandatory argument reprocess_date : '|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'reprocess_date'
    ,p_argument_value => p_reprocess_date
    );

   --
  -- Validate business group.
  --
  hr_utility.set_location('Validating business group : '|| l_proc, 40);
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_business_group_id
    );
  --
  -- Get assignment id.
  --
  hr_utility.set_location('Getting assignment id : '|| l_proc, 50);
  l_assignment_id := get_assignment_id
                       (p_business_group_id => p_business_group_id
                       ,p_assignment_number => p_assignment_number
                       ,p_full_name         => p_full_name
                       );

  hr_utility.set_location('Calling pay_retro_status_internal.update_reprocess_date : '|| l_proc, 60);
  pay_retro_status_internal.update_reprocess_date(
                            p_assignment_id   => l_assignment_id
                            ,p_reprocess_date => p_reprocess_date
			    ,p_retro_asg_id => p_new_retro_asg_id);

  hr_utility.set_location('Leaving:'|| l_proc, 100);

end update_reprocess_date;
--
end pay_retro_status_load;

/
