--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TEMPLATE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TEMPLATE_UTIL" as
/* $Header: pyetmutl.pkb 120.0 2005/05/29 04:42:49 appldev noship $ */
----------------
-- Exceptions --
----------------
plsql_value_error exception;
pragma exception_init(plsql_value_error, -6502);
-----------------------
-- Package Variables --
-----------------------
g_package  varchar2(33) := '  pay_element_template_util.';
--  -----------------------------------------------------------------------
--  |------------------------<  get_template_type       >-----------------|
--  -----------------------------------------------------------------------
function get_template_type(p_template_id in number) return varchar2 is
  cursor get_template_type is
  select template_type from pay_element_templates pet
  where  pet.template_id = p_template_id;
  --
  l_template_type varchar2(2000);
begin
  open get_template_type;
  fetch get_template_type into l_template_type;
  if get_template_type%notfound then
    l_template_type := null;
  end if;
  close get_template_type;
  return l_template_type;
end get_template_type;
--  -----------------------------------------------------------------------
--  |----------------------<  busgrp_in_legislation   >-------------------|
--  -----------------------------------------------------------------------
function busgrp_in_legislation
  (p_business_group_id             in     number
  ,p_legislation_code  in varchar2
  ) return boolean is
  cursor csr_busgrp_in_legislation
  (p_business_group_id in number ,p_legislation_code  in varchar2) is
  select 'Y'
  from   per_business_groups_perf
  where  business_group_id = p_business_group_id
  and    legislation_code = p_legislation_code;
  l_ret    boolean := true;
  l_exists varchar2(1);
begin
  open csr_busgrp_in_legislation(p_business_group_id, p_legislation_code);
  fetch csr_busgrp_in_legislation into l_exists;
  if csr_busgrp_in_legislation%notfound then
    l_ret := false;
  end if;
  close csr_busgrp_in_legislation;
  return l_ret;
exception
  when others then
    if csr_busgrp_in_legislation%isopen then
      close csr_busgrp_in_legislation;
    end if;
    raise;
end busgrp_in_legislation;
--  ---------------------------------------------------------------------------
--  |-----------------------------<  hr_mb_substrb >--------------------------|
--  ---------------------------------------------------------------------------
function hr_mb_substrb
  (p_char                          in     varchar2
  ,p_m                             in     number
  ,p_n                             in     number default null
  ) return varchar2 is
  l_n       number;
  l_strblen number;
  l_strclen number;
  l_str     varchar2(32767);
begin
  --
  -- Make sure we use integer portion of p_n.
  --
  l_n := trunc(p_n);
  --
  -- Get the string portion starting at character position p_m.
  --
  l_str := substr(p_char, p_m);
  --
  -- If l_n is null or greater than the length of l_str then return l_str.
  --
  if l_n is null or l_n >= lengthb(l_str) then
    return l_str;
  end if;
  --
  -- If l_n <= 0 then return null.
  --
  if l_n <= 0 then
    return null;
  end if;
  --
  -- An n-byte multibyte string can have at most n characters, so
  -- starting with an n character return string strip off 1 character
  -- at a time from the end until the return string fits into n bytes.
  --
  l_strclen := l_n;
  l_str     := substr(l_str, 1, l_strclen);
  l_strblen := lengthb(l_str);
  while l_strblen > l_n loop
    --
    -- Exit when string is short enough.
    --
    exit when l_strblen <= l_n;
    --
    -- Strip off a character.
    --
    l_strclen := l_strclen - 1;
    --
    -- Exhausted all the characters from the string, so return null.
    -- For example, l_n = 1 and a single character multibyte string
    -- is actually 2 bytes long.
    --
    if l_strclen = 0 then
      return null;
    end if;
    l_str     := substr(l_str, 1, l_strclen);
    l_strblen := lengthb(l_str);
  end loop;
  return substr(l_str, 1, l_strclen);
end hr_mb_substrb;
-- ----------------------------------------------------------------------------
-- |------------------------< flush_plsql_template >--------------------------|
-- ----------------------------------------------------------------------------
procedure flush_plsql_template
  (p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_core_objects                  in out nocopy t_core_objects
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  ) is
  l_proc                varchar2(72) := g_package||'flush_plsql_template';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  p_element_template := null;
  p_core_objects.delete;
  p_exclusion_rules.delete;
  p_element_types.delete;
  p_input_values.delete;
  p_formulas.delete;
  p_formula_rules.delete;
  p_balance_types.delete;
  p_balance_feeds.delete;
  p_defined_balances.delete;
  p_balance_classis.delete;
  p_sub_classi_rules.delete;
  p_iterative_rules.delete;
  p_ele_type_usages.delete;
  p_gu_bal_exclusions.delete;
  p_bal_attributes.delete;
  p_template_ff_usages.delete;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end flush_plsql_template;
-- ----------------------------------------------------------------------------
-- |------------------------< get_element_template >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_element_template
  (p_template_id                   in     number
  ,p_element_template                 out nocopy pay_etm_shd.g_rec_type
  ) is
  l_proc                varchar2(72) := g_package||'get_element_template';
  --
  cursor csr_element_template(p_template_id in number) is
    select
      template_id,
      template_type,
      template_name,
      base_processing_priority,
      business_group_id,
      legislation_code,
      version_number,
      base_name,
      max_base_name_length,
      preference_info_category,
      preference_information1,
      preference_information2,
      preference_information3,
      preference_information4,
      preference_information5,
      preference_information6,
      preference_information7,
      preference_information8,
      preference_information9,
      preference_information10,
      preference_information11,
      preference_information12,
      preference_information13,
      preference_information14,
      preference_information15,
      preference_information16,
      preference_information17,
      preference_information18,
      preference_information19,
      preference_information20,
      preference_information21,
      preference_information22,
      preference_information23,
      preference_information24,
      preference_information25,
      preference_information26,
      preference_information27,
      preference_information28,
      preference_information29,
      preference_information30,
      configuration_info_category,
      configuration_information1,
      configuration_information2,
      configuration_information3,
      configuration_information4,
      configuration_information5,
      configuration_information6,
      configuration_information7,
      configuration_information8,
      configuration_information9,
      configuration_information10,
      configuration_information11,
      configuration_information12,
      configuration_information13,
      configuration_information14,
      configuration_information15,
      configuration_information16,
      configuration_information17,
      configuration_information18,
      configuration_information19,
      configuration_information20,
      configuration_information21,
      configuration_information22,
      configuration_information23,
      configuration_information24,
      configuration_information25,
      configuration_information26,
      configuration_information27,
      configuration_information28,
      configuration_information29,
      configuration_information30,
      object_version_number
    from  pay_element_templates
    where template_id = p_template_id
    for update of template_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  open csr_element_template(p_template_id);
  fetch csr_element_template into p_element_template;
  if csr_element_template%notfound then
    close csr_element_template;
    --
    -- The template_id is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_element_template;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 30);
    if csr_element_template%isopen then
      close csr_element_template;
    end if;
    raise;
end get_element_template;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_core_objects >-----------------------------|
-- ----------------------------------------------------------------------------
procedure get_core_objects
  (p_template_id      in     number
  ,p_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                varchar2(72) := g_package||'get_core_objects';
  --
  cursor csr_core_objects(p_template_id in number) is
    select
      template_core_object_id,
      template_id,
      core_object_type,
      core_object_id,
      shadow_object_id,
      effective_date,
      object_version_number
    from  pay_template_core_objects
    where template_id = p_template_id
    order by core_object_type
    for update of core_object_id;
begin
  --
  -- Get the template core objects for the template.
  --
  for crec in  csr_core_objects(p_template_id) loop
    p_core_objects(crec.core_object_id) := crec;
  end loop;
end get_core_objects;
-- ----------------------------------------------------------------------------
-- |------------------------< get_exclusion_rules >---------------------------|
-- ----------------------------------------------------------------------------
procedure get_exclusion_rules
  (p_template_id     in            number
  ,p_exclusion_rules    out nocopy t_exclusion_rules
  ) is
  l_proc                varchar2(72) := g_package||'get_exclusion_rules';
  --
  cursor csr_exclusion_rules(p_template_id in number) is
    select
      exclusion_rule_id,
      template_id,
      flexfield_column,
      exclusion_value,
      description,
      object_version_number
    from  pay_template_exclusion_rules
    where template_id = p_template_id
    for update of exclusion_rule_id;
  --
begin
  for crec in csr_exclusion_rules(p_template_id) loop
    p_exclusion_rules(crec.exclusion_rule_id) := crec;
  end loop;
end get_exclusion_rules;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_element_types >---------------------------|
-- ----------------------------------------------------------------------------
procedure get_element_types
  (p_template_id                   in     number
  ,p_element_types                    out nocopy t_element_types
  ) is
  l_proc varchar2(72) := g_package||'get_element_types';
  --
  cursor csr_element_types(p_template_id in number) is
    select
      element_type_id,
      template_id,
      classification_name,
      additional_entry_allowed_flag,
      adjustment_only_flag,
      closed_for_entry_flag,
      element_name,
      indirect_only_flag,
      multiple_entries_allowed_flag,
      multiply_value_flag,
      post_termination_rule,
      process_in_run_flag,
      relative_processing_priority,
      processing_type,
      standard_link_flag,
      input_currency_code,
      output_currency_code,
      benefit_classification_name,
      description,
      qualifying_age,
      qualifying_length_of_service,
      qualifying_units,
      reporting_name,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      element_information_category,
      element_information1,
      element_information2,
      element_information3,
      element_information4,
      element_information5,
      element_information6,
      element_information7,
      element_information8,
      element_information9,
      element_information10,
      element_information11,
      element_information12,
      element_information13,
      element_information14,
      element_information15,
      element_information16,
      element_information17,
      element_information18,
      element_information19,
      element_information20,
      third_party_pay_only_flag,
      skip_formula,
      payroll_formula_id,
      exclusion_rule_id,
      iterative_flag,
      iterative_priority,
      iterative_formula_name,
      process_mode,
      grossup_flag,
      advance_indicator,
      advance_payable,
      advance_deduction,
      process_advance_entry,
      proration_group,
      proration_formula,
      recalc_event_group,
      once_each_period_flag,
      object_version_number
    from  pay_shadow_element_types
    where template_id = p_template_id
    for update of element_type_id;
begin
  for crec in csr_element_types(p_template_id) loop
    p_element_types(crec.element_type_id) := crec;
  end loop;
end get_element_types;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_balance_types >---------------------------|
-- ----------------------------------------------------------------------------
procedure get_balance_types
  (p_template_id   in            number
  ,p_balance_types    out nocopy t_balance_types
  ) is
  l_proc varchar2(72) := g_package||'get_balance_types';
  --
  cursor csr_balance_types(p_template_id in number) is
    select
      balance_type_id,
      template_id,
      assignment_remuneration_flag,
      balance_name,
      balance_uom,
      currency_code,
      comments,
      reporting_name,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      jurisdiction_level,
      tax_type,
      exclusion_rule_id,
      object_version_number,
      category_name,
      base_balance_type_id,
      base_balance_name,
      input_value_id
    from  pay_shadow_balance_types
    where template_id = p_template_id
    for update of balance_type_id;
begin
  for crec in csr_balance_types(p_template_id) loop
    p_balance_types(crec.balance_type_id) := crec;
  end loop;
end get_balance_types;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_formulas >-----------------------------|
-- ----------------------------------------------------------------------------
procedure get_formulas
  (p_template_id                   in     number
  ,p_formulas                      in out nocopy t_formulas
  ) is
  l_proc                varchar2(72) := g_package||'get_formulas';
  --
  cursor csr_set_formulas(p_template_id in number) is
  select f.formula_id
  ,      f.template_type
  ,      f.legislation_code
  ,      f.business_group_id
  ,      f.formula_name
  ,      f.description
  ,      f.formula_text
  ,      f.formula_type_name
  ,      f.object_version_number
  from  pay_shadow_formulas f
  ,     pay_shadow_element_types et
  where et.template_id = p_template_id
  and   et.payroll_formula_id is not null
  and   f.formula_id = et.payroll_formula_id
  for update of f.formula_id;
  --
  cursor csr_siv_formulas(p_template_id in number) is
  select f.formula_id
  ,      f.template_type
  ,      f.legislation_code
  ,      f.business_group_id
  ,      f.formula_name
  ,      f.description
  ,      f.formula_text
  ,      f.formula_type_name
  ,      f.object_version_number
  from  pay_shadow_formulas f
  ,     pay_shadow_element_types et
  ,	  pay_shadow_input_values iv
  where et.template_id = p_template_id
  and   et.element_type_id = iv.element_type_id
  and   iv.formula_id is not null
  and   f.formula_id = iv.formula_id
  for update of f.formula_id;
  --
  cursor csr_tfu_formulas(p_template_id in number) is
  select f.formula_id
  ,      f.template_type
  ,      f.legislation_code
  ,      f.business_group_id
  ,      f.formula_name
  ,      f.description
  ,      f.formula_text
  ,      f.formula_type_name
  ,      f.object_version_number
  from  pay_shadow_formulas f
  ,     pay_template_ff_usages tfu
  where tfu.template_id = p_template_id
  and   f.formula_id = tfu.formula_id
  for update of f.formula_id;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Element payroll formulas.
  --
  for crec in csr_set_formulas(p_template_id) loop
    p_formulas(crec.formula_id) := crec;
  end loop;

  --
  -- Input validation formulas.
  --
  for crec in csr_siv_formulas(p_template_id) loop
    p_formulas(crec.formula_id) := crec;
  end loop;

  --
  -- Template formula usages.
  --
  for crec in csr_tfu_formulas(p_template_id) loop
    p_formulas(crec.formula_id) := crec;
  end loop;

  hr_utility.set_location('Leaving:'|| l_proc, 20);
exception
  --
  -- Catch exception for overflow of the 32k buffer when reading from
  -- the LONG formula text column.
  --
  when plsql_value_error then
    hr_utility.set_location('Leaving:'|| l_proc, 30);
    fnd_message.set_name(801, 'PAY_50068_ETM_GEN_FF_TOO_LONG');
    fnd_message.set_token('BASE_NAME', '');
    fnd_message.set_token('LENGTH', 32767);
    fnd_message.raise_error;
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 40);
    raise;
