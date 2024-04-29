--------------------------------------------------------
--  DDL for Package Body PAY_SIV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SIV_BUS" as
/* $Header: pysivrhi.pkb 120.0 2005/05/29 08:52:40 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_siv_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_element_info >----------------------------|
-- ----------------------------------------------------------------------------
Procedure get_element_info
  (p_element_type_id             in            number
  ,p_template_id                    out nocopy number
  ,p_input_currency_code            out nocopy varchar2
  ) is
  --
  -- Cursor to get the template information.
  --
  cursor csr_get_element_info is
  select pet.template_id
  ,      pset.input_currency_code
  from   pay_shadow_element_types pset
  ,      pay_element_templates    pet
  where  pset.element_type_id = p_element_type_id
  and    pet.template_id = pset.template_id;
--
  l_proc  varchar2(72) := g_package||'get_element_info';
  l_api_updating boolean;
  l_valid        varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  open csr_get_element_info;
  fetch csr_get_element_info
  into  p_template_id
  ,     p_input_currency_code;
  close csr_get_element_info;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End get_element_info;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_template_info >--------------------------|
-- ----------------------------------------------------------------------------
Procedure get_template_info
  (p_template_id                 in            number
  ,p_business_group_id           in out nocopy number
  ,p_legislation_code            in out nocopy varchar2
  ,p_template_type               in out nocopy varchar2
  ) is
  --
  -- Cursor to get the template information.
  --
  cursor csr_get_template_info is
  select pet.business_group_id
  ,      pet.legislation_code
  ,      pet.template_type
   from   pay_element_templates pet
  where  pet.template_id = p_template_id;
--
  l_proc  varchar2(72) := g_package||'get_template_info';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  open csr_get_template_info;

  fetch csr_get_template_info
  into  p_business_group_id
  ,     p_legislation_code
  ,     p_template_type;

  close csr_get_template_info;

  if p_business_group_id is not null then
    p_legislation_code := hr_api.return_legislation_code(p_business_group_id);
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 15);
End get_template_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
(p_rec in pay_siv_shd.g_rec_type
) is
  --
  -- Cursor to disallow update if a balance has been generated from
  -- this shadow balance.
  --
  cursor csr_disallow_update is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_siv_lookup_type
  and    tco.shadow_object_id = p_rec.input_value_id;
  --
  -- Cursor to disallow update of UOM if balance feeds to this
  -- balance exists.
  --
  cursor csr_disallow_uom is
  select null
  from   pay_shadow_balance_feeds sbf
  where  sbf.input_value_id = p_rec.input_value_id;
--
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_error exception;
  l_api_updating boolean;
  l_argument     varchar2(30);
  l_disallow     varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_siv_shd.api_updating
    (p_input_value_id        => p_rec.input_value_id
    ,p_object_version_number => p_rec.object_version_number
    );
  if not l_api_updating then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '10');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Check that the update is actually allowed.
  --
  open csr_disallow_update;
  fetch csr_disallow_update into l_disallow;
  if csr_disallow_update%found then
    hr_utility.set_location(l_proc, 20);
    close csr_disallow_update;
    fnd_message.set_name('PAY', 'PAY_50121_SIV_CORE_ROW_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_disallow_update;
  --
  -- Check the otherwise non-updateable arguments.
  --
  -- p_element_type_id
  --
  if nvl(p_rec.element_type_id, hr_api.g_number) <>
     nvl(pay_siv_shd.g_old_rec.element_type_id, hr_api.g_number)
  then
    l_argument := 'p_element_type_id';
    raise l_error;
  end if;
  --
  -- p_uom
  --
  if nvl(p_rec.uom, hr_api.g_varchar2) <>
     nvl(pay_siv_shd.g_old_rec.uom, hr_api.g_varchar2)
  then
    --
    -- Check to see if the update is allowed.
    --
    open csr_disallow_uom;
    fetch csr_disallow_uom into l_disallow;
    if csr_disallow_uom%found then
      close csr_disallow_uom;
      l_argument := 'p_uom';
      raise l_error;
    end if;
    close csr_disallow_uom;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
    when l_error then
       hr_utility.set_location('Leaving:'||l_proc, 30);
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       hr_utility.set_location('Leaving:'||l_proc, 35);
       raise;
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_element_type_id >-------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_element_type_id
  (p_element_type_id     in     number
  ,p_exclusion_rule_id   in     number
  ) is
  --
  -- Cursor to check that the element type exists.
  --
  cursor csr_element_type_exists is
  select null
  from   pay_shadow_element_types pset
  where  pset.element_type_id = p_element_type_id;
  --
  -- Cursor to count the number of input values that the element type
  -- already has.
  --
  cursor csr_input_value_count is
  select count(siv.input_value_id)
  from   pay_shadow_input_values siv
  where  siv.element_type_id = p_element_type_id
  and    siv.exclusion_rule_id is null
  ;
--
  l_proc  varchar2(72) := g_package||'chk_element_type_id';
  l_exists varchar2(1);
  l_count number;
  l_max_input_values constant number := 15;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the element type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_element_type_id'
  ,p_argument_value => p_element_type_id
  );
  --
  -- Check that the element type exists.
  --
  open csr_element_type_exists;
  fetch csr_element_type_exists into l_exists;
  if csr_element_type_exists%notfound then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_element_type_exists;
    fnd_message.set_name('PAY', 'PAY_50095_ETM_INVALID_ELE_TYPE');
    fnd_message.raise_error;
  end if;
  close csr_element_type_exists;
  --
  -- Count the number of input values for this element type.
  --
  open csr_input_value_count;
  fetch csr_input_value_count into l_count;
  if p_exclusion_rule_id is null and
    l_count >= l_max_input_values then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    close csr_input_value_count;
    fnd_message.set_name('PAY', 'PAY_50122_SIV_TOO_MANY_INPUTS');
    fnd_message.set_token('MAX', l_max_input_values);
    fnd_message.raise_error;
  end if;
  close csr_input_value_count;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when others then
    if csr_input_value_count%isopen then
      close csr_input_value_count;
    end if;
    if csr_element_type_exists%isopen then
      close  csr_element_type_exists;
    end if;
    raise;
End chk_element_type_id;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_display_sequence >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_display_sequence
  (p_display_sequence      in number
  ,p_input_value_id        in number
  ,p_object_version_number in number
  ) is
  l_proc  varchar2(72) := g_package||'chk_display_sequence';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id        => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_display_sequence, hr_api.g_number) <>
      nvl(pay_siv_shd.g_old_rec.display_sequence, hr_api.g_number)) or
      not l_api_updating
  then
    --
    -- Check that display_sequence is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_display_sequence'
    ,p_argument_value => p_display_sequence
    );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_display_sequence;
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_lookups >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_lookups
  (p_effective_date         in     date
  ,p_generate_db_items_flag in     varchar2
  ,p_hot_default_flag       in     varchar2
  ,p_mandatory_flag         in     varchar2
  ,p_uom                    in     varchar2
  ,p_warning_or_error       in     varchar2
  ,p_input_value_id         in     number
  ,p_object_version_number  in     number
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
  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id        => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );
  --
  -- generate_db_items_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'generate_db_items_flag'
  ,p_old_lookup_code  => pay_siv_shd.g_old_rec.generate_db_items_flag
  ,p_lookup_code      => p_generate_db_items_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- hot_default_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'hot_default_flag'
  ,p_old_lookup_code  => pay_siv_shd.g_old_rec.hot_default_flag
  ,p_lookup_code      => p_hot_default_flag
  ,p_lookup_type      => 'YES_NO'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- mandatory_flag
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'mandatory_flag'
  ,p_old_lookup_code  => pay_siv_shd.g_old_rec.mandatory_flag
  ,p_lookup_code      => p_mandatory_flag
  ,p_lookup_type      => 'YES_NO_NEVER'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- uom
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'uom'
  ,p_old_lookup_code  => pay_siv_shd.g_old_rec.uom
  ,p_lookup_code      => p_uom
  ,p_lookup_type      => 'UNITS'
  ,p_mandatory        => true
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  --
  -- warning_or_error
  --
  chk_lookup
  (p_effective_date   => p_effective_date
  ,p_caller           => l_proc
  ,p_argument_name    => 'warning_or_error'
  ,p_old_lookup_code  => pay_siv_shd.g_old_rec.warning_or_error
  ,p_lookup_code      => p_warning_or_error
  ,p_lookup_type      => 'WARNING_ERROR'
  ,p_mandatory        => false
  ,p_updatable        => true
  ,p_api_updating     => l_api_updating
  );
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_lookups;
-- ----------------------------------------------------------------------------
-- |--------------------------------< chk_name >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_name
  (p_name                  in   varchar2
  ,p_element_type_id       in   number
  ,p_input_value_id        in   number
  ,p_object_version_number in   number
  ) is
  --
  -- Cursor to check that the input value name does not exist for the
  -- element type.
  --
  cursor csr_name_exists is
  select null
  from   pay_shadow_input_values siv
  where  siv.element_type_id = p_element_type_id
  and    upper(siv.name) = upper(p_name);
--
  l_proc  varchar2(72) := g_package||'chk_name';
  l_api_updating boolean;
  l_exists       varchar2(1);
  l_value        varchar2(2000);
  l_output       varchar2(2000);
  l_rgeflg       varchar2(2000);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id        => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_name, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.name, hr_api.g_varchar2)) or
     not l_api_updating
  then
    --
    -- Check that the name is not already in use.
    --
    open csr_name_exists;
    fetch csr_name_exists into l_exists;
    if csr_name_exists%found then
      close csr_name_exists;
      fnd_message.set_name('PAY', 'PAY_50142_SIV_NAME_EXISTS');
      fnd_message.set_token('NAME', p_name);
      fnd_message.raise_error;
    end if;
    close csr_name_exists;
    --
    -- Check that the name format is correct (not null payroll name).
    --
    l_value := p_name;
    hr_chkfmt.checkformat
    (value   => l_value
    ,format  => 'PAY_NAME'
    ,output  => l_output
    ,minimum => null
    ,maximum => null
    ,nullok  => 'N'
    ,rgeflg  => l_rgeflg
    ,curcode => null
    );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_name;
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_lookup_type >----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_lookup_type
  (p_effective_date        in date
  ,p_lookup_type           in varchar2
  ,p_uom                   in varchar2
  ,p_default_value         in varchar2
  ,p_input_value_id        in number
  ,p_object_version_number in number
  ) is
  --
  -- Cursor to check that lookup_type is valid.
  --
  cursor csr_lookup_type_valid is
  select null
  from   hr_lookups hr
  where  hr.lookup_type = p_lookup_type
  and    hr.enabled_flag = 'Y'
  and    p_effective_date between
         nvl(start_date_active, p_effective_date)
         and nvl(end_date_active, p_effective_date);
  --
  l_proc  varchar2(72) := g_package||'chk_lookup_type';
  l_valid varchar2(1);
  l_api_updating boolean;
  l_uom_changed  boolean;
  l_chk_default  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id        => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );
  --
  -- Has the UOM changed ?
  --
  l_uom_changed :=
  l_api_updating and nvl(p_uom, hr_api.g_varchar2) <>
                     nvl(pay_siv_shd.g_old_rec.uom, hr_api.g_varchar2);
  --
  -- Check the lookup type.
  --
  l_chk_default := false;
  if (l_api_updating and nvl(p_lookup_type, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.lookup_type, hr_api.g_varchar2)) or
      not l_api_updating or
      l_uom_changed
  then
    if p_lookup_type is not null then
      --
      -- UOM must be 'C' if lookup type is used for validation.
      --
      if p_uom <> 'C' then
        hr_utility.set_location(' Leaving:'||l_proc, 10);
        fnd_message.set_name('PAY', 'PAY_50132_SIV_BAD_LOOKUP_UOM');
        fnd_message.set_token('UOM', 'C');
        fnd_message.raise_error;
      end if;
      --
      -- Check that the lookup type exists.
      --
      open csr_lookup_type_valid;
      fetch csr_lookup_type_valid into l_valid;
      if csr_lookup_type_valid%notfound then
        hr_utility.set_location(' Leaving:'||l_proc, 15);
        close csr_lookup_type_valid;
        fnd_message.set_name('PAY', 'PAY_50133_SIV_BAD_LOOKUP_TYPE');
        fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
        fnd_message.raise_error;
      end if;
      close csr_lookup_type_valid;
      --
      -- Flag the need to recheck the default value.
      --
      l_chk_default := true;
    end if;
  end if;
  --
  -- Check the default value.
  --
  if (l_api_updating and nvl(p_default_value, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.default_value, hr_api.g_varchar2)) or
      not l_api_updating or
      l_chk_default
  then
    if p_default_value is not null and p_lookup_type is not null and
       hr_api.not_exists_in_hr_lookups
       (p_effective_date => p_effective_date
       ,p_lookup_type    => p_lookup_type
       ,p_lookup_code    => p_default_value
       )
    then
      hr_utility.set_location(' Leaving:'||l_proc, 20);
      fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
      fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
      fnd_message.set_token('COLUMN', 'DEFAULT_VALUE');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_lookup_type;
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_values >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_values
  (p_effective_date		in     date
  ,p_input_currency_code	in     varchar2
  ,p_uom			in     varchar2
  ,p_lookup_type		in     varchar2
  ,p_default_value		in     varchar2
  ,p_min_value			in     varchar2
  ,p_max_value			in     varchar2
  ,p_input_value_id		in     number
  ,p_formula_id			in     number
  ,p_input_validation_formula   in     varchar2
  ,p_object_version_number	in     number
  ) is
  --
  -- Cursor to check that lookup_type is valid.
  --
  cursor csr_lookup_type_valid is
  select null
  from   hr_lookups hr
  where  hr.lookup_type = p_lookup_type
  and    hr.enabled_flag = 'Y'
  and    p_effective_date between
         nvl(start_date_active, p_effective_date)
         and nvl(end_date_active, p_effective_date);
--
  l_proc  varchar2(72) := g_package||'chk_values';
  l_api_updating boolean;
  l_exists       varchar2(1);
  l_value        varchar2(2000);
  l_output       varchar2(2000);
  l_rgeflg       varchar2(2000);
  l_min          varchar2(2000);
  l_min_output   varchar2(2000);
  l_max          varchar2(2000);
  l_max_output   varchar2(2000);
  l_uom          varchar2(2000);
  l_def          varchar2(2000);
  l_def_output   varchar2(2000);
  l_chk_def      boolean := false;
  l_chk_max      boolean := false;
  l_chk_min      boolean := false;
  l_uom_updated  boolean := false;
  l_do_checks    boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check against the lookup type (which should have already been
  -- validated against the default value).
  --
  if p_lookup_type is not null then
    --
    -- The maximum and minimum values must both be null if lookup type
    -- is not null.
    --
    if p_max_value is not null or p_min_value is not null then
      hr_utility.set_location('Leaving:'||l_proc, 10);
      fnd_message.set_name('PAY', 'PAY_50134_SIV_LOOKUP_AND_RANGE');
      fnd_message.raise_error;
    end if;
    --
    -- The formula_id and input_validation_formula must both be null if
    -- lookup type is not null.
    --
    if p_formula_id is not null or p_input_validation_formula is not null then
      hr_utility.set_location('Leaving:'||l_proc, 15);
      fnd_message.set_name('PAY', 'PAY_33184_SIV_VALID_COMB');
      fnd_message.raise_error;
    end if;
    --
    --
    hr_utility.set_location('Leaving:'||l_proc, 20);
    return;
  end if;
  --
  if p_formula_id is not null then
    --
    -- The maximum and minimum values must both be null if formula id
    -- is not null.
    --
    if p_max_value is not null or p_min_value is not null then
      hr_utility.set_location('Leaving:'||l_proc, 25);
      fnd_message.set_name('PAY', 'PAY_33184_SIV_VALID_COMB');
      fnd_message.raise_error;
    end if;
    --
    -- The input validation formula must be null when formula id is not null
    --
    if p_input_validation_formula is not null then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      fnd_message.set_name('PAY', 'PAY_33184_SIV_VALID_COMB');
      fnd_message.raise_error;
    end if;
    --
    --

    hr_utility.set_location('Leaving:'||l_proc, 35);
    return;

  end if;
  --
  if p_input_validation_formula is not null then
    --
    -- The maximum and minimum values must both be null if input validation formula
    -- is not null.
    --
    if p_max_value is not null or p_min_value is not null then
      hr_utility.set_location('Leaving:'||l_proc, 40);
      fnd_message.set_name('PAY', 'PAY_33184_SIV_VALID_COMB');
      fnd_message.raise_error;
    end if;

    hr_utility.set_location('Leaving:'||l_proc, 45);
    return;

  end if;
  --
  --
  -- The code needs to check the minimum, maximum, and default values
  -- using checkformat and the supplied UOM.
  --
  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id        => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );
  --
  -- Did the UOM get updated ? Note: it should have already been checked
  -- for validity.
  --
  if (l_api_updating and nvl(p_uom, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.uom, hr_api.g_varchar2)) or
      not l_api_updating
  then
    l_uom_updated := true;
    l_uom := p_uom;
  else
    l_uom := pay_siv_shd.g_old_rec.uom;
  end if;
  --
  -- Decide what needs checking.
  --
  if (l_api_updating and nvl(p_default_value, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.default_value, hr_api.g_varchar2)) or
      not l_api_updating
  then
    l_chk_def := true;
    l_def := p_default_value;
  else
    l_def := pay_siv_shd.g_old_rec.default_value;
  end if;
  --
  if (l_api_updating and nvl(p_max_value, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.max_value, hr_api.g_varchar2)) or
      not l_api_updating
  then
    l_chk_max := true;
    l_max := p_max_value;
  else
    l_max := pay_siv_shd.g_old_rec.max_value;
  end if;
  --
  if (l_api_updating and nvl(p_min_value, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.min_value, hr_api.g_varchar2)) or
      not l_api_updating
  then
    l_chk_min := true;
    l_min := p_min_value;
  else
    l_min := pay_siv_shd.g_old_rec.min_value;
  end if;
  --
  -- If anything's changed (or it's the first time) then everything has
  -- to be checked.
  --
  l_do_checks := l_uom_updated or l_chk_def or l_chk_min or l_chk_max;
  --
  -- Nothing's changed so return.
  --
  if not l_do_checks then
    hr_utility.set_location('Leaving:'||l_proc, 50);
    return;
  end if;
  -------------
  -- Minimum/Maximum/Default Value Checks:
  -- o changeformat expects input value in canonical format for number/date,
  --   and is used to check that the minimum/maximum and default values are
  --   in the correct internal format.
  -- o changeformat converts to output in display format.
  -- o checkformat expects value in display format, and minimum/maximum values
  --   in canonical format for number/date, and is used for range checking.
  -------------
  --
  -- Check the minimum value.
  --
  l_value := l_min;
  hr_chkfmt.changeformat
  (input   => l_value
  ,output  => l_min_output
  ,format  => l_uom
  ,curcode => p_input_currency_code
  );
  --
  -- Check the maximum value.
  --
  l_value := l_max;
  hr_chkfmt.changeformat
  (input   => l_value
  ,output  => l_max_output
  ,format  => l_uom
  ,curcode => p_input_currency_code
  );
  --
  -- Check the default value.
  --
  l_value := l_def;
  hr_chkfmt.changeformat
  (input   => l_value
  ,output  => l_def_output
  ,format  => l_uom
  ,curcode => p_input_currency_code
  );
  --
  -- Do the range check (starting with the minimum and maximum values).
  --
  l_rgeflg := 'S';
  --
  -- Only check maximum and minimum values if both values are not null.
  --
  if l_min is not null and l_max is not null then
    hr_chkfmt.checkformat
    (value   => l_min_output
    ,format  => l_uom
    ,output  => l_output
    ,minimum => l_min
    ,maximum => l_max
    ,nullok  => 'Y'
    ,rgeflg  => l_rgeflg
    ,curcode => p_input_currency_code
    );
  end if;
  --
  -- Only check the default value if the previous check did not fail, if
  -- the default value is not null, and at least one of l_min or l_max is
  -- not null.
  --
  if l_rgeflg <> 'F' and l_def is not null and
     (l_min is not null or l_max is not null) then
    hr_chkfmt.checkformat
    (value   => l_def_output
    ,format  => l_uom
    ,output  => l_output
    ,minimum => l_min
    ,maximum => l_max
    ,nullok  => 'Y'
    ,rgeflg  => l_rgeflg
    ,curcode => p_input_currency_code
    );
  end if;
  --
  if l_rgeflg = 'F' then
    --
    -- Range check failed.
    --
    hr_utility.set_location('Leaving:'||l_proc, 55);
    fnd_message.set_name('PAY', 'PAY_50135_SIV_BAD_RANGE_VALUES');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 60);
End chk_values;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_default_value_column >-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_default_value_column
  (p_default_value_column  in     varchar2
  ,p_template_id           in     number
  ,p_uom                   in     varchar2
  ,p_lookup_type           in     varchar2
  ,p_input_value_id        in     number
  ,p_object_version_number in     number
  ) is
  --
  -- Cursor to ensure that the default value column is not being used as
  -- a flexfield column in PAY_TEMPLATE_EXCLUSION_RULES.
  --
  cursor csr_default_value_clash is
  select null
  from   pay_template_exclusion_rules ter
  where  ter.template_id = p_template_id
  and    upper(ter.flexfield_column) = upper(p_default_value_column);
  --
  -- Cursor to make sure that the default value column is being used
  -- consistently.
  --
  cursor csr_inconsistent_def_val is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_input_values psiv
  where  pset.template_id = p_template_id
  and    psiv.element_type_id = pset.element_type_id
  and    nvl(upper(psiv.default_value_column), hr_api.g_varchar2) =
         upper(p_default_value_column)
  and    (psiv.uom <> p_uom or nvl(psiv.lookup_type, hr_api.g_varchar2) <>
          nvl(p_lookup_type, hr_api.g_varchar2));
--
  l_proc  varchar2(72) := g_package||'chk_default_value_column';
  l_len   number;
  l_prefix varchar2(2000);
  l_suffix number;
  l_error  exception;
  l_api_updating boolean;
  l_clash  varchar2(1);
  l_inconsistent varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id        => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_default_value_column, hr_api.g_varchar2) <>
      nvl(pay_siv_shd.g_old_rec.default_value_column, hr_api.g_varchar2)) or
     not l_api_updating
  then
    if p_default_value_column is not null then
      --
      -- Check that the default value column name is valid i.e. in the set
      -- CONFIGURATION_INFORMATION1 .. CONFIGURATION_INFORMATION30
      --
      begin
        l_len := length('CONFIGURATION_INFORMATION');
        l_prefix := upper(substr(p_default_value_column, 1, l_len));
        l_suffix :=
        fnd_number.canonical_to_number(substr(p_default_value_column, l_len + 1));
        l_suffix := nvl(l_suffix, -1);
        if l_prefix <> 'CONFIGURATION_INFORMATION' or
           (l_suffix < 1 or l_suffix > 30) or
           (l_suffix <> trunc(l_suffix))
        then
          raise l_error;
        end if;
      exception
        --
        -- All exceptions are due to the name being in the incorrect
        -- format.
        --
        when others then
          hr_utility.set_location(' Leaving:'||l_proc, 10);
          fnd_message.set_name('PAY', 'PAY_50130_ETM_BAD_FLEX_COLUMN');
          fnd_message.set_token('FLEXFIELD_COLUMN', p_default_value_column);
          fnd_message.raise_error;
      end;
      --
      -- Check that the default value column does not clash with a
      -- flexfield column on PAY_TEMPLATE_EXCLUSION_RULES.
      --
      open csr_default_value_clash;
      fetch csr_default_value_clash into l_clash;
      if csr_default_value_clash%found then
        hr_utility.set_location(' Leaving:'||l_proc, 15);
        close csr_default_value_clash;
        fnd_message.set_name('PAY', 'PAY_50131_TER_SIV_CLASH');
        fnd_message.raise_error;
      end if;
      close csr_default_value_clash;
      --
      -- Check that there are no consistency problems with the use of
      -- this default value column.
      --
      open csr_inconsistent_def_val;
      fetch csr_inconsistent_def_val into l_inconsistent;
      if csr_inconsistent_def_val%found then
        hr_utility.set_location(' Leaving:'||l_proc, 20);
        close csr_inconsistent_def_val;
        fnd_message.set_name('PAY', 'PAY_50136_SIV_DEFVAL_DIFF_UOMS');
        fnd_message.raise_error;
      end if;
      close csr_inconsistent_def_val;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 25);
End chk_default_value_column;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_exclusion_rule_id >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_exclusion_rule_id
  (p_exclusion_rule_id     in     number
  ,p_template_id           in     number
  ,p_input_value_id        in     number
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
  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id        => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );
  if (l_api_updating and nvl(p_exclusion_rule_id, hr_api.g_number) <>
      nvl(pay_siv_shd.g_old_rec.exclusion_rule_id, hr_api.g_number)) or
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
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_delete >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_delete
  (p_input_value_id     in     number
  ) is
  --
  -- Cursors to check for rows referencing the balance classification.
  --
  cursor csr_core_objects is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_type = pay_tco_shd.g_siv_lookup_type
  and    tco.shadow_object_id = p_input_value_id;
  --
  cursor csr_balance_feeds is
  select null
  from   pay_shadow_balance_feeds sbf
  where  sbf.input_value_id = p_input_value_id;
  --
  cursor csr_formula_rules is
  select null
  from   pay_shadow_formula_rules sfr
  where  nvl(sfr.input_value_id, hr_api.g_number) = p_input_value_id;
  --
  cursor csr_iterative_rules is
  select null
  from   pay_shadow_iterative_rules sir
  where  sir.input_value_id = p_input_value_id;
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_error  exception;
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  open csr_core_objects;
  fetch csr_core_objects into l_exists;
  if csr_core_objects%found then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    close csr_core_objects;
    raise l_error;
  end if;
  close csr_core_objects;
  --
  open csr_balance_feeds;
  fetch csr_balance_feeds into l_exists;
  if csr_balance_feeds%found then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
    close csr_balance_feeds;
    raise l_error;
  end if;
  close csr_balance_feeds;
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
  open csr_iterative_rules;
  fetch csr_iterative_rules into l_exists;
  if csr_iterative_rules%found then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    close csr_iterative_rules;
    raise l_error;
  end if;
  close csr_iterative_rules;
  hr_utility.set_location(' Leaving:'||l_proc, 30);
exception
  when l_error then
    fnd_message.set_name('PAY', 'PAY_50123_SIV_INVALID_DELETE');
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 35);
    raise;
End chk_delete;
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_formula_id >------------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_formula_id
  (p_formula_id             in     number
  ,p_template_id            in     number
  ,p_template_type          in     varchar2
  ,p_business_group_id      in     number
  ,p_legislation_code       in     varchar2
  ,p_input_value_id         in     number
  ,p_object_version_number  in     number
  ) is
--
  --
  -- Check that the formula is valid.
  --
  -- If the shadow element belongs to a template of type 'T' then the formula
  -- may be shared with other templates, but the legislative domain of the
  -- formula must encompass that of the template.

  cursor csr_T_formula_valid is
  select null
  from   pay_shadow_formulas sf
  where  sf.formula_id = p_formula_id
  and    sf.template_type = 'T'
  and	 sf.formula_type_name = pay_sf_shd.g_input_val_formula_type
  and    ((sf.legislation_code is null and sf.business_group_id is null) or
          sf.legislation_code  = p_legislation_code or
          sf.business_group_id = p_business_group_id);
  --
  -- If the shadow element belongs to a template of type 'U' then the formula
  -- must not be shared with any other templates to avoid name clashes.
  --
  cursor csr_U_formula_valid is
  select null
  from   pay_shadow_formulas sf
  where  sf.formula_id = p_formula_id
  and    sf.template_type = 'U'
  and	 sf.formula_type_name = pay_sf_shd.g_input_val_formula_type
  and    sf.business_group_id = p_business_group_id
  and    not exists
         (select null
          from   pay_shadow_input_values psiv , pay_shadow_element_types pset
          where  psiv.formula_id = p_formula_id
	  and    pset.element_type_id = psiv.element_type_id
          and    pset.template_id <> p_template_id);
--
  l_proc  varchar2(72) := g_package||'chk_formula_id';
  l_api_updating boolean;
  l_valid varchar2(1);
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  l_api_updating := pay_siv_shd.api_updating
  (p_input_value_id       => p_input_value_id
  ,p_object_version_number => p_object_version_number
  );

  if (l_api_updating and nvl(p_formula_id, hr_api.g_number) <>
      nvl(pay_siv_shd.g_old_rec.formula_id, hr_api.g_number)) or
     not l_api_updating
  then

    if p_formula_id is not null then

	if p_template_type = 'T' then

		open csr_T_formula_valid;
	        fetch csr_T_formula_valid into l_valid;

		if csr_T_formula_valid%notfound then
			hr_utility.set_location(' Leaving:'||l_proc, 10);
			close csr_T_formula_valid;
		        fnd_message.set_name('PAY', 'PAY_33185_SIV_BAD_FORMULA');
		        fnd_message.raise_error;
		end if;

	        close csr_T_formula_valid;

        elsif p_template_type = 'U' then

		open csr_U_formula_valid;
	        fetch csr_U_formula_valid into l_valid;

		if csr_U_formula_valid%notfound then
		        hr_utility.set_location(' Leaving:'||l_proc, 15);
		        close csr_U_formula_valid;
		        fnd_message.set_name('PAY', 'PAY_33185_SIV_BAD_FORMULA');
			fnd_message.raise_error;
	        end if;

		close csr_U_formula_valid;
	end if;

    end if;

  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 20);

End chk_formula_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
(p_effective_date in date
,p_rec in out nocopy pay_siv_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_template_id number;
  l_input_currency_code varchar2(256);

  l_business_group_id        pay_element_templates.business_group_id%type;
  l_legislation_code         pay_element_templates.legislation_code%type;
  l_template_type            pay_element_templates.template_type%type;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_element_type_id
  (p_element_type_id   => p_rec.element_type_id
  ,p_exclusion_rule_id => p_rec.exclusion_rule_id
  );
  --
  get_element_info
  (p_element_type_id => p_rec.element_type_id
  ,p_template_id     => l_template_id
  ,p_input_currency_code => l_input_currency_code
  );
  --
  get_template_info
  (p_template_id              => l_template_id
  ,p_business_group_id        => l_business_group_id
  ,p_legislation_code         => l_legislation_code
  ,p_template_type            => l_template_type
  );
  --
  chk_name
  (p_name                  => p_rec.name
  ,p_element_type_id       => p_rec.element_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_display_sequence
  (p_display_sequence      => p_rec.display_sequence
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_lookups
  (p_effective_date         => p_effective_date
  ,p_generate_db_items_flag => p_rec.generate_db_items_flag
  ,p_hot_default_flag       => p_rec.hot_default_flag
  ,p_mandatory_flag         => p_rec.mandatory_flag
  ,p_uom                    => p_rec.uom
  ,p_warning_or_error       => p_rec.warning_or_error
  ,p_input_value_id         => p_rec.input_value_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_lookup_type
  (p_effective_date        => p_effective_date
  ,p_lookup_type           => p_rec.lookup_type
  ,p_uom                   => p_rec.uom
  ,p_default_value         => p_rec.default_value
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_values
  (p_effective_date		=> p_effective_date
  ,p_input_currency_code	=> l_input_currency_code
  ,p_lookup_type		=> p_rec.lookup_type
  ,p_uom			=> p_rec.uom
  ,p_default_value		=> p_rec.default_value
  ,p_min_value			=> p_rec.min_value
  ,p_max_value			=> p_rec.max_value
  ,p_input_value_id		=> p_rec.input_value_id
  ,p_formula_id			=> p_rec.formula_id
  ,p_input_validation_formula	=> p_rec.input_validation_formula
  ,p_object_version_number	=> p_rec.object_version_number
  );
  --
  chk_default_value_column
  (p_default_value_column  => p_rec.default_value_column
  ,p_template_id           => l_template_id
  ,p_uom                   => p_rec.uom
  ,p_lookup_type           => p_rec.lookup_type
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => l_template_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_formula_id
  (p_formula_id            => p_rec.formula_id
  ,p_template_id           => l_template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_legislation_code      => l_legislation_code
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
(p_effective_date in date
,p_rec in out nocopy pay_siv_shd.g_rec_type
) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_template_id number;
  l_input_currency_code varchar2(256);

  l_business_group_id        pay_element_templates.business_group_id%type;
  l_legislation_code         pay_element_templates.legislation_code%type;
  l_template_type            pay_element_templates.template_type%type;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  get_element_info
  (p_element_type_id => p_rec.element_type_id
  ,p_template_id     => l_template_id
  ,p_input_currency_code => l_input_currency_code
  );
  --
  get_template_info
  (p_template_id              => l_template_id
  ,p_business_group_id        => l_business_group_id
  ,p_legislation_code         => l_legislation_code
  ,p_template_type            => l_template_type
  );
  --
  chk_non_updateable_args(p_rec);
  --
  chk_name
  (p_name                  => p_rec.name
  ,p_element_type_id       => p_rec.element_type_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_display_sequence
  (p_display_sequence      => p_rec.display_sequence
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_lookups
  (p_effective_date         => p_effective_date
  ,p_generate_db_items_flag => p_rec.generate_db_items_flag
  ,p_hot_default_flag       => p_rec.hot_default_flag
  ,p_mandatory_flag         => p_rec.mandatory_flag
  ,p_uom                    => p_rec.uom
  ,p_warning_or_error       => p_rec.warning_or_error
  ,p_input_value_id         => p_rec.input_value_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  chk_lookup_type
  (p_effective_date        => p_effective_date
  ,p_lookup_type           => p_rec.lookup_type
  ,p_uom                   => p_rec.uom
  ,p_default_value         => p_rec.default_value
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_values
  (p_effective_date		=> p_effective_date
  ,p_input_currency_code	=> l_input_currency_code
  ,p_lookup_type		=> p_rec.lookup_type
  ,p_uom			=> p_rec.uom
  ,p_default_value		=> p_rec.default_value
  ,p_min_value			=> p_rec.min_value
  ,p_max_value			=> p_rec.max_value
  ,p_input_value_id		=> p_rec.input_value_id
  ,p_formula_id			=> p_rec.formula_id
  ,p_input_validation_formula	=> p_rec.input_validation_formula
  ,p_object_version_number	=> p_rec.object_version_number
  );
  --
  chk_default_value_column
  (p_default_value_column  => p_rec.default_value_column
  ,p_template_id           => l_template_id
  ,p_uom                   => p_rec.uom
  ,p_lookup_type           => p_rec.lookup_type
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_exclusion_rule_id
  (p_exclusion_rule_id     => p_rec.exclusion_rule_id
  ,p_template_id           => l_template_id
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_formula_id
  (p_formula_id            => p_rec.formula_id
  ,p_template_id           => l_template_id
  ,p_template_type         => l_template_type
  ,p_business_group_id     => l_business_group_id
  ,p_legislation_code      => l_legislation_code
  ,p_input_value_id        => p_rec.input_value_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_siv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_delete(p_rec.input_value_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_siv_bus;

/
