--------------------------------------------------------
--  DDL for Package Body PAY_TCO_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_TCO_BUS" as
/* $Header: pytcorhi.pkb 120.0 2005/05/29 09:01:02 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_tco_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_template_info >---------------------------|
-- ----------------------------------------------------------------------------
Procedure get_template_info
  (p_template_id                 in     	number
  ,p_business_group_id           in out nocopy  number
  ) is
  --
  -- Cursor to get the template information.
  --
  cursor csr_get_template_info is
  select pet.business_group_id
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
  into  p_business_group_id;
  close csr_get_template_info;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End get_template_info;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec     in     pay_tco_shd.g_rec_type
  ) is
  l_proc  varchar2(72) := g_package||'chk_non_updateable_args';
  l_updating boolean;
  l_error    exception;
  l_argument varchar2(30);
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_tco_shd.api_updating
    (p_template_core_object_id => p_rec.template_core_object_id
    ,p_object_version_number   => p_rec.object_version_number
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
  -- p_template_id
  --
  if nvl(p_rec.template_id, hr_api.g_number) <>
     nvl(pay_tco_shd.g_old_rec.template_id, hr_api.g_number)
  then
    l_argument := 'p_template_id';
    raise l_error;
  end if;
  --
  -- p_core_object_type
  --
  if nvl(p_rec.core_object_type, hr_api.g_varchar2) <>
     nvl(pay_tco_shd.g_old_rec.core_object_type, hr_api.g_varchar2)
  then
    l_argument := 'p_core_object_type';
    raise l_error;
  end if;
  --
  -- p_shadow_object_id
  --
  if nvl(p_rec.shadow_object_id, hr_api.g_number) <>
     nvl(pay_tco_shd.g_old_rec.shadow_object_id, hr_api.g_number)
  then
    l_argument := 'p_shadow_object_id';
    raise l_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
    when l_error then
       hr_utility.set_location('Leaving:'||l_proc, 25);
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       hr_utility.set_location('Leaving:'||l_proc, 30);
       raise;
End chk_non_updateable_args;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_effective_date >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_effective_date
  (p_effective_date          in     date
  ,p_template_core_object_id in     number
  ,p_object_version_number   in     number
  ) is
  l_proc  varchar2(72) := g_package||'chk_effective_date';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_tco_shd.api_updating
  (p_template_core_object_id => p_template_core_object_id
  ,p_object_version_number   => p_object_version_number
  );
  if (l_api_updating and nvl(p_effective_date, hr_api.g_date) <>
      nvl(pay_tco_shd.g_old_rec.effective_date, hr_api.g_date)) or
     not l_api_updating
  then
    --
    -- Check that the effective date is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value => p_effective_date
    );
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_effective_date;
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
  where  pet.template_id = p_template_id
  and    pet.template_type = 'U';
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
    fnd_message.set_name('PAY', 'PAY_50065_BAD_USER_TEMPLATE');
    fnd_message.raise_error;
  end if;
  close csr_template_id_valid;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
End chk_template_id;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_core_object_type >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_core_object_type
(p_effective_date       in date
,p_core_object_type     in varchar2
) is
--
  l_proc  varchar2(72) := g_package||'chk_core_object_type';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that the core object type is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_core_object_type'
  ,p_argument_value => p_core_object_type
  );
  --
  -- Validate against hr_lookups.
  --
  if hr_api.not_exists_in_hr_lookups
     (p_effective_date => p_effective_date
     ,p_lookup_type    => 'CORE_OBJECT_TYPE'
     ,p_lookup_code    => p_core_object_type
     )
  then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
    fnd_message.set_name('PAY', 'HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('LOOKUP_TYPE', 'CORE_OBJECT_TYPE');
    fnd_message.set_token('COLUMN', 'CORE_OBJECT_TYPE');
    fnd_message.raise_error;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End chk_core_object_type;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_shadow_object_id >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_shadow_object_id
  (p_shadow_object_id     in     number
  ,p_core_object_type     in     varchar2
  ,p_template_id          in     number
  ) is
  --
  -- Cursor to check that the combination of shadow_object_id and
  -- core_object_type is unique.
  --
  cursor csr_comb_exists is
  select null
  from   pay_template_core_objects tco
  where  tco.shadow_object_id = p_shadow_object_id
  and    tco.core_object_type = p_core_object_type;
  --
  -- Cursors to check that the shadow_object_id belongs to the template
  -- specified by template_id.
  --
  cursor csr_sf_belongs is
  select null
  from   pay_shadow_element_types pset
  where  pset.template_id = p_template_id
  and    pset.payroll_formula_id = p_shadow_object_id;
  --
  cursor csr_sfiv_belongs is
  select null
  from   pay_shadow_input_values psiv
  ,      pay_shadow_element_types pset
  where  pset.template_id = p_template_id
  and    pset.element_type_id = psiv.element_type_id
  and    psiv.formula_id = p_shadow_object_id;
  --
  cursor csr_sbt_belongs is
  select null
  from   pay_shadow_balance_types sbt
  where  sbt.template_id = p_template_id
  and    sbt.balance_type_id = p_shadow_object_id;
  --
  cursor csr_sdb_belongs is
  select null
  from   pay_shadow_balance_types sbt
  ,      pay_shadow_defined_balances sdb
  where  sbt.template_id = p_template_id
  and    sdb.balance_type_id = sbt.balance_type_id
  and    sdb.defined_balance_id = p_shadow_object_id;
  --
  cursor csr_set_belongs is
  select null
  from   pay_shadow_element_types pset
  where  pset.template_id = p_template_id
  and    pset.element_type_id = p_shadow_object_id;
  --
  cursor csr_ssr_belongs is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_sub_classi_rules scr
  where  pset.template_id = p_template_id
  and    scr.element_type_id = pset.element_type_id
  and    scr.sub_classification_rule_id = p_shadow_object_id;
  --
  cursor csr_sbc_belongs is
  select null
  from   pay_shadow_balance_types sbt
  ,      pay_shadow_balance_classi sbc
  where  sbt.template_id = p_template_id
  and    sbc.balance_type_id = sbt.balance_type_id
  and    sbc.balance_classification_id = p_shadow_object_id;
  --
  cursor csr_siv_belongs is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_input_values siv
  where  pset.template_id = p_template_id
  and    siv.element_type_id = pset.element_type_id
  and    siv.input_value_id = p_shadow_object_id;
  --
  cursor csr_sbf_belongs is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_input_values siv
  ,      pay_shadow_balance_feeds sbf
  where  pset.template_id = p_template_id
  and    siv.element_type_id = pset.element_type_id
  and    sbf.input_value_id = siv.input_value_id
  and    sbf.balance_feed_id = p_shadow_object_id;
  --
  cursor csr_sfr_belongs is
  select null
  from   pay_shadow_element_types pset
  ,      pay_shadow_formula_rules sfr
  where  pset.template_id = p_template_id
  and    sfr.shadow_element_type_id = pset.element_type_id
  and    sfr.formula_result_rule_id = p_shadow_object_id;
  --
  cursor csr_sir_belongs is
  select null
  from   pay_shadow_element_types   pset
  ,      pay_shadow_iterative_rules sir
  where  pset.template_id      = p_template_id
  and    sir.element_type_id   = pset.element_type_id
  and    sir.iterative_rule_id = p_shadow_object_id;
  --
  cursor csr_seu_belongs is
  select null
  from   pay_shadow_element_types   pset
  ,      pay_shadow_ele_type_usages etu
  where  pset.template_id          = p_template_id
  and    etu.element_type_id       = pset.element_type_id
  and    etu.element_type_usage_id = p_shadow_object_id;
  --
  cursor csr_sgb_belongs is
  select null
  from   pay_shadow_element_types     pset
  ,      pay_shadow_gu_bal_exclusions sgb
  where  pset.template_id        = p_template_id
  and    sgb.source_id           = pset.element_type_id
  and    sgb.grossup_balances_id = p_shadow_object_id;
  --
  cursor csr_sba_belongs is
  select null
  from   pay_shadow_balance_types    sbt
  ,      pay_shadow_defined_balances sdb
  ,      pay_shadow_bal_attributes   sba
  where  sba.balance_attribute_id = p_shadow_object_id
  and    sba.defined_balance_id   = sdb.defined_balance_id
  and    sdb.balance_type_id      = sbt.balance_type_id
  and    sbt.template_id          = p_template_id;
--
  l_proc  varchar2(72) := g_package||'chk_shadow_object_id';
  l_exists varchar(1);
  l_error  exception;
  l_table  varchar2(2000);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check that shadow_object_id is not null.
  --
  hr_api.mandatory_arg_error
  (p_api_name       => l_proc
  ,p_argument       => 'p_shadow_object_id'
  ,p_argument_value => p_shadow_object_id
  );
  --
  -- Check that the core_object_type and shadow_object_id are a
  -- unique combination.
  --
  open csr_comb_exists;
  fetch csr_comb_exists into l_exists;
  if csr_comb_exists%found then
    hr_utility.set_location(l_proc, 10);
    close csr_comb_exists;
    fnd_message.set_name('PAY', 'PAY_50126_TCO_SHAD_OBJ_EXISTS');
    fnd_message.raise_error;
  end if;
  close csr_comb_exists;
  --
  -- Check that the shadow_object_id belongs to the template.
  --

  if p_core_object_type = pay_tco_shd.g_sf_lookup_type then
    l_table := 'PAY_SHADOW_FORMULAS';
    --
    -- Look for element type payroll formula.
    --
    open csr_sf_belongs;
    fetch csr_sf_belongs into l_exists;
    if csr_sf_belongs%notfound then
      close csr_sf_belongs;
      --
      -- Look for input value formula.
      --
      open csr_sfiv_belongs;
      fetch csr_sfiv_belongs into l_exists;
      if csr_sfiv_belongs%notfound then
        close csr_sfiv_belongs;
        raise l_error;
      end if;
      close csr_sfiv_belongs;
    end if;

    if csr_sf_belongs%isopen then
      close csr_sf_belongs;
    end if;
  elsif p_core_object_type = pay_tco_shd.g_sbt_lookup_type then
    l_table := 'PAY_SHADOW_BALANCE_TYPES';
    open csr_sbt_belongs;
    fetch csr_sbt_belongs into l_exists;
    if csr_sbt_belongs%notfound then
      close csr_sbt_belongs;
      raise l_error;
    end if;
    close csr_sbt_belongs;
  elsif p_core_object_type = pay_tco_shd.g_sdb_lookup_type then
    l_table := 'PAY_SHADOW_DEFINED_BALANCES';
    open csr_sdb_belongs;
    fetch csr_sdb_belongs into l_exists;
    if csr_sdb_belongs%notfound then
      close csr_sdb_belongs;
      raise l_error;
    end if;
    close csr_sdb_belongs;
  elsif p_core_object_type = pay_tco_shd.g_set_lookup_type or
        p_core_object_type = pay_tco_shd.g_spr_lookup_type
  then
    l_table := 'PAY_SHADOW_ELEMENT_TYPES';
    open csr_set_belongs;
    fetch csr_set_belongs into l_exists;
    if csr_set_belongs%notfound then
      close csr_set_belongs;
      raise l_error;
    end if;
    close csr_set_belongs;
  elsif p_core_object_type = pay_tco_shd.g_ssr_lookup_type then
    l_table := 'PAY_SHADOW_SUB_CLASSI_RULES';
    open csr_ssr_belongs;
    fetch csr_ssr_belongs into l_exists;
    if csr_ssr_belongs%notfound then
      close csr_ssr_belongs;
      raise l_error;
    end if;
    close csr_ssr_belongs;
  elsif p_core_object_type = pay_tco_shd.g_sbc_lookup_type then
    l_table := 'PAY_SHADOW_BALANCE_CLASSI';
    open csr_sbc_belongs;
    fetch csr_sbc_belongs into l_exists;
    if csr_sbc_belongs%notfound then
      close csr_sbc_belongs;
      raise l_error;
    end if;
    close csr_sbc_belongs;
  elsif p_core_object_type = pay_tco_shd.g_siv_lookup_type then
    l_table := 'PAY_SHADOW_INPUT_VALUES';
    open csr_siv_belongs;
    fetch csr_siv_belongs into l_exists;
    if csr_siv_belongs%notfound then
      close csr_siv_belongs;
      raise l_error;
    end if;
    close csr_siv_belongs;
  elsif p_core_object_type = pay_tco_shd.g_sbf_lookup_type then
    l_table := 'PAY_SHADOW_BALANCE_FEEDS';
    open csr_sbf_belongs;
    fetch csr_sbf_belongs into l_exists;
    if csr_sbf_belongs%notfound then
      close csr_sbf_belongs;
      raise l_error;
    end if;
    close csr_sbf_belongs;
  elsif p_core_object_type = pay_tco_shd.g_sfr_lookup_type then
    l_table := 'PAY_SHADOW_FORMULA_RULES';
    open csr_sfr_belongs;
    fetch csr_sfr_belongs into l_exists;
    if csr_sfr_belongs%notfound then
      close csr_sfr_belongs;
      raise l_error;
    end if;
    close csr_sfr_belongs;
  elsif p_core_object_type = pay_tco_shd.g_sir_lookup_type then
    l_table := 'PAY_SHADOW_ITERATIVE_RULES';
    open csr_sir_belongs;
    fetch csr_sir_belongs into l_exists;
    if csr_sir_belongs%notfound then
      close csr_sir_belongs;
      raise l_error;
    end if;
    close csr_sir_belongs;
  elsif p_core_object_type = pay_tco_shd.g_seu_lookup_type then
    l_table := 'PAY_SHADOW_ELE_TYPE_USAGES';
    open csr_seu_belongs;
    fetch csr_seu_belongs into l_exists;
    if csr_seu_belongs%notfound then
      close csr_seu_belongs;
      raise l_error;
    end if;
    close csr_seu_belongs;
  elsif p_core_object_type = pay_tco_shd.g_sgb_lookup_type then
    l_table := 'PAY_SHADOW_GU_BAL_EXCLUSIONS';
    open csr_sgb_belongs;
    fetch csr_sgb_belongs into l_exists;
    if csr_sgb_belongs%notfound then
      close csr_sgb_belongs;
      raise l_error;
    end if;
    close csr_sgb_belongs;
  elsif p_core_object_type = pay_tco_shd.g_sba_lookup_type then
    l_table := 'PAY_SHADOW_BAL_ATTRIBUTES';
    open csr_sba_belongs;
    fetch csr_sba_belongs into l_exists;
    if csr_sba_belongs%notfound then
      close csr_sba_belongs;
      raise l_error;
    end if;
    close csr_sba_belongs;
  else
    hr_general.assert_condition(false);
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
exception
  when l_error then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    fnd_message.set_name('PAY', 'PAY_50127_TCO_SHAD_NOT_FOUND');
    fnd_message.set_token('TABLE', l_table);
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    raise;
End chk_shadow_object_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_core_object_id >---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_core_object_id
  (p_core_object_id          in     number
  ,p_core_object_type        in     varchar2
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_template_core_object_id in     number
  ,p_object_version_number   in     number
  ) is
  --
  -- Cursor to check that the combination of core_object_id and
  -- core_object_type is unique.
  --
  cursor csr_comb_exists is
  select null
  from   pay_template_core_objects tco
  where  tco.core_object_id = p_core_object_id
  and    tco.core_object_type = p_core_object_type;
  --
  -- Cursors to check that the core_object_id exists to the template
  -- specified by template_id.
  --
  cursor csr_sf_exists is
  select null
  from   ff_formulas_f ff
  where  ff.formula_id = p_core_object_id
  and    ff.business_group_id = p_business_group_id
  and    p_effective_date between
         ff.effective_start_date and ff.effective_end_date;
  --
  cursor csr_sbt_exists is
  select null
  from   pay_balance_types bt
  where  bt.balance_type_id = p_core_object_id
  and    bt.business_group_id = p_business_group_id;
  --
  cursor csr_sdb_exists is
  select null
  from   pay_defined_balances db
  where  db.defined_balance_id = p_core_object_id
  and    db.business_group_id = p_business_group_id;
  --
  cursor csr_set_exists is
  select null
  from   pay_element_types_f et
  where  et.element_type_id = p_core_object_id
  and    et.business_group_id = p_business_group_id
  and    p_effective_date between
         et.effective_start_date and et.effective_end_date;
  --
  cursor csr_ssr_exists is
  select null
  from   pay_sub_classification_rules_f scr
  where  scr.sub_classification_rule_id = p_core_object_id
  and    scr.business_group_id = p_business_group_id
  and    p_effective_date between
         scr.effective_start_date and scr.effective_end_date;
  --
  cursor csr_sbc_exists is
  select null
  from   pay_balance_classifications bc
  where  bc.balance_classification_id = p_core_object_id
  and    bc.business_group_id = p_business_group_id;
  --
  cursor csr_siv_exists is
  select null
  from   pay_input_values_f iv
  where  iv.input_value_id = p_core_object_id
  and    iv.business_group_id = p_business_group_id
  and    p_effective_date between
         iv.effective_start_date and iv.effective_end_date;
  --
  cursor csr_sbf_exists is
  select null
  from   pay_balance_feeds_f bf
  where  bf.balance_feed_id = p_core_object_id
  and    bf.business_group_id = p_business_group_id
  and    p_effective_date between
         bf.effective_start_date and bf.effective_end_date;
  --
  cursor csr_sfr_exists is
  select null
  from   pay_formula_result_rules_f frr
  where  frr.formula_result_rule_id = p_core_object_id
  and    frr.business_group_id = p_business_group_id
  and    p_effective_date between
         frr.effective_start_date and frr.effective_end_date;
  --
  cursor csr_spr_exists is
  select null
  from   pay_status_processing_rules_f spr
  where  spr.status_processing_rule_id = p_core_object_id
  and    spr.business_group_id = p_business_group_id
  and    p_effective_date between
         spr.effective_start_date and spr.effective_end_date;
  --
  cursor csr_sir_exists is
  select null
  from   pay_iterative_rules_f  pir
  where  pir.iterative_rule_id     = p_core_object_id
  and    pir.business_group_id = p_business_group_id
  and    p_effective_date between
         pir.effective_start_date and pir.effective_end_date;
  --
  cursor csr_sgb_exists is
  select null
  from   pay_grossup_bal_exclusions gbe
  ,      pay_balance_types          pbt
  where  gbe.grossup_balances_id   = p_core_object_id
  and    gbe.balance_type_id       = pbt.balance_type_id
  and    pbt.business_group_id = p_business_group_id;
  --
  cursor csr_seu_exists is
  select null
  from   pay_element_type_usages_f etu
  where  etu.business_group_id = p_business_group_id
  and    etu.element_type_usage_id = p_core_object_id
  and    p_effective_date between
         etu.effective_start_date and etu.effective_end_date;
  --
  cursor csr_sba_exists is
  select null
  from   pay_balance_attributes ba
  where  ba.business_group_id = p_business_group_id
  and    ba.balance_attribute_id = p_core_object_id;
--
  l_proc  varchar2(72) := g_package||'chk_core_object_id';
  l_exists varchar(1);
  l_error  exception;
  l_table  varchar2(2000);
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_api_updating := pay_tco_shd.api_updating
  (p_template_core_object_id => p_template_core_object_id
  ,p_object_version_number   => p_object_version_number
  );
  if (l_api_updating and nvl(p_core_object_id, hr_api.g_number) <>
      nvl(pay_tco_shd.g_old_rec.core_object_id, hr_api.g_number)) or
     not l_api_updating
  then
    --
    -- Check that core_object_id is not null.
    --
    hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'p_core_object_id'
    ,p_argument_value => p_core_object_id
    );
    --
    -- Check that the core_object_type and core_object_id are a
    -- unique combination.
    --
    open csr_comb_exists;
    fetch csr_comb_exists into l_exists;
    if csr_comb_exists%found then
      hr_utility.set_location(l_proc, 10);
      close csr_comb_exists;
      fnd_message.set_name('PAY', 'PAY_50124_TCO_CORE_OBJ_EXISTS');
      fnd_message.raise_error;
    end if;
    close csr_comb_exists;
    --
    -- Check that the core_object_id exists to the template.
    --
    if p_core_object_type = pay_tco_shd.g_sf_lookup_type then
      l_table := 'FF_FORMULAS_F';
      open csr_sf_exists;
      fetch csr_sf_exists into l_exists;
      if csr_sf_exists%notfound then
        close csr_sf_exists;
        raise l_error;
      end if;
      close csr_sf_exists;
    elsif p_core_object_type = pay_tco_shd.g_sbt_lookup_type then
      l_table := 'PAY_BALANCE_TYPES';
      open csr_sbt_exists;
      fetch csr_sbt_exists into l_exists;
      if csr_sbt_exists%notfound then
        close csr_sbt_exists;
        raise l_error;
      end if;
      close csr_sbt_exists;
    elsif p_core_object_type = pay_tco_shd.g_sdb_lookup_type then
      l_table := 'PAY_DEFINED_BALANCES';
      open csr_sdb_exists;
      fetch csr_sdb_exists into l_exists;
      if csr_sdb_exists%notfound then
        close csr_sdb_exists;
        raise l_error;
      end if;
      close csr_sdb_exists;
    elsif p_core_object_type = pay_tco_shd.g_set_lookup_type
    then
      l_table := 'PAY_ELEMENT_TYPES_F';
      open csr_set_exists;
      fetch csr_set_exists into l_exists;
      if csr_set_exists%notfound then
        close csr_set_exists;
        raise l_error;
      end if;
      close csr_set_exists;
    elsif p_core_object_type = pay_tco_shd.g_ssr_lookup_type then
      l_table := 'PAY_SUB_CLASSIFICATION_RULES_F';
      open csr_ssr_exists;
      fetch csr_ssr_exists into l_exists;
      if csr_ssr_exists%notfound then
        close csr_ssr_exists;
        raise l_error;
      end if;
      close csr_ssr_exists;
    elsif p_core_object_type = pay_tco_shd.g_sbc_lookup_type then
      l_table := 'PAY_BALANCE_CLASSIFICATIONS';
      open csr_sbc_exists;
      fetch csr_sbc_exists into l_exists;
      if csr_sbc_exists%notfound then
        close csr_sbc_exists;
        raise l_error;
      end if;
      close csr_sbc_exists;
    elsif p_core_object_type = pay_tco_shd.g_siv_lookup_type then
      l_table := 'PAY_INPUT_VALUES_F';
      open csr_siv_exists;
      fetch csr_siv_exists into l_exists;
      if csr_siv_exists%notfound then
        close csr_siv_exists;
        raise l_error;
      end if;
      close csr_siv_exists;
    elsif p_core_object_type = pay_tco_shd.g_sbf_lookup_type then
      l_table := 'PAY_BALANCE_FEEDS_F';
      open csr_sbf_exists;
      fetch csr_sbf_exists into l_exists;
      if csr_sbf_exists%notfound then
        close csr_sbf_exists;
        raise l_error;
      end if;
      close csr_sbf_exists;
    elsif p_core_object_type = pay_tco_shd.g_spr_lookup_type then
      l_table := 'PAY_STATUS_PROCESSING_RULES_F';
      open csr_spr_exists;
      fetch csr_spr_exists into l_exists;
      if csr_spr_exists%notfound then
        close csr_spr_exists;
        raise l_error;
      end if;
      close csr_spr_exists;
    elsif p_core_object_type = pay_tco_shd.g_sfr_lookup_type then
      l_table := 'PAY_FORMULA_RESULT_RULES_F';
      open csr_sfr_exists;
      fetch csr_sfr_exists into l_exists;
      if csr_sfr_exists%notfound then
        close csr_sfr_exists;
        raise l_error;
      end if;
      close csr_sfr_exists;
    elsif p_core_object_type = pay_tco_shd.g_sir_lookup_type then
      l_table := 'PAY_ITERATIVE_RULES_F';
      open csr_sir_exists;
      fetch csr_sir_exists into l_exists;
      if csr_sir_exists%notfound then
        close csr_sir_exists;
        raise l_error;
      end if;
      close csr_sir_exists;
    elsif p_core_object_type = pay_tco_shd.g_sgb_lookup_type then
      l_table := 'PAY_GROSSUP_BAL_EXCLUSIONS';
      open csr_sgb_exists;
      fetch csr_sgb_exists into l_exists;
      if csr_sgb_exists%notfound then
        close csr_sgb_exists;
        raise l_error;
      end if;
      close csr_sgb_exists;
    elsif p_core_object_type = pay_tco_shd.g_seu_lookup_type then
      l_table := 'PAY_ELEMENT_TYPE_USAGES_F';
      open csr_seu_exists;
      fetch csr_seu_exists into l_exists;
      if csr_seu_exists%notfound then
        close csr_seu_exists;
        raise l_error;
      end if;
      close csr_seu_exists;
    elsif p_core_object_type = pay_tco_shd.g_sba_lookup_type then
      l_table := 'PAY_BALANCE_ATTRIBUTES';
      open csr_sba_exists;
      fetch csr_sba_exists into l_exists;
      if csr_sba_exists%notfound then
        close csr_sba_exists;
        raise l_error;
      end if;
      close csr_sba_exists;
    else
      hr_general.assert_condition(false);
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
exception
  when l_error then
    hr_utility.set_location(' Leaving:'||l_proc, 20);
    fnd_message.set_name('PAY', 'PAY_50125_TCO_CORE_NOT_FOUND');
    fnd_message.set_token('TABLE', l_table);
    fnd_message.raise_error;
  when others then
    hr_utility.set_location(' Leaving:'||l_proc, 25);
    raise;
End chk_core_object_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pay_tco_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_business_group_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_template_id(p_template_id => p_rec.template_id);
  --
  get_template_info
  (p_template_id       => p_rec.template_id
  ,p_business_group_id => l_business_group_id
  );
  --
  chk_effective_date
  (p_effective_date          => p_rec.effective_date
  ,p_template_core_object_id => p_rec.template_core_object_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_core_object_type
  (p_effective_date   => p_rec.effective_date
  ,p_core_object_type => p_rec.core_object_type
  );
  --
  chk_shadow_object_id
  (p_shadow_object_id => p_rec.shadow_object_id
  ,p_core_object_type => p_rec.core_object_type
  ,p_template_id      => p_rec.template_id
  );
  --
  chk_core_object_id
  (p_core_object_id          => p_rec.core_object_id
  ,p_core_object_type        => p_rec.core_object_type
  ,p_effective_date          => p_rec.effective_date
  ,p_business_group_id       => l_business_group_id
  ,p_template_core_object_id => p_rec.template_core_object_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pay_tco_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_business_group_id number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_non_updateable_args(p_rec);
  --
  get_template_info
  (p_template_id       => p_rec.template_id
  ,p_business_group_id => l_business_group_id
  );
  --
  chk_effective_date
  (p_effective_date          => p_rec.effective_date
  ,p_template_core_object_id => p_rec.template_core_object_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  --
  chk_core_object_id
  (p_core_object_id          => p_rec.core_object_id
  ,p_core_object_type        => p_rec.core_object_type
  ,p_effective_date          => p_rec.effective_date
  ,p_business_group_id       => l_business_group_id
  ,p_template_core_object_id => p_rec.template_core_object_id
  ,p_object_version_number   => p_rec.object_version_number
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pay_tco_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_tco_bus;

/