end get_formulas;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_balance_feeds >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_balance_feeds
  (p_input_values                  in     t_input_values
  ,p_balance_feeds                    out nocopy t_balance_feeds
  ) is
  l_proc                varchar2(72) := g_package||'get_balance_feeds';
  l_input_value_id      number;
  i                     number;
  --
  cursor csr_balance_feeds(p_input_value_id in number) is
    select
      balance_feed_id,
      balance_type_id,
      input_value_id,
      scale,
      balance_name,
      exclusion_rule_id,
      object_version_number
    from  pay_shadow_balance_feeds
    where input_value_id = p_input_value_id
    for update of balance_feed_id;
begin
  --
  -- Exit if no balance types in the PL/SQL element template.
  --
  if p_input_values.count = 0 then
    return;
  end if;
  --
  -- For each input value get the balance feeds.
  --
  i := p_input_values.first;
  loop
    exit when not p_input_values.exists(i);
    --
    l_input_value_id := p_input_values(i).input_value_id;
    for crec in csr_balance_feeds(l_input_value_id) loop
      p_balance_feeds(crec.balance_feed_id) := crec;
    end loop;
    --
    i := p_input_values.next(i);
  end loop;
end get_balance_feeds;
-- ----------------------------------------------------------------------------
-- |------------------------< get_defined_balances >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_defined_balances
  (p_balance_types                 in     t_balance_types
  ,p_defined_balances                 out nocopy t_defined_balances
  ) is
  l_proc                varchar2(72) := g_package||'get_defined_balances';
  l_balance_type_id     number;
  i                     number;
  --
  cursor csr_defined_balances(p_balance_type_id in number) is
    select
      defined_balance_id,
      balance_type_id,
      dimension_name,
      force_latest_balance_flag,
      grossup_allowed_flag,
      object_version_number,
      exclusion_rule_id
    from  pay_shadow_defined_balances
    where balance_type_id = p_balance_type_id
    for update of defined_balance_id;
begin
  --
  -- Exit if no balance types in the PL/SQL element template.
  --
  if p_balance_types.count = 0 then
    return;
  end if;
  --
  -- For each balance type get the defined balances.
  --
  i := p_balance_types.first;
  loop
    exit when not p_balance_types.exists(i);
    --
    l_balance_type_id := p_balance_types(i).balance_type_id;
    for crec in csr_defined_balances(l_balance_type_id) loop
      p_defined_balances(crec.defined_balance_id) := crec;
    end loop;
    --
    i := p_balance_types.next(i);
  end loop;
end get_defined_balances;
-- ----------------------------------------------------------------------------
-- |------------------------< get_balance_classis >---------------------------|
-- ----------------------------------------------------------------------------
procedure get_balance_classis
  (p_balance_types                 in     t_balance_types
  ,p_balance_classis                  out nocopy t_balance_classis
  ) is
  l_proc                varchar2(72) := g_package||'get_balance_classis';
  l_balance_type_id     number;
  i                     number;
  --
  cursor csr_balance_classis(p_balance_type_id in number) is
    select
      balance_classification_id,
      balance_type_id,
      element_classification,
      scale,
      object_version_number,
      exclusion_rule_id
    from  pay_shadow_balance_classi
    where balance_type_id = p_balance_type_id
    for update of balance_classification_id;
begin
  --
  -- Exit if no balance types in the PL/SQL element template.
  --
  if p_balance_types.count = 0 then
    return;
  end if;
  --
  -- For each balance type get the balance classifications.
  --
  i := p_balance_types.first;
  loop
    exit when not p_balance_types.exists(i);
    --
    l_balance_type_id := p_balance_types(i).balance_type_id;
    for crec in csr_balance_classis(l_balance_type_id) loop
      p_balance_classis(crec.balance_classification_id) := crec;
    end loop;
    --
    i := p_balance_types.next(i);
  end loop;
end get_balance_classis;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_input_values >-----------------------------|
-- ----------------------------------------------------------------------------
procedure get_input_values
  (p_element_types                 in     t_element_types
  ,p_input_values                     out nocopy t_input_values
  ) is
  l_proc                varchar2(72) := g_package||'get_input_values';
  l_element_type_id     number;
  i                     number;
  --
  cursor csr_input_values(p_element_type_id in number) is
    select
      input_value_id,
      element_type_id,
      display_sequence,
      generate_db_items_flag,
      hot_default_flag,
      mandatory_flag,
      name,
      uom,
      lookup_type,
      default_value,
      max_value,
      min_value,
      warning_or_error,
      default_value_column,
      exclusion_rule_id,
      formula_id,
      input_validation_formula,
      object_version_number
    from  pay_shadow_input_values
    where element_type_id = p_element_type_id
    for update of input_value_id;
begin
  --
  -- Exit if no element types in the PL/SQL element template.
  --
  if p_element_types.count = 0 then
    return;
  end if;
  --
  -- For each element type get the input values.
  --
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    l_element_type_id := p_element_types(i).element_type_id;
    for crec in csr_input_values(l_element_type_id) loop
      p_input_values(crec.input_value_id) := crec;
    end loop;
    --
    i := p_element_types.next(i);
  end loop;
end get_input_values;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_formula_rules >----------------------------|
-- ----------------------------------------------------------------------------
procedure get_formula_rules
  (p_element_types                 in     t_element_types
  ,p_formula_rules                    out nocopy t_formula_rules
  ) is
  l_proc                varchar2(72) := g_package||'get_formula_rules';
  l_element_type_id     number;
  i                     number;
  --
  cursor csr_formula_rules(p_element_type_id in number) is
    select
      formula_result_rule_id,
      shadow_element_type_id,
      element_type_id,
      result_name,
      result_rule_type,
      severity_level,
      input_value_id,
      exclusion_rule_id,
      object_version_number,
      element_name
    from  pay_shadow_formula_rules
    where shadow_element_type_id = p_element_type_id
    for update of formula_result_rule_id;
begin
  --
  -- Exit if no element types in the PL/SQL element template.
  --
  if p_element_types.count = 0 then
    return;
  end if;
  --
  -- For each element type get the formula rules.
  --
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    l_element_type_id := p_element_types(i).element_type_id;
    for crec in csr_formula_rules(l_element_type_id) loop
      p_formula_rules(crec.formula_result_rule_id) := crec;
    end loop;
    --
    i := p_element_types.next(i);
  end loop;
end get_formula_rules;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_sub_classi_rules >-------------------------|
-- ----------------------------------------------------------------------------
procedure get_sub_classi_rules
  (p_element_types                 in     t_element_types
  ,p_sub_classi_rules                 out nocopy t_sub_classi_rules
  ) is
  l_proc                varchar2(72) := g_package||'get_sub_classi_rules';
  l_element_type_id     number;
  i                     number;
  --
  cursor csr_sub_classi_rules(p_element_type_id in number) is
    select
      sub_classification_rule_id,
      element_type_id,
      element_classification,
      object_version_number,
      exclusion_rule_id
    from  pay_shadow_sub_classi_rules
    where element_type_id = p_element_type_id
    for update of sub_classification_rule_id;
begin
  --
  -- Exit if no element types in the PL/SQL element template.
  --
  if p_element_types.count = 0 then
    return;
  end if;
  --
  -- For each element type get the sub-classification rules.
  --
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    l_element_type_id := p_element_types(i).element_type_id;
    for crec in csr_sub_classi_rules(l_element_type_id) loop
      p_sub_classi_rules(crec.sub_classification_rule_id) := crec;
    end loop;
    --
    i := p_element_types.next(i);
  end loop;
end get_sub_classi_rules;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_iterative_rules >----------------------------|
-- ----------------------------------------------------------------------------
procedure get_iterative_rules
  (p_element_types                 in     t_element_types
  ,p_iterative_rules                  out nocopy t_iterative_rules
  ) is
  --
  l_proc                varchar2(72) := g_package||'get_iterative_rules';
  l_element_type_id     number;
  i                     number;
  --
  cursor csr_iterative_rules(p_element_type_id in number) is
    select
      iterative_rule_id,
      element_type_id,
      result_name,
      iterative_rule_type,
      input_value_id,
      severity_level,
      exclusion_rule_id,
      object_version_number
    from  pay_shadow_iterative_rules
    where element_type_id = p_element_type_id
    for update of iterative_rule_id;
begin
  --
  -- Exit if no element types in the PL/SQL element template.
  --
  if p_element_types.count = 0 then
    return;
  end if;
  --
  -- For each element type get the iterative rules.
  --
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    l_element_type_id := p_element_types(i).element_type_id;
    for crec in csr_iterative_rules(l_element_type_id) loop
      p_iterative_rules(crec.iterative_rule_id) := crec;
    end loop;
    --
    i := p_element_types.next(i);
  end loop;
end get_iterative_rules;
-- ----------------------------------------------------------------------------
-- |-----------------------< get_ele_type_usages >----------------------------|
-- ----------------------------------------------------------------------------
procedure get_ele_type_usages
  (p_element_types                 in     t_element_types
  ,p_ele_type_usages                  out nocopy t_ele_type_usages
  ) is
  l_proc                varchar2(72) := g_package||'get_ele_type_usages';
  l_element_type_id     number;
  i                     number;
  --
  cursor csr_ele_type_usages(p_element_type_id in number) is
    select
      element_type_usage_id,
      element_type_id,
      inclusion_flag,
      run_type_name,
      exclusion_rule_id,
      object_version_number
    from  pay_shadow_ele_type_usages
    where element_type_id = p_element_type_id
    for update of element_type_usage_id;
begin
  --
  -- Exit if no element types in the PL/SQL element template.
  --
  if p_element_types.count = 0 then
    return;
  end if;
  --
  -- For each element type get the element type usages.
  --
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    l_element_type_id := p_element_types(i).element_type_id;
    for crec in csr_ele_type_usages(l_element_type_id) loop
      p_ele_type_usages(crec.element_type_usage_id) := crec;
    end loop;
    --
    i := p_element_types.next(i);
  end loop;
