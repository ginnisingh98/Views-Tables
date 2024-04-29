--------------------------------------------------------
--  DDL for Package Body PAY_SET_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SET_BUS" as
/* $Header: pysetrhi.pkb 120.0 2005/05/29 08:39:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_set_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_template_info >--------------------------|
-- ----------------------------------------------------------------------------
Procedure get_template_info
  (p_template_id                 in            number
  ,p_business_group_id           in out nocopy number
  ,p_legislation_code            in out nocopy varchar2
  ,p_template_type               in out nocopy varchar2
  ,p_base_processing_priority    in out nocopy number
  ) is
  --
  -- Cursor to get the template information.
  --
  cursor csr_get_template_info is
  select pet.business_group_id
  ,      pet.legislation_code
  ,      pet.template_type
  ,      pet.base_processing_priority
  from   pay_element_templates pet
  where  pet.template_id = p_template_id;
--
  l_proc  varchar2(72) := g_package||'get_template_info';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_get_template_info;
  fetch csr_get_template_info
  into  p_business_group_id
  ,     p_legislation_code
  ,     p_template_type
  ,     p_base_processing_priority;
  close csr_get_template_info;
  if p_business_group_id is not null then
    p_legislation_code :=
    hr_api.return_legislation_code(p_business_group_id);
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End get_template_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
(p_rec in pay_set_shd.g_rec_type
) is
  --
  -- Cursor to disallow update if a core element has been generated from
  -- this shadow element.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  (tco.core_object_type = pay_tco_shd.g_set_lookup_type or
          tco.core_object_type = pay_tco_shd.g_spr_lookup_type)
  and    tco.shadow_object_id = p_rec.element_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_error exception;
  l_api_updating boolean;
  l_argument     varchar2(30);
  l_disallow     varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
    (p_element_type_id       => p_rec.element_type_id
    ,p_object_version_number => p_rec.object_version_number
    );
  if not l_api_updating then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '10');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that the update is actually allowed.
  --
  open csr_disallow_update;
  fetch csr_disallow_update into l_disallow;
  if csr_disallow_update%found then
    hr_utility.set_location(l_proc, 25);
    close csr_disallow_update;
    fnd_message.set_name('PAY', 'PAY_50137_SET_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- Check the otherwise non-updateable arguments.
  --
  -- p_template_id
  --
  if nvl(p_rec.template_id, hr_api.g_number) <>
     nvl(pay_set_shd.g_old_rec.template_id, hr_api.g_number)
  then
    l_argument := 'p_template_id';
    raise l_error;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 35);
exception
    when l_error then
       hr_utility.set_location('Leaving:'||l_proc, 40);
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       hr_utility.set_location('Leaving:'||l_proc, 45);
       raise;
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_template_id >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_template_id
  (p_template_id     in     number
  ) is
  --
  -- Cursor to check that template_id is valid.
  --
  cursor csr_template_id_valid is
  select null
  from   pay_element_templates pet
  where  pet.template_id = p_template_id;
  --
  l_proc  varchar2(72) := g_package||'chk_template_id';
  l_valid varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that template_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_template_id'
  ,p_argument_value => p_template_id
  );
  --
  -- Check that template_id is valid.
  --
  open csr_template_id_valid;
  fetch csr_template_id_valid into l_valid;
  if csr_template_id_valid%notfound then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_template_id_valid;
    fnd_message.set_name('PAY', 'PAY_50114_ETM_INVALID_TEMPLATE');
    fnd_message.raise_error;
  end if;
  close csr_template_id_valid;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_template_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_classification_name >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_classification_name
  (p_classification_name     in     varchar2
  ,p_element_type_id         in     number
  ,p_object_version_number   in     number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_classification_name';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
  (p_element_type_id       => p_element_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_classification_name, hr_api.g_varchar2) <>
      nvl(pay_set_shd.g_old_rec.classification_name, hr_api.g_varchar2)) or
     not l_api_updating
  then
    --
    -- Check that the classification name is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_classification_name'
    ,p_argument_value => p_classification_name
    );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_classification_name;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_lookups >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_lookups
  (p_effective_date                    in     date
  ,p_additional_entry_allowed_fla      in     varchar2
  ,p_adjustment_only_flag              in     varchar2
  ,p_closed_for_entry_flag             in     varchar2
  ,p_indirect_only_flag                in     varchar2
  ,p_multiple_entries_allowed_fla      in     varchar2
  ,p_multiply_value_flag               in     varchar2
  ,p_post_termination_rule             in     varchar2
  ,p_process_in_run_flag               in     varchar2
  ,p_processing_type                   in     varchar2
  ,p_standard_link_flag                in     varchar2
  ,p_qualifying_units                  in     varchar2
  ,p_third_party_pay_only_flag         in     varchar2
  ,p_iterative_flag                    in     varchar2
  ,p_grossup_flag                      in     varchar2
  ,p_advance_indicator                 in     varchar2
  ,p_advance_payable                   in     varchar2
  ,p_advance_deduction                 in     varchar2
  ,p_process_advance_entry             in     varchar2
  ,p_once_each_period_flag             in     varchar2
  ,p_element_type_id                   in     number
  ,p_object_version_number             in     number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_lookups';
  l_api_updating boolean;
--
  Procedure chk_lookup
    (p_effective_date                     in    date
    ,p_caller                             in    varchar2
    ,p_argument_name                      in    varchar2
    ,p_old_lookup_code                    in    varchar2
    ,p_lookup_code                        in    varchar2
    ,p_lookup_type                        in    varchar2
    ,p_mandatory                          in    boolean
    ,p_updatable                          in    boolean
    ,p_api_updating                       in    boolean
    ) is
  begin
    if (p_updatable  and p_api_updating and
        nvl(p_lookup_code, hr_api.g_varchar2) <>
        nvl(p_old_lookup_code, hr_api.g_varchar2)) or not p_api_updating
    then
      --
      -- Check that mandatory argument is not null.
      --
      if p_mandatory then
        hr_api.mandatory_arg_error
        (p_api_name       => p_caller
        ,p_argument       => p_argument_name
        ,p_argument_value => p_lookup_code
        );
      end if;
      --
      -- Exit if the argument is null, and not mandatory.
      --
      if not p_mandatory and p_lookup_code is null then
        return;
      end if;
      --
      -- Do the lookup check.
      --
      if hr_api.not_exists_in_hr_lookups
         (p_effective_date => p_effective_date
         ,p_lookup_type    => p_lookup_type
         ,p_lookup_code    => p_lookup_code
         )
      then
        fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
        fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
        fnd_message.set_token('COLUMN', upper(p_argument_name));
        fnd_message.raise_error;
      end if;
    end if;
  end chk_lookup;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
  (p_element_type_id       => p_element_type_id
  ,p_object_version_number => p_object_version_number
  );
  --
  -- additional_entry_allowed_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'additional_entry_allowed_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.additional_entry_allowed_flag
  ,p_lookup_code      => p_additional_entry_allowed_fla
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- adjustment_only_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'adjustment_only_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.adjustment_only_flag
  ,p_lookup_code      => p_adjustment_only_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- closed_for_entry_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'closed_for_entry_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.closed_for_entry_flag
  ,p_lookup_code      => p_closed_for_entry_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- indirect_only_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'indirect_only_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.indirect_only_flag
  ,p_lookup_code      => p_indirect_only_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- multiple_entries_allowed_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'multiple_entries_allowed_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.multiple_entries_allowed_flag
  ,p_lookup_code      => p_multiple_entries_allowed_fla
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- multiply_value_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'multiply_value_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.multiply_value_flag
  ,p_lookup_code      => p_multiply_value_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- post_termination_rule
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'post_termination_rule'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.post_termination_rule
  ,p_lookup_code      => p_post_termination_rule
  ,p_lookup_type      => 'TERMINATION_RULE'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- process_in_run_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'process_in_run_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.process_in_run_flag
  ,p_lookup_code      => p_process_in_run_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- processing_type
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'processing_type'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.processing_type
  ,p_lookup_code      => p_processing_type
  ,p_lookup_type      => 'PROCESSING_TYPE'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- standard_link_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'standard_link_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.standard_link_flag
  ,p_lookup_code      => p_standard_link_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- qualifying_units
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'qualifying_units'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.qualifying_units
  ,p_lookup_code      => p_qualifying_units
  ,p_lookup_type      => 'QUALIFYING_UNITS'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- third_party_pay_only_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'third_party_only_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.third_party_pay_only_flag
  ,p_lookup_code      => p_third_party_pay_only_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- iterative_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'iterative_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.iterative_flag
  ,p_lookup_code      => p_iterative_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- grossup_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'grossup_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.grossup_flag
  ,p_lookup_code      => p_grossup_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- advance_indicator
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'advance_indicator'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.advance_indicator
  ,p_lookup_code      => p_advance_indicator
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- advance_payable
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'advance_payable'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.advance_payable
  ,p_lookup_code      => p_advance_payable
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- advance_deduction
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'advance_deduction'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.advance_deduction
  ,p_lookup_code      => p_advance_deduction
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- process_advance_entry
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'process_advance_entry'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.process_advance_entry
  ,p_lookup_code      => p_process_advance_entry
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- once_each_period_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'once_each_period_flag'
  ,p_old_lookup_code  => pay_set_shd.g_old_rec.once_each_period_flag
  ,p_lookup_code      => p_once_each_period_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_lookups;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_element_name >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_element_name
  (p_element_name          in     varchar2
  ,p_template_id           in     number
  ,p_template_type         in     varchar2
  ,p_business_group_id     in     number
  ,p_element_type_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check that the element name is unique within a template
  -- (template_type = 'T').
  --
  cursor csr_T_element_name_exists is
    select null
    from   pay_shadow_element_types pset
    where  pset.template_id = p_template_id
    and    upper(nvl(pset.element_name, hr_api.g_varchar2)) =
           upper(nvl(p_element_name, hr_api.g_varchar2));
  --
  -- Cursor to check that the element name is unique for a business group
  -- (template type = 'U').
  --
  cursor csr_U_element_name_exists is
    select null
    from   pay_shadow_element_types pset
    ,      pay_element_templates    pet
    where  upper(pset.element_name) = upper(p_element_name)
    and    pet.template_id  = pset.template_id
    and    pet.template_type = 'U'
    and    pet.business_group_id = p_business_group_id;
--
  l_proc  varchar2(72) := g_package||'chk_element_name';
  l_legislation_code varchar2(2000);
  l_exists           varchar2(1);
  l_value            varchar2(2000);
  l_output           varchar2(2000);
  l_rgeflg           varchar2(2000);
  l_nullok           varchar2(2000);
  l_api_updating     boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
  (p_element_type_id       => p_element_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_element_name, hr_api.g_varchar2) <>
      nvl(pay_set_shd.g_old_rec.element_name, hr_api.g_varchar2)) or
      not l_api_updating
  then
    --
    -- Name cannot be null if the template type is 'U'.
    --
    if p_template_type = 'U' then
      l_nullok := 'N';
    else
      l_nullok := 'Y';
    end if;
    --
    -- Check that the name format is correct (payroll name).
    --
    l_value := p_element_name;
    if p_template_type = 'T' then
      --
      -- If template type is 'T' then the element name can begin
      -- with a space which is not the correct format.
      --
      l_value := replace(l_value, ' ', 'A');
    end if;
    hr_chkfmt.checkformat
    (value   => l_value
    ,format  => 'PAY_NAME'
    ,output  => l_output
    ,minimum => null
    ,maximum => null
    ,nullok  => l_nullok
    ,rgeflg  => l_rgeflg
    ,curcode => null
    );
    --
    -- Uniqueness checks.
    --
    if p_template_type = 'T' then
      --
      -- Check for uniqueness using the cursor.
      --
      open csr_T_element_name_exists;
      fetch csr_T_element_name_exists into l_exists;
      if csr_T_element_name_exists%found then
        close csr_T_element_name_exists;
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        fnd_message.set_name('PAY', 'PAY_50139_SET_ELEMENT_EXISTS');
        fnd_message.set_token('ELEMENT_NAME', p_element_name);
        fnd_message.raise_error;
      end if;
      close csr_T_element_name_exists;
    elsif p_template_type = 'U' then
      --
      -- Check for uniqueness using the cursor.
      --
      open csr_U_element_name_exists;
      fetch csr_U_element_name_exists into l_exists;
      if csr_U_element_name_exists%found then
        close csr_U_element_name_exists;
        hr_utility.set_location(' Leaving:'||l_proc, 15);
        fnd_message.set_name('PAY', 'PAY_50139_SET_ELEMENT_EXISTS');
        fnd_message.set_token('ELEMENT_NAME', p_element_name);
        fnd_message.raise_error;
      end if;
      close csr_U_element_name_exists;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_element_name;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_processing_priority >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_processing_priority
(p_relative_processing_priority in number
,p_base_processing_priority     in number
,p_element_type_id              in number
,p_object_version_number        in number
) is
--
  l_proc  varchar2(72) := g_package||'chk_processing_priority';
  l_api_updating boolean;
  l_lower constant number := 0;
  l_upper constant number := pay_etm_shd.g_max_processing_priority;
  l_too_large varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
    (p_element_type_id       => p_element_type_id
    ,p_object_version_number => p_object_version_number
    );
  --
  if (l_api_updating and
      nvl(pay_set_shd.g_old_rec.relative_processing_priority, hr_api.g_number)
      <> nvl(p_relative_processing_priority, hr_api.g_number)) or
     not l_api_updating
  then
    --
    -- Check that the priority is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_relative_processing_priority'
    ,p_argument_value => p_relative_processing_priority
    );
    --
    -- Check that the processing priority sum is within the allowable range.
    --
    if (p_relative_processing_priority < l_lower - p_base_processing_priority) or
       (p_relative_processing_priority > l_upper - p_base_processing_priority)
    then
      hr_utility.set_location(' Leaving:'||l_proc, 15);
      fnd_message.set_name('PAY', 'PAY_50140_SET_PRI_SUM_RANGE');
      fnd_message.set_token('PRIORITY', p_relative_processing_priority);
      fnd_message.set_token('LOWER', l_lower);
      fnd_message.set_token('UPPER', l_upper);
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_processing_priority;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_input_currency_code >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_input_currency_code
  (p_input_currency_code   in     varchar2
  ,p_element_type_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Check that the currency code is valid.
  --
  cursor csr_valid_currency_code is
  select null
  from   fnd_currencies fc
  where  upper(fc.currency_code) = upper(p_input_currency_code)
  and    fc.enabled_flag = 'Y'
  and    fc.currency_flag = 'Y';
--
  l_proc  varchar2(72) := g_package||'chk_input_currency_code';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
  (p_element_type_id       => p_element_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_input_currency_code, hr_api.g_varchar2) <>
      nvl(pay_set_shd.g_old_rec.input_currency_code, hr_api.g_varchar2)) or
     not l_api_updating
  then
    if p_input_currency_code is not null then
      open csr_valid_currency_code;
      fetch csr_valid_currency_code into l_valid;
      if csr_valid_currency_code%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        close csr_valid_currency_code;
        fnd_message.set_name('PAY', 'HR_51855_QUA_CCY_INV');
        fnd_message.raise_error;
      end if;
      close csr_valid_currency_code;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 15);
  end if;
End chk_input_currency_code;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_output_currency_code >---------------------|
-- ----------------------------------------------------------------------------
Procedure chk_output_currency_code
  (p_output_currency_code  in     varchar2
  ,p_element_type_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Check that the currency code is valid.
  --
  cursor csr_valid_currency_code is
  select null
  from   fnd_currencies fc
  where  upper(fc.currency_code) = upper(p_output_currency_code)
  and    fc.enabled_flag = 'Y'
  and    fc.currency_flag = 'Y';
--
  l_proc  varchar2(72) := g_package||'chk_output_currency_code';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
  (p_element_type_id       => p_element_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_output_currency_code, hr_api.g_varchar2) <>
      nvl(pay_set_shd.g_old_rec.output_currency_code, hr_api.g_varchar2)) or
     not l_api_updating
  then
    if p_output_currency_code is not null then
      open csr_valid_currency_code;
      fetch csr_valid_currency_code into l_valid;
      if csr_valid_currency_code%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        close csr_valid_currency_code;
        fnd_message.set_name('PAY', 'HR_51855_QUA_CCY_INV');
        fnd_message.raise_error;
      end if;
      close csr_valid_currency_code;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc, 15);
  end if;
End chk_output_currency_code;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_payroll_formula_id >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_payroll_formula_id
  (p_payroll_formula_id     in     number
  ,p_template_id            in     number
  ,p_template_type          in     varchar2
  ,p_business_group_id      in     number
  ,p_legislation_code       in     varchar2
  ,p_element_type_id        in     number
  ,p_object_version_number  in     number
  ) is
--
  --
  -- Check that the payroll formula is valid.
  --
  -- If the shadow element belongs to a template of type 'T' then the formula
  -- may be shared with other templates, but the legislative domain of the
  -- formula must encompass that of the template.
  cursor csr_T_formula_valid is
  select null
  from   pay_shadow_formulas sf
  where  sf.formula_id = p_payroll_formula_id
  and    sf.template_type = 'T'
  and    nvl(sf.formula_type_name,pay_sf_shd.g_payroll_formula_type) = pay_sf_shd.g_payroll_formula_type
  and    ((sf.legislation_code is null and sf.business_group_id is null) or
          sf.legislation_code = p_legislation_code or
          sf.business_group_id = p_business_group_id);
  --
  -- If the shadow element belongs to a template of type 'U' then the formula
  -- must not be shared with any other templates to avoid name clashes.
  --
  cursor csr_U_formula_valid is
  select null
  from   pay_shadow_formulas sf
  where  sf.formula_id = p_payroll_formula_id
  and    sf.template_type = 'U'
  and    nvl(sf.formula_type_name,pay_sf_shd.g_payroll_formula_type) = pay_sf_shd.g_payroll_formula_type
  and    sf.business_group_id = p_business_group_id
  and    not exists
         (select null
          from   pay_shadow_element_types pset
          where  pset.payroll_formula_id = p_payroll_formula_id
          and    pset.template_id <> p_template_id);
--
  l_proc  varchar2(72) := g_package||'chk_payroll_formula_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
  (p_element_type_id       => p_element_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_payroll_formula_id, hr_api.g_number) <>
      nvl(pay_set_shd.g_old_rec.payroll_formula_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_payroll_formula_id is not null then
      if p_template_type = 'T' then
        open csr_T_formula_valid;
        fetch csr_T_formula_valid into l_valid;
        if csr_T_formula_valid%notfound then
          hr_utility.set_location(' Leaving:'||l_proc, 10);
          close csr_T_formula_valid;
          fnd_message.set_name('PAY', 'PAY_50141_SET_BAD_PAY_FORMULA');
          fnd_message.raise_error;
        end if;
        close csr_T_formula_valid;
      elsif p_template_type = 'U' then
        open csr_U_formula_valid;
        fetch csr_U_formula_valid into l_valid;
        if csr_U_formula_valid%notfound then
          hr_utility.set_location(' Leaving:'||l_proc, 15);
          close csr_U_formula_valid;
          fnd_message.set_name('PAY', 'PAY_50141_SET_BAD_PAY_FORMULA');
          fnd_message.raise_error;
        end if;
        close csr_U_formula_valid;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_payroll_formula_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id     in     number
  ,p_template_id           in     number
  ,p_element_type_id       in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to check that the exclusion_rule_id is valid.
  --
  cursor csr_exclusion_rule_id_valid is
  select null
  from pay_template_exclusion_rules ter
  where ter.exclusion_rule_id = p_exclusion_rule_id
  and   ter.template_id = p_template_id;
--
  l_proc  varchar2(72) := g_package||'chk_exclusion_rule_id';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_set_shd.api_updating
  (p_element_type_id       => p_element_type_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_set_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
     not l_api_updating
  then
    if p_exclusion_rule_id is not null then
      open csr_exclusion_rule_id_valid;
      fetch csr_exclusion_rule_id_valid into l_valid;
      if csr_exclusion_rule_id_valid%notfound then
        hr_utility.set_location('Leaving:'||l_proc, 10);
        close csr_exclusion_rule_id_valid;
        fnd_message.set_name('PAY', 'PAY_50100_ETM_INVALID_EXC_RULE');
        fnd_message.raise_error;
      end if;
      close csr_exclusion_rule_id_valid;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_exclusion_rule_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_iterative_flag >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_iterative_flag
  (p_iterative_flag  in  varchar2
  ,p_grossup_flag    in  varchar2
  ) is
--
  l_proc  varchar2(72)  := g_package||'chk_iterative_flag';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (p_grossup_flag = 'Y' and p_iterative_flag <> 'Y') then
    fnd_message.set_name('PAY', 'PAY_34147_ELE_ITR_GROSSUP');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_iterative_flag;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_iterative_priority >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_iterative_priority
  (p_iterative_priority  in number
  ,p_iterative_flag      in varchar2
  ) is
--
  l_proc  varchar2(72)  := g_package||'chk_iterative_priority';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (p_iterative_flag = 'N' and p_iterative_priority is not null) then
    fnd_message.set_name('PAY', 'PAY_34144_ELE_ITR_NO_FORML_PRI');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_iterative_priority;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_iterative_formula_name >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_iterative_formula_name
  (p_iterative_formula_name  in varchar2
  ,p_iterative_flag          in varchar2
  ) is
--
  l_proc  varchar2(72)  := g_package||'chk_iterative_formula_name';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_iterative_flag is not null then
    if (p_iterative_flag = 'N' and p_iterative_formula_name is not null) then
      fnd_message.set_name('PAY', 'PAY_34144_ELE_ITR_NO_FORML_PRI');
      fnd_message.raise_error;
    end if;
    if (p_iterative_flag = 'Y' and p_iterative_formula_name is null) then
      fnd_message.set_name('PAY', 'PAY_34146_ELE_ITR_FORML_REQD');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_iterative_formula_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_process_mode >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_process_mode
  (p_process_mode  in  varchar2
  ,p_grossup_flag  in  varchar2
  ) is
--
  l_proc  varchar2(72)  := g_package||'chk_process_mode';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if (p_grossup_flag = 'Y' and p_process_mode = 'N') then
    fnd_message.set_name('PAY', 'PAY_50093_ELE_GROSSUP_PROC_MOD');
    fnd_message.raise_error;
  end if;
  --
  if (p_process_mode not in ('N','S','P')) then
    fnd_message.set_name('PAY', 'PAY_34148_ELE_PROC_MODE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_process_mode;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_element_type_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the element.
  --
  cursor csr_input_values is
  select null
  from   pay_shadow_input_values psiv
  where  psiv.element_type_id = p_element_type_id;
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  (tco.core_object_type = pay_tco_shd.g_set_lookup_type or
          tco.core_object_type = pay_tco_shd.g_spr_lookup_type)
  and    tco.shadow_object_id = p_element_type_id;
  --
  cursor csr_formula_rules is
  select null
  from   pay_shadow_formula_rules sfr
  where  sfr.shadow_element_type_id = p_element_type_id or
         sfr.element_type_id = p_element_type_id;
  --
  cursor csr_sub_classi_rules is
  select null
  from   pay_shadow_sub_classi_rules ssr
  where  ssr.element_type_id = p_element_type_id;
  --
  cursor csr_iterative_rules is
  select null
  from   pay_shadow_iterative_rules sir
  where  sir.element_type_id = p_element_type_id;
  --
  cursor csr_ele_type_usages is
  select null
  from   pay_shadow_ele_type_usages seu
  where  seu.element_type_id = p_element_type_id;
  --
  cursor csr_gu_bal_exclusions is
  select null
  from   pay_shadow_gu_bal_exclusions sgb
  where  sgb.source_id = p_element_type_id;
  --
  cursor csr_template_ff_usages is
  select null
  from   pay_template_ff_usages tfu
  where  tfu.object_id = p_element_type_id;
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_error  exception;
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_input_values;
  fetch csr_input_values into l_exists;
  if csr_input_values%found then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_input_values;
    raise l_error;
  end if;
  close csr_input_values;
  --
  open csr_core_objects;
  fetch csr_core_objects into l_exists;
  if csr_core_objects%found then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    close csr_core_objects;
    raise l_error;
  end if;
  close csr_core_objects;
  --
  open csr_formula_rules;
  fetch csr_formula_rules into l_exists;
  if csr_formula_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    close csr_formula_rules;
    raise l_error;
  end if;
  close csr_formula_rules;
  --
  open csr_sub_classi_rules;
  fetch csr_sub_classi_rules into l_exists;
  if csr_sub_classi_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    close csr_sub_classi_rules;
    raise l_error;
  end if;
  close csr_sub_classi_rules;
  --
  open csr_iterative_rules;
  fetch csr_iterative_rules into l_exists;
  if csr_iterative_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 30);
    close csr_iterative_rules;
    raise l_error;
  end if;
  close csr_iterative_rules;
  --
  open csr_ele_type_usages;
  fetch csr_ele_type_usages into l_exists;
  if csr_ele_type_usages%found then
    hr_utility.set_location(' Leaving:'||l_proc, 35);
    close csr_ele_type_usages;
    raise l_error;
  end if;
  close csr_ele_type_usages;
  --
  open csr_gu_bal_exclusions;
  fetch csr_gu_bal_exclusions into l_exists;
  if csr_gu_bal_exclusions%found then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
    close csr_gu_bal_exclusions;
    raise l_error;
  end if;
  close csr_gu_bal_exclusions;
  --
  open csr_template_ff_usages;
  fetch csr_template_ff_usages into l_exists;
  if csr_template_ff_usages%found then
    hr_utility.set_location(' Leaving:'||l_proc, 45);
    close csr_template_ff_usages;
    raise l_error;
  end if;
  close csr_template_ff_usages;
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50138_SET_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 200);
    raise;
  hr_utility.set_location(' Leaving:'||l_proc, 205);
End chk_delete;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date in date
,p_rec in pay_set_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_business_group_id        number;
  l_legislation_code         varchar2(2000);
  l_template_type            varchar2(2000);
  l_base_processing_priority number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_id(p_template_id => p_rec.template_id);
  --
  get_template_info
  (p_template_id              => p_rec.template_id
  ,p_business_group_id        => l_business_group_id
  ,p_legislation_code         => l_legislation_code
  ,p_template_type            => l_template_type
  ,p_base_processing_priority => l_base_processing_priority
  );
  --
  chk_classification_name
  (p_classification_name   => p_rec.classification_name
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_lookups
  (p_effective_date               => p_effective_date
  ,p_additional_entry_allowed_fla => p_rec.additional_entry_allowed_flag
  ,p_adjustment_only_flag         => p_rec.adjustment_only_flag
  ,p_closed_for_entry_flag        => p_rec.closed_for_entry_flag
  ,p_indirect_only_flag           => p_rec.indirect_only_flag
  ,p_multiple_entries_allowed_fla => p_rec.multiple_entries_allowed_flag
  ,p_multiply_value_flag          => p_rec.multiply_value_flag
  ,p_post_termination_rule        => p_rec.post_termination_rule
  ,p_process_in_run_flag          => p_rec.process_in_run_flag
  ,p_processing_type              => p_rec.processing_type
  ,p_standard_link_flag           => p_rec.standard_link_flag
  ,p_qualifying_units             => p_rec.qualifying_units
  ,p_third_party_pay_only_flag    => p_rec.third_party_pay_only_flag
  ,p_iterative_flag               => p_rec.iterative_flag
  ,p_grossup_flag                 => p_rec.grossup_flag
  ,p_advance_indicator            => p_rec.advance_indicator
  ,p_advance_payable              => p_rec.advance_payable
  ,p_advance_deduction            => p_rec.advance_deduction
  ,p_process_advance_entry        => p_rec.process_advance_entry
  ,p_once_each_period_flag        => p_rec.once_each_period_flag
  ,p_element_type_id              => p_rec.element_type_id
  ,p_object_version_number        => p_rec.object_version_number
  );
  --
  chk_element_name
  (p_element_name          => p_rec.element_name
  ,p_template_id           => p_rec.template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_processing_priority
  (p_relative_processing_priority => p_rec.relative_processing_priority
  ,p_base_processing_priority     => l_base_processing_priority
  ,p_element_type_id              => p_rec.element_type_id
  ,p_object_version_number        => p_rec.object_version_number
  );
  --
  chk_input_currency_code
  (p_input_currency_code   => p_rec.input_currency_code
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_output_currency_code
  (p_output_currency_code  => p_rec.output_currency_code
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_payroll_formula_id
  (p_payroll_formula_id    => p_rec.payroll_formula_id
  ,p_template_id           => p_rec.template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_legislation_code      => l_legislation_code
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => p_rec.template_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_iterative_flag
  (p_iterative_flag        => p_rec.iterative_flag
  ,p_grossup_flag          => p_rec.grossup_flag
  );
  --
  chk_iterative_priority
  (p_iterative_priority    => p_rec.iterative_priority
  ,p_iterative_flag        => p_rec.iterative_flag
  );
  --
  chk_iterative_formula_name
  (p_iterative_formula_name => p_rec.iterative_formula_name
  ,p_iterative_flag         => p_rec.iterative_flag
  );
  --
  chk_process_mode
  (p_process_mode           => p_rec.process_mode
  ,p_grossup_flag           => p_rec.grossup_flag
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
(p_effective_date in date
,p_rec in pay_set_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_business_group_id        number;
  l_legislation_code         varchar2(2000);
  l_template_type            varchar2(2000);
  l_base_processing_priority number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec);
  --
  get_template_info
  (p_template_id              => p_rec.template_id
  ,p_business_group_id        => l_business_group_id
  ,p_legislation_code         => l_legislation_code
  ,p_template_type            => l_template_type
  ,p_base_processing_priority => l_base_processing_priority
  );
  --
  chk_classification_name
  (p_classification_name   => p_rec.classification_name
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_lookups
  (p_effective_date               => p_effective_date
  ,p_additional_entry_allowed_fla => p_rec.additional_entry_allowed_flag
  ,p_adjustment_only_flag         => p_rec.adjustment_only_flag
  ,p_closed_for_entry_flag        => p_rec.closed_for_entry_flag
  ,p_indirect_only_flag           => p_rec.indirect_only_flag
  ,p_multiple_entries_allowed_fla => p_rec.multiple_entries_allowed_flag
  ,p_multiply_value_flag          => p_rec.multiply_value_flag
  ,p_post_termination_rule        => p_rec.post_termination_rule
  ,p_process_in_run_flag          => p_rec.process_in_run_flag
  ,p_processing_type              => p_rec.processing_type
  ,p_standard_link_flag           => p_rec.standard_link_flag
  ,p_qualifying_units             => p_rec.qualifying_units
  ,p_third_party_pay_only_flag    => p_rec.third_party_pay_only_flag
  ,p_iterative_flag               => p_rec.iterative_flag
  ,p_grossup_flag                 => p_rec.grossup_flag
  ,p_advance_indicator            => p_rec.advance_indicator
  ,p_advance_payable              => p_rec.advance_payable
  ,p_advance_deduction            => p_rec.advance_deduction
  ,p_process_advance_entry        => p_rec.process_advance_entry
  ,p_once_each_period_flag        => p_rec.once_each_period_flag
  ,p_element_type_id              => p_rec.element_type_id
  ,p_object_version_number        => p_rec.object_version_number
  );
  --
  chk_element_name
  (p_element_name          => p_rec.element_name
  ,p_template_id           => p_rec.template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_processing_priority
  (p_relative_processing_priority => p_rec.relative_processing_priority
  ,p_base_processing_priority     => l_base_processing_priority
  ,p_element_type_id              => p_rec.element_type_id
  ,p_object_version_number        => p_rec.object_version_number
  );
  --
  chk_input_currency_code
  (p_input_currency_code   => p_rec.input_currency_code
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_output_currency_code
  (p_output_currency_code  => p_rec.output_currency_code
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_payroll_formula_id
  (p_payroll_formula_id    => p_rec.payroll_formula_id
  ,p_template_id           => p_rec.template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_legislation_code      => l_legislation_code
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => p_rec.template_id
  ,p_element_type_id       => p_rec.element_type_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_iterative_flag
  (p_iterative_flag        => p_rec.iterative_flag
  ,p_grossup_flag          => p_rec.grossup_flag
  );
  --
  chk_iterative_priority
  (p_iterative_priority    => p_rec.iterative_priority
  ,p_iterative_flag        => p_rec.iterative_flag
  );
  --
  chk_iterative_formula_name
  (p_iterative_formula_name => p_rec.iterative_formula_name
  ,p_iterative_flag         => p_rec.iterative_flag
  );
  --
  chk_process_mode
  (p_process_mode           => p_rec.process_mode
  ,p_grossup_flag           => p_rec.grossup_flag
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_set_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.element_type_id);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_set_bus;

/