end get_ele_type_usages;
-- ----------------------------------------------------------------------------
-- |------------------------< get_gu_bal_exclusions>--------------------------|
-- ----------------------------------------------------------------------------
procedure get_gu_bal_exclusions
  (p_element_types                 in     t_element_types
  ,p_gu_bal_exclusions                out nocopy t_gu_bal_exclusions
  ) is
  --
  l_proc                varchar2(72) := g_package||'get_gu_bal_exclusions';
  l_element_type_id     number;
  i                     number;
  --
  cursor csr_gu_bal_exclusions(p_element_type_id in number) is
    select
      grossup_balances_id,
      source_id,
      source_type,
      balance_type_name,
      balance_type_id,
      exclusion_rule_id,
      object_version_number
    from  pay_shadow_gu_bal_exclusions
    where source_id = p_element_type_id
    for update of grossup_balances_id;
begin
  --
  -- Exit if no element types in the PL/SQL element template.
  --
  if p_element_types.count = 0 then
    return;
  end if;
  --
  -- For each element type get the grossup balance exclusions.
  --
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    l_element_type_id := p_element_types(i).element_type_id;
    for crec in csr_gu_bal_exclusions(l_element_type_id) loop
      p_gu_bal_exclusions(crec.grossup_balances_id) := crec;
    end loop;
    --
    i := p_element_types.next(i);
  end loop;
end get_gu_bal_exclusions;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_bal_attributes >---------------------------|
-- ----------------------------------------------------------------------------
procedure get_bal_attributes
  (p_defined_balances in            t_defined_balances
  ,p_bal_attributes      out nocopy t_bal_attributes
  ) is
  l_proc               varchar2(72) := g_package||'get_bal_attributes';
  l_defined_balance_id number;
  i                    number;
  --
  cursor csr_bal_attributes(p_defined_balance_id in number) is
    select
      balance_attribute_id,
      attribute_name,
      defined_balance_id,
      object_version_number,
      exclusion_rule_id
    from  pay_shadow_bal_attributes
    where defined_balance_id = p_defined_balance_id
    for update of balance_attribute_id;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Exit if no balance types in the PL/SQL element template.
  --
  if p_defined_balances.count = 0 then
    hr_utility.set_location('Leaving:'|| l_proc, 20);
    return;
  end if;
  --
  -- For each balance type get the defined balances.
  --
  i := p_defined_balances.first;
  loop
    exit when not p_defined_balances.exists(i);
    --
    l_defined_balance_id := p_defined_balances(i).defined_balance_id;
    for crec in csr_bal_attributes(l_defined_balance_id) loop
      p_bal_attributes(crec.balance_attribute_id) := crec;
    end loop;
    --
    i := p_defined_balances.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 30);
end get_bal_attributes;
-- ----------------------------------------------------------------------------
-- |-----------------------< get_template_ff_usages >-------------------------|
-- ----------------------------------------------------------------------------
procedure get_template_ff_usages
  (p_template_id        in           number
  ,p_template_ff_usages   out nocopy t_template_ff_usages
  ) is
  l_proc   varchar2(72) := g_package||'get_template_ff_usages';
  l_rec    pay_tfu_shd.g_rec_type;
  l_tfu_id binary_integer;
  --
  cursor csr_template_ff_usages(p_template_id in number) is
    select
      template_ff_usage_id,
      template_id,
      formula_id,
      object_id,
      object_version_number,
      exclusion_rule_id
    from  pay_template_ff_usages
    where template_id = p_template_id
    for update of template_ff_usage_id;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  for crec in  csr_template_ff_usages(p_template_id => p_template_id) loop
    p_template_ff_usages(crec.template_ff_usage_id) := crec;
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end get_template_ff_usages;
-- ----------------------------------------------------------------------------
-- |----------------------------< exclusion_on >------------------------------|
-- ----------------------------------------------------------------------------
function exclusion_on
  (p_element_template              in     pay_etm_shd.g_rec_type
  ,p_rec                           in     pay_ter_shd.g_rec_type
  ) return boolean is
  l_proc                varchar2(72) := g_package||'exclusion_on';
  l_exclusion_on        boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_exclusion_on := false;
  if upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION1' and
     p_element_template.configuration_information1 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION2' and
     p_element_template.configuration_information2 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION3' and
     p_element_template.configuration_information3 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION4' and
     p_element_template.configuration_information4 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION5' and
     p_element_template.configuration_information5 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION6' and
     p_element_template.configuration_information6 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION7' and
     p_element_template.configuration_information7 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION8' and
     p_element_template.configuration_information8 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION9' and
     p_element_template.configuration_information9 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION10' and
     p_element_template.configuration_information10 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION11' and
     p_element_template.configuration_information11 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION12' and
     p_element_template.configuration_information12 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION13' and
     p_element_template.configuration_information13 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION14' and
     p_element_template.configuration_information14 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION15' and
     p_element_template.configuration_information15 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION16' and
     p_element_template.configuration_information16 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION17' and
     p_element_template.configuration_information17 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION18' and
     p_element_template.configuration_information18 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION19' and
     p_element_template.configuration_information19 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION20' and
     p_element_template.configuration_information20 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION21' and
     p_element_template.configuration_information21 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION22' and
     p_element_template.configuration_information22 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION23' and
     p_element_template.configuration_information23 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION24' and
     p_element_template.configuration_information24 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION25' and
     p_element_template.configuration_information25 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION26' and
     p_element_template.configuration_information26 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION27' and
     p_element_template.configuration_information27 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION28' and
     p_element_template.configuration_information28 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION29' and
     p_element_template.configuration_information29 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  elsif upper(p_rec.flexfield_column) = 'CONFIGURATION_INFORMATION30' and
     p_element_template.configuration_information30 =
     p_rec.exclusion_value then
    l_exclusion_on := true;
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
  return l_exclusion_on;
end exclusion_on;
-- ----------------------------------------------------------------------------
-- |-----------------------< exclude_defined_balance >------------------------|
-- ----------------------------------------------------------------------------
procedure exclude_defined_balance
  (p_i                in     number
  ,p_defined_balances in out nocopy t_defined_balances
  ,p_bal_attributes   in out nocopy t_bal_attributes
  ) is
  l_proc               varchar2(72) := g_package||'exclude_defined_balance';
  l_defined_balance_id number;
  i                    number;
  j                    number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Get the defined_balance_id for this defined balance.
  --
  l_defined_balance_id := p_defined_balances(p_i).defined_balance_id;
  --
  -- Delete the defined balance.
  --
  p_defined_balances.delete(p_i);
  --
  -- Exclude any associated balance attributes.
  --
  i := p_bal_attributes.first;
  loop
    exit when not p_bal_attributes.exists(i);
    --
    if p_bal_attributes(i).defined_balance_id = l_defined_balance_id then
      j := i;
      i := p_bal_attributes.next(i);
      p_bal_attributes.delete(j);
    else
      i := p_bal_attributes.next(i);
    end if;
    --
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end exclude_defined_balance;
-- ----------------------------------------------------------------------------
-- |-------------------------< exclude_balance_type >-------------------------|
-- ----------------------------------------------------------------------------
procedure exclude_balance_type
  (p_i                             in     number
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ) is
  l_proc                varchar2(72) := g_package||'exclude_balance_type';
  l_balance_type_id     number;
  i                     number;
  j                     number;
  l_remaining_balances  t_balance_types;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Confirm that this balance has not already been excluded.
  --
  if not p_balance_types.exists(p_i) then
    return;
  end if;
  --
  -- Get the balance_type_id for this balance type.
  --
  l_balance_type_id := p_balance_types(p_i).balance_type_id;
  --
  -- Delete the balance type.
  --
  p_balance_types.delete(p_i);
  --
  -- Exclude any associated balance feeds.
  --
  i := p_balance_feeds.first;
  loop
    exit when not p_balance_feeds.exists(i);
    --
    if p_balance_feeds(i).balance_type_id is not null and
       p_balance_feeds(i).balance_type_id = l_balance_type_id then
      j := i;
      i := p_balance_feeds.next(i);
      p_balance_feeds.delete(j);
    else
      i := p_balance_feeds.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated defined balances.
  --
  i := p_defined_balances.first;
  loop
    exit when not p_defined_balances.exists(i);
    --
    if p_defined_balances(i).balance_type_id = l_balance_type_id then
      j := i;
      i := p_defined_balances.next(i);
      exclude_defined_balance
      (p_i                => j
      ,p_defined_balances => p_defined_balances
      ,p_bal_attributes   => p_bal_attributes
      );
    else
      i := p_defined_balances.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any balance classifications.
  --
  i := p_balance_classis.first;
  loop
    exit when not p_balance_classis.exists(i);
    --
    if p_balance_classis(i).balance_type_id = l_balance_type_id then
      j := i;
      i := p_balance_classis.next(i);
      p_balance_classis.delete(j);
    else
      i := p_balance_classis.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated grossup balance exclusions.
  --
  i := p_gu_bal_exclusions.first;
  loop
    exit when not p_gu_bal_exclusions.exists(i);
    --
    if p_gu_bal_exclusions(i).balance_type_id is not null and
       p_gu_bal_exclusions(i).balance_type_id = l_balance_type_id then
      j := i;
      i := p_gu_bal_exclusions.next(i);
      p_gu_bal_exclusions.delete(j);
    else
      i := p_gu_bal_exclusions.next(i);
    end if;
    --
  end loop;
  --
  -- Recursively exclude any child balances.
  --
  l_remaining_balances := p_balance_types;
  i := p_balance_types.first;
  loop
    exit when not p_balance_types.exists(i);
    --
    if p_balance_types(i).base_balance_type_id is not null and
       p_balance_types(i).base_balance_type_id = l_balance_type_id then
      --
      exclude_balance_type
      (p_i                 => i
      ,p_balance_types     => l_remaining_balances
      ,p_defined_balances  => p_defined_balances
      ,p_balance_classis   => p_balance_classis
      ,p_balance_feeds     => p_balance_feeds
      ,p_gu_bal_exclusions => p_gu_bal_exclusions
      ,p_bal_attributes    => p_bal_attributes
      );
    end if;
    --
    i := p_balance_types.next(i);
    --
  end loop;
  --
  p_balance_types := l_remaining_balances;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end exclude_balance_type;
-- ----------------------------------------------------------------------------
-- |-------------------------< exclude_input_value >--------------------------|
-- ----------------------------------------------------------------------------
procedure exclude_input_value
  (p_i                             in     number
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ) is
  l_proc                varchar2(72) := g_package||'exclude_input_value';
  l_input_value_id      number;
  i                     number;
  j                     number;
  l_remaining_balances  t_balance_types;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Get the input_value_id for this input value.
  --
  l_input_value_id := p_input_values(p_i).input_value_id;
  --
  -- Delete the input value.
  --
  p_input_values.delete(p_i);
  --
  -- Exclude any associated formula result rules.
  --
  i := p_formula_rules.first;
  loop
    exit when not p_formula_rules.exists(i);
    --
    if p_formula_rules(i).input_value_id is not null and
       p_formula_rules(i).input_value_id = l_input_value_id then
      j := i;
      i := p_formula_rules.next(i);
      p_formula_rules.delete(j);
    else
      i := p_formula_rules.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated balance feeds.
  --
  i := p_balance_feeds.first;
  loop
    exit when not p_balance_feeds.exists(i);
    --
    if p_balance_feeds(i).input_value_id = l_input_value_id then
      j := i;
      i := p_balance_feeds.next(i);
      p_balance_feeds.delete(j);
    else
      i := p_balance_feeds.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated iterative rules.
  --
  i := p_iterative_rules.first;
  loop
    exit when not p_iterative_rules.exists(i);
    --
    if p_iterative_rules(i).input_value_id = l_input_value_id then
      j := i;
      i := p_iterative_rules.next(i);
      p_iterative_rules.delete(j);
    else
      i := p_iterative_rules.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude the balance types that reference this input value.
  --
  l_remaining_balances := p_balance_types;
  i := p_balance_types.first;
  loop
    exit when not p_balance_types.exists(i);
    --
    if p_balance_types(i).input_value_id = l_input_value_id then
      exclude_balance_type
      (p_i                 => i
      ,p_balance_types     => l_remaining_balances
      ,p_defined_balances  => p_defined_balances
      ,p_balance_classis   => p_balance_classis
      ,p_balance_feeds     => p_balance_feeds
      ,p_gu_bal_exclusions => p_gu_bal_exclusions
      ,p_bal_attributes    => p_bal_attributes
      );
    end if;
    --
    i := p_balance_types.next(i);
    --
  end loop;
  --
  p_balance_types := l_remaining_balances;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end exclude_input_value;
-- ----------------------------------------------------------------------------
-- |-------------------------< exclude_element_type >-------------------------|
-- ----------------------------------------------------------------------------
procedure exclude_element_type
  (p_i                             in     number
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  ) is
  l_proc                varchar2(72) := g_package||'exclude_element_type';
  l_element_type_id     number;
  i                     number;
  j                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Get the element_type_id for this element type.
  --
  l_element_type_id := p_element_types(p_i).element_type_id;
  --
  -- Delete the element type.
  --
  p_element_types.delete(p_i);
  --
  -- Exclude any associated formula result rules.
  --
  i := p_formula_rules.first;
  loop
    exit when not p_formula_rules.exists(i);
    --
    if (p_formula_rules(i).shadow_element_type_id = l_element_type_id) or
       (p_formula_rules(i).element_type_id is not null and
        p_formula_rules(i).element_type_id = l_element_type_id) then
      j := i;
      i := p_formula_rules.next(i);
      p_formula_rules.delete(j);
    else
      i := p_formula_rules.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated input values.
  --
  i := p_input_values.first;
  loop
    exit when not p_input_values.exists(i);
    --
    if p_input_values(i).element_type_id = l_element_type_id then
      j := i;
      i := p_input_values.next(i);
      exclude_input_value
      (p_i                           => j
      ,p_input_values                => p_input_values
      ,p_balance_feeds               => p_balance_feeds
      ,p_formula_rules               => p_formula_rules
      ,p_iterative_rules             => p_iterative_rules
      ,p_balance_types               => p_balance_types
      ,p_defined_balances            => p_defined_balances
      ,p_balance_classis             => p_balance_classis
      ,p_gu_bal_exclusions           => p_gu_bal_exclusions
      ,p_bal_attributes              => p_bal_attributes
      );
    else
      i := p_input_values.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated sub-classification rules.
  --
  i := p_sub_classi_rules.first;
  loop
    exit when not p_sub_classi_rules.exists(i);
    --
    if p_sub_classi_rules(i).element_type_id = l_element_type_id then
      j := i;
      i := p_sub_classi_rules.next(i);
      p_sub_classi_rules.delete(j);
    else
      i := p_sub_classi_rules.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated iterative rules.
  --
  i := p_iterative_rules.first;
  loop
    exit when not p_iterative_rules.exists(i);
    --
    if p_iterative_rules(i).element_type_id = l_element_type_id then
      j := i;
      i := p_iterative_rules.next(i);
      p_iterative_rules.delete(j);
    else
      i := p_iterative_rules.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated element type usages.
  --
  i := p_ele_type_usages.first;
  loop
    exit when not p_ele_type_usages.exists(i);
    --
    if p_ele_type_usages(i).element_type_id = l_element_type_id then
      j := i;
      i := p_ele_type_usages.next(i);
      p_ele_type_usages.delete(j);
    else
      i := p_ele_type_usages.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated grossup balance exclusions.
  --
  i := p_gu_bal_exclusions.first;
  loop
    exit when not p_gu_bal_exclusions.exists(i);
    --
    if p_gu_bal_exclusions(i).source_id = l_element_type_id then
      j := i;
      i := p_gu_bal_exclusions.next(i);
      p_gu_bal_exclusions.delete(j);
    else
      i := p_gu_bal_exclusions.next(i);
    end if;
    --
  end loop;
  --
  -- Exclude any associated template formula usages.
  --
  i := p_template_ff_usages.first;
  loop
    exit when not p_template_ff_usages.exists(i);
    --
    if p_template_ff_usages(i).object_id = l_element_type_id then
      j := i;
      i := p_template_ff_usages.next(i);
      p_template_ff_usages.delete(j);
    else
      i := p_template_ff_usages.next(i);
    end if;
    --
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end exclude_element_type;
-- ----------------------------------------------------------------------------
-- |--------------------------< exclude_formulas >----------------------------|
-- ----------------------------------------------------------------------------
procedure exclude_formulas
  (p_formulas           in out nocopy t_formulas
  ,p_element_types      in out nocopy t_element_types
  ,p_input_values       in out nocopy t_input_values
  ) is
  l_proc                varchar2(72) := g_package||'exclude_formulas';
  l_formula_id          number;
  l_formula_not_used    boolean;
  i                     number;
  j                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_formulas.first;
  loop
    exit when not p_formulas.exists(i);
    --
    l_formula_id := p_formulas(i).formula_id;
    l_formula_not_used := true;
    --
    -- Check to see if the formula is used by any element types.
    --
    j := p_element_types.first;
    loop
      exit when not p_element_types.exists(j);
      --
      if p_element_types(j).payroll_formula_id = l_formula_id then
        l_formula_not_used := false;
        exit;
      end if;
      --
      j := p_element_types.next(j);
    end loop;
    --
    -- Check to see if the formula is used by any input values.
    --
    if l_formula_not_used then
      j := p_input_values.first;
      loop
        exit when not p_input_values.exists(j);
        --
        if p_input_values(j).formula_id = l_formula_id then
          l_formula_not_used := false;
          exit;
        end if;
        --
        j := p_input_values.next(j);
      end loop;
    end if;
    --
    if l_formula_not_used then
      j := i;
      i := p_formulas.next(i);
      p_formulas.delete(j);
    else
      i := p_formulas.next(i);
    end if;
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 50);
end exclude_formulas;
-- ----------------------------------------------------------------------------
-- |----------------------------< apply_ff_usages >---------------------------|
-- ----------------------------------------------------------------------------
procedure apply_ff_usages
(p_template_ff_usages in out nocopy t_template_ff_usages
,p_element_types      in out nocopy t_element_types
) is
i         number;
j         number;
k         number;
l_applied t_element_types;
begin
  i := p_template_ff_usages.first;
  loop
    exit when not p_template_ff_usages.exists(i);
    --
    -- Check to see if the formula is used by any element types.
    --
    j := p_element_types.first;
    loop
      exit when not p_element_types.exists(j);
      --
      if p_element_types(j).element_type_id = p_template_ff_usages(i).object_id
      then
        if l_applied.exists(j) then
          --
          -- A formula usage has already been applied to this element. This
          -- means that the exclusion rules were not applied correctly.
          --
          fnd_message.set_name(801, 'PAY_50206_MULTIPLE_FF_USAGES');
          fnd_message.set_token('TABLE', 'PAY_SHADOW_ELEMENT_TYPES');
          fnd_message.raise_error;
        else
          p_element_types(j).payroll_formula_id :=
          p_template_ff_usages(i).formula_id;
          l_applied(j) := p_element_types(j);
        end if;
      end if;
      --
      j := p_element_types.next(j);
    end loop;
    --
    i := p_template_ff_usages.next(i);
  end loop;
  --
  -- All the formula usages have been successfully applied now.
  --
  p_template_ff_usages.delete;
end apply_ff_usages;
-- ----------------------------------------------------------------------------
-- |-----------------------< apply_exclusion_rules >--------------------------|
-- ----------------------------------------------------------------------------
procedure apply_exclusion_rules
  (p_element_template              in     pay_etm_shd.g_rec_type
  ,p_exclusion_rules               in     t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  ) is
  l_proc                varchar2(72) := g_package||'apply_exclusion_rules';
  i                     number;
  j                     number;
  k                     number;
  l_exclusion_rule_id   number;
  l_remaining_balances  t_balance_types;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_exclusion_rules.first;
  loop
    exit when not p_exclusion_rules.exists(i);
    if exclusion_on(p_element_template, p_exclusion_rules(i)) then
      l_exclusion_rule_id := p_exclusion_rules(i).exclusion_rule_id;
      --
      -- Exclude element types.
      --
      j := p_element_types.first;
      loop
        exit when not p_element_types.exists(j);
        --
        if p_element_types(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_element_types.next(j);
          exclude_element_type
          (p_i                           => k
          ,p_element_types               => p_element_types
          ,p_sub_classi_rules            => p_sub_classi_rules
          ,p_input_values                => p_input_values
          ,p_balance_feeds               => p_balance_feeds
          ,p_formula_rules               => p_formula_rules
          ,p_iterative_rules             => p_iterative_rules
          ,p_ele_type_usages             => p_ele_type_usages
          ,p_balance_types               => p_balance_types
          ,p_defined_balances            => p_defined_balances
          ,p_balance_classis             => p_balance_classis
          ,p_gu_bal_exclusions           => p_gu_bal_exclusions
          ,p_bal_attributes              => p_bal_attributes
          ,p_template_ff_usages          => p_template_ff_usages
          );
        else
          j := p_element_types.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude input values. Moved ahead of balance types because
      -- balance types have an input_value_id column.
      --
      j := p_input_values.first;
      loop
        exit when not p_input_values.exists(j);
        --
        if p_input_values(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_input_values.next(j);
          exclude_input_value
          (p_i                           => k
          ,p_input_values                => p_input_values
          ,p_balance_feeds               => p_balance_feeds
          ,p_formula_rules               => p_formula_rules
          ,p_iterative_rules             => p_iterative_rules
          ,p_balance_types               => p_balance_types
          ,p_defined_balances            => p_defined_balances
          ,p_balance_classis             => p_balance_classis
          ,p_gu_bal_exclusions           => p_gu_bal_exclusions
          ,p_bal_attributes              => p_bal_attributes
          );
        else
          j := p_input_values.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude balance types.
      --
      l_remaining_balances := p_balance_types;
      j := p_balance_types.first;
      loop
        exit when not p_balance_types.exists(j);
        --
        if p_balance_types(j).exclusion_rule_id = l_exclusion_rule_id then
          exclude_balance_type
          (p_i                 => j
          ,p_balance_types     => l_remaining_balances
          ,p_defined_balances  => p_defined_balances
          ,p_balance_classis   => p_balance_classis
          ,p_balance_feeds     => p_balance_feeds
          ,p_gu_bal_exclusions => p_gu_bal_exclusions
          ,p_bal_attributes    => p_bal_attributes
          );
        end if;
        --
        j := p_balance_types.next(j);
        --
      end loop;
      --
      p_balance_types := l_remaining_balances;
      --
      -- Exclude formula rules.
      --
      j := p_formula_rules.first;
      loop
        exit when not p_formula_rules.exists(j);
        --
        if p_formula_rules(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_formula_rules.next(j);
          p_formula_rules.delete(k);
        else
          j := p_formula_rules.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude balance feeds.
      --
      j := p_balance_feeds.first;
      loop
        exit when not p_balance_feeds.exists(j);
        --
        if p_balance_feeds(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_balance_feeds.next(j);
          p_balance_feeds.delete(k);
        else
          j := p_balance_feeds.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude balance classifications.
      --
      j := p_balance_classis.first;
      loop
        exit when not p_balance_classis.exists(j);
        --
        if p_balance_classis(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_balance_classis.next(j);
          p_balance_classis.delete(k);
        else
          j := p_balance_classis.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude defined balances.
      --
      j := p_defined_balances.first;
      loop
        exit when not p_defined_balances.exists(j);
        --
        if p_defined_balances(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_defined_balances.next(j);
          exclude_defined_balance
          (p_i                => k
          ,p_defined_balances => p_defined_balances
          ,p_bal_attributes   => p_bal_attributes
          );
        else
          j := p_defined_balances.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude sub-classification rules.
      --
      j := p_sub_classi_rules.first;
      loop
        exit when not p_sub_classi_rules.exists(j);
        --
        if p_sub_classi_rules(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_sub_classi_rules.next(j);
          p_sub_classi_rules.delete(k);
        else
          j := p_sub_classi_rules.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude iterative rules.
      --
      j := p_iterative_rules.first;
      loop
        exit when not p_iterative_rules.exists(j);
        --
        if p_iterative_rules(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_iterative_rules.next(j);
          p_iterative_rules.delete(k);
        else
          j := p_iterative_rules.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude element type usages
      --
      j := p_ele_type_usages.first;
      loop
        exit when not p_ele_type_usages.exists(j);
        --
        if p_ele_type_usages(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_ele_type_usages.next(j);
          p_ele_type_usages.delete(k);
        else
          j := p_ele_type_usages.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude grossup balance exclusions
      --
      j := p_gu_bal_exclusions.first;
      loop
        exit when not p_gu_bal_exclusions.exists(j);
        --
        if p_gu_bal_exclusions(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_gu_bal_exclusions.next(j);
          p_gu_bal_exclusions.delete(k);
        else
          j := p_gu_bal_exclusions.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude template ff usages.
      --
      j := p_template_ff_usages.first;
      loop
        exit when not p_template_ff_usages.exists(j);
        --
        if p_template_ff_usages(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_template_ff_usages.next(j);
          p_template_ff_usages.delete(k);
        else
          j := p_template_ff_usages.next(j);
        end if;
        --
      end loop;
      --
      -- Exclude balance attributes.
      --
      j := p_bal_attributes.first;
      loop
        exit when not p_bal_attributes.exists(j);
        --
        if p_bal_attributes(j).exclusion_rule_id = l_exclusion_rule_id then
          k := j;
          j := p_bal_attributes.next(j);
          p_bal_attributes.delete(k);
        else
          j := p_bal_attributes.next(j);
        end if;
        --
      end loop;
    end if;
    i := p_exclusion_rules.next(i);
  end loop;
  --
  -- Apply the template formula usages.
  --
  apply_ff_usages
  (p_template_ff_usages => p_template_ff_usages
  ,p_element_types      => p_element_types
  );
  --
  -- Exclusion rules have been applied. Now take out the formulas that
  -- have no references in the template.
  --
  exclude_formulas
  (p_formulas           => p_formulas
  ,p_element_types      => p_element_types
  ,p_input_values       => p_input_values
  );
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end apply_exclusion_rules;
-- ----------------------------------------------------------------------------
-- |----------------------< set_input_value_defaults >------------------------|
-- ----------------------------------------------------------------------------
procedure set_input_value_defaults
  (p_element_template              in     pay_etm_shd.g_rec_type
  ,p_input_values                  in out nocopy t_input_values
  ) is
  l_proc                varchar2(72) := g_package||'set_input_value_defaults';
  i                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_input_values.first;
  loop
    exit when not p_input_values.exists(i);
    --
    if p_input_values(i).default_value_column is not null then
      if upper(p_input_values(i).default_value_column) =
         'CONFIGURATION_INFORMATION1'
         and p_element_template.configuration_information1 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information1;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION2' and
            p_element_template.configuration_information2 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information2;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION3' and
            p_element_template.configuration_information3 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information3;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION4' and
            p_element_template.configuration_information4 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information4;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION5' and
            p_element_template.configuration_information5 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information5;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION6' and
            p_element_template.configuration_information6 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information6;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION7' and
            p_element_template.configuration_information7 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information7;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION8' and
            p_element_template.configuration_information8 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information8;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION9' and
            p_element_template.configuration_information9 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information9;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION10' and
            p_element_template.configuration_information10 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information10;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION11' and
            p_element_template.configuration_information11 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information11;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION12' and
            p_element_template.configuration_information12 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information12;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION13' and
            p_element_template.configuration_information13 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information13;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION14' and
            p_element_template.configuration_information14 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information14;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION15' and
            p_element_template.configuration_information15 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information15;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION16' and
            p_element_template.configuration_information16 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information16;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION17' and
            p_element_template.configuration_information17 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information17;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION18' and
            p_element_template.configuration_information18 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information18;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION19' and
            p_element_template.configuration_information19 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information19;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION20' and
            p_element_template.configuration_information20 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information20;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION21' and
        p_element_template.configuration_information21 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information21;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION22' and
            p_element_template.configuration_information22 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information22;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION23' and
            p_element_template.configuration_information23 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information23;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION24' and
            p_element_template.configuration_information24 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information24;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION25' and
            p_element_template.configuration_information25 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information25;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION26' and
            p_element_template.configuration_information26 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information26;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION27' and
            p_element_template.configuration_information27 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information27;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION28' and
            p_element_template.configuration_information28 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information28;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION29' and
            p_element_template.configuration_information29 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information29;
      elsif upper(p_input_values(i).default_value_column) =
            'CONFIGURATION_INFORMATION30' and
            p_element_template.configuration_information30 is not null then
        p_input_values(i).default_value :=
        p_element_template.configuration_information30;
      end if;
    end if;
    --
    i := p_input_values.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end set_input_value_defaults;
-- ----------------------------------------------------------------------------
-- |------------------------< create_plsql_template >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_plsql_template
  (p_lock                          in     boolean default false
  ,p_template_id                   in     number
  ,p_generate_part1                in     boolean default false
  ,p_generate_part2                in     boolean default false
  ,p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_core_objects                  in out nocopy t_core_objects
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  ) is
  l_proc                varchar2(72) := g_package||'create_plsql_template';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  savepoint create_plsql_template;
  --
  -- Get the shadow schema rows in locking ladder order.
  --
  get_element_template
  (p_template_id                  => p_template_id
  ,p_element_template             => p_element_template
  );
  get_core_objects
  (p_template_id                  => p_template_id
  ,p_core_objects                 => p_core_objects
  );
  --
  if not p_generate_part1 and not p_generate_part2 then
    get_exclusion_rules
    (p_template_id                  => p_template_id
    ,p_exclusion_rules              => p_exclusion_rules
    );
  end if;
  --
  if not p_generate_part2 then
    get_formulas
    (p_template_id                  => p_template_id
    ,p_formulas                     => p_formulas
    );
    get_balance_types
    (p_template_id                  => p_template_id
    ,p_balance_types                => p_balance_types
    );
    get_defined_balances
    (p_balance_types                => p_balance_types
    ,p_defined_balances             => p_defined_balances
    );
  end if;
  --
  get_element_types
  (p_template_id                  => p_template_id
  ,p_element_types                => p_element_types
  );
  --
  if not p_generate_part2 then
    get_sub_classi_rules
    (p_element_types                => p_element_types
    ,p_sub_classi_rules             => p_sub_classi_rules
    );
    get_balance_classis
    (p_balance_types                => p_balance_types
    ,p_balance_classis              => p_balance_classis
    );
    get_input_values
    (p_element_types                => p_element_types
    ,p_input_values                 => p_input_values
    );
    get_balance_feeds
    (p_input_values                 => p_input_values
    ,p_balance_feeds                => p_balance_feeds
    );
  end if;
  --
  if not p_generate_part1 then
    get_formula_rules
    (p_element_types                => p_element_types
    ,p_formula_rules                => p_formula_rules
    );
    get_iterative_rules
    (p_element_types                => p_element_types
    ,p_iterative_rules              => p_iterative_rules
    );
  end if;
  --
  if not p_generate_part2 then
    get_ele_type_usages
    (p_element_types                => p_element_types
    ,p_ele_type_usages              => p_ele_type_usages
    );
    get_gu_bal_exclusions
    (p_element_types                => p_element_types
    ,p_gu_bal_exclusions            => p_gu_bal_exclusions
    );
  end if;
  --
  if not p_generate_part1 and not p_generate_part2 then
    get_template_ff_usages
    (p_template_id                  => p_template_id
    ,p_template_ff_usages           => p_template_ff_usages
    );
  end if;
  --
  if not p_generate_part2 then
    get_bal_attributes
    (p_defined_balances             => p_defined_balances
    ,p_bal_attributes               => p_bal_attributes
    );
  end if;
  --
  -- Release locks if required.
  --
  if not p_lock then
    --
    -- Release locks.
    --
    rollback to create_plsql_template;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 90);
exception
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 100);
    flush_plsql_template
    (p_element_template             => p_element_template
    ,p_core_objects                 => p_core_objects
    ,p_formulas                     => p_formulas
    ,p_exclusion_rules              => p_exclusion_rules
    ,p_balance_types                => p_balance_types
    ,p_defined_balances             => p_defined_balances
    ,p_element_types                => p_element_types
    ,p_sub_classi_rules             => p_sub_classi_rules
    ,p_balance_classis              => p_balance_classis
    ,p_input_values                 => p_input_values
    ,p_balance_feeds                => p_balance_feeds
    ,p_formula_rules                => p_formula_rules
    ,p_iterative_rules              => p_iterative_rules
    ,p_ele_type_usages              => p_ele_type_usages
    ,p_gu_bal_exclusions            => p_gu_bal_exclusions
    ,p_bal_attributes               => p_bal_attributes
    ,p_template_ff_usages           => p_template_ff_usages
    );
    --
    -- Release locks.
    --
    rollback to create_plsql_template;
    raise;
end create_plsql_template;
-- ----------------------------------------------------------------------------
-- |------------------------< insert_balance_type >---------------------------|
-- ----------------------------------------------------------------------------
procedure insert_balance_type
(p_effective_date  in            date
,p_balance_type_id in            number
,p_template_id     in            number
,p_input_values    in            t_input_values
,p_balance_types   in out nocopy t_balance_types
) is
l_id number;
begin
  --
  -- Return if this balance type has already been inserted (this is possible
  -- if it is the base balance for another balance type).
  --
  if p_balance_types(p_balance_type_id).balance_type_id <> p_balance_type_id
  then
    return;
  end if;
  --
  -- Go ahead and insert the balance type.
  --
  p_balance_types(p_balance_type_id).balance_type_id := null;
  p_balance_types(p_balance_type_id).object_version_number := null;
  p_balance_types(p_balance_type_id).exclusion_rule_id := null;
  --
  p_balance_types(p_balance_type_id).template_id := p_template_id;
  --
  l_id  := p_balance_types(p_balance_type_id).input_value_id;
  if l_id is not null then
    p_balance_types(p_balance_type_id).input_value_id :=
    p_input_values(l_id).input_value_id;
  end if;
  --
  l_id  := p_balance_types(p_balance_type_id).base_balance_type_id;
  if l_id is not null then
    --
    -- Recursively insert the base balance if it has not been already created.
    --
    if l_id = p_balance_types(l_id).balance_type_id then
      insert_balance_type
      (p_effective_date  => p_effective_date
      ,p_balance_type_id => l_id
      ,p_template_id     => p_template_id
      ,p_input_values    => p_input_values
      ,p_balance_types   => p_balance_types
      );
    end if;
    p_balance_types(p_balance_type_id).base_balance_type_id :=
    p_balance_types(l_id).balance_type_id;
  end if;
  --
  pay_sbt_ins.ins(p_effective_date, p_balance_types(p_balance_type_id));
  --
end insert_balance_type;
-- ----------------------------------------------------------------------------
-- |------------------------< plsql_to_db_template >--------------------------|
-- ----------------------------------------------------------------------------
procedure plsql_to_db_template
  (p_effective_date                in     date
  ,p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  l_proc                varchar2(72) := g_package||'plsql_to_db_template';
  l_id                  number;
  i                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  ------------------------------------------
  -- Create row in pay_element_templates. --
  ------------------------------------------
  p_element_template.template_id := null;
  p_element_template.object_version_number := null;
  pay_etm_ins.ins(p_effective_date, p_element_template);
  p_template_id := p_element_template.template_id;
  p_object_version_number := p_element_template.object_version_number;
  -----------------------------------
  -- Create the template formulas. --
  -----------------------------------
  hr_utility.set_location(l_proc, 20);
  i := p_formulas.first;
  loop
    exit when not p_formulas.exists(i);
    --
    p_formulas(i).formula_id := null;
    p_formulas(i).object_version_number := null;
    pay_sf_ins.ins(p_effective_date, p_formulas(i));
    --
    i := p_formulas.next(i);
  end loop;
  -------------------------------
  -- Create the element types. --
  -------------------------------
  hr_utility.set_location(l_proc, 30);
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    p_element_types(i).element_type_id := null;
    p_element_types(i).object_version_number := null;
    p_element_types(i).exclusion_rule_id := null;
    --
    p_element_types(i).template_id := p_element_template.template_id;
    l_id := p_element_types(i).payroll_formula_id;
    if l_id is not null then
      p_element_types(i).payroll_formula_id := p_formulas(l_id).formula_id;
    end if;
    pay_set_ins.ins(p_effective_date, p_element_types(i));
    --
    i := p_element_types.next(i);
  end loop;
  ------------------------------
  -- Create the input values. --
  ------------------------------
  hr_utility.set_location(l_proc, 40);
  i := p_input_values.first;
  loop
    exit when not p_input_values.exists(i);
    --
    p_input_values(i).input_value_id := null;
    p_input_values(i).object_version_number := null;
    p_input_values(i).exclusion_rule_id := null;
    --
    l_id := p_input_values(i).element_type_id;
    p_input_values(i).element_type_id := p_element_types(l_id).element_type_id;
    --
    l_id := p_input_values(i).formula_id;
    if l_id is not null then
      p_input_values(i).formula_id := p_formulas(l_id).formula_id;
    end if;
    pay_siv_ins.ins(p_effective_date, p_input_values(i));
    --
    i := p_input_values.next(i);
  end loop;
  -------------------------------
  -- Create the balance types. --
  -------------------------------
  hr_utility.set_location(l_proc, 50);
  i := p_balance_types.first;
  loop
    exit when not p_balance_types.exists(i);
    --
    insert_balance_type
    (p_effective_date  => p_effective_date
    ,p_balance_type_id => i
    ,p_template_id     => p_element_template.template_id
    ,p_input_values    => p_input_values
    ,p_balance_types   => p_balance_types
    );
    --
    i := p_balance_types.next(i);
  end loop;
  ------------------------------------------
  -- Create the sub-classification rules. --
  ------------------------------------------
  hr_utility.set_location(l_proc, 60);
  i := p_sub_classi_rules.first;
  loop
    exit when not p_sub_classi_rules.exists(i);
    --
    p_sub_classi_rules(i).sub_classification_rule_id := null;
    p_sub_classi_rules(i).object_version_number := null;
    p_sub_classi_rules(i).exclusion_rule_id := null;
    --
    l_id := p_sub_classi_rules(i).element_type_id;
    p_sub_classi_rules(i).element_type_id :=
    p_element_types(l_id).element_type_id;
    pay_ssr_ins.ins(p_effective_date, p_sub_classi_rules(i));
    --
    i := p_sub_classi_rules.next(i);
  end loop;
  --------------------------------------
  -- Create the formula result rules. --
  --------------------------------------
  hr_utility.set_location(l_proc, 70);
  i := p_formula_rules.first;
  loop
    exit when not p_formula_rules.exists(i);
    --
    p_formula_rules(i).formula_result_rule_id := null;
    p_formula_rules(i).object_version_number := null;
    p_formula_rules(i).exclusion_rule_id := null;
    --
    l_id := p_formula_rules(i).shadow_element_type_id;
    p_formula_rules(i).shadow_element_type_id :=
    p_element_types(l_id).element_type_id;
    l_id  := p_formula_rules(i).element_type_id;
    if l_id is not null then
      p_formula_rules(i).element_type_id :=
      p_element_types(l_id).element_type_id;
    end if;
    l_id  := p_formula_rules(i).input_value_id;
    if l_id is not null then
      p_formula_rules(i).input_value_id :=
      p_input_values(l_id).input_value_id;
    end if;
    pay_sfr_ins.ins(p_effective_date, p_formula_rules(i));
    --
    i := p_formula_rules.next(i);
  end loop;
  -----------------------------------------
  -- Create the balance classifications. --
  -----------------------------------------
  hr_utility.set_location(l_proc, 80);
  i := p_balance_classis.first;
  loop
    exit when not p_balance_classis.exists(i);
    --
    p_balance_classis(i).balance_classification_id := null;
    p_balance_classis(i).object_version_number := null;
    p_balance_classis(i).exclusion_rule_id := null;
    --
    l_id := p_balance_classis(i).balance_type_id;
    p_balance_classis(i).balance_type_id :=
    p_balance_types(l_id).balance_type_id;
    pay_sbc_ins.ins(p_effective_date, p_balance_classis(i));
    --
    i := p_balance_classis.next(i);
  end loop;
  ----------------------------------
  -- Create the defined balances. --
  ----------------------------------
  hr_utility.set_location(l_proc, 90);
  i := p_defined_balances.first;
  loop
    exit when not p_defined_balances.exists(i);
    --
    p_defined_balances(i).defined_balance_id := null;
    p_defined_balances(i).object_version_number := null;
    p_defined_balances(i).exclusion_rule_id := null;
    --
    l_id := p_defined_balances(i).balance_type_id;
    p_defined_balances(i).balance_type_id :=
    p_balance_types(l_id).balance_type_id;
    pay_sdb_ins.ins(p_effective_date, p_defined_balances(i));
    --
    i := p_defined_balances.next(i);
  end loop;
  -------------------------------
  -- Create the balance feeds. --
  -------------------------------
  hr_utility.set_location(l_proc, 100);
  i := p_balance_feeds.first;
  loop
    exit when not p_balance_feeds.exists(i);
    --
    p_balance_feeds(i).balance_feed_id := null;
    p_balance_feeds(i).object_version_number := null;
    p_balance_feeds(i).exclusion_rule_id := null;
    --
    l_id := p_balance_feeds(i).balance_type_id;
    if l_id is not null then
      p_balance_feeds(i).balance_type_id :=
      p_balance_types(l_id).balance_type_id;
    end if;
    l_id := p_balance_feeds(i).input_value_id;
    p_balance_feeds(i).input_value_id := p_input_values(l_id).input_value_id;
    pay_sbf_ins.ins(p_effective_date, p_balance_feeds(i));
    --
    i := p_balance_feeds.next(i);
  end loop;
  ---------------------------------
  -- Create the iterative rules. --
  ---------------------------------
  hr_utility.set_location(l_proc, 110);
  i := p_iterative_rules.first;
  loop
    exit when not p_iterative_rules.exists(i);
    --
    p_iterative_rules(i).iterative_rule_id := null;
    p_iterative_rules(i).object_version_number := null;
    p_iterative_rules(i).exclusion_rule_id := null;
    --
    l_id  := p_iterative_rules(i).input_value_id;
    if l_id is not null then
      p_iterative_rules(i).input_value_id :=
      p_input_values(l_id).input_value_id;
    end if;
    l_id := p_iterative_rules(i).element_type_id;
    p_iterative_rules(i).element_type_id := p_element_types(l_id).element_type_id;
    pay_sir_ins.ins(p_effective_date, p_iterative_rules(i));
    --
    i := p_iterative_rules.next(i);
  end loop;
  -------------------------------------
  -- Create the element type usages. --
  -------------------------------------
  hr_utility.set_location(l_proc, 120);
  i := p_ele_type_usages.first;
  loop
    exit when not p_ele_type_usages.exists(i);
    --
    p_ele_type_usages(i).element_type_usage_id := null;
    p_ele_type_usages(i).object_version_number := null;
    p_ele_type_usages(i).exclusion_rule_id := null;
    --
    l_id := p_ele_type_usages(i).element_type_id;
    p_ele_type_usages(i).element_type_id := p_element_types(l_id).element_type_id;
    pay_seu_ins.ins(p_effective_date, p_ele_type_usages(i));
    --
    i := p_ele_type_usages.next(i);
  end loop;
  --------------------------------------------
  -- Create the grossup balance exclusions. --
  --------------------------------------------
  hr_utility.set_location(l_proc, 130);
  i := p_gu_bal_exclusions.first;
  loop
    exit when not p_gu_bal_exclusions.exists(i);
    --
    p_gu_bal_exclusions(i).grossup_balances_id := null;
    p_gu_bal_exclusions(i).object_version_number := null;
    p_gu_bal_exclusions(i).exclusion_rule_id := null;
    --
    l_id := p_gu_bal_exclusions(i).balance_type_id;
    if l_id is not null then
      p_gu_bal_exclusions(i).balance_type_id :=
      p_balance_types(l_id).balance_type_id;
    end if;
    l_id  := p_gu_bal_exclusions(i).source_id;
    p_gu_bal_exclusions(i).source_id := p_element_types(l_id).element_type_id;
    pay_sgb_ins.ins(p_effective_date, p_gu_bal_exclusions(i));
    --
    i := p_gu_bal_exclusions.next(i);
  end loop;
  ------------------------------------
  -- Create the balance attributes. --
  ------------------------------------
  hr_utility.set_location(l_proc, 140);
  i := p_bal_attributes.first;
  loop
    exit when not p_bal_attributes.exists(i);
    --
    p_bal_attributes(i).balance_attribute_id := null;
    p_bal_attributes(i).object_version_number := null;
    p_bal_attributes(i).exclusion_rule_id := null;
    --
    l_id := p_bal_attributes(i).defined_balance_id;
    if l_id is not null then
      p_bal_attributes(i).defined_balance_id :=
      p_defined_balances(l_id).defined_balance_id;
    end if;
    pay_sba_ins.ins(p_bal_attributes(i));
    --
    i := p_bal_attributes.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 500);
end plsql_to_db_template;
-- ----------------------------------------------------------------------------
-- |---------------------------< replace_name >-------------------------------|
-- ----------------------------------------------------------------------------
procedure replace_name
  (p_string                        in out nocopy varchar2
  ,p_base_name                     in     varchar2
  ,p_string_length                 in     number
  ) is
  l_proc               varchar2(72) := g_package||'replace_name';
  l_temp_string        varchar2(32767);
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_temp_string := replace(p_string, g_name_placeholder, p_base_name);
  p_string := hr_mb_substrb(l_temp_string, 1, p_string_length);
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end replace_name;
-- ----------------------------------------------------------------------------
-- |---------------------------< prefix_name >--------------------------------|
-- ----------------------------------------------------------------------------
procedure prefix_name
  (p_string                        in out nocopy varchar2
  ,p_maximum_string_length         in     number
  ,p_prefix                        in     varchar2
  ) is
  l_proc               varchar2(72) := g_package||'prefix_name';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Preserve the prefix at the expense of the suffix.
  --
  p_string :=
  hr_mb_substrb(p_prefix || p_string, 1, p_maximum_string_length);
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end prefix_name;
-- ----------------------------------------------------------------------------
-- |-------------------< create_plsql_user_structure >------------------------|
-- ----------------------------------------------------------------------------
procedure create_plsql_user_structure
  (p_business_group_id             in     number
  ,p_base_name                     in     varchar2
  ,p_base_processing_priority      in     number   default null
  ,p_preference_info_category      in     varchar2 default null
  ,p_preference_information1       in     varchar2 default null
  ,p_preference_information2       in     varchar2 default null
  ,p_preference_information3       in     varchar2 default null
  ,p_preference_information4       in     varchar2 default null
  ,p_preference_information5       in     varchar2 default null
  ,p_preference_information6       in     varchar2 default null
  ,p_preference_information7       in     varchar2 default null
  ,p_preference_information8       in     varchar2 default null
  ,p_preference_information9       in     varchar2 default null
  ,p_preference_information10      in     varchar2 default null
  ,p_preference_information11      in     varchar2 default null
  ,p_preference_information12      in     varchar2 default null
  ,p_preference_information13      in     varchar2 default null
  ,p_preference_information14      in     varchar2 default null
  ,p_preference_information15      in     varchar2 default null
  ,p_preference_information16      in     varchar2 default null
  ,p_preference_information17      in     varchar2 default null
  ,p_preference_information18      in     varchar2 default null
  ,p_preference_information19      in     varchar2 default null
  ,p_preference_information20      in     varchar2 default null
  ,p_preference_information21      in     varchar2 default null
  ,p_preference_information22      in     varchar2 default null
  ,p_preference_information23      in     varchar2 default null
  ,p_preference_information24      in     varchar2 default null
  ,p_preference_information25      in     varchar2 default null
  ,p_preference_information26      in     varchar2 default null
  ,p_preference_information27      in     varchar2 default null
  ,p_preference_information28      in     varchar2 default null
  ,p_preference_information29      in     varchar2 default null
  ,p_preference_information30      in     varchar2 default null
  ,p_configuration_info_category   in     varchar2 default null
  ,p_configuration_information1    in     varchar2 default null
  ,p_configuration_information2    in     varchar2 default null
  ,p_configuration_information3    in     varchar2 default null
  ,p_configuration_information4    in     varchar2 default null
  ,p_configuration_information5    in     varchar2 default null
  ,p_configuration_information6    in     varchar2 default null
  ,p_configuration_information7    in     varchar2 default null
  ,p_configuration_information8    in     varchar2 default null
  ,p_configuration_information9    in     varchar2 default null
  ,p_configuration_information10   in     varchar2 default null
  ,p_configuration_information11   in     varchar2 default null
  ,p_configuration_information12   in     varchar2 default null
  ,p_configuration_information13   in     varchar2 default null
  ,p_configuration_information14   in     varchar2 default null
  ,p_configuration_information15   in     varchar2 default null
  ,p_configuration_information16   in     varchar2 default null
  ,p_configuration_information17   in     varchar2 default null
  ,p_configuration_information18   in     varchar2 default null
  ,p_configuration_information19   in     varchar2 default null
  ,p_configuration_information20   in     varchar2 default null
  ,p_configuration_information21   in     varchar2 default null
  ,p_configuration_information22   in     varchar2 default null
  ,p_configuration_information23   in     varchar2 default null
  ,p_configuration_information24   in     varchar2 default null
  ,p_configuration_information25   in     varchar2 default null
  ,p_configuration_information26   in     varchar2 default null
  ,p_configuration_information27   in     varchar2 default null
  ,p_configuration_information28   in     varchar2 default null
  ,p_configuration_information29   in     varchar2 default null
  ,p_configuration_information30   in     varchar2 default null
  ,p_prefix_reporting_name         in     varchar2 default 'N'
  ,p_element_template              in out nocopy pay_etm_shd.g_rec_type
  ,p_exclusion_rules               in out nocopy t_exclusion_rules
  ,p_formulas                      in out nocopy t_formulas
  ,p_balance_types                 in out nocopy t_balance_types
  ,p_defined_balances              in out nocopy t_defined_balances
  ,p_element_types                 in out nocopy t_element_types
  ,p_sub_classi_rules              in out nocopy t_sub_classi_rules
  ,p_balance_classis               in out nocopy t_balance_classis
  ,p_input_values                  in out nocopy t_input_values
  ,p_balance_feeds                 in out nocopy t_balance_feeds
  ,p_formula_rules                 in out nocopy t_formula_rules
  ,p_iterative_rules               in out nocopy t_iterative_rules
  ,p_ele_type_usages               in out nocopy t_ele_type_usages
  ,p_gu_bal_exclusions             in out nocopy t_gu_bal_exclusions
  ,p_bal_attributes                in out nocopy t_bal_attributes
  ,p_template_ff_usages            in out nocopy t_template_ff_usages
  ) is
  l_proc              varchar2(72) := g_package||'create_plsql_user_structure';
  i                   number;
  l_base_name         varchar2(2000);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  ---------------------------------------------------------------------------
  -- Keep a local copy of the base name with spaces replaced by '_'.       --
  ---------------------------------------------------------------------------
  l_base_name := upper(replace(p_base_name, ' ', '_'));
  ---------------------------------------------------------------------------
  -- Change template type to a user structure and set up base name for the --
  -- element template.                                                     --
  ---------------------------------------------------------------------------
  p_element_template.template_type := 'U';
  p_element_template.base_name := p_base_name;
  ------------------------------------------------------------------------
  -- Check that p_business_group_id is valid for the element template's --
  -- legislation and apply it.                                          --
  ------------------------------------------------------------------------
  if not busgrp_in_legislation
         (p_business_group_id, p_element_template.legislation_code) then
    fnd_message.set_name(801, 'PAY_50067_ETM_BUS_LEG_MISMATCH' );
    fnd_message.raise_error;
  end if;
  p_element_template.business_group_id := p_business_group_id;
  p_element_template.legislation_code  := null;
  i := p_formulas.first;
  loop
    exit when not p_formulas.exists(i);
    p_formulas(i).business_group_id := p_business_group_id;
    p_formulas(i).legislation_code := null;
    p_formulas(i).template_type := 'U';
    i := p_formulas.next(i);
  end loop;
  --------------------------------------
  -- Update base processing priority. --
  --------------------------------------
  if p_base_processing_priority is not null then
    p_element_template.base_processing_priority := p_base_processing_priority;
  end if;
  --------------------------------------
  -- Update the preference flexfield. --
  --------------------------------------
  if p_preference_info_category is not null then
    p_element_template.preference_info_category := p_preference_info_category;
  end if;
  if p_preference_information1 is not null then
    p_element_template.preference_information1 := p_preference_information1;
  end if;
  if p_preference_information2 is not null then
    p_element_template.preference_information2 := p_preference_information2;
  end if;
  if p_preference_information3 is not null then
    p_element_template.preference_information3 := p_preference_information3;
  end if;
  if p_preference_information4 is not null then
    p_element_template.preference_information4 := p_preference_information4;
  end if;
  if p_preference_information5 is not null then
    p_element_template.preference_information5 := p_preference_information5;
  end if;
  if p_preference_information6 is not null then
    p_element_template.preference_information6 := p_preference_information6;
  end if;
  if p_preference_information7 is not null then
    p_element_template.preference_information7 := p_preference_information7;
  end if;
  if p_preference_information8 is not null then
    p_element_template.preference_information8 := p_preference_information8;
  end if;
  if p_preference_information9 is not null then
    p_element_template.preference_information9 := p_preference_information9;
  end if;
  if p_preference_information10 is not null then
    p_element_template.preference_information10 := p_preference_information10;
  end if;
  if p_preference_information11 is not null then
    p_element_template.preference_information11 := p_preference_information11;
  end if;
  if p_preference_information12 is not null then
    p_element_template.preference_information12 := p_preference_information12;
  end if;
  if p_preference_information13 is not null then
    p_element_template.preference_information13 := p_preference_information13;
  end if;
  if p_preference_information14 is not null then
    p_element_template.preference_information14 := p_preference_information14;
  end if;
  if p_preference_information15 is not null then
    p_element_template.preference_information15 := p_preference_information15;
  end if;
  if p_preference_information16 is not null then
    p_element_template.preference_information16 := p_preference_information16;
  end if;
  if p_preference_information17 is not null then
    p_element_template.preference_information17 := p_preference_information17;
  end if;
  if p_preference_information18 is not null then
    p_element_template.preference_information18 := p_preference_information18;
  end if;
  if p_preference_information19 is not null then
    p_element_template.preference_information19 := p_preference_information19;
  end if;
  if p_preference_information20 is not null then
    p_element_template.preference_information20 := p_preference_information20;
  end if;
  if p_preference_information21 is not null then
    p_element_template.preference_information21 := p_preference_information21;
  end if;
  if p_preference_information22 is not null then
    p_element_template.preference_information22 := p_preference_information22;
  end if;
  if p_preference_information23 is not null then
    p_element_template.preference_information23 := p_preference_information23;
  end if;
  if p_preference_information24 is not null then
    p_element_template.preference_information24 := p_preference_information24;
  end if;
  if p_preference_information25 is not null then
    p_element_template.preference_information25 := p_preference_information25;
  end if;
  if p_preference_information26 is not null then
    p_element_template.preference_information26 := p_preference_information26;
  end if;
  if p_preference_information27 is not null then
    p_element_template.preference_information27 := p_preference_information27;
  end if;
  if p_preference_information28 is not null then
    p_element_template.preference_information28 := p_preference_information28;
  end if;
  if p_preference_information29 is not null then
    p_element_template.preference_information29 := p_preference_information29;
  end if;
  if p_preference_information30 is not null then
    p_element_template.preference_information30 := p_preference_information30;
  end if;
  -----------------------------------------
  -- Update the configuration flexfield. --
  -----------------------------------------
  if p_configuration_info_category is not null then
    p_element_template.configuration_info_category :=
    p_configuration_info_category;
  end if;
  if p_configuration_information1 is not null then
    p_element_template.configuration_information1 :=
    p_configuration_information1;
  end if;
  if p_configuration_information2 is not null then
    p_element_template.configuration_information2 :=
    p_configuration_information2;
  end if;
  if p_configuration_information3 is not null then
    p_element_template.configuration_information3 :=
    p_configuration_information3;
  end if;
  if p_configuration_information4 is not null then
    p_element_template.configuration_information4 :=
    p_configuration_information4;
  end if;
  if p_configuration_information5 is not null then
    p_element_template.configuration_information5 :=
    p_configuration_information5;
  end if;
  if p_configuration_information6 is not null then
    p_element_template.configuration_information6 :=
    p_configuration_information6;
  end if;
  if p_configuration_information7 is not null then
    p_element_template.configuration_information7 :=
    p_configuration_information7;
  end if;
  if p_configuration_information8 is not null then
    p_element_template.configuration_information8 :=
    p_configuration_information8;
  end if;
  if p_configuration_information9 is not null then
    p_element_template.configuration_information9 :=
    p_configuration_information9;
  end if;
  if p_configuration_information10 is not null then
    p_element_template.configuration_information10 :=
    p_configuration_information10;
  end if;
  if p_configuration_information11 is not null then
    p_element_template.configuration_information11 :=
    p_configuration_information11;
  end if;
  if p_configuration_information12 is not null then
    p_element_template.configuration_information12 :=
    p_configuration_information12;
  end if;
  if p_configuration_information13 is not null then
    p_element_template.configuration_information13 :=
    p_configuration_information13;
  end if;
  if p_configuration_information14 is not null then
    p_element_template.configuration_information14 :=
    p_configuration_information14;
  end if;
  if p_configuration_information15 is not null then
    p_element_template.configuration_information15 :=
    p_configuration_information15;
  end if;
  if p_configuration_information16 is not null then
    p_element_template.configuration_information16 :=
    p_configuration_information16;
  end if;
  if p_configuration_information17 is not null then
    p_element_template.configuration_information17 :=
    p_configuration_information17;
  end if;
  if p_configuration_information18 is not null then
    p_element_template.configuration_information18 :=
    p_configuration_information18;
  end if;
  if p_configuration_information19 is not null then
    p_element_template.configuration_information19 :=
    p_configuration_information19;
  end if;
  if p_configuration_information20 is not null then
    p_element_template.configuration_information20 :=
    p_configuration_information20;
  end if;
  if p_configuration_information21 is not null then
    p_element_template.configuration_information21 :=
    p_configuration_information21;
  end if;
  if p_configuration_information22 is not null then
    p_element_template.configuration_information22 :=
    p_configuration_information22;
  end if;
  if p_configuration_information23 is not null then
    p_element_template.configuration_information23 :=
    p_configuration_information23;
  end if;
  if p_configuration_information24 is not null then
    p_element_template.configuration_information24 :=
    p_configuration_information24;
  end if;
  if p_configuration_information25 is not null then
    p_element_template.configuration_information25 :=
    p_configuration_information25;
  end if;
  if p_configuration_information26 is not null then
    p_element_template.configuration_information26 :=
    p_configuration_information26;
  end if;
  if p_configuration_information27 is not null then
    p_element_template.configuration_information27 :=
    p_configuration_information27;
  end if;
  if p_configuration_information28 is not null then
    p_element_template.configuration_information28 :=
    p_configuration_information28;
  end if;
  if p_configuration_information29 is not null then
    p_element_template.configuration_information29 :=
    p_configuration_information29;
  end if;
  if p_configuration_information30 is not null then
    p_element_template.configuration_information30 :=
    p_configuration_information30;
  end if;
  -----------------------------------------------------------
  -- Carry out placeholder substitution using p_base_name. --
  -----------------------------------------------------------
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    prefix_name (p_element_types(i).element_name, 80, p_base_name);
    if p_prefix_reporting_name = 'Y' then
      prefix_name (p_element_types(i).reporting_name, 80, p_base_name);
    end if;
    replace_name(p_element_types(i).attribute1, p_base_name, 150);
    replace_name(p_element_types(i).attribute2, p_base_name, 150);
    replace_name(p_element_types(i).attribute3, p_base_name, 150);
    replace_name(p_element_types(i).attribute4, p_base_name, 150);
    replace_name(p_element_types(i).attribute5, p_base_name, 150);
    replace_name(p_element_types(i).attribute6, p_base_name, 150);
    replace_name(p_element_types(i).attribute7, p_base_name, 150);
    replace_name(p_element_types(i).attribute8, p_base_name, 150);
    replace_name(p_element_types(i).attribute9, p_base_name, 150);
    replace_name(p_element_types(i).attribute10, p_base_name, 150);
    replace_name(p_element_types(i).attribute11, p_base_name, 150);
    replace_name(p_element_types(i).attribute12, p_base_name, 150);
    replace_name(p_element_types(i).attribute13, p_base_name, 150);
    replace_name(p_element_types(i).attribute14, p_base_name, 150);
    replace_name(p_element_types(i).attribute15, p_base_name, 150);
    replace_name(p_element_types(i).attribute16, p_base_name, 150);
    replace_name(p_element_types(i).attribute17, p_base_name, 150);
    replace_name(p_element_types(i).attribute18, p_base_name, 150);
    replace_name(p_element_types(i).attribute19, p_base_name, 150);
    replace_name(p_element_types(i).attribute20, p_base_name, 150);
    replace_name(p_element_types(i).element_information1, p_base_name, 150);
    replace_name(p_element_types(i).element_information2, p_base_name, 150);
    replace_name(p_element_types(i).element_information3, p_base_name, 150);
    replace_name(p_element_types(i).element_information4, p_base_name, 150);
    replace_name(p_element_types(i).element_information5, p_base_name, 150);
    replace_name(p_element_types(i).element_information6, p_base_name, 150);
    replace_name(p_element_types(i).element_information7, p_base_name, 150);
    replace_name(p_element_types(i).element_information8, p_base_name, 150);
    replace_name(p_element_types(i).element_information9, p_base_name, 150);
    replace_name(p_element_types(i).element_information10, p_base_name, 150);
    replace_name(p_element_types(i).element_information11, p_base_name, 150);
    replace_name(p_element_types(i).element_information12, p_base_name, 150);
    replace_name(p_element_types(i).element_information13, p_base_name, 150);
    replace_name(p_element_types(i).element_information14, p_base_name, 150);
    replace_name(p_element_types(i).element_information15, p_base_name, 150);
    replace_name(p_element_types(i).element_information16, p_base_name, 150);
    replace_name(p_element_types(i).element_information17, p_base_name, 150);
    replace_name(p_element_types(i).element_information18, p_base_name, 150);
    replace_name(p_element_types(i).element_information19, p_base_name, 150);
    replace_name(p_element_types(i).element_information20, p_base_name, 150);
    i := p_element_types.next(i);
  end loop;

  i := p_balance_types.first;
  loop
    exit when not p_balance_types.exists(i);
    prefix_name (p_balance_types(i).balance_name, 80, p_base_name);
    prefix_name (p_balance_types(i).reporting_name, 80, p_base_name);
    replace_name(p_balance_types(i).attribute1, p_base_name, 150);
    replace_name(p_balance_types(i).attribute2, p_base_name, 150);
    replace_name(p_balance_types(i).attribute3, p_base_name, 150);
    replace_name(p_balance_types(i).attribute4, p_base_name, 150);
    replace_name(p_balance_types(i).attribute5, p_base_name, 150);
    replace_name(p_balance_types(i).attribute6, p_base_name, 150);
    replace_name(p_balance_types(i).attribute7, p_base_name, 150);
    replace_name(p_balance_types(i).attribute8, p_base_name, 150);
    replace_name(p_balance_types(i).attribute9, p_base_name, 150);
    replace_name(p_balance_types(i).attribute10, p_base_name, 150);
    replace_name(p_balance_types(i).attribute11, p_base_name, 150);
    replace_name(p_balance_types(i).attribute12, p_base_name, 150);
    replace_name(p_balance_types(i).attribute13, p_base_name, 150);
    replace_name(p_balance_types(i).attribute14, p_base_name, 150);
    replace_name(p_balance_types(i).attribute15, p_base_name, 150);
    replace_name(p_balance_types(i).attribute16, p_base_name, 150);
    replace_name(p_balance_types(i).attribute17, p_base_name, 150);
    replace_name(p_balance_types(i).attribute18, p_base_name, 150);
    replace_name(p_balance_types(i).attribute19, p_base_name, 150);
    replace_name(p_balance_types(i).attribute20, p_base_name, 150);
    i := p_balance_types.next(i);
  end loop;

  i := p_formulas.first;
  loop
    exit when not p_formulas.exists(i);
    prefix_name(p_formulas(i).formula_name, 80, l_base_name);
    begin
      replace_name(p_formulas(i).formula_text, l_base_name, 32767);
    exception
      when plsql_value_error then
        hr_utility.set_location('Leaving:'|| l_proc, 20);
        fnd_message.set_name(801, 'PAY_50068_ETM_GEN_FF_TOO_LONG');
        fnd_message.set_token('BASE_NAME', l_base_name, false);
        fnd_message.set_token('LENGTH', 32767);
        fnd_message.raise_error;
      when others then
        hr_utility.set_location('Leaving:'|| l_proc, 30);
        raise;
    end;
    i := p_formulas.next(i);
  end loop;
  ------------------------------------
  -- Set defaults for input values. --
  ------------------------------------
  set_input_value_defaults
  (p_element_template              => p_element_template
  ,p_input_values                  => p_input_values
  );
  ----------------------------
  -- Apply exclusion rules. --
  ----------------------------
  apply_exclusion_rules
  (p_element_template              => p_element_template
  ,p_exclusion_rules               => p_exclusion_rules
  ,p_formulas                      => p_formulas
  ,p_balance_types                 => p_balance_types
  ,p_defined_balances              => p_defined_balances
  ,p_element_types                 => p_element_types
  ,p_sub_classi_rules              => p_sub_classi_rules
  ,p_balance_classis               => p_balance_classis
  ,p_input_values                  => p_input_values
  ,p_balance_feeds                 => p_balance_feeds
  ,p_formula_rules                 => p_formula_rules
  ,p_iterative_rules               => p_iterative_rules
  ,p_ele_type_usages               => p_ele_type_usages
  ,p_gu_bal_exclusions             => p_gu_bal_exclusions
  ,p_bal_attributes                => p_bal_attributes
  ,p_template_ff_usages            => p_template_ff_usages
  );
  ----------------------------------------
  -- Apply the template formula usages. --
  ----------------------------------------
  hr_utility.set_location('Leaving:'|| l_proc, 40);
end create_plsql_user_structure;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_template >----------------------------|
-- ----------------------------------------------------------------------------
procedure delete_template
  (p_template_id     in number
  ,p_formulas        in t_formulas
  ,p_delete_formulas in boolean default true
  ) is
  l_proc varchar2(72) := g_package||'delete_template';
  i      number;
  l_ovn  number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  ---------------------------------------------
  -- Delete template core object rows first. --
  ---------------------------------------------
  delete from pay_template_core_objects
  where  template_id = p_template_id
  ;
  ----------------------------------
  -- Delete in foreign key order. --
  ----------------------------------
  -------------------------------
  -- pay_shadow_bal_attributes --
  -------------------------------
  delete from pay_shadow_bal_attributes
  where  defined_balance_id in
  (
    select db.defined_balance_id
    from   pay_shadow_defined_balances db
    ,      pay_shadow_balance_types bt
    where  db.balance_type_id = bt.balance_type_id
    and    bt.template_id = p_template_id
  );
  ----------------------------
  -- pay_template_ff_usages --
  ----------------------------
  delete from pay_template_ff_usages
  where  template_id = p_template_id;
  ----------------------------------
  -- pay_shadow_gu_bal_exclusions --
  ----------------------------------
  delete from pay_shadow_gu_bal_exclusions
  where  balance_type_id in
  (
    select balance_type_id
    from   pay_shadow_balance_types
    where  template_id = p_template_id
  );
  --------------------------------
  -- pay_shadow_ele_type_usages --
  --------------------------------
  delete from pay_shadow_ele_type_usages
  where  element_type_id in
  (
    select element_type_id
    from   pay_shadow_element_types
    where  template_id = p_template_id
  );
  --------------------------------
  -- pay_shadow_iterative_rules --
  --------------------------------
  delete from pay_shadow_iterative_rules
  where  element_type_id in
  (
    select element_type_id
    from   pay_shadow_element_types
    where  template_id = p_template_id
  );
  ------------------------------
  -- pay_shadow_formula_rules --
  ------------------------------
  delete from pay_shadow_formula_rules
  where  shadow_element_type_id in
  (
    select element_type_id
    from   pay_shadow_element_types
    where  template_id = p_template_id
  );
  ------------------------------
  -- pay_shadow_balance_feeds --
  ------------------------------
  delete from pay_shadow_balance_feeds
  where  input_value_id in
  (
    select iv.input_value_id
    from   pay_shadow_input_values iv
    ,      pay_shadow_element_types et
    where  et.template_id = p_template_id
    and    iv.element_type_id = et.element_type_id
  );
  --------------------------------
  -- pay_shadow_balance_classis --
  --------------------------------
  delete from pay_shadow_balance_classi
  where  balance_type_id in
  (
    select balance_type_id
    from   pay_shadow_balance_types
    where  template_id = p_template_id
  );
  ---------------------------------
  -- pay_shadow_defined_balances --
  ---------------------------------
  delete from pay_shadow_defined_balances
  where  balance_type_id in
  (
    select balance_type_id
    from   pay_shadow_balance_types
    where  template_id = p_template_id
  );
  ---------------------------------
  -- pay_shadow_sub_classi_rules --
  ---------------------------------
  delete from pay_shadow_sub_classi_rules
  where  element_type_id in
  (
    select element_type_id
    from   pay_shadow_element_types
    where  template_id = p_template_id
  );
  ------------------------------
  -- pay_shadow_balance_types --
  ------------------------------
  --
  -- NULL the base_base_balance_type_id to avoid having to recursively
  -- delete because of the base_balance_type_id.
  --
  update pay_shadow_balance_types
  set    base_balance_type_id = null
  where  base_balance_type_id is not null
  and    template_id = p_template_id;
  --
  delete from pay_shadow_balance_types
  where  template_id = p_template_id;
  -----------------------------
  -- pay_shadow_input_values --
  -----------------------------
  delete from pay_shadow_input_values
  where  element_type_id in
  (
    select element_type_id
    from   pay_shadow_element_types
    where  template_id = p_template_id
  );
  ------------------------------
  -- pay_shadow_element_types --
  ------------------------------
  delete from pay_shadow_element_types
  where  template_id = p_template_id;
  -------------------------
  -- pay_shadow_formulas --
  -------------------------
  --
  -- It may not be as fast, but using the formulas table gives the most
  --  maintainable code when it comes to deleting the template's formulas.
  --
  if p_delete_formulas then
    i := p_formulas.first;
    loop
      exit when not p_formulas.exists(i);
      --
      l_ovn := p_formulas(i).object_version_number;
      pay_sf_del.del(i, l_ovn);
      --
      i := p_formulas.next(i);
    end loop;
  end if;
  ----------------------------------
  -- pay_template_exclusion_rules --
  ----------------------------------
  delete from pay_template_exclusion_rules
  where  template_id = p_template_id;
  ---------------------------
  -- pay_element_templates --
  ---------------------------
  delete from pay_element_templates
  where  template_id = p_template_id;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 200);
end delete_template;
--

FUNCTION get_shadow_formula_name(p_formula_id in number)
           return varchar2 is

    l_formula_name  pay_shadow_formulas.formula_name%TYPE;

    CURSOR cur_get_formula_name IS
    SELECT formula_name
    FROM pay_shadow_formulas
    WHERE formula_id = p_formula_id;

BEGIN
    OPEN cur_get_formula_name;
    FETCH cur_get_formula_name INTO l_formula_name;
    if cur_get_formula_name%NOTFOUND then
      l_formula_name := NULL;
    end if;

    CLOSE cur_get_formula_name;

    RETURN l_formula_name;

END get_shadow_formula_name;
--
end pay_element_template_util;

/
