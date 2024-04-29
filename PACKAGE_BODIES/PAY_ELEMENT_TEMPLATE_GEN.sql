--------------------------------------------------------
--  DDL for Package Body PAY_ELEMENT_TEMPLATE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELEMENT_TEMPLATE_GEN" as
/* $Header: pyetmgen.pkb 120.3 2006/07/11 15:41:46 arashid ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_element_template_gen.';
---------------------------------------------------------------------------
-- Record for holding primary key and rowid information. This is because --
-- the code uses currently available code (as opposed to proper APIs).   --
---------------------------------------------------------------------------
type g_rowid_id_rec is record
  (id                             number
  ,rowid                          varchar2(128)
  ,effective_date                 date
  );
--
type t_rowid_id_recs is table of g_rowid_id_rec index by binary_integer;
---------------------------------------------------------------------------
-- Record for holding primary key and object version number. This is for --
-- the iterative tables which use row handler calls.                     --
---------------------------------------------------------------------------
type g_id_ovn_rec is record
  (id             number
  ,ovn            number
  ,effective_date date
  );
--
type t_id_ovn_recs is table of g_id_ovn_rec index by binary_integer;
--------------------------------------------------------
-- Constant definitions for CORE_OBJECT_TYPE lookups. --
--------------------------------------------------------
g_sf_lookup_type  constant varchar2(30) default pay_tco_shd.g_sf_lookup_type;
g_sbt_lookup_type constant varchar2(30) default pay_tco_shd.g_sbt_lookup_type;
g_sdb_lookup_type constant varchar2(30) default pay_tco_shd.g_sdb_lookup_type;
g_set_lookup_type constant varchar2(30) default pay_tco_shd.g_set_lookup_type;
g_ssr_lookup_type constant varchar2(30) default pay_tco_shd.g_ssr_lookup_type;
g_sbc_lookup_type constant varchar2(30) default pay_tco_shd.g_sbc_lookup_type;
g_siv_lookup_type constant varchar2(30) default pay_tco_shd.g_siv_lookup_type;
g_sbf_lookup_type constant varchar2(30) default pay_tco_shd.g_sbf_lookup_type;
g_sfr_lookup_type constant varchar2(30) default pay_tco_shd.g_sfr_lookup_type;
g_spr_lookup_type constant varchar2(30) default pay_tco_shd.g_spr_lookup_type;
g_sir_lookup_type constant varchar2(30) default pay_tco_shd.g_sir_lookup_type;
g_seu_lookup_type constant varchar2(30) default pay_tco_shd.g_seu_lookup_type;
g_sgb_lookup_type constant varchar2(30) default pay_tco_shd.g_sgb_lookup_type;
g_sba_lookup_type constant varchar2(30) default pay_tco_shd.g_sba_lookup_type;
--------------------------------------------------
-- Constant definitions for formula type names. --
--------------------------------------------------
g_skip_formula_type    constant varchar2(30) default
pay_sf_shd.g_skip_formula_type;
g_payroll_formula_type constant varchar2(30) default
pay_sf_shd.g_payroll_formula_type;
g_input_val_formula_type constant varchar2(30) default
pay_sf_shd.g_input_val_formula_type;
g_iterative_formula_type constant varchar2(30) default
pay_sf_shd.g_iterative_formula_type;
g_proration_formula_type constant varchar2(30) default
pay_sf_shd.g_proration_formula_type;
------------------------------------
-- Cached FORMULA_TYPE_ID values. --
------------------------------------
g_skip_formula_type_id      number;
g_payroll_formula_type_id   number;
g_input_val_formula_type_id number;
g_iterative_formula_type_id number;
g_proration_formula_type_id number;
-------------------------------------------------
-- Constant definitions for event group names. --
-------------------------------------------------
g_proration_event_group  constant varchar2(30) default 'P';
g_retro_event_group      constant varchar2(30) default 'R';
--------------------
-- Deletion mode. --
--------------------
g_zap_deletion_mode    constant varchar2(30) default 'ZAP';
-- ----------------------------------------------------------------------------
-- |-------------------------< get_formula_type_id >--------------------------|
-- ----------------------------------------------------------------------------
function get_formula_type_id
(p_formula_type_name in varchar2
) return number is
begin
  if p_formula_type_name = g_payroll_formula_type then
    return g_payroll_formula_type_id;
  elsif p_formula_type_name = g_skip_formula_type then
    return g_skip_formula_type_id;
  elsif p_formula_type_name = g_input_val_formula_type then
    return g_input_val_formula_type_id;
  elsif  p_formula_type_name = g_iterative_formula_type then
    return g_iterative_formula_type_id;
  elsif p_formula_type_name = g_proration_formula_type then
    return g_proration_formula_type_id;
  end if;
  return null;
end get_formula_type_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_formula_types  >--------------------------|
-- ----------------------------------------------------------------------------
procedure get_formula_types is
--
  procedure get_formula_type_id
  (p_formula_type    in varchar2
  ,p_formula_type_id out nocopy number
  ) is
  cursor csr_formula_type(p_formula_type in varchar2) is
  select formula_type_id
  from   ff_formula_types
  where formula_type_name = p_formula_type
  ;
  begin
    open csr_formula_type(p_formula_type);
    fetch csr_formula_type into p_formula_type_id;
    if csr_formula_type%notfound then
      close csr_formula_type;
      hr_utility.set_message(801, 'PAY_50058_ETM_BAD_FORMULA_TYPE');
      hr_utility.set_message_token('FORMULA_TYPE', p_formula_type);
      hr_utility.raise_error;
    end if;
    close csr_formula_type;
  end get_formula_type_id;
--
begin
  get_formula_type_id(g_skip_formula_type, g_skip_formula_type_id);
  --
  get_formula_type_id(g_payroll_formula_type, g_payroll_formula_type_id);
  --
  get_formula_type_id(g_input_val_formula_type, g_input_val_formula_type_id);
  --
  get_formula_type_id(g_iterative_formula_type, g_iterative_formula_type_id);
  --
  get_formula_type_id(g_proration_formula_type, g_proration_formula_type_id);
end get_formula_types;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_ele_classification_id >--------------------|
-- ----------------------------------------------------------------------------
function get_ele_classification_id
(p_business_group_id in            number
,p_legislation_code  in            varchar2
,p_classification    in            varchar2
,p_non_payments_flag    out nocopy varchar2
) return number is
l_proc              varchar2(72) := g_package||'get_ele_classification_id';
l_classification_id number;
--
cursor csr_ele_classification
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_classification    in varchar2
) is
select classification_id
,      non_payments_flag
from   pay_element_classifications
where  upper(classification_name) = p_classification
and
(
  (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_ele_classification
       (p_business_group_id
       ,p_legislation_code
       ,upper(p_classification)
       );
  fetch csr_ele_classification
  into  l_classification_id
  ,     p_non_payments_flag
  ;
  if csr_ele_classification%notfound then
    close csr_ele_classification;
    hr_utility.set_message(801, 'PAY_50060_ETM_BAD_ELE_CLASS');
    hr_utility.set_message_token('CLASSIFICATION', p_classification);
    hr_utility.raise_error;
  end if;
  close csr_ele_classification;
  --
  return l_classification_id;
end get_ele_classification_id;
-- ----------------------------------------------------------------------------
-- |------------------------< get_ben_classification_id >---------------------|
-- ----------------------------------------------------------------------------
function get_ben_classification_id
(p_business_group_id  in number
,p_legislation_code   in varchar2
,p_ben_classification in varchar2
) return number is
l_proc                  varchar2(72) := g_package||'get_ben_classification_id';
l_ben_classification_id number;
--
cursor csr_ben_classification
(p_business_group_id  in number
,p_legislation_code   in varchar2
,p_ben_classification in varchar2
) is
select benefit_classification_id
from   ben_benefit_classifications
where  upper(benefit_classification_name) = p_ben_classification
and
(
  (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_ben_classification
       (p_business_group_id
       ,p_legislation_code
       ,upper(p_ben_classification)
       );
  fetch csr_ben_classification into l_ben_classification_id;
  if csr_ben_classification%notfound then
    close csr_ben_classification;
    hr_utility.set_message(801, 'PAY_50061_ETM_BAD_BEN_CLASS');
    hr_utility.set_message_token('CLASSIFICATION', p_ben_classification);
    hr_utility.raise_error;
  end if;
  close csr_ben_classification;
  --
  return l_ben_classification_id;
end get_ben_classification_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< get_formula_id  >---------------------------|
-- ----------------------------------------------------------------------------
function get_formula_id
(p_effective_date    in date
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_formula_type_id   in number
,p_formula           in varchar2
) return number is
l_proc       varchar2(72) := g_package||'get_formula_id';
l_formula_id number;
  --
cursor csr_formula
(p_effective_date    in     date
,p_business_group_id in     number
,p_legislation_code  in     varchar2
,p_formula_type_id   in     number
,p_formula           in varchar2
) is
  select formula_id
  from ff_formulas_f
  where formula_type_id = p_formula_type_id
  and   upper(formula_name) = p_formula
  and (p_effective_date between
       effective_start_date and nvl(effective_end_date, hr_api.g_eot))
  and
  (
    (business_group_id is null and legislation_code is null)
    or (legislation_code is null and business_group_id = p_business_group_id)
    or (business_group_id is null and legislation_code = p_legislation_code)
  );
begin
  open csr_formula
       (p_effective_date
       ,p_business_group_id
       ,p_legislation_code
       ,p_formula_type_id
       ,upper(p_formula)
       );
  fetch csr_formula into l_formula_id;
  if csr_formula%notfound then
    close csr_formula;
    hr_utility.set_message(801, 'PAY_50062_ETM_BAD_FORMULA_NAME');
    hr_utility.set_message_token('FORMULA_NAME', p_formula);
    hr_utility.raise_error;
  end if;
  close csr_formula;
  --
  return l_formula_id;
end get_formula_id;
-- ----------------------------------------------------------------------------
-- |----------------------------< get_balance_id  >---------------------------|
-- ----------------------------------------------------------------------------
function get_balance_id
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_balance           in varchar2
) return number is
l_proc       varchar2(72) := g_package||'get_balance_id';
l_balance_id number;
--
cursor csr_balance
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_balance           in varchar2
) is
select balance_type_id
from pay_balance_types
where upper(balance_name) = p_balance
and
(
  (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_balance
       (p_business_group_id
       ,p_legislation_code
       ,upper(p_balance)
       );
  fetch csr_balance into l_balance_id;
  if csr_balance%notfound then
    close csr_balance;
    hr_utility.set_message(801, 'PAY_50063_ETM_BAD_BALANCE_NAME');
    hr_utility.set_message_token('BALANCE_NAME', p_balance);
  end if;
  close csr_balance;
  --
  return l_balance_id;
end get_balance_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_element_type_id  >-------------------------|
-- ----------------------------------------------------------------------------
function get_element_type_id
(p_effective_date    in date
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_element_name      in varchar2
) return number is
l_proc            varchar2(72) := g_package||'get_element_type_id';
l_element_type_id number;
  --
cursor csr_element_name
(p_effective_date    in date
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_element_name      in varchar2
) is
select element_type_id
from  pay_element_types_f
where upper(element_name) = p_element_name
and   p_effective_date between
      effective_start_date and nvl(effective_end_date, hr_api.g_eot)
and
(
  (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_element_name
       (p_effective_date
       ,p_business_group_id
       ,p_legislation_code
       ,upper(p_element_name)
       );
  fetch csr_element_name into l_element_type_id;
  if csr_element_name%notfound then
    close csr_element_name;
    hr_utility.set_message(801, 'PAY_50215_ETM_BAD_ELEMENT_TYPE');
    hr_utility.set_message_token('ELEMENT_TYPE', p_element_name);
    hr_utility.raise_error;
  end if;
  close csr_element_name;
  --
  return l_element_type_id;
end get_element_type_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_event_group_id >---------------------------|
-- ----------------------------------------------------------------------------
function get_event_group_id
(p_business_group_id in     number
,p_legislation_code  in     varchar2
,p_event_group_type  in     varchar2
,p_event_group       in     varchar2
) return number is
l_proc           varchar2(72) := g_package||'get_event_group_id';
l_event_group_id number;
--
cursor csr_event_group
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_event_group_type  in varchar2
,p_event_group       in varchar2
) is
select event_group_id
from pay_event_groups
where event_group_type = p_event_group_type
and   upper(event_group_name) = p_event_group
and
(
  (business_group_id is null and legislation_code is null) or
  (legislation_code is null and business_group_id = p_business_group_id) or
  (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_event_group
       (p_business_group_id
       ,p_legislation_code
       ,p_event_group_type
       ,upper(p_event_group)
       );
  fetch csr_event_group into l_event_group_id;
  if csr_event_group%notfound then
    close csr_event_group;
    hr_utility.set_message(801, 'PAY_50201_ETM_BAD_EVENT_GROUP');
    hr_utility.set_message_token('EVENT_GROUP', p_event_group);
    hr_utility.raise_error;
  end if;
  close csr_event_group;
  --
  return l_event_group_id;
end get_event_group_id;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_bal_dimension_id >-------------------------|
-- ----------------------------------------------------------------------------
function get_bal_dimension_id
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_bal_dimension     in varchar2
) return number is
l_proc             varchar2(72) := g_package||'get_bal_dimension_id';
l_bal_dimension_id number;
--
cursor csr_bal_dimension
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_bal_dimension     in varchar2
) is
select balance_dimension_id
from   pay_balance_dimensions
where  upper(dimension_name) = p_bal_dimension
and
(
 (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_bal_dimension
       (p_business_group_id
       ,p_legislation_code
       ,upper(p_bal_dimension)
       );
  fetch csr_bal_dimension into l_bal_dimension_id;
  if csr_bal_dimension%notfound then
    close csr_bal_dimension;
    hr_utility.set_message(801, 'PAY_50059_ETM_BAD_BAL_DIMENSON');
    hr_utility.set_message_token('BALANCE_DIMENSION', p_bal_dimension);
    hr_utility.raise_error;
  end if;
  close csr_bal_dimension;
  --
  return l_bal_dimension_id;
end get_bal_dimension_id;
-- ----------------------------------------------------------------------------
-- |---------------------------< get_run_type_id  >---------------------------|
-- ----------------------------------------------------------------------------
function get_run_type_id
(p_effective_date    in date
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_run_type          in varchar2
) return number is
l_proc        varchar2(72) := g_package||'get_run_type_id';
l_run_type_id number;
  --
cursor csr_run_type
(p_effective_date    in date
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_run_type          in varchar2
) is
select run_type_id
from  pay_run_types_f
where upper(run_type_name) = p_run_type
and   p_effective_date between
      effective_start_date and nvl(effective_end_date, hr_api.g_eot)
and
(
  (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_run_type
       (p_effective_date
       ,p_business_group_id
       ,p_legislation_code
       ,upper(p_run_type)
       );
  fetch csr_run_type into l_run_type_id;
  if csr_run_type%notfound then
    close csr_run_type;
    hr_utility.set_message(801, 'PAY_50064_ETM_BAD_RUN_TYPE');
    hr_utility.set_message_token('RUN_TYPE', p_run_type);
    hr_utility.raise_error;
  end if;
  close csr_run_type;
  --
  return l_run_type_id;
end get_run_type_id;
-- ----------------------------------------------------------------------------
-- |--------------------------< get_bal_category_id >-------------------------|
-- ----------------------------------------------------------------------------
function get_bal_category_id
(p_effective_date    in date
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_bal_category      in varchar2
) return number is
l_proc                varchar2(72) := g_package||'get_bal_category_id';
l_balance_category_id number;
--
cursor csr_balance_category
(p_effective_date    in date
,p_business_group_id in number
,p_legislation_code  in varchar2
,p_bal_category      in varchar2
) is
select balance_category_id
from   pay_balance_categories_f
where  upper(category_name) = p_bal_category
and    p_effective_date between
       effective_start_date and effective_end_date
and
(
  (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_balance_category
       (p_effective_date
       ,p_business_group_id
       ,p_legislation_code
       ,upper(p_bal_category)
       );
  fetch csr_balance_category into l_balance_category_id;
  if csr_balance_category%notfound then
    close csr_balance_category;
    hr_utility.set_message(801, 'PAY_51520_ETM_BAD_BAL_CATEGORY');
    hr_utility.set_message_token('BALANCE_CATEGORY', p_bal_category);
    hr_utility.raise_error;
  end if;
  close csr_balance_category;
  --
  return l_balance_category_id;
end get_bal_category_id;
-- ----------------------------------------------------------------------------
-- |----------------------< get_bal_attribute_def_id >------------------------|
-- ----------------------------------------------------------------------------
function get_bal_attribute_def_id
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_attribute         in varchar2
) return number is
l_proc         varchar2(72) := g_package||'get_bal_attribute_def_id';
l_attribute_id number;
--
cursor csr_attribute
(p_business_group_id in number
,p_legislation_code  in varchar2
,p_attribute         in varchar2
) is
select attribute_id
from pay_bal_attribute_definitions
where upper(attribute_name) = p_attribute
and
(
  (business_group_id is null and legislation_code is null)
  or (legislation_code is null and business_group_id = p_business_group_id)
  or (business_group_id is null and legislation_code = p_legislation_code)
);
begin
  open csr_attribute
       (p_business_group_id
       ,p_legislation_code
       ,upper(p_attribute)
       );
  fetch csr_attribute into l_attribute_id;
  if csr_attribute%notfound then
    close csr_attribute;
    hr_utility.set_message(801, 'PAY_50211_ETM_BAD_BAL_ATTR_DEF');
    hr_utility.set_message_token('BALANCE_ATTR_DEF', p_attribute);
    hr_utility.raise_error;
  end if;
  close csr_attribute;
  --
  return l_attribute_id;
end get_bal_attribute_def_id;
-- ----------------------------------------------------------------------------
-- |------------------------< flush_generation_tables >-----------------------|
-- ----------------------------------------------------------------------------
procedure flush_generation_tables
  (p_sf_core_objects      in out nocopy pay_element_template_util.t_core_objects
  ,p_sbt_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sdb_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_set_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_ssr_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sbc_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_siv_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sbf_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_spr_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sfr_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sir_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_seu_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sgb_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sba_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                varchar2(72) := g_package||'flush_generation_tables';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  p_sf_core_objects.delete;
  p_sbt_core_objects.delete;
  p_sdb_core_objects.delete;
  p_set_core_objects.delete;
  p_ssr_core_objects.delete;
  p_sbc_core_objects.delete;
  p_siv_core_objects.delete;
  p_sbf_core_objects.delete;
  p_spr_core_objects.delete;
  p_sfr_core_objects.delete;
  p_sir_core_objects.delete;
  p_seu_core_objects.delete;
  p_sgb_core_objects.delete;
  p_sba_core_objects.delete;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end flush_generation_tables;
-- ----------------------------------------------------------------------------
-- |----------------------< create_generation_tables >------------------------|
-- ----------------------------------------------------------------------------
procedure create_generation_tables
  (p_all_core_objects          in     pay_element_template_util.t_core_objects
  ,p_index_by_core_object_id   in     boolean default false
  ,p_sf_core_objects     in out nocopy pay_element_template_util.t_core_objects
  ,p_sbt_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_sdb_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_set_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_ssr_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_sbc_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_siv_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_sbf_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_spr_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_sfr_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_sir_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_seu_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_sgb_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ,p_sba_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                varchar2(72) := g_package||'create_generation_tables';
  i                     number;
  l_index               number;
  l_core_object_type    varchar2(30);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Flush the current generation tables.
  --
  flush_generation_tables
  (p_sf_core_objects               => p_sf_core_objects
  ,p_sbt_core_objects              => p_sbt_core_objects
  ,p_sdb_core_objects              => p_sdb_core_objects
  ,p_set_core_objects              => p_set_core_objects
  ,p_ssr_core_objects              => p_ssr_core_objects
  ,p_sbc_core_objects              => p_sbc_core_objects
  ,p_siv_core_objects              => p_siv_core_objects
  ,p_sbf_core_objects              => p_sbf_core_objects
  ,p_spr_core_objects              => p_spr_core_objects
  ,p_sfr_core_objects              => p_sfr_core_objects
  ,p_sir_core_objects              => p_sir_core_objects
  ,p_seu_core_objects              => p_seu_core_objects
  ,p_sgb_core_objects              => p_sgb_core_objects
  ,p_sba_core_objects              => p_sba_core_objects
  );
  --
  -- For each core object, set entries in the per-shadow-table generation
  -- tables.
  --
  i := p_all_core_objects.first;
  loop
    exit when not p_all_core_objects.exists(i);
    --
    -- Index by shadow_object_id or core_object_id according to the caller's
    -- choice.
    --
    if p_index_by_core_object_id then
      l_index := p_all_core_objects(i).core_object_id;
    else
      l_index := p_all_core_objects(i).shadow_object_id;
    end if;
    l_core_object_type := p_all_core_objects(i).core_object_type;
    if l_core_object_type = g_sf_lookup_type then
      p_sf_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sbt_lookup_type then
     p_sbt_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sdb_lookup_type then
     p_sdb_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_set_lookup_type then
     p_set_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_ssr_lookup_type then
     p_ssr_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sbc_lookup_type then
     p_sbc_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_siv_lookup_type then
     p_siv_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sbf_lookup_type then
     p_sbf_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_spr_lookup_type then
     p_spr_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sfr_lookup_type then
     p_sfr_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sir_lookup_type then
     p_sir_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_seu_lookup_type then
     p_seu_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sgb_lookup_type then
     p_sgb_core_objects(l_index) := p_all_core_objects(i);
    elsif l_core_object_type = g_sba_lookup_type then
     p_sba_core_objects(l_index) := p_all_core_objects(i);
    end if;
    --
    i := p_all_core_objects.next(i);
  end loop;
  hr_utility.set_location(' Leaving:'||l_proc, 90);
end create_generation_tables;
-- ----------------------------------------------------------------------------
-- |-------------------------< core_object_exists >---------------------------|
-- ----------------------------------------------------------------------------
function core_object_exists
  (p_shadow_object_id              in     number
  ,p_object_type                   in     varchar2
  ,p_core_objects                  in     pay_element_template_util.t_core_objects
  ) return boolean is
  l_proc                varchar2(72) := g_package||'core_object_exists';
  l_core_object_id      number;
  l_count               number;
  --
  cursor csr_sf_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   ff_formulas_f
  where  formula_id = p_core_object_id;
  --
  cursor csr_set_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_element_types_f
  where  element_type_id = p_core_object_id;
  --
  cursor csr_sbt_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_balance_types
  where  balance_type_id = p_core_object_id;
  --
  cursor csr_sdb_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_defined_balances
  where  defined_balance_id = p_core_object_id;
  --
  cursor csr_ssr_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_sub_classification_rules_f
  where  sub_classification_rule_id = p_core_object_id;
  --
  cursor csr_sbc_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_balance_classifications
  where  balance_classification_id = p_core_object_id;
  --
  cursor csr_siv_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_input_values_f
  where  input_value_id = p_core_object_id;
  --
  cursor csr_sbf_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_balance_feeds_f
  where  balance_feed_id = p_core_object_id;
  --
  cursor csr_sfr_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_formula_result_rules_f
  where  formula_result_rule_id = p_core_object_id;
  --
  cursor csr_spr_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_status_processing_rules_f
  where  status_processing_rule_id = p_core_object_id;
  --
  cursor csr_sir_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_iterative_rules_f
  where  iterative_rule_id = p_core_object_id;
  --
  cursor csr_seu_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_element_type_usages_f
  where  element_type_usage_id = p_core_object_id;
  --
  cursor csr_sgb_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_grossup_bal_exclusions
  where  grossup_balances_id = p_core_object_id;
  --
  cursor csr_sba_core_object_exists(p_core_object_id in number) is
  select count(0)
  from   pay_balance_attributes
  where  balance_attribute_id = p_core_object_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- A core object corresponding a shadow object exists if there is
  -- a row for it in PAY_TEMPLATE_CORE_OBJECTS, and the generated object
  -- still exists in the core schema.
  --
  if p_core_objects.exists(p_shadow_object_id) then
    l_core_object_id := p_core_objects(p_shadow_object_id).core_object_id;
    if p_object_type = g_sf_lookup_type then
      hr_utility.set_location(l_proc, 20);
      open csr_sf_core_object_exists(l_core_object_id);
      fetch csr_sf_core_object_exists into l_count;
      close csr_sf_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_set_lookup_type then
      hr_utility.set_location(l_proc, 30);
      open csr_set_core_object_exists(l_core_object_id);
      fetch csr_set_core_object_exists into l_count;
      close csr_set_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sbt_lookup_type then
      hr_utility.set_location(l_proc, 40);
      open csr_sbt_core_object_exists(l_core_object_id);
      fetch csr_sbt_core_object_exists into l_count;
      close csr_sbt_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sdb_lookup_type then
      hr_utility.set_location(l_proc, 50);
      open csr_sdb_core_object_exists(l_core_object_id);
      fetch csr_sdb_core_object_exists into l_count;
      close csr_sdb_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_ssr_lookup_type then
      hr_utility.set_location(l_proc, 60);
      open csr_ssr_core_object_exists(l_core_object_id);
      fetch csr_ssr_core_object_exists into l_count;
      close csr_ssr_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sbc_lookup_type then
      hr_utility.set_location(l_proc, 70);
      open csr_sbc_core_object_exists(l_core_object_id);
      fetch csr_sbc_core_object_exists into l_count;
      close csr_sbc_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_siv_lookup_type then
      hr_utility.set_location(l_proc, 80);
      open csr_siv_core_object_exists(l_core_object_id);
      fetch csr_siv_core_object_exists into l_count;
      close csr_siv_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sbf_lookup_type then
      hr_utility.set_location(l_proc, 90);
      open csr_sbf_core_object_exists(l_core_object_id);
      fetch csr_sbf_core_object_exists into l_count;
      close csr_sbf_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_spr_lookup_type then
      hr_utility.set_location(l_proc, 95);
      open csr_spr_core_object_exists(l_core_object_id);
      fetch csr_spr_core_object_exists into l_count;
      close csr_spr_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sfr_lookup_type then
      hr_utility.set_location(l_proc, 100);
      open csr_sfr_core_object_exists(l_core_object_id);
      fetch csr_sfr_core_object_exists into l_count;
      close csr_sfr_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sir_lookup_type then
      hr_utility.set_location(l_proc, 110);
      open csr_sir_core_object_exists(l_core_object_id);
      fetch csr_sir_core_object_exists into l_count;
      close csr_sir_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_seu_lookup_type then
      hr_utility.set_location(l_proc, 120);
      open csr_seu_core_object_exists(l_core_object_id);
      fetch csr_seu_core_object_exists into l_count;
      close csr_seu_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sgb_lookup_type then
      hr_utility.set_location(l_proc, 130);
      open csr_sgb_core_object_exists(l_core_object_id);
      fetch csr_sgb_core_object_exists into l_count;
      close csr_sgb_core_object_exists;
      return l_count > 0;
    elsif p_object_type = g_sba_lookup_type then
      hr_utility.set_location(l_proc, 140);
      open csr_sba_core_object_exists(l_core_object_id);
      fetch csr_sba_core_object_exists into l_count;
      close csr_sba_core_object_exists;
      return l_count > 0;
    end if;
    --
    -- Should never get here.
    --
    hr_general.assert_condition(false);
  end if;
  --
  -- Object does not exist because no rows in PAY_TEMPLATE_CORE_OBJECTS.
  --
  return false;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 500);
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 510);
    if csr_sf_core_object_exists%isopen then
      close csr_sf_core_object_exists;
    end if;
    --
    if csr_set_core_object_exists%isopen then
      close csr_set_core_object_exists;
    end if;
    --
    if csr_sbt_core_object_exists%isopen then
      close csr_sbt_core_object_exists;
    end if;
    --
    if csr_sdb_core_object_exists%isopen then
      close csr_sdb_core_object_exists;
    end if;
    --
    if csr_ssr_core_object_exists%isopen then
      close csr_ssr_core_object_exists;
    end if;
    --
    if csr_sbc_core_object_exists%isopen then
      close csr_sbc_core_object_exists;
    end if;
    --
    if csr_siv_core_object_exists%isopen then
      close csr_siv_core_object_exists;
    end if;
    --
    if csr_sbf_core_object_exists%isopen then
      close csr_sbf_core_object_exists;
    end if;
    --
    if csr_spr_core_object_exists%isopen then
      close csr_spr_core_object_exists;
    end if;
    --
    if csr_sfr_core_object_exists%isopen then
      close csr_sfr_core_object_exists;
    end if;
    --
    if csr_sir_core_object_exists%isopen then
      close csr_sir_core_object_exists;
    end if;
    --
    if csr_seu_core_object_exists%isopen then
      close csr_seu_core_object_exists;
    end if;
    --
    if csr_sgb_core_object_exists%isopen then
      close csr_sgb_core_object_exists;
    end if;
    --
    if csr_sba_core_object_exists%isopen then
      close csr_sba_core_object_exists;
    end if;
    --
    raise;
end core_object_exists;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_core_objects >--------------------------|
-- ----------------------------------------------------------------------------
procedure update_core_objects
  (p_effective_date       in     date
  ,p_template_id          in     number
  ,p_core_object_type     in     varchar2
  ,p_shadow_object_id     in     number
  ,p_core_object_id       in     number
  ,p_core_objects         in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                varchar2(72) := g_package||'update_core_objects';
  l_core_object         pay_tco_shd.g_rec_type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  if p_core_objects.exists(p_shadow_object_id) then
    l_core_object := p_core_objects(p_shadow_object_id);
    l_core_object.core_object_id := p_core_object_id;
    pay_tco_upd.upd(l_core_object);
  else
    l_core_object.template_id       := p_template_id;
    l_core_object.core_object_type  := p_core_object_type;
    l_core_object.shadow_object_id  := p_shadow_object_id;
    l_core_object.core_object_id    := p_core_object_id;
    l_core_object.effective_date    := p_effective_date;
    pay_tco_ins.ins(l_core_object);
  end if;
  --
  -- Insert to allow indexing by the shadow_object_id.
  --
  p_core_objects(p_shadow_object_id) := l_core_object;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end update_core_objects;
-- ----------------------------------------------------------------------------
-- |---------------------------< new_core_object >----------------------------|
-- ----------------------------------------------------------------------------
function new_core_object
  (p_core_object                   in     pay_tco_shd.g_rec_type
  ,p_all_core_objects              in     pay_element_template_util.t_core_objects
  ) return boolean is
  l_proc                varchar2(72) := g_package||'new_core_object';
  l_template_core_object_id        number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 100);
  l_template_core_object_id := p_core_object.template_core_object_id;
  return not p_all_core_objects.exists(l_template_core_object_id);
end new_core_object;
-- ----------------------------------------------------------------------------
-- |---------------------------< gen_formulas >-------------------------------|
-- ----------------------------------------------------------------------------
procedure gen_formulas
  (p_effective_date          in     date
  ,p_template_id             in     number
  ,p_hr_only                 in     boolean
  ,p_formulas                in     pay_element_template_util.t_formulas
  ,p_sf_core_objects         in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                varchar2(72) := g_package||'gen_formulas';
  l_shadow_object_id    number;
  i                     number;
  --
  l_rowid               varchar2(128);
  l_formula_id          number;
  l_formula_name        varchar2(80);
  l_last_update_date    date;
  l_formula_type_id     number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_formulas.first;
  loop
    exit when not p_formulas.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sf_lookup_type
           ,p_core_objects     => p_sf_core_objects
           )
       and
       (
         not p_hr_only or
         (p_hr_only and
           (
             p_formulas(i).formula_type_name = g_input_val_formula_type
           )
         )
       )
    then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_formula_name := p_formulas(i).formula_name;
      l_formula_id := null;
      l_rowid := null;
      l_last_update_date := hr_api.g_sys;

      --
      -- Get the formula type. If formula type is null then consider
      -- formula to be of type 'Oracle Payroll' and use g_payroll_formula_id.
      --
      if p_formulas(i).formula_type_name is null or
        p_formulas(i).formula_type_name = g_payroll_formula_type then
        l_formula_type_id := g_payroll_formula_type_id;
      else
        l_formula_type_id := get_formula_type_id(p_formulas(i).formula_type_name);
      end if;
      --
      -- Insert the formula row.
      --
      ff_formulas_f_pkg.insert_row
      (x_rowid                      => l_rowid
      ,x_formula_id                 => l_formula_id
      ,x_effective_start_date       => p_effective_date
      ,x_effective_end_date         => hr_api.g_eot
      ,x_business_group_id          => p_formulas(i).business_group_id
      ,x_legislation_code           => null
      ,x_formula_type_id            => l_formula_type_id
      ,x_formula_name               => l_formula_name
      ,x_description                => p_formulas(i).description
      ,x_formula_text               => p_formulas(i).formula_text
      ,x_sticky_flag                => 'N'
      ,x_last_update_date           => l_last_update_date
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_sf_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_formula_id
      ,p_core_objects               => p_sf_core_objects
      );
    end if;
    --
    i := p_formulas.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_formulas;
-- ----------------------------------------------------------------------------
-- |----------------------------< gen_balance_type >--------------------------|
-- ----------------------------------------------------------------------------
procedure gen_balance_type
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ,p_balance_type_id   in     number
  ,p_balance_types     in     pay_element_template_util.t_balance_types
  ,p_siv_core_objects  in     pay_element_template_util.t_core_objects
  ,p_sbt_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                 varchar2(72) := g_package||'gen_balance_type';
  l_rowid                varchar2(128);
  l_balance_type_id      number;
  l_base_balance_type_id number;
  l_balance_category_id  number;
  l_input_value_id       number;
  l_id                   number;
  l_id1                  number;
begin
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  -- Only generate if a generated core object does not exist.
  --
  l_id := p_balance_type_id;
  if not core_object_exists
         (p_shadow_object_id => l_id
         ,p_object_type      => g_sbt_lookup_type
         ,p_core_objects     => p_sbt_core_objects
         ) then
    hr_utility.set_location(l_proc, 20);
    --
    -- Set up the in/out parameters.
    --
    l_balance_type_id := null;
    l_rowid := null;
    --
    -- Set up the balance_category_id value.
    --
    l_balance_category_id := null;
    if p_balance_types(l_id).category_name is not null then
      --
      l_balance_category_id :=
      get_bal_category_id
      (p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_bal_category      => p_balance_types(l_id).category_name
      );
    end if;
    --
    -- Set up the base_balance_type_id value.
    --
    l_base_balance_type_id := null;
    if p_balance_types(l_id).base_balance_name is not null then
      --
      -- External base balance.
      --
      l_base_balance_type_id :=
      get_balance_id
      (p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_balance           => p_balance_types(l_id).base_balance_name
      );
      --
    elsif p_balance_types(l_id).base_balance_type_id is not null then
      --
      -- The base balance type may or may not be generated. If it's not been
      -- generated then make a recursive call to generate it.
      --
      l_id1 := p_balance_types(l_id).base_balance_type_id;
      if not core_object_exists
             (p_shadow_object_id => l_id1
             ,p_object_type      => g_sbt_lookup_type
             ,p_core_objects     => p_sbt_core_objects
             ) then
        gen_balance_type
        (p_effective_date    => p_effective_date
        ,p_template_id       => p_template_id
        ,p_business_group_id => p_business_group_id
        ,p_legislation_code  => p_legislation_code
        ,p_balance_type_id   => l_id1
        ,p_balance_types     => p_balance_types
        ,p_siv_core_objects  => p_siv_core_objects
        ,p_sbt_core_objects  => p_sbt_core_objects
        );
      end if;
      --
      -- Core object exists at this stage.
      --
      l_base_balance_type_id := p_sbt_core_objects(l_id1).core_object_id;
    end if;
    --
    -- Set up the input_value_id value.
    --
    l_input_value_id := null;
    if p_balance_types(l_id).input_value_id is not null then
      l_input_value_id :=
      p_siv_core_objects(p_balance_types(l_id).input_value_id).core_object_id;
    end if;
    --
    -- Insert the balance row.
    --
    pay_balance_types_pkg.insert_row
    (x_rowid                        => l_rowid
    ,x_balance_type_id              => l_balance_type_id
    ,x_business_group_id            => p_business_group_id
    ,x_legislation_code             => null
    ,x_currency_code                => p_balance_types(l_id).currency_code
    ,x_assignment_remuneration_flag =>
     p_balance_types(l_id).assignment_remuneration_flag
    ,x_balance_name                 => p_balance_types(l_id).balance_name
    ,x_base_balance_name            => p_balance_types(l_id).balance_name
    ,x_balance_uom                  => p_balance_types(l_id).balance_uom
    ,x_comments                     => p_balance_types(l_id).comments
    ,x_legislation_subgroup         => null
    ,x_reporting_name               => p_balance_types(l_id).reporting_name
    ,x_attribute_category           => p_balance_types(l_id).attribute_category
    ,x_attribute1                   => p_balance_types(l_id).attribute1
    ,x_attribute2                   => p_balance_types(l_id).attribute2
    ,x_attribute3                   => p_balance_types(l_id).attribute3
    ,x_attribute4                   => p_balance_types(l_id).attribute4
    ,x_attribute5                   => p_balance_types(l_id).attribute5
    ,x_attribute6                   => p_balance_types(l_id).attribute6
    ,x_attribute7                   => p_balance_types(l_id).attribute7
    ,x_attribute8                   => p_balance_types(l_id).attribute8
    ,x_attribute9                   => p_balance_types(l_id).attribute9
    ,x_attribute10                  => p_balance_types(l_id).attribute10
    ,x_attribute11                  => p_balance_types(l_id).attribute11
    ,x_attribute12                  => p_balance_types(l_id).attribute12
    ,x_attribute13                  => p_balance_types(l_id).attribute13
    ,x_attribute14                  => p_balance_types(l_id).attribute14
    ,x_attribute15                  => p_balance_types(l_id).attribute15
    ,x_attribute16                  => p_balance_types(l_id).attribute16
    ,x_attribute17                  => p_balance_types(l_id).attribute17
    ,x_attribute18                  => p_balance_types(l_id).attribute18
    ,x_attribute19                  => p_balance_types(l_id).attribute19
    ,x_attribute20                  => p_balance_types(l_id).attribute20
    ,x_balance_category_id          => l_balance_category_id
    ,x_base_balance_type_id         => l_base_balance_type_id
    ,x_input_value_id               => l_input_value_id
    );
    --
    -- Set up the core object table rows.
    --
    hr_utility.set_location(l_proc, 30);
    update_core_objects
    (p_effective_date             => p_effective_date
    ,p_template_id                => p_template_id
    ,p_core_object_type           => g_sbt_lookup_type
    ,p_shadow_object_id           => p_balance_type_id
    ,p_core_object_id             => l_balance_type_id
    ,p_core_objects               => p_sbt_core_objects
    );
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_balance_type;
-- ----------------------------------------------------------------------------
-- |---------------------------< gen_balance_types >--------------------------|
-- ----------------------------------------------------------------------------
procedure gen_balance_types
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ,p_balance_types     in     pay_element_template_util.t_balance_types
  ,p_siv_core_objects  in     pay_element_template_util.t_core_objects
  ,p_sbt_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                 varchar2(72) := g_package||'gen_balance_types';
  i                      number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_balance_types.first;
  loop
    exit when not p_balance_types.exists(i);
    --
    gen_balance_type
    (p_effective_date    => p_effective_date
    ,p_template_id       => p_template_id
    ,p_business_group_id => p_business_group_id
    ,p_legislation_code  => p_legislation_code
    ,p_balance_type_id   => i
    ,p_balance_types     => p_balance_types
    ,p_siv_core_objects  => p_siv_core_objects
    ,p_sbt_core_objects  => p_sbt_core_objects
    );
    --
    i := p_balance_types.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_balance_types;
-- ----------------------------------------------------------------------------
-- |--------------------------< gen_defined_balances >------------------------|
-- ----------------------------------------------------------------------------
procedure gen_defined_balances
  (p_effective_date      in     date
  ,p_template_id         in     number
  ,p_business_group_id   in     number
  ,p_legislation_code    in     varchar2
  ,p_defined_balances    in     pay_element_template_util.t_defined_balances
  ,p_sbt_core_objects    in     pay_element_template_util.t_core_objects
  ,p_sdb_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                   varchar2(72) := g_package||'gen_defined_balances';
  l_shadow_object_id       number;
  i                        number;
  --
  l_rowid                  varchar2(128);
  l_balance_type_id        number;
  l_shadow_balance_type_id number;
  l_balance_dimension_id   number;
  l_defined_balance_id     number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_defined_balances.first;
  loop
    exit when not p_defined_balances.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sdb_lookup_type
           ,p_core_objects     => p_sdb_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_defined_balance_id := null;
      l_rowid := null;
      --
      -- Set up balance_dimension_id.
      --
      l_balance_dimension_id :=
      get_bal_dimension_id
      (p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_bal_dimension     => p_defined_balances(i).dimension_name
      );
      --
      -- Set up the balance_balance_type_id from the table of generated
      -- balance types.
      --
      l_shadow_balance_type_id := p_defined_balances(i).balance_type_id;
      l_balance_type_id :=
      p_sbt_core_objects(l_shadow_balance_type_id).core_object_id;
      --
      -- Insert the defined balance row.
      --
      pay_defined_balances_pkg.insert_row
      (x_rowid                        => l_rowid
      ,x_defined_balance_id           => l_defined_balance_id
      ,x_business_group_id            => p_business_group_id
      ,x_legislation_code             => null
      ,x_balance_type_id              => l_balance_type_id
      ,x_balance_dimension_id         => l_balance_dimension_id
      ,x_force_latest_balance_flag    =>
             p_defined_balances(i).force_latest_balance_flag
      ,x_legislation_subgroup         => null
      ,x_grossup_allowed_flag         =>
             nvl(p_defined_balances(i).grossup_allowed_flag, 'N')
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_sdb_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_defined_balance_id
      ,p_core_objects               => p_sdb_core_objects
      );
    end if;
    --
    i := p_defined_balances.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_defined_balances;
-- ----------------------------------------------------------------------------
-- |---------------------------< gen_element_types >--------------------------|
-- ----------------------------------------------------------------------------
procedure gen_element_types
  (p_effective_date           in     date
  ,p_template_id              in     number
  ,p_business_group_id        in     number
  ,p_hr_only                  in     boolean
  ,p_legislation_code         in     varchar2
  ,p_base_processing_priority in     number
  ,p_element_types            in     pay_element_template_util.t_element_types
  ,p_sf_core_objects          in     pay_element_template_util.t_core_objects
  ,p_set_core_objects         in out nocopy pay_element_template_util.t_core_objects
  ,p_spr_core_objects         in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                      varchar2(72) := g_package||'gen_element_types';
  l_shadow_object_id          number;
  i                           number;
  --
  l_rowid                     varchar2(128);
  l_element_type_id           number;
  l_ele_classification_id     number;
  l_ben_classification_id     number;
  l_formula_id                number;
  l_iterative_formula_id      number;
  l_processing_priority       number;
  l_non_payments_flag         varchar2(30);
  l_status_processing_rule_id number;
  l_bus_grp_currency_code     varchar2(30);
  l_proration_group_id        number;
  l_proration_formula_id      number;
  l_recalc_event_group_id     number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  l_bus_grp_currency_code :=
  hr_general.default_currency_code(p_business_group_id);
  --
  i := p_element_types.first;
  loop
    exit when not p_element_types.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_set_lookup_type
           ,p_core_objects     => p_set_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_element_type_id := null;
      l_rowid := null;
      --
      -- Set up processing priority.
      --
      l_processing_priority := p_base_processing_priority +
                               p_element_types(i).relative_processing_priority;
      --
      -- Map names to id values.
      --
      l_ele_classification_id :=
      get_ele_classification_id
      (p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_classification    => p_element_types(i).classification_name
      ,p_non_payments_flag => l_non_payments_flag
      );
      --
      l_ben_classification_id := null;
      if p_element_types(i).benefit_classification_name is not null then
        l_ben_classification_id :=
        get_ben_classification_id
        (p_business_group_id  => p_business_group_id
        ,p_legislation_code   => p_legislation_code
        ,p_ben_classification => p_element_types(i).benefit_classification_name
        );
      end if;
      --
      l_formula_id := null;
      if p_element_types(i).skip_formula is not null then
        l_formula_id :=
        get_formula_id
        (p_effective_date     => p_effective_date
        ,p_business_group_id  => p_business_group_id
        ,p_legislation_code   => p_legislation_code
        ,p_formula_type_id    => g_skip_formula_type_id
        ,p_formula            => p_element_types(i).skip_formula
        );
      end if;
      --
      l_iterative_formula_id := null;
      if p_element_types(i).iterative_formula_name is not null then
        l_iterative_formula_id :=
        get_formula_id
        (p_effective_date     => p_effective_date
        ,p_business_group_id  => p_business_group_id
        ,p_legislation_code   => p_legislation_code
        ,p_formula_type_id    => g_iterative_formula_type_id
        ,p_formula            => p_element_types(i).iterative_formula_name
        );
      end if;
      --
      l_proration_formula_id := null;
      if p_element_types(i).proration_formula is not null then
        l_proration_formula_id :=
        get_formula_id
        (p_effective_date     => p_effective_date
        ,p_business_group_id  => p_business_group_id
        ,p_legislation_code   => p_legislation_code
        ,p_formula_type_id    => g_proration_formula_type_id
        ,p_formula            => p_element_types(i).proration_formula
        );
      end if;
      --
      l_proration_group_id := null;
      if p_element_types(i).proration_group is not null then
        l_proration_group_id :=
        get_event_group_id
        (p_business_group_id => p_business_group_id
        ,p_legislation_code  => p_legislation_code
        ,p_event_group_type  => g_proration_event_group
        ,p_event_group       => p_element_types(i).proration_group
        );
      end if;
      --
      l_recalc_event_group_id := null;
      if p_element_types(i).recalc_event_group is not null then
        l_recalc_event_group_id :=
        get_event_group_id
        (p_business_group_id => p_business_group_id
        ,p_legislation_code  => p_legislation_code
        ,p_event_group_type  => g_retro_event_group
        ,p_event_group       => p_element_types(i).recalc_event_group
        );
      end if;

      --
      -- The business rule checking has to be performed here because the
      -- creation API does not contain business rule checking code!
      --
      hr_utility.set_location(l_proc, 40);
      hr_elements.chk_element_type
      (p_element_name                 => p_element_types(i).element_name
      ,p_element_type_id              => null
      ,p_val_start_date               => p_effective_date
      ,p_val_end_date                 => hr_api.g_eot
      ,p_reporting_name               => p_element_types(i).reporting_name
      ,p_rowid                        => null
      ,p_recurring_flag               => p_element_types(i).processing_type
      ,p_standard_flag                => p_element_types(i).standard_link_flag
      ,p_scndry_ent_allwd_flag        =>
       p_element_types(i).additional_entry_allowed_flag
      ,p_process_in_run_flag          => p_element_types(i).process_in_run_flag
      ,p_indirect_only_flag           => p_element_types(i).indirect_only_flag
      ,p_adjustment_only_flag         => p_element_types(i).adjustment_only_flag
      ,p_multiply_value_flag          => p_element_types(i).multiply_value_flag
      ,p_classification_type          => l_non_payments_flag
      ,p_output_currency_code         => p_element_types(i).output_currency_code
      ,p_input_currency_code          => p_element_types(i).input_currency_code
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => p_legislation_code
      ,p_bus_grp_currency_code        => l_bus_grp_currency_code
      );
      --
      -- Insert the element row.
      --
      hr_utility.set_location(l_proc, 50);
      pay_element_types_pkg.insert_row
      (p_rowid                        => l_rowid
      ,p_element_type_id              => l_element_type_id
      ,p_effective_start_date         => p_effective_date
      ,p_effective_end_date           => hr_api.g_eot
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => null
      ,p_formula_id                   => l_formula_id
      ,p_input_currency_code          => p_element_types(i).input_currency_code
      ,p_output_currency_code         => p_element_types(i).output_currency_code
      ,p_classification_id            => l_ele_classification_id
      ,p_benefit_classification_id    => l_ben_classification_id
      ,p_additional_entry_allowed     =>
       p_element_types(i).additional_entry_allowed_flag
      ,p_adjustment_only_flag         => p_element_types(i).adjustment_only_flag
      ,p_closed_for_entry_flag        =>
       p_element_types(i).closed_for_entry_flag
      ,p_element_name                 => p_element_types(i).element_name
      ,p_base_element_name            => p_element_types(i).element_name
      ,p_indirect_only_flag           => p_element_types(i).indirect_only_flag
      ,p_multiple_entries_allowed     =>
       p_element_types(i).multiple_entries_allowed_flag
      ,p_multiply_value_flag          => p_element_types(i).multiply_value_flag
      ,p_post_termination_rule        =>
       p_element_types(i).post_termination_rule
      ,p_process_in_run_flag          => p_element_types(i).process_in_run_flag
      ,p_processing_priority          => l_processing_priority
      ,p_processing_type              => p_element_types(i).processing_type
      ,p_standard_link_flag           => p_element_types(i).standard_link_flag
      ,p_comment_id                   => null
      ,p_description                  => p_element_types(i).description
      ,p_legislation_subgroup         => null
      ,p_qualifying_age               => p_element_types(i).qualifying_age
      ,p_qualifying_length_of_service =>
       p_element_types(i).qualifying_length_of_service
      ,p_qualifying_units             => p_element_types(i).qualifying_units
      ,p_reporting_name               => p_element_types(i).reporting_name
      ,p_attribute_category           => p_element_types(i).attribute_category
      ,p_attribute1                   => p_element_types(i).attribute1
      ,p_attribute2                   => p_element_types(i).attribute2
      ,p_attribute3                   => p_element_types(i).attribute3
      ,p_attribute4                   => p_element_types(i).attribute4
      ,p_attribute5                   => p_element_types(i).attribute5
      ,p_attribute6                   => p_element_types(i).attribute6
      ,p_attribute7                   => p_element_types(i).attribute7
      ,p_attribute8                   => p_element_types(i).attribute8
      ,p_attribute9                   => p_element_types(i).attribute9
      ,p_attribute10                  => p_element_types(i).attribute10
      ,p_attribute11                  => p_element_types(i).attribute11
      ,p_attribute12                  => p_element_types(i).attribute12
      ,p_attribute13                  => p_element_types(i).attribute13
      ,p_attribute14                  => p_element_types(i).attribute14
      ,p_attribute15                  => p_element_types(i).attribute15
      ,p_attribute16                  => p_element_types(i).attribute16
      ,p_attribute17                  => p_element_types(i).attribute17
      ,p_attribute18                  => p_element_types(i).attribute18
      ,p_attribute19                  => p_element_types(i).attribute19
      ,p_attribute20                  => p_element_types(i).attribute20
      ,p_element_information_category =>
       p_element_types(i).element_information_category
      ,p_element_information1        => p_element_types(i).element_information1
      ,p_element_information2        => p_element_types(i).element_information2
      ,p_element_information3        => p_element_types(i).element_information3
      ,p_element_information4        => p_element_types(i).element_information4
      ,p_element_information5        => p_element_types(i).element_information5
      ,p_element_information6        => p_element_types(i).element_information6
      ,p_element_information7        => p_element_types(i).element_information7
      ,p_element_information8        => p_element_types(i).element_information8
      ,p_element_information9        => p_element_types(i).element_information9
      ,p_element_information10       => p_element_types(i).element_information10
      ,p_element_information11       => p_element_types(i).element_information11
      ,p_element_information12       => p_element_types(i).element_information12
      ,p_element_information13       => p_element_types(i).element_information13
      ,p_element_information14       => p_element_types(i).element_information14
      ,p_element_information15       => p_element_types(i).element_information15
      ,p_element_information16       => p_element_types(i).element_information16
      ,p_element_information17       => p_element_types(i).element_information17
      ,p_element_information18       => p_element_types(i).element_information18
      ,p_element_information19       => p_element_types(i).element_information19
      ,p_element_information20       => p_element_types(i).element_information20
      ,p_non_payments_flag           => l_non_payments_flag
      --
      -- Don't generate the additional input values for benefits. They should
      -- be defined in the template.
      --
      ,p_default_benefit_uom         => null
      ,p_contributions_used          => 'N'
      ,p_third_party_pay_only_flag   =>
       p_element_types(i).third_party_pay_only_flag
      ,p_retro_summ_ele_id           => null
      ,p_iterative_flag              => p_element_types(i).iterative_flag
      ,p_iterative_formula_id        => l_iterative_formula_id
      ,p_iterative_priority          => p_element_types(i).iterative_priority
      ,p_process_mode                => p_element_types(i).process_mode
      ,p_grossup_flag                => p_element_types(i).grossup_flag
      ,p_advance_indicator           => p_element_types(i).advance_indicator
      ,p_advance_payable             => p_element_types(i).advance_payable
      ,p_advance_deduction           => p_element_types(i).advance_deduction
      ,p_process_advance_entry       => p_element_types(i).process_advance_entry
      ,p_proration_group_id          => l_proration_group_id
      ,p_proration_formula_id        => l_proration_formula_id
      ,p_recalc_event_group_id       => l_recalc_event_group_id
      ,p_once_each_period_flag       => p_element_types(i).once_each_period_flag
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 40);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_set_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_element_type_id
      ,p_core_objects               => p_set_core_objects
      );
    end if;
    --
    -- Create a "Standard" status processing rule for the element if
    -- it is associated with a payroll formula. Note: for status processing
    -- rules, the shadow_object_id is that of the element type.
    --
    if not p_hr_only and
       p_element_types(i).payroll_formula_id is not null and
       not core_object_exists
           (p_shadow_object_id => i
           ,p_object_type      => g_spr_lookup_type
           ,p_core_objects     => p_spr_core_objects
           ) then
      hr_utility.set_location(l_proc, 50);
      --
      l_element_type_id := p_set_core_objects(i).core_object_id;
      l_shadow_object_id := p_element_types(i).payroll_formula_id;
      l_formula_id := p_sf_core_objects(l_shadow_object_id).core_object_id;
      l_rowid := null;
      l_status_processing_rule_id := null;
      --
      pay_status_rules_pkg.insert_row
      (x_rowid                      => l_rowid
      ,x_status_processing_rule_id  => l_status_processing_rule_id
      ,x_effective_start_date       => p_effective_date
      ,x_effective_end_date         => hr_api.g_eot
      ,x_business_group_id          => p_business_group_id
      ,x_legislation_code           => null
      ,x_element_type_id            => l_element_type_id
      ,x_assignment_status_type_id  => null
      ,x_formula_id                 => l_formula_id
      ,x_processing_rule            => 'P'
      ,x_comment_id                 => null
      ,x_legislation_subgroup       => null
      ,x_last_update_date           => hr_api.g_sys
      ,x_last_updated_by            => -1
      ,x_last_update_login          => -1
      ,x_created_by                 => -1
      ,x_creation_date              => hr_api.g_sys
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 60);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_spr_lookup_type
      ,p_shadow_object_id           => i
      ,p_core_object_id             => l_status_processing_rule_id
      ,p_core_objects               => p_spr_core_objects
      );
    end if;
    --
    i := p_element_types.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_element_types;
-- ----------------------------------------------------------------------------
-- |----------------------< implicit_sub_classi_rules >-----------------------|
-- ----------------------------------------------------------------------------
procedure implicit_sub_classi_rules
(p_effective_date      in     date
,p_template_id         in     number
,p_business_group_id   in     number
,p_legislation_code    in     varchar2
,p_all_core_objects    in     pay_element_template_util.t_core_objects
,p_set_core_objects    in     pay_element_template_util.t_core_objects
,p_sub_classi_rules    in     pay_element_template_util.t_sub_classi_rules
,p_ssr_core_objects    in out nocopy pay_element_template_util.t_core_objects
) is
l_proc                 varchar2(72) := g_package||'implicit_sub_classi_rules';
i                            number;
l_shadow_object_id           number;
l_element_type_id            number;
l_shadow_element_type_id     number;
l_ele_classification_id      number;
l_sub_classification_rule_id number;
l_non_payments_flag          varchar2(30);
--
-- Cursor to detect a sub-classification rule exists for a given
-- element_type_id, and classification_id. Don't need to worry about
-- date-track because this cursor is only executed if element_type_id
-- is that of a newly created element.
--
cursor csr_sub_classi_rule
(p_element_type_id   in     number
,p_classification_id in     number
) is
select sub_classification_rule_id
from   pay_sub_classification_rules_f
where  element_type_id = p_element_type_id
and    classification_id = p_classification_id;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_sub_classi_rules.first;
  loop
    exit when not p_sub_classi_rules.exists(i);
    --
    l_shadow_element_type_id := p_sub_classi_rules(i).element_type_id;
    l_shadow_object_id := i;
    --
    -- Check to set if the element type is newly generated.
    --
    if new_core_object
       (p_set_core_objects(l_shadow_element_type_id)
       ,p_all_core_objects
       ) then
      l_element_type_id :=
      p_set_core_objects(l_shadow_element_type_id).core_object_id;
      --
      -- Get the classification_id.
      --
      l_ele_classification_id :=
      get_ele_classification_id
      (p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_classification    => p_sub_classi_rules(i).element_classification
      ,p_non_payments_flag => l_non_payments_flag
      );
      --
      -- Look for the implicitly created sub-classification rule.
      --
      hr_utility.set_location(l_proc, 20);
      open csr_sub_classi_rule(l_element_type_id ,l_ele_classification_id);
      fetch csr_sub_classi_rule into l_sub_classification_rule_id;
      if csr_sub_classi_rule%found then
        --
        -- Sub-classification rule found. Update the template generation
        -- table.
        --
        hr_utility.set_location(l_proc, 30);
        update_core_objects
        (p_effective_date             => p_effective_date
        ,p_template_id                => p_template_id
        ,p_core_object_type           => g_ssr_lookup_type
        ,p_shadow_object_id           => l_shadow_object_id
        ,p_core_object_id             => l_sub_classification_rule_id
        ,p_core_objects               => p_ssr_core_objects
        );
      end if;
      close csr_sub_classi_rule;
    end if;
    --
    i := p_sub_classi_rules.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 110);
    if csr_sub_classi_rule%isopen then
      close csr_sub_classi_rule;
    end if;
    raise;
end implicit_sub_classi_rules;
-- ----------------------------------------------------------------------------
-- |-------------------------< gen_sub_classi_rules >-------------------------|
-- ----------------------------------------------------------------------------
procedure gen_sub_classi_rules
  (p_effective_date      in     date
  ,p_template_id         in     number
  ,p_business_group_id   in     number
  ,p_legislation_code    in     varchar2
  ,p_sub_classi_rules    in     pay_element_template_util.t_sub_classi_rules
  ,p_set_core_objects    in     pay_element_template_util.t_core_objects
  ,p_ssr_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                       varchar2(72) := g_package||'gen_sub_classi_rules';
  l_shadow_object_id           number;
  i                            number;
  --
  l_rowid                      varchar2(128);
  l_element_type_id            number;
  l_sub_classification_rule_id number;
  l_ele_classification_id      number;
  l_non_payments_flag          varchar2(30);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_sub_classi_rules.first;
  loop
    exit when not p_sub_classi_rules.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_ssr_lookup_type
           ,p_core_objects     => p_ssr_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_sub_classification_rule_id := null;
      l_rowid := null;
      --
      -- Set up the classification_id.
      --
      l_ele_classification_id :=
      get_ele_classification_id
      (p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_classification    => p_sub_classi_rules(i).element_classification
      ,p_non_payments_flag => l_non_payments_flag
      );
      --
      -- Set up the element_type_id value.
      --
      l_element_type_id :=
      p_set_core_objects(p_sub_classi_rules(i).element_type_id).core_object_id;
      --
      -- Insert the secondary classification row.
      --
      hr_utility.set_location(l_proc, 30);
      pay_sub_class_rules_pkg.insert_row
      (p_rowid                        => l_rowid
      ,p_sub_classification_rule_id   => l_sub_classification_rule_id
      ,p_effective_start_date         => p_effective_date
      ,p_effective_end_date           => hr_api.g_eot
      ,p_element_type_id              => l_element_type_id
      ,p_classification_id            => l_ele_classification_id
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => null
      ,p_last_update_date             => hr_api.g_sys
      ,p_last_updated_by              => -1
      ,p_last_update_login            => -1
      ,p_created_by                   => -1
      ,p_creation_date                => hr_api.g_sys
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_ssr_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_sub_classification_rule_id
      ,p_core_objects               => p_ssr_core_objects
      );
    end if;
    --
    i := p_sub_classi_rules.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_sub_classi_rules;
-- ----------------------------------------------------------------------------
-- |-------------------------< gen_balance_classis >--------------------------|
-- ----------------------------------------------------------------------------
procedure gen_balance_classis
  (p_effective_date      in     date
  ,p_template_id         in     number
  ,p_business_group_id   in     number
  ,p_legislation_code    in     varchar2
  ,p_balance_classis     in     pay_element_template_util.t_balance_classis
  ,p_sbt_core_objects    in     pay_element_template_util.t_core_objects
  ,p_sbc_core_objects    in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                      varchar2(72) := g_package||'gen_balance_classis';
  l_shadow_object_id          number;
  i                           number;
  --
  l_rowid                     varchar2(128);
  l_balance_type_id           number;
  l_balance_classification_id number;
  l_ele_classification_id     number;
  l_non_payments_flag         varchar2(30);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_balance_classis.first;
  loop
    exit when not p_balance_classis.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sbc_lookup_type
           ,p_core_objects     => p_sbc_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_balance_classification_id := null;
      l_rowid := null;
      --
      -- Set up the classification_id.
      --
      l_ele_classification_id :=
      get_ele_classification_id
      (p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_classification    => p_balance_classis(i).element_classification
      ,p_non_payments_flag => l_non_payments_flag
      );
      --
      -- Set up the balance_type_id value.
      --
      l_balance_type_id :=
      p_sbt_core_objects(p_balance_classis(i).balance_type_id).core_object_id;
      --
      -- Insert the balance classification row.
      --
      pay_bal_classifications_pkg.insert_row
      (x_rowid                        => l_rowid
      ,x_balance_classification_id    => l_balance_classification_id
      ,x_business_group_id            => p_business_group_id
      ,x_legislation_code             => null
      ,x_balance_type_id              => l_balance_type_id
      ,x_classification_id            => l_ele_classification_id
      ,x_scale                        => p_balance_classis(i).scale
      ,x_legislation_subgroup         => null
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_sbc_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_balance_classification_id
      ,p_core_objects               => p_sbc_core_objects
      );
    end if;
    --
    i := p_balance_classis.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_balance_classis;
-- ----------------------------------------------------------------------------
-- |-------------------------< implicit_input_values >------------------------|
-- ----------------------------------------------------------------------------
procedure implicit_input_values
  (p_effective_date   in     date
  ,p_template_id      in     number
  ,p_all_core_objects in     pay_element_template_util.t_core_objects
  ,p_set_core_objects in     pay_element_template_util.t_core_objects
  ,p_input_values     in     pay_element_template_util.t_input_values
  ,p_siv_core_objects in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                   varchar2(72) := g_package||'implicit_input_values';
  i                        number;
  l_shadow_element_type_id number;
  l_element_type_id        number;
  l_name                   varchar2(256);
  --
  -- Cursor to detect an input value of a given name for a given
  -- element_type_id exists. Don't need to worry about date-track because
  -- this cursor is only executed if element_type_id is that of a newly
  -- created element.
  -- Note: in R11i, this cursor looks for 'Pay Value' on the pay_input_values_f
  -- base table whereas, in R11 the translated name appears on the base table.
  --
  cursor csr_input_value
  (p_element_type_id in     number
  ,p_name            in     varchar2
  ) is
  select rowid
  ,      input_value_id
  ,      effective_start_date
  ,      effective_end_date
  ,      element_type_id
  ,      lookup_type
  ,      business_group_id
  ,      display_sequence
  ,      generate_db_items_flag
  ,      hot_default_flag
  ,      mandatory_flag
  ,      name
  ,      uom
  ,      default_value
  ,      max_value
  ,      min_value
  ,      warning_or_error
  from   pay_input_values_f
  where  element_type_id = p_element_type_id
  and    name = 'Pay Value';
  --
  l_input_value csr_input_value%rowtype;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_input_values.first;
  loop
    exit when not p_input_values.exists(i);
    --
    -- Hate to hard code, but 'Pay Value' is the only implicitly
    -- generated input value that this code is concerned with. Check to
    -- see if this input value is a 'Pay Value' and that its element
    -- type is newly created.
    --
    l_shadow_element_type_id := p_input_values(i).element_type_id;
    l_name := upper(p_input_values(i).name);
    if (l_name = 'PAY VALUE') and
       new_core_object
       (p_set_core_objects(l_shadow_element_type_id)
       ,p_all_core_objects
       ) then
      --
      -- It's a new element, so check for the implicitly created 'Pay Value'.
      --
      hr_utility.set_location(l_proc, 20);
      l_element_type_id :=
      p_set_core_objects(l_shadow_element_type_id).core_object_id;
      open csr_input_value(l_element_type_id ,l_name);
      fetch csr_input_value into l_input_value;
      if csr_input_value%found then
        --
        -- Input value rule found. Update the template generation table.
        --
        hr_utility.set_location(l_proc, 30);
        update_core_objects
        (p_effective_date             => p_effective_date
        ,p_template_id                => p_template_id
        ,p_core_object_type           => g_siv_lookup_type
        ,p_shadow_object_id           => p_input_values(i).input_value_id
        ,p_core_object_id             => l_input_value.input_value_id
        ,p_core_objects               => p_siv_core_objects
        );
        --
        -- Update the input value if the mandatory flags differ - there
        -- shouldn't be any other difference of interest.
        --
        hr_utility.set_location(l_proc, 35);
        if l_input_value.mandatory_flag <>
           p_input_values(i).mandatory_flag then
          pay_input_values_pkg.update_row
          (p_rowid                  => l_input_value.rowid
          ,p_input_value_id         => l_input_value.input_value_id
          ,p_effective_start_date   => l_input_value.effective_start_date
          ,p_effective_end_date     => l_input_value.effective_end_date
          ,p_element_type_id        => l_input_value.element_type_id
          ,p_lookup_type            => l_input_value.lookup_type
          ,p_business_group_id      => l_input_value.business_group_id
          ,p_legislation_code       => null
          ,p_formula_id             => null
          ,p_display_sequence       => l_input_value.display_sequence
          ,p_generate_db_items_flag => l_input_value.generate_db_items_flag
          ,p_hot_default_flag       => l_input_value.hot_default_flag
          ,p_mandatory_flag         => p_input_values(i).mandatory_flag
          ,p_name                   => l_input_value.name
          ,p_uom                    => l_input_value.uom
          ,p_default_value          => l_input_value.default_value
          ,p_legislation_subgroup   => null
          ,p_max_value              => l_input_value.max_value
          ,p_min_value              => l_input_value.min_value
          ,p_warning_or_error       => l_input_value.warning_or_error
          ,p_recreate_db_items      => 'Y'
          ,p_base_name              => l_input_value.name
          );
        end if;
      end if;
      close csr_input_value;
    end if;
    --
    i := p_input_values.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 110);
    if csr_input_value%isopen then
      close csr_input_value;
    end if;
    raise;
end implicit_input_values;
-- ----------------------------------------------------------------------------
-- |---------------------------< gen_input_values >---------------------------|
-- ----------------------------------------------------------------------------
procedure gen_input_values
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ,p_input_values      in     pay_element_template_util.t_input_values
  ,p_set_core_objects  in     pay_element_template_util.t_core_objects
  ,p_sf_core_objects   in     pay_element_template_util.t_core_objects
  ,p_siv_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                       varchar2(72) := g_package||'gen_input_values';
  l_shadow_object_id           number;
  i                            number;
  --
  l_rowid                      varchar2(128);
  l_element_type_id            number;
  l_input_value_id             number;
  l_min_value                  varchar2(2000);
  l_max_value                  varchar2(2000);
  l_default_value              varchar2(2000);
  l_formula_id		       number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_input_values.first;
  loop
    exit when not p_input_values.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_siv_lookup_type
           ,p_core_objects     => p_siv_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_input_value_id := null;
      l_rowid := null;
      --
      -- Set up the element_type_id value.
      --
      l_element_type_id:=
      p_set_core_objects(p_input_values(i).element_type_id).core_object_id;
      --
      -- Insert the input value row.
      --
      hr_utility.set_location(l_proc, 30);
      --

      l_default_value := p_input_values(i).default_value;

      if p_input_values(i).lookup_type is not null then
        l_min_value := null;
        l_max_value := null;
        l_formula_id := null;
      elsif p_input_values(i).formula_id is not null then
        l_min_value := null;
        l_max_value := null;
        l_formula_id :=
        p_sf_core_objects(p_input_values(i).formula_id).core_object_id;
      elsif p_input_values(i).input_validation_formula is not null then
        l_min_value := null;
        l_max_value := null;
        --
	l_formula_id :=
        get_formula_id
        (p_effective_date     => p_effective_date
        ,p_business_group_id  => p_business_group_id
        ,p_legislation_code   => p_legislation_code
        ,p_formula_type_id    => g_input_val_formula_type_id
        ,p_formula            => p_input_values(i).input_validation_formula
        );
      else
        l_min_value := p_input_values(i).min_value;
        l_max_value := p_input_values(i).max_value;
        l_formula_id := null;
      end if;

      pay_input_values_pkg.insert_row
      (p_rowid                        => l_rowid
      ,p_input_value_id               => l_input_value_id
      ,p_effective_start_date         => p_effective_date
      ,p_effective_end_date           => hr_api.g_eot
      ,p_element_type_id              => l_element_type_id
      ,p_lookup_type                  => p_input_values(i).lookup_type
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => null
      ,p_formula_id                   => l_formula_id
      ,p_display_sequence             => p_input_values(i).display_sequence
      ,p_generate_db_items_flag       => p_input_values(i).generate_db_items_flag
      ,p_hot_default_flag             => p_input_values(i).hot_default_flag
      ,p_mandatory_flag               => p_input_values(i).mandatory_flag
      ,p_name                         => p_input_values(i).name
      ,p_base_name                    => p_input_values(i).name
      ,p_uom                          => p_input_values(i).uom
      ,p_default_value                => l_default_value
      ,p_legislation_subgroup         => null
      ,p_min_value                    => l_min_value
      ,p_max_value                    => l_max_value
      ,p_warning_or_error             => p_input_values(i).warning_or_error
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_siv_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_input_value_id
      ,p_core_objects               => p_siv_core_objects
      );
    end if;
    --
    i := p_input_values.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_input_values;
-- ----------------------------------------------------------------------------
-- |---------------------------< gen_balance_feeds >--------------------------|
-- ----------------------------------------------------------------------------
procedure gen_balance_feeds
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ,p_balance_feeds     in     pay_element_template_util.t_balance_feeds
  ,p_sbt_core_objects  in     pay_element_template_util.t_core_objects
  ,p_siv_core_objects  in     pay_element_template_util.t_core_objects
  ,p_sbf_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                       varchar2(72) := g_package||'gen_balance_feeds';
  l_shadow_object_id           number;
  i                            number;
  --
  l_rowid                      varchar2(128);
  l_balance_type_id            number;
  l_input_value_id             number;
  l_balance_feed_id            number;
  l_check_latest_balances      boolean;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_balance_feeds.first;
  loop
    exit when not p_balance_feeds.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sbf_lookup_type
           ,p_core_objects     => p_sbf_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_balance_feed_id := null;
      l_rowid := null;
      --
      -- Set up the balance_type_id value.
      --
      if p_balance_feeds(i).balance_name is not null then
        --
        -- External balance - set up the name.
        --
        l_balance_type_id :=
        get_balance_id
        (p_business_group_id => p_business_group_id
        ,p_legislation_code  => p_legislation_code
        ,p_balance           => p_balance_feeds(i).balance_name
        );
      else
        --
        -- Generated balance - get balance_type_id from generated objects table.
        --
        l_balance_type_id :=
        p_sbt_core_objects(p_balance_feeds(i).balance_type_id).core_object_id;
      end if;
      --
      -- Set up the input_value_id value.
      --
      l_input_value_id :=
      p_siv_core_objects(p_balance_feeds(i).input_value_id).core_object_id;
      --
      -- Insert the balance feed row.
      --
      hr_utility.set_location(l_proc, 30);

      begin
        --
        -- Disable (unnecessary) latest balance checking.
        --
        l_check_latest_balances := hrassact.check_latest_balances;
        hrassact.check_latest_balances := false;

        pay_balance_feeds_f_pkg.insert_row
        (x_rowid                        => l_rowid
        ,x_balance_feed_id              => l_balance_feed_id
        ,x_effective_start_date         => p_effective_date
        ,x_effective_end_date           => hr_api.g_eot
        ,x_business_group_id            => p_business_group_id
        ,x_legislation_code             => null
        ,x_balance_type_id              => l_balance_type_id
        ,x_input_value_id               => l_input_value_id
        ,x_scale                        => p_balance_feeds(i).scale
        ,x_legislation_subgroup         => null
        );

        --
        -- Reset latest balance checking status.
        --
        hrassact.check_latest_balances := l_check_latest_balances;

      exception
        when others then
          --
          -- Reset latest balance checking status.
          --
          hrassact.check_latest_balances := l_check_latest_balances;
          raise;
      end;

      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 40);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_sbf_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_balance_feed_id
      ,p_core_objects               => p_sbf_core_objects
      );
    end if;
    --
    i := p_balance_feeds.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_balance_feeds;
-- ----------------------------------------------------------------------------
-- |---------------------------< gen_formula_rules >--------------------------|
-- ----------------------------------------------------------------------------
procedure gen_formula_rules
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ,p_formula_rules     in     pay_element_template_util.t_formula_rules
  ,p_sf_core_objects   in     pay_element_template_util.t_core_objects
  ,p_set_core_objects  in     pay_element_template_util.t_core_objects
  ,p_siv_core_objects  in     pay_element_template_util.t_core_objects
  ,p_spr_core_objects  in     pay_element_template_util.t_core_objects
  ,p_sfr_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                      varchar2(72) := g_package||'gen_formula_rules';
  l_shadow_object_id          number;
  i                           number;
  --
  l_rowid                     varchar2(128);
  l_shadow_element_type_id    number;
  l_element_type_id           number;
  l_shadow_formula_id         number;
  l_shadow_input_value_id     number;
  l_input_value_id            number;
  l_formula_result_rule_id    number;
  l_status_processing_rule_id number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_formula_rules.first;
  loop
    exit when not p_formula_rules.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sfr_lookup_type
           ,p_core_objects     => p_sfr_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      -----------------------------------
      -- Set up the in/out parameters. --
      -----------------------------------
      l_formula_result_rule_id := null;
      l_rowid := null;
      ----------------------------------------
      -- Get the status_processing_rule_id. --
      ----------------------------------------
      l_shadow_element_type_id := p_formula_rules(i).shadow_element_type_id;
      if core_object_exists
         (p_shadow_object_id => l_shadow_element_type_id
         ,p_object_type      => g_spr_lookup_type
         ,p_core_objects     => p_spr_core_objects
         ) then
       l_status_processing_rule_id :=
       p_spr_core_objects(l_shadow_element_type_id).core_object_id;
      else
        hr_utility.set_message(801, 'PAY_50066_ETM_GEN_NO_FK_ROW');
        hr_utility.set_message_token('TABLE', 'PAY_STATUS_PROCESSING_RULES_F');
        hr_utility.set_message_token('FK_TABLE', 'PAY_ELEMENT_TYPES_F');
        hr_utility.raise_error;
      end if;
      -------------------------------------------------------------------
      -- Set up the element_type_id and input_value_id columns for the --
      -- formula rule. Raise an error if they have not been generated. --
      -------------------------------------------------------------------
      l_input_value_id := null;
      l_shadow_input_value_id := p_formula_rules(i).input_value_id;
      if l_shadow_input_value_id is not null then
        if core_object_exists
           (p_shadow_object_id => l_shadow_input_value_id
           ,p_object_type      => g_siv_lookup_type
           ,p_core_objects     => p_siv_core_objects
           ) then
          l_input_value_id :=
          p_siv_core_objects(l_shadow_input_value_id).core_object_id;
        else
          hr_utility.set_message(801, 'PAY_50066_ETM_GEN_NO_FK_ROW');
          hr_utility.set_message_token('TABLE', 'PAY_STATUS_PROCESSING_RULES_F');
          hr_utility.set_message_token('FK_TABLE', 'PAY_INPUT_VALUES_F');
          hr_utility.raise_error;
        end if;
      end if;
      --
      l_element_type_id := null;
      l_shadow_element_type_id := p_formula_rules(i).element_type_id;
      if l_shadow_element_type_id is not null then
        if core_object_exists
           (p_shadow_object_id => l_shadow_element_type_id
           ,p_object_type      => g_set_lookup_type
           ,p_core_objects     => p_set_core_objects
           ) then
          l_element_type_id :=
          p_set_core_objects(l_shadow_element_type_id).core_object_id;
        else
          hr_utility.set_message(801, 'PAY_50066_ETM_GEN_NO_FK_ROW');
          hr_utility.set_message_token('TABLE', 'PAY_STATUS_PROCESSING_RULES_F');
          hr_utility.set_message_token('FK_TABLE', 'PAY_ELEMENT_TYPES_F');
          hr_utility.raise_error;
        end if;
      elsif p_formula_rules(i).element_name is not null then
        l_element_type_id :=
        get_element_type_id
        (p_effective_date    => p_effective_date
        ,p_business_group_id => p_business_group_id
        ,p_legislation_code  => p_legislation_code
        ,p_element_name      => p_formula_rules(i).element_name
        );
      end if;
      -----------------------------------------
      -- Insert the formula result rule row. --
      -----------------------------------------
      pay_formula_result_rules_pkg.insert_row
      (p_rowid                        => l_rowid
      ,p_formula_result_rule_id       => l_formula_result_rule_id
      ,p_effective_start_date         => p_effective_date
      ,p_effective_end_date           => hr_api.g_eot
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => null
      ,p_element_type_id              => l_element_type_id
      ,p_status_processing_rule_id    => l_status_processing_rule_id
      ,p_result_name                  => upper(p_formula_rules(i).result_name)
      ,p_result_rule_type             => p_formula_rules(i).result_rule_type
      ,p_legislation_subgroup         => null
      ,p_severity_level               => p_formula_rules(i).severity_level
      ,p_input_value_id               => l_input_value_id
      ,p_created_by                   => -1
      ,p_session_date                 => hr_api.g_sys
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_sfr_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_formula_result_rule_id
      ,p_core_objects               => p_sfr_core_objects
      );
    end if;
    --
    i := p_formula_rules.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_formula_rules;
-- ----------------------------------------------------------------------------
-- |--------------------------< gen_iterative_rules >-------------------------|
-- ----------------------------------------------------------------------------
procedure gen_iterative_rules
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_iterative_rules   in     pay_element_template_util.t_iterative_rules
  ,p_set_core_objects  in     pay_element_template_util.t_core_objects
  ,p_siv_core_objects  in     pay_element_template_util.t_core_objects
  ,p_sir_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                      varchar2(72) := g_package||'gen_iterative_rules';
  l_shadow_object_id          number;
  i                           number;
  --
  l_shadow_element_type_id    number;
  l_element_type_id           number;
  l_shadow_input_value_id     number;
  l_input_value_id            number;
  l_iterative_rule_id         number;
  l_object_version_number     number;
  l_effective_start_date      date;
  l_effective_end_date        date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_iterative_rules.first;
  loop
    exit when not p_iterative_rules.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sir_lookup_type
           ,p_core_objects     => p_sir_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      -----------------------------------
      -- Set up the in/out parameters. --
      -----------------------------------
      l_iterative_rule_id     := null;
      l_object_version_number := null;
      l_effective_start_date  := null;
      l_effective_end_date    := null;
      -------------------------------------------------------------------
      -- Set up the element_type_id and input_value_id columns for the --
      -- iterative rule. Raise an error if they have not been generated. --
      -------------------------------------------------------------------
      l_input_value_id := null;
      l_shadow_input_value_id := p_iterative_rules(i).input_value_id;
      if l_shadow_input_value_id is not null then
        if core_object_exists
           (p_shadow_object_id => l_shadow_input_value_id
           ,p_object_type      => g_siv_lookup_type
           ,p_core_objects     => p_siv_core_objects
           ) then
          l_input_value_id :=
          p_siv_core_objects(l_shadow_input_value_id).core_object_id;
        else
          hr_utility.set_message(801, 'PAY_50066_ETM_GEN_NO_FK_ROW');
          hr_utility.set_message_token('TABLE', 'PAY_ITERATIVE_RULES_F');
          hr_utility.set_message_token('FK_TABLE', 'PAY_INPUT_VALUES_F');
          hr_utility.raise_error;
        end if;
      end if;
      --
      l_element_type_id := null;
      l_shadow_element_type_id := p_iterative_rules(i).element_type_id;
      if l_shadow_element_type_id is not null then
        if core_object_exists
           (p_shadow_object_id => l_shadow_element_type_id
           ,p_object_type      => g_set_lookup_type
           ,p_core_objects     => p_set_core_objects
           ) then
          l_element_type_id :=
          p_set_core_objects(l_shadow_element_type_id).core_object_id;
        else
          hr_utility.set_message(801, 'PAY_50066_ETM_GEN_NO_FK_ROW');
          hr_utility.set_message_token('TABLE', 'PAY_ITERATIVE_RULES_F');
          hr_utility.set_message_token('FK_TABLE', 'PAY_ELEMENT_TYPES_F');
          hr_utility.raise_error;
        end if;
      end if;
      ------------------------------------
      -- Insert the iterative rule row. --
      ------------------------------------
      pay_itr_ins.ins
      (p_effective_date               => p_effective_date
      ,p_element_type_id              => l_element_type_id
      ,p_result_name                  => p_iterative_rules(i).result_name
      ,p_iterative_rule_type          => p_iterative_rules(i).iterative_rule_type
      ,p_input_value_id               => l_input_value_id
      ,p_severity_level               => p_iterative_rules(i).severity_level
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => null
      ,p_iterative_rule_id            => l_iterative_rule_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_sir_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_iterative_rule_id
      ,p_core_objects               => p_sir_core_objects
      );
    end if;
    --
    i := p_iterative_rules.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_iterative_rules;
-- ----------------------------------------------------------------------------
-- |--------------------------< gen_ele_type_usages >--------------------------|
-- ----------------------------------------------------------------------------
procedure gen_ele_type_usages
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ,p_ele_type_usages   in     pay_element_template_util.t_ele_type_usages
  ,p_set_core_objects  in     pay_element_template_util.t_core_objects
  ,p_seu_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                       varchar2(72) := g_package||'gen_ele_type_usages';
  l_shadow_object_id           number;
  i                            number;
  --
  l_run_type_id             number;
  l_element_type_id         number;
  l_element_type_usage_id   number;
  l_effective_start_date    date;
  l_effective_end_date      date;
  l_object_version_number   number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_ele_type_usages.first;
  loop
    exit when not p_ele_type_usages.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_seu_lookup_type
           ,p_core_objects     => p_seu_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      -----------------------------------
      -- Set up the in/out parameters. --
      -----------------------------------
      l_element_type_usage_id := null;
      l_effective_start_date  := null;
      l_effective_end_date    := null;
      l_object_version_number := null;
      --
      -- Set up the run_type_id value.
      --
      l_run_type_id :=
      get_run_type_id
      (p_effective_date    => p_effective_date
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_run_type          => p_ele_type_usages(i).run_type_name
      );
      --
      -- Set up the element_type_id value.
      --
      l_element_type_id :=
      p_set_core_objects(p_ele_type_usages(i).element_type_id).core_object_id;
      --
      -- Insert the element type usage row.
      --
      hr_utility.set_location(l_proc, 30);
      pay_etu_ins.ins
      (p_effective_date               => p_effective_date
      ,p_run_type_id                  => l_run_type_id
      ,p_element_type_id              => l_element_type_id
      ,p_inclusion_flag               => p_ele_type_usages(i).inclusion_flag
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => null
      ,p_element_type_usage_id        => l_element_type_usage_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 40);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_seu_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_element_type_usage_id
      ,p_core_objects               => p_seu_core_objects
      );
    end if;
    --
    i := p_ele_type_usages.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_ele_type_usages;
-- ----------------------------------------------------------------------------
-- |-------------------------< gen_gu_bal_exclusions >------------------------|
-- ----------------------------------------------------------------------------
procedure gen_gu_bal_exclusions
  (p_effective_date    in     date
  ,p_template_id       in     number
  ,p_business_group_id in     number
  ,p_legislation_code  in     varchar2
  ,p_gu_bal_exclusions in     pay_element_template_util.t_gu_bal_exclusions
  ,p_sbt_core_objects  in     pay_element_template_util.t_core_objects
  ,p_set_core_objects  in     pay_element_template_util.t_core_objects
  ,p_sgb_core_objects  in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                       varchar2(72) := g_package||'gen_gu_bal_exclusions';
  l_shadow_object_id           number;
  i                            number;
  --
  l_balance_type_id            number;
  l_source_id                  number;
  l_grossup_balances_id        number;
  l_object_version_number      number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_gu_bal_exclusions.first;
  loop
    exit when not p_gu_bal_exclusions.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sgb_lookup_type
           ,p_core_objects     => p_sgb_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the in/out parameters.
      --
      l_grossup_balances_id   := null;
      l_object_version_number := null;
      --
      -- Set up the balance_type_id value.
      --
      if p_gu_bal_exclusions(i).balance_type_name is not null then
        --
        -- External balance - set up the balance_type_id using the name mapping
        -- table.
        --
        l_balance_type_id :=
        get_balance_id
        (p_business_group_id => p_business_group_id
        ,p_legislation_code  => p_legislation_code
        ,p_balance           => p_gu_bal_exclusions(i).balance_type_name
        );
      else
        --
        -- Generated balance - get balance_type_id from generated objects table.
        --
        l_balance_type_id := p_gu_bal_exclusions(i).balance_type_id;
        if core_object_exists
           (p_shadow_object_id => l_balance_type_id
           ,p_object_type      => g_sbt_lookup_type
           ,p_core_objects     => p_sbt_core_objects
           ) then
           l_balance_type_id :=
           p_sbt_core_objects(l_balance_type_id).core_object_id;
        else
          hr_utility.set_message(801, 'PAY_50066_ETM_GEN_NO_FK_ROW');
          hr_utility.set_message_token('TABLE', 'PAY_GROSSUP_BAL_EXCLUSIONS');
          hr_utility.set_message_token('FK_TABLE', 'PAY_BALANCE_TYPES');
          hr_utility.raise_error;
        end if;
      end if;
      --
      -- Set up the source_id value.
      --
      if p_gu_bal_exclusions(i).source_id is not null then
        if core_object_exists
           (p_shadow_object_id => p_gu_bal_exclusions(i).source_id
           ,p_object_type      => g_set_lookup_type
           ,p_core_objects     => p_set_core_objects
           ) then
          l_source_id :=
          p_set_core_objects(p_gu_bal_exclusions(i).source_id).core_object_id;
        else
          hr_utility.set_message(801, 'PAY_50066_ETM_GEN_NO_FK_ROW');
          hr_utility.set_message_token('TABLE', 'PAY_GROSSUP_BAL_EXCLUSIONS');
          hr_utility.set_message_token('FK_TABLE', 'PAY_ELEMENT_TYPES_F');
          hr_utility.raise_error;
        end if;
      end if;
      --
      -- Insert the grossup balance exclusion row.
      --
      hr_utility.set_location(l_proc, 30);
      pay_gbe_ins.ins
      (p_start_date                   => p_effective_date
      ,p_end_date                     => hr_api.g_eot
      ,p_source_id                    => l_source_id
      ,p_source_type                  => p_gu_bal_exclusions(i).source_type
      ,p_balance_type_id              => l_balance_type_id
      ,p_grossup_balances_id          => l_grossup_balances_id
      ,p_object_version_number        => l_object_version_number
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 40);
      update_core_objects
      (p_effective_date             => p_effective_date
      ,p_template_id                => p_template_id
      ,p_core_object_type           => g_sgb_lookup_type
      ,p_shadow_object_id           => l_shadow_object_id
      ,p_core_object_id             => l_grossup_balances_id
      ,p_core_objects               => p_sgb_core_objects
      );
    end if;
    --
    i := p_gu_bal_exclusions.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_gu_bal_exclusions;
-- ----------------------------------------------------------------------------
-- |-----------------------< gen_balance_attributes >-------------------------|
-- ----------------------------------------------------------------------------
procedure gen_bal_attributes
  (p_effective_date     in     date
  ,p_template_id        in     number
  ,p_business_group_id  in     number
  ,p_legislation_code   in     varchar2
  ,p_bal_attributes     in     pay_element_template_util.t_bal_attributes
  ,p_sdb_core_objects   in     pay_element_template_util.t_core_objects
  ,p_sba_core_objects   in out nocopy pay_element_template_util.t_core_objects
  ) is
  l_proc                 varchar2(72) := g_package||'gen_balance_attributes';
  l_shadow_object_id     number;
  i                      number;
  --
  l_balance_attribute_id number;
  l_defined_balance_id   number;
  l_bal_attribute_def_id number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  i := p_bal_attributes.first;
  loop
    exit when not p_bal_attributes.exists(i);
    --
    -- Only generate if a generated core object does not exist.
    --
    l_shadow_object_id := i;
    if not core_object_exists
           (p_shadow_object_id => l_shadow_object_id
           ,p_object_type      => g_sba_lookup_type
           ,p_core_objects     => p_sba_core_objects
           ) then
      hr_utility.set_location(l_proc, 20);
      --
      -- Set up the attribute_id for the external balance attribute definition.
      --
      l_bal_attribute_def_id :=
      get_bal_attribute_def_id
      (p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_attribute         => p_bal_attributes(i).attribute_name
      );
      --
      -- Set up the defined_balance_id value.
      --
      l_defined_balance_id :=
      p_sdb_core_objects(p_bal_attributes(i).defined_balance_id).core_object_id;
      --
      -- Insert the balance attribute row.
      --
      pay_balance_attribute_api.create_balance_attribute
      (p_validate             => false
      ,p_attribute_id         => l_bal_attribute_def_id
      ,p_business_group_id    => p_business_group_id
      ,p_legislation_code     => null
      ,p_defined_balance_id   => l_defined_balance_id
      ,p_balance_attribute_id => l_balance_attribute_id
      );
      --
      -- Set up the core object table rows.
      --
      hr_utility.set_location(l_proc, 30);
      update_core_objects
      (p_effective_date   => p_effective_date
      ,p_template_id      => p_template_id
      ,p_core_object_type => g_sba_lookup_type
      ,p_shadow_object_id => l_shadow_object_id
      ,p_core_object_id   => l_balance_attribute_id
      ,p_core_objects     => p_sba_core_objects
      );
    end if;
    --
    i := p_bal_attributes.next(i);
  end loop;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end gen_bal_attributes;
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part1 >-----------------------------|
-- ----------------------------------------------------------------------------
procedure generate_part1
  (p_effective_date                in     date
  ,p_hr_only                       in     boolean
  ,p_hr_to_payroll                 in     boolean default false
  ,p_template_id                   in     number
  ) is
  l_proc                     varchar2(72) := g_package||'generate_part1';
  l_business_group_id        number;
  l_legislation_code         varchar2(30);
  l_base_processing_priority number;
  l_template_type            varchar2(2000);
  -----------------------------
  -- PL/SQL template tables. --
  -----------------------------
  l_element_template        pay_etm_shd.g_rec_type;
  l_exclusion_rules         pay_element_template_util.t_exclusion_rules;
  l_formulas                pay_element_template_util.t_formulas;
  l_balance_types           pay_element_template_util.t_balance_types;
  l_defined_balances        pay_element_template_util.t_defined_balances;
  l_element_types           pay_element_template_util.t_element_types;
  l_sub_classi_rules        pay_element_template_util.t_sub_classi_rules;
  l_balance_classis         pay_element_template_util.t_balance_classis;
  l_input_values            pay_element_template_util.t_input_values;
  l_balance_feeds           pay_element_template_util.t_balance_feeds;
  l_formula_rules           pay_element_template_util.t_formula_rules;
  l_iterative_rules         pay_element_template_util.t_iterative_rules;
  l_ele_type_usages         pay_element_template_util.t_ele_type_usages;
  l_gu_bal_exclusions       pay_element_template_util.t_gu_bal_exclusions;
  l_bal_attributes          pay_element_template_util.t_bal_attributes;
  l_template_ff_usages      pay_element_template_util.t_template_ff_usages;
  ------------------------
  -- Generation tables. --
  ------------------------
  l_all_core_objects        pay_element_template_util.t_core_objects;
  l_sf_core_objects         pay_element_template_util.t_core_objects;
  l_sbt_core_objects        pay_element_template_util.t_core_objects;
  l_sdb_core_objects        pay_element_template_util.t_core_objects;
  l_set_core_objects        pay_element_template_util.t_core_objects;
  l_ssr_core_objects        pay_element_template_util.t_core_objects;
  l_sbc_core_objects        pay_element_template_util.t_core_objects;
  l_siv_core_objects        pay_element_template_util.t_core_objects;
  l_sbf_core_objects        pay_element_template_util.t_core_objects;
  l_spr_core_objects        pay_element_template_util.t_core_objects;
  l_sfr_core_objects        pay_element_template_util.t_core_objects;
  l_sir_core_objects        pay_element_template_util.t_core_objects;
  l_seu_core_objects        pay_element_template_util.t_core_objects;
  l_sgb_core_objects        pay_element_template_util.t_core_objects;
  l_sba_core_objects        pay_element_template_util.t_core_objects;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  ----------------------------------------------
  -- Check that the template type is correct. --
  ----------------------------------------------
  l_template_type :=
  pay_element_template_util.get_template_type(p_template_id);
  if l_template_type is null or l_template_type <> 'U' then
    hr_utility.set_message(801, 'PAY_50065_BAD_USER_TEMPLATE');
    hr_utility.raise_error;
  end if;
  ---------------------------------------
  -- Read in the template information. --
  ---------------------------------------
  pay_element_template_util.create_plsql_template
  (p_template_id                  => p_template_id
  ,p_generate_part1               => true
  ,p_core_objects                 => l_all_core_objects
  ,p_element_template             => l_element_template
  ,p_exclusion_rules              => l_exclusion_rules
  ,p_formulas                     => l_formulas
  ,p_balance_types                => l_balance_types
  ,p_defined_balances             => l_defined_balances
  ,p_element_types                => l_element_types
  ,p_sub_classi_rules             => l_sub_classi_rules
  ,p_balance_classis              => l_balance_classis
  ,p_input_values                 => l_input_values
  ,p_balance_feeds                => l_balance_feeds
  ,p_formula_rules                => l_formula_rules
  ,p_iterative_rules              => l_iterative_rules
  ,p_ele_type_usages              => l_ele_type_usages
  ,p_gu_bal_exclusions            => l_gu_bal_exclusions
  ,p_bal_attributes               => l_bal_attributes
  ,p_template_ff_usages           => l_template_ff_usages
  );
  -----------------------------------------------
  -- Read in information on generated objects. --
  -----------------------------------------------
  hr_utility.set_location(l_proc, 20);
  create_generation_tables
  (p_all_core_objects             => l_all_core_objects
  ,p_index_by_core_object_id      => false
  ,p_sf_core_objects              => l_sf_core_objects
  ,p_sbt_core_objects             => l_sbt_core_objects
  ,p_sdb_core_objects             => l_sdb_core_objects
  ,p_set_core_objects             => l_set_core_objects
  ,p_ssr_core_objects             => l_ssr_core_objects
  ,p_sbc_core_objects             => l_sbc_core_objects
  ,p_siv_core_objects             => l_siv_core_objects
  ,p_sbf_core_objects             => l_sbf_core_objects
  ,p_spr_core_objects             => l_spr_core_objects
  ,p_sfr_core_objects             => l_sfr_core_objects
  ,p_sir_core_objects             => l_sir_core_objects
  ,p_seu_core_objects             => l_seu_core_objects
  ,p_sgb_core_objects             => l_sgb_core_objects
  ,p_sba_core_objects             => l_sba_core_objects
  );
  --
  hr_utility.set_location(l_proc, 30);
  get_formula_types;
  l_business_group_id := l_element_template.business_group_id;
  l_legislation_code :=
  hr_api.return_legislation_code(l_business_group_id);
  hr_general.assert_condition(l_legislation_code is not null);
  ---------------------------------
  -- At last, do the generation! --
  ---------------------------------
  -----------------
  -- 1. Formulas --
  -----------------
  gen_formulas
  (p_effective_date                 => p_effective_date
  ,p_template_id                    => p_template_id
  ,p_hr_only                        => p_hr_only
  ,p_formulas                       => l_formulas
  ,p_sf_core_objects                => l_sf_core_objects
  );
  -----------------------
  -- 2. Element Types. --
  -----------------------
  hr_utility.set_location(l_proc, 70);
  l_base_processing_priority := l_element_template.base_processing_priority;
  gen_element_types
  (p_effective_date                 => p_effective_date
  ,p_template_id                    => p_template_id
  ,p_business_group_id              => l_business_group_id
  ,p_hr_only                        => p_hr_only
  ,p_legislation_code               => l_legislation_code
  ,p_base_processing_priority       => l_base_processing_priority
  ,p_element_types                  => l_element_types
  ,p_sf_core_objects                => l_sf_core_objects
  ,p_set_core_objects               => l_set_core_objects
  ,p_spr_core_objects               => l_spr_core_objects
  );
  ------------------------------
  -- 3. Element Input Values. --
  ------------------------------
  hr_utility.set_location(l_proc, 100);
  implicit_input_values
  (p_effective_date                 => p_effective_date
  ,p_template_id                    => p_template_id
  ,p_all_core_objects               => l_all_core_objects
  ,p_input_values                   => l_input_values
  ,p_set_core_objects               => l_set_core_objects
  ,p_siv_core_objects               => l_siv_core_objects
  );
  gen_input_values
  (p_effective_date                 => p_effective_date
  ,p_template_id                    => p_template_id
  ,p_business_group_id              => l_business_group_id
  ,p_legislation_code		    => l_legislation_code
  ,p_input_values                   => l_input_values
  ,p_set_core_objects               => l_set_core_objects
  ,p_sf_core_objects                => l_sf_core_objects
  ,p_siv_core_objects               => l_siv_core_objects
  );
  ----------------------
  -- 4. Balance Types --
  ----------------------
  hr_utility.set_location(l_proc, 50);
  gen_balance_types
  (p_effective_date                 => p_effective_date
  ,p_template_id                    => p_template_id
  ,p_business_group_id              => l_business_group_id
  ,p_legislation_code               => l_legislation_code
  ,p_balance_types                  => l_balance_types
  ,p_sbt_core_objects               => l_sbt_core_objects
  ,p_siv_core_objects               => l_siv_core_objects
  );
  --------------------------
  -- 5. Defined Balances. --
  --------------------------
  hr_utility.set_location(l_proc, 60);
  if not p_hr_only then
    gen_defined_balances
    (p_effective_date                 => p_effective_date
    ,p_template_id                    => p_template_id
    ,p_business_group_id              => l_business_group_id
    ,p_legislation_code               => l_legislation_code
    ,p_defined_balances               => l_defined_balances
    ,p_sbt_core_objects               => l_sbt_core_objects
    ,p_sdb_core_objects               => l_sdb_core_objects
    );
  end if;
  ----------------------------------
  -- 6. Sub-Classification Rules. --
  ----------------------------------
  --
  -- Have to allow for the implicitly created sub-classification
  -- rules whatever options the user chooses, otherwise the code
  -- may error when it's time to generate everything.
  --
  hr_utility.set_location(l_proc, 80);
  implicit_sub_classi_rules
  (p_effective_date                 => p_effective_date
  ,p_template_id                    => p_template_id
  ,p_business_group_id              => l_business_group_id
  ,p_legislation_code               => l_legislation_code
  ,p_all_core_objects               => l_all_core_objects
  ,p_sub_classi_rules               => l_sub_classi_rules
  ,p_set_core_objects               => l_set_core_objects
  ,p_ssr_core_objects               => l_ssr_core_objects
  );
  if not p_hr_only then
    gen_sub_classi_rules
    (p_effective_date                 => p_effective_date
    ,p_template_id                    => p_template_id
    ,p_business_group_id              => l_business_group_id
    ,p_legislation_code               => l_legislation_code
    ,p_sub_classi_rules               => l_sub_classi_rules
    ,p_set_core_objects               => l_set_core_objects
    ,p_ssr_core_objects               => l_ssr_core_objects
    );
    ---------------------------------
    -- 7. Balance Classifications. --
    ---------------------------------
    hr_utility.set_location(l_proc, 90);
    gen_balance_classis
    (p_effective_date                 => p_effective_date
    ,p_template_id                    => p_template_id
    ,p_business_group_id              => l_business_group_id
    ,p_legislation_code               => l_legislation_code
    ,p_balance_classis                => l_balance_classis
    ,p_sbt_core_objects               => l_sbt_core_objects
    ,p_sbc_core_objects               => l_sbc_core_objects
    );
    -----------------------
    -- 8. Balance Feeds. --
    -----------------------
    hr_utility.set_location(l_proc, 110);
    gen_balance_feeds
    (p_effective_date                 => p_effective_date
    ,p_template_id                    => p_template_id
    ,p_business_group_id              => l_business_group_id
    ,p_legislation_code               => l_legislation_code
    ,p_balance_feeds                  => l_balance_feeds
    ,p_sbt_core_objects               => l_sbt_core_objects
    ,p_siv_core_objects               => l_siv_core_objects
    ,p_sbf_core_objects               => l_sbf_core_objects
    );
    -----------------------------
    -- 9. Element type usages. --
    -----------------------------
    hr_utility.set_location(l_proc, 120);
    gen_ele_type_usages
    (p_effective_date               => p_effective_date
    ,p_template_id                  => p_template_id
    ,p_business_group_id            => l_business_group_id
    ,p_legislation_code               => l_legislation_code
    ,p_ele_type_usages              => l_ele_type_usages
    ,p_set_core_objects             => l_set_core_objects
    ,p_seu_core_objects             => l_seu_core_objects
    );
    -------------------------------------
    -- 10. Grossup balance exclusions. --
    -------------------------------------
    hr_utility.set_location(l_proc, 130);
    gen_gu_bal_exclusions
    (p_effective_date               => p_effective_date
    ,p_template_id                  => p_template_id
    ,p_business_group_id            => l_business_group_id
    ,p_legislation_code             => l_legislation_code
    ,p_gu_bal_exclusions            => l_gu_bal_exclusions
    ,p_sbt_core_objects             => l_sbt_core_objects
    ,p_set_core_objects             => l_set_core_objects
    ,p_sgb_core_objects             => l_sgb_core_objects
    );
    -----------------------------
    -- 11. Balance attributes. --
    -----------------------------
    hr_utility.set_location(l_proc, 140);
    gen_bal_attributes
    (p_effective_date                 => p_effective_date
    ,p_template_id                    => p_template_id
    ,p_business_group_id              => l_business_group_id
    ,p_legislation_code               => l_legislation_code
    ,p_bal_attributes                 => l_bal_attributes
    ,p_sdb_core_objects               => l_sdb_core_objects
    ,p_sba_core_objects               => l_sba_core_objects
    );
  end if;
  hr_utility.set_location('Leaving:'|| l_proc, 200);
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 210);
    raise;
end generate_part1;
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part2 >-----------------------------|
-- ----------------------------------------------------------------------------
procedure generate_part2
  (p_effective_date                in     date
  ,p_template_id                   in     number
  ) is
  l_proc                     varchar2(72) := g_package||'generate_part2';
  l_business_group_id        number;
  l_legislation_code         varchar2(30);
  l_template_type            varchar2(2000);
  -----------------------------
  -- PL/SQL template tables. --
  -----------------------------
  l_element_template        pay_etm_shd.g_rec_type;
  l_exclusion_rules         pay_element_template_util.t_exclusion_rules;
  l_formulas                pay_element_template_util.t_formulas;
  l_balance_types           pay_element_template_util.t_balance_types;
  l_defined_balances        pay_element_template_util.t_defined_balances;
  l_element_types           pay_element_template_util.t_element_types;
  l_sub_classi_rules        pay_element_template_util.t_sub_classi_rules;
  l_balance_classis         pay_element_template_util.t_balance_classis;
  l_input_values            pay_element_template_util.t_input_values;
  l_balance_feeds           pay_element_template_util.t_balance_feeds;
  l_formula_rules           pay_element_template_util.t_formula_rules;
  l_iterative_rules         pay_element_template_util.t_iterative_rules;
  l_ele_type_usages         pay_element_template_util.t_ele_type_usages;
  l_gu_bal_exclusions       pay_element_template_util.t_gu_bal_exclusions;
  l_template_ff_usages      pay_element_template_util.t_template_ff_usages;
  l_bal_attributes          pay_element_template_util.t_bal_attributes;
  ------------------------
  -- Generation tables. --
  ------------------------
  l_all_core_objects        pay_element_template_util.t_core_objects;
  l_sf_core_objects         pay_element_template_util.t_core_objects;
  l_sbt_core_objects        pay_element_template_util.t_core_objects;
  l_sdb_core_objects        pay_element_template_util.t_core_objects;
  l_set_core_objects        pay_element_template_util.t_core_objects;
  l_ssr_core_objects        pay_element_template_util.t_core_objects;
  l_sbc_core_objects        pay_element_template_util.t_core_objects;
  l_siv_core_objects        pay_element_template_util.t_core_objects;
  l_sbf_core_objects        pay_element_template_util.t_core_objects;
  l_spr_core_objects        pay_element_template_util.t_core_objects;
  l_sfr_core_objects        pay_element_template_util.t_core_objects;
  l_sir_core_objects        pay_element_template_util.t_core_objects;
  l_seu_core_objects        pay_element_template_util.t_core_objects;
  l_sgb_core_objects        pay_element_template_util.t_core_objects;
  l_sba_core_objects        pay_element_template_util.t_core_objects;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  ----------------------------------------------
  -- Check that the template type is correct. --
  ----------------------------------------------
  l_template_type :=
  pay_element_template_util.get_template_type(p_template_id);
  if l_template_type is null or l_template_type <> 'U' then
    hr_utility.set_message(801, 'PAY_50065_BAD_USER_TEMPLATE');
    hr_utility.raise_error;
  end if;
  ---------------------------------------
  -- Read in the template information. --
  ---------------------------------------
  pay_element_template_util.create_plsql_template
  (p_template_id                  => p_template_id
  ,p_generate_part2               => true
  ,p_element_template             => l_element_template
  ,p_core_objects                 => l_all_core_objects
  ,p_exclusion_rules              => l_exclusion_rules
  ,p_formulas                     => l_formulas
  ,p_balance_types                => l_balance_types
  ,p_defined_balances             => l_defined_balances
  ,p_element_types                => l_element_types
  ,p_sub_classi_rules             => l_sub_classi_rules
  ,p_balance_classis              => l_balance_classis
  ,p_input_values                 => l_input_values
  ,p_balance_feeds                => l_balance_feeds
  ,p_formula_rules                => l_formula_rules
  ,p_iterative_rules              => l_iterative_rules
  ,p_ele_type_usages              => l_ele_type_usages
  ,p_gu_bal_exclusions            => l_gu_bal_exclusions
  ,p_template_ff_usages           => l_template_ff_usages
  ,p_bal_attributes               => l_bal_attributes
  );
  --
  l_business_group_id := l_element_template.business_group_id;
  l_legislation_code :=
  hr_api.return_legislation_code(l_business_group_id);
  --
  get_formula_types;
  -----------------------------------------------
  -- Read in information on generated objects. --
  -----------------------------------------------
  hr_utility.set_location(l_proc, 20);
  create_generation_tables
  (p_all_core_objects             => l_all_core_objects
  ,p_index_by_core_object_id      => false
  ,p_sf_core_objects              => l_sf_core_objects
  ,p_sbt_core_objects             => l_sbt_core_objects
  ,p_sdb_core_objects             => l_sdb_core_objects
  ,p_set_core_objects             => l_set_core_objects
  ,p_ssr_core_objects             => l_ssr_core_objects
  ,p_sbc_core_objects             => l_sbc_core_objects
  ,p_siv_core_objects             => l_siv_core_objects
  ,p_sbf_core_objects             => l_sbf_core_objects
  ,p_spr_core_objects             => l_spr_core_objects
  ,p_sfr_core_objects             => l_sfr_core_objects
  ,p_sir_core_objects             => l_sir_core_objects
  ,p_seu_core_objects             => l_seu_core_objects
  ,p_sgb_core_objects             => l_sgb_core_objects
  ,p_sba_core_objects             => l_sba_core_objects
  );

  -----------------------------------------------------------------
  -- DEVELOPER'S NOTE: This procedure should only generate those --
  -- objects that depend upon formula compilation taking place.  --
  -----------------------------------------------------------------

  ----------------------------------------
  -- Generate the formula result rules. --
  ----------------------------------------
  hr_utility.set_location(l_proc, 30);
  gen_formula_rules
  (p_effective_date               => p_effective_date
  ,p_template_id                  => p_template_id
  ,p_business_group_id            => l_business_group_id
  ,p_legislation_code             => l_legislation_code
  ,p_formula_rules                => l_formula_rules
  ,p_sf_core_objects              => l_sf_core_objects
  ,p_set_core_objects             => l_set_core_objects
  ,p_siv_core_objects             => l_siv_core_objects
  ,p_spr_core_objects             => l_spr_core_objects
  ,p_sfr_core_objects             => l_sfr_core_objects
  );
  -----------------------------------
  -- Generate the iterative rules. --
  -----------------------------------
  hr_utility.set_location(l_proc, 40);
  gen_iterative_rules
  (p_effective_date               => p_effective_date
  ,p_template_id                  => p_template_id
  ,p_business_group_id            => l_business_group_id
  ,p_iterative_rules              => l_iterative_rules
  ,p_set_core_objects             => l_set_core_objects
  ,p_siv_core_objects             => l_siv_core_objects
  ,p_sir_core_objects             => l_sir_core_objects
  );
  hr_utility.set_location('Leaving:'|| l_proc, 200);
end generate_part2;
-- ----------------------------------------------------------------------------
-- |---------------------------< core_objects_lock >--------------------------|
-- ----------------------------------------------------------------------------
procedure core_objects_lock
  (p_core_object_type          in     varchar2
  ,p_core_objects              in     pay_element_template_util.t_core_objects
  ,p_rowid_id_recs             in out nocopy t_rowid_id_recs
  ,p_id_ovn_recs               in out nocopy t_id_ovn_recs
  ) is
  l_proc                     varchar2(72) := g_package||'core_objects_lock';
  l_rowid_id_rec             g_rowid_id_rec;
  l_id_ovn_rec               g_id_ovn_rec;
  i                          number;
  j                          number;
  --
  cursor csr_formulas_lock(p_formula_id in number) is
  select formula_id
  ,      rowid
  ,      effective_start_date
  from   ff_formulas_f
  where  formula_id = p_formula_id
  for    update of formula_id;
  --
  cursor csr_balance_types_lock(p_balance_type_id in number) is
  select balance_type_id
  ,      rowid
  ,      null
  from   pay_balance_types
  where  balance_type_id = p_balance_type_id
  for    update of balance_type_id;
  --
  cursor csr_defined_balances_lock(p_defined_balance_id in number) is
  select defined_balance_id
  ,      rowid
  ,      null
  from   pay_defined_balances
  where  defined_balance_id = p_defined_balance_id
  for    update of defined_balance_id;
  --
  cursor csr_element_types_lock(p_element_type_id in number) is
  select element_type_id
  ,      rowid
  ,      effective_start_date
  from   pay_element_types_f
  where  element_type_id = p_element_type_id
  for    update of element_type_id;
  --
  cursor csr_balance_feeds_lock(p_balance_feed_id in number) is
  select balance_feed_id
  ,      rowid
  ,      effective_start_date
  from   pay_balance_feeds_f
  where  balance_feed_id = p_balance_feed_id
  for    update of balance_feed_id;
  --
  cursor csr_sub_classi_rules_lock(p_sub_classification_rule_id in number) is
  select sub_classification_rule_id
  ,      rowid
  ,      effective_start_date
  from   pay_sub_classification_rules_f
  where  sub_classification_rule_id = p_sub_classification_rule_id
  for    update of sub_classification_rule_id;
  --
  cursor csr_balance_classis_lock(p_balance_classification_id in number) is
  select balance_classification_id
  ,      rowid
  ,      null
  from   pay_balance_classifications
  where  balance_classification_id = p_balance_classification_id
  for    update of balance_classification_id;
  --
  cursor csr_input_values_lock(p_input_value_id in number) is
  select input_value_id
  ,      rowid
  ,      effective_start_date
  from   pay_input_values_f
  where  input_value_id = p_input_value_id
  for    update of input_value_id;
  --
  cursor csr_status_rules_lock(p_status_processing_rule_id in number) is
  select status_processing_rule_id
  ,      rowid
  ,      effective_start_date
  from   pay_status_processing_rules_f
  where  status_processing_rule_id = p_status_processing_rule_id
  for    update of status_processing_rule_id;
  --
  cursor csr_formula_rules_lock(p_formula_result_rule_id in number) is
  select formula_result_rule_id
  ,      rowid
  ,      effective_start_date
  from   pay_formula_result_rules_f
  where  formula_result_rule_id = p_formula_result_rule_id
  for    update of formula_result_rule_id;
  --
  cursor csr_iterative_rules_lock(p_iterative_rule_id in number) is
  select iterative_rule_id
  ,      object_version_number
  ,      effective_start_date
  from   pay_iterative_rules_f
  where  iterative_rule_id = p_iterative_rule_id
  for    update of iterative_rule_id;
  --
  cursor csr_ele_type_usages_lock(p_element_type_usage_id in number) is
  select element_type_usage_id
  ,      object_version_number
  ,      effective_start_date
  from   pay_element_type_usages_f
  where  element_type_usage_id = p_element_type_usage_id
  for    update of element_type_usage_id;
  --
  cursor csr_gu_bal_exclusions_lock(p_grossup_balances_id in number) is
  select grossup_balances_id
  ,      object_version_number
  ,      null
  from   pay_grossup_bal_exclusions
  where  grossup_balances_id = p_grossup_balances_id
  for    update of grossup_balances_id;
  --
  cursor csr_bal_attributes_lock(p_balance_attribute_id in number) is
  select balance_attribute_id
  ,      to_number(null)
  ,      null
  from   pay_balance_attributes
  where  balance_attribute_id = p_balance_attribute_id
  for    update of balance_attribute_id;
  --
begin
  --
  -- Generated formulas.
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if p_core_object_type = g_sf_lookup_type then
    hr_utility.set_location(l_proc, 15);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_formulas_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_formulas_lock into l_rowid_id_rec;
        exit when csr_formulas_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_formulas_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated balance types.
  --
  if p_core_object_type = g_sbt_lookup_type then
    hr_utility.set_location(l_proc, 20);
    i := p_core_objects.first;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_balance_types_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_balance_types_lock into l_rowid_id_rec;
        exit when csr_balance_types_lock%notfound;
        --
        -- Set up array index as the balance_type_id to allow base
        -- balances to be deleted before the balances that reference them.
        --
        j := l_rowid_id_rec.id;
        p_rowid_id_recs(j) := l_rowid_id_rec;
      end loop;
      close csr_balance_types_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated defined balances.
  --
  if p_core_object_type = g_sdb_lookup_type then
    hr_utility.set_location(l_proc, 30);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_defined_balances_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_defined_balances_lock into l_rowid_id_rec;
        exit when csr_defined_balances_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_defined_balances_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated element types.
  --
  if p_core_object_type = g_set_lookup_type then
    hr_utility.set_location(l_proc, 40);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_element_types_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_element_types_lock into l_rowid_id_rec;
        exit when csr_element_types_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_element_types_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated sub-classification rules.
  --
  if p_core_object_type = g_ssr_lookup_type then
    hr_utility.set_location(l_proc, 50);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_sub_classi_rules_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_sub_classi_rules_lock into l_rowid_id_rec;
        exit when csr_sub_classi_rules_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_sub_classi_rules_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated balance classifications.
  --
  if p_core_object_type = g_sbc_lookup_type then
    hr_utility.set_location(l_proc, 60);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_balance_classis_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_balance_classis_lock into l_rowid_id_rec;
        exit when csr_balance_classis_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_balance_classis_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated input values.
  --
  if p_core_object_type = g_siv_lookup_type then
    hr_utility.set_location(l_proc, 70);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_input_values_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_input_values_lock into l_rowid_id_rec;
        exit when csr_input_values_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_input_values_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated balance feeds.
  --
  if p_core_object_type = g_sbf_lookup_type then
    hr_utility.set_location(l_proc, 80);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_balance_feeds_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_balance_feeds_lock into l_rowid_id_rec;
        exit when csr_balance_feeds_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_balance_feeds_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated status processing rules.
  --
  if p_core_object_type = g_spr_lookup_type then
    hr_utility.set_location(l_proc, 90);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_status_rules_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_status_rules_lock into l_rowid_id_rec;
        exit when csr_status_rules_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_status_rules_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated formula rules.
  --
  if p_core_object_type = g_sfr_lookup_type then
    hr_utility.set_location(l_proc, 100);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_formula_rules_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_formula_rules_lock into l_rowid_id_rec;
        exit when csr_formula_rules_lock%notfound;
        p_rowid_id_recs(j) := l_rowid_id_rec;
        j := j + 1;
      end loop;
      close csr_formula_rules_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated iterative rules.
  --
  if p_core_object_type = g_sir_lookup_type then
    hr_utility.set_location(l_proc, 110);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_iterative_rules_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_iterative_rules_lock into l_id_ovn_rec;
        exit when csr_iterative_rules_lock%notfound;
        p_id_ovn_recs(j) := l_id_ovn_rec;
        j := j + 1;
      end loop;
      close csr_iterative_rules_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated element type usages.
  --
  if p_core_object_type = g_seu_lookup_type then
    hr_utility.set_location(l_proc, 120);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_ele_type_usages_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_ele_type_usages_lock into l_id_ovn_rec;
        exit when csr_ele_type_usages_lock%notfound;
        p_id_ovn_recs(j) := l_id_ovn_rec;
        j := j + 1;
      end loop;
      close csr_ele_type_usages_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated grossup balance exclusions.
  --
  if p_core_object_type = g_sgb_lookup_type then
    hr_utility.set_location(l_proc, 130);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_gu_bal_exclusions_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_gu_bal_exclusions_lock into l_id_ovn_rec;
        exit when csr_gu_bal_exclusions_lock%notfound;
        p_id_ovn_recs(j) := l_id_ovn_rec;
        j := j + 1;
      end loop;
      close csr_gu_bal_exclusions_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  -- Generated balance attributes.
  --
  if p_core_object_type = g_sba_lookup_type then
    hr_utility.set_location(l_proc, 140);
    i := p_core_objects.first;
    j := 0;
    loop
      exit when not p_core_objects.exists(i);
      --
      open csr_bal_attributes_lock(p_core_objects(i).core_object_id);
      loop
        fetch csr_bal_attributes_lock into l_id_ovn_rec;
        exit when csr_bal_attributes_lock%notfound;
        p_id_ovn_recs(j) := l_id_ovn_rec;
        j := j + 1;
      end loop;
      close csr_bal_attributes_lock;
      --
      i := p_core_objects.next(i);
    end loop;
  end if;
  --
  hr_utility.set_location('Leaving:'|| l_proc, 200);
  return;
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 210);
    --
    if csr_formulas_lock%isopen then
      close csr_formulas_lock;
    end if;
    --
    if csr_balance_types_lock%isopen then
      close csr_balance_types_lock;
    end if;
    --
    if csr_defined_balances_lock%isopen then
      close csr_defined_balances_lock;
    end if;
    --
    if csr_element_types_lock%isopen then
      close csr_element_types_lock;
    end if;
    --
    if csr_sub_classi_rules_lock%isopen then
      close csr_sub_classi_rules_lock;
    end if;
    --
    if csr_balance_classis_lock%isopen then
      close csr_balance_classis_lock;
    end if;
    --
    if csr_input_values_lock%isopen then
      close csr_input_values_lock;
    end if;
    --
    if csr_balance_feeds_lock%isopen then
      close csr_balance_feeds_lock;
    end if;
    --
    if csr_status_rules_lock%isopen then
      close csr_status_rules_lock;
    end if;
    --
    if csr_formula_rules_lock%isopen then
      close csr_formula_rules_lock;
    end if;
    --
    if csr_iterative_rules_lock%isopen then
      close csr_iterative_rules_lock;
    end if;
    --
    if csr_ele_type_usages_lock%isopen then
      close csr_ele_type_usages_lock;
    end if;
    --
    if csr_gu_bal_exclusions_lock%isopen then
      close csr_gu_bal_exclusions_lock;
    end if;
    --
    if csr_bal_attributes_lock%isopen then
      close csr_bal_attributes_lock;
    end if;
    --
    raise;
end core_objects_lock;
-- ----------------------------------------------------------------------------
-- |-----------------------------< el_balance_type >-------------------------|
-- ----------------------------------------------------------------------------
procedure del_balance_type
(p_balance_type_id in            number
,p_rowid_id_recs   in            t_rowid_id_recs
,p_remaining_recs  in out nocopy t_rowid_id_recs
) is
--
cursor csr_child_balances(p_balance_type_id in number) is
select pbt.balance_type_id
,      pbt.balance_name
from   pay_balance_types pbt
where  pbt.base_balance_type_id = p_balance_type_id;
--
l_balance_name varchar2(320);
begin
  --
  -- Only delete balances on the remaining records list. If not on the list,
  -- they may have been deleted before.
  --
  if p_remaining_recs.exists(p_balance_type_id) then
    --
    -- Delete from the remaining records list to avoid any chance of a
    -- double delete even though the template engine prevents circular
    -- relationships, the core schema may have been updated.
    --
    p_remaining_recs.delete(p_balance_type_id);
    --
    -- Loop through the child balances.
    --
    for crec in csr_child_balances(p_balance_type_id) loop
      --
      -- Recursively delete the child balances if they belong to the
      -- template.
      --
      if p_rowid_id_recs.exists(crec.balance_type_id) then
        del_balance_type
        (p_balance_type_id => crec.balance_type_id
        ,p_rowid_id_recs   => p_rowid_id_recs
        ,p_remaining_recs  => p_remaining_recs
        );
      else
        --
        -- The child balance is external to the template - raise an error.
        --
        select pbt.balance_name
        into   l_balance_name
        from   pay_balance_types pbt
        where  pbt.balance_type_id = p_balance_type_id
        ;
        hr_utility.set_message(801, 'PAY_50213_ETM_EXTERNAL_BAL_DEL');
        hr_utility.set_message_token('BASE_BALANCE', l_balance_name);
        hr_utility.set_message_token('EXT_BALANCE', crec.balance_name);
        hr_utility.raise_error;
      end if;
    end loop;
    --
    -- Delete this balance.
    --
    pay_balance_types_pkg.delete_row
    (x_rowid           => p_rowid_id_recs(p_balance_type_id).rowid
    ,x_balance_type_id => p_balance_type_id
    );
  end if;
end del_balance_type;
-- ----------------------------------------------------------------------------
-- |----------------------------< del_balance_types >-------------------------|
-- ----------------------------------------------------------------------------
procedure del_balance_types
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_balance_types';
  i                     number;
  l_remaining_recs      t_rowid_id_recs;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_remaining_recs := p_rowid_id_recs;
  --
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    del_balance_type
    (p_balance_type_id => i
    ,p_rowid_id_recs   => p_rowid_id_recs
    ,p_remaining_recs  => l_remaining_recs
    );
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_balance_types;
-- ----------------------------------------------------------------------------
-- |--------------------------< del_defined_balances >------------------------|
-- ----------------------------------------------------------------------------
procedure del_defined_balances
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_defined_balances';
  i                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
      pay_defined_balances_pkg.delete_row
      (x_rowid                        => p_rowid_id_recs(i).rowid
      ,x_defined_balance_id           => p_rowid_id_recs(i).id
      );
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_defined_balances;
-- ----------------------------------------------------------------------------
-- |---------------------------< del_element_types >--------------------------|
-- ----------------------------------------------------------------------------
procedure del_element_types
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_element_types';
  i                     number;
  l_id                  number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    if l_id is null or l_id <> p_rowid_id_recs(i).id then
      pay_element_types_pkg.delete_row
      (p_rowid                        => p_rowid_id_recs(i).rowid
      ,p_element_type_id              => p_rowid_id_recs(i).id
      ,p_session_date                 => p_rowid_id_recs(i).effective_date
      ,p_processing_priority          => null
      ,p_delete_mode                  => g_zap_deletion_mode
      );
      l_id := p_rowid_id_recs(i).id;
    end if;
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_element_types;
-- ----------------------------------------------------------------------------
-- |---------------------------< del_sub_classi_rules >-----------------------|
-- ----------------------------------------------------------------------------
procedure del_sub_classi_rules
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_sub_classi_rules';
  i                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
      pay_sub_class_rules_pkg.delete_row
      (p_rowid                        => p_rowid_id_recs(i).rowid
      ,p_sub_classification_rule_id   => p_rowid_id_recs(i).id
      ,p_delete_mode                  => g_zap_deletion_mode
      ,p_validation_start_date        => hr_api.g_sot
      ,p_validation_end_date          => hr_api.g_eot
      );
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_sub_classi_rules;
-- ----------------------------------------------------------------------------
-- |---------------------------< del_balance_classis >------------------------|
-- ----------------------------------------------------------------------------
procedure del_balance_classis
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_balance_classis';
  i                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
      pay_bal_classifications_pkg.delete_row
      (x_rowid                        => p_rowid_id_recs(i).rowid
      ,x_balance_classification_id    => p_rowid_id_recs(i).id
      );
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_balance_classis;
-- ----------------------------------------------------------------------------
-- |----------------------------< del_input_values >--------------------------|
-- ----------------------------------------------------------------------------
procedure del_input_values
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_input_values';
  i                     number;
  l_id                  number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    if l_id is null or l_id <> p_rowid_id_recs(i).id then
      pay_input_values_pkg.delete_row
      (p_rowid                        => p_rowid_id_recs(i).rowid
      ,p_input_value_id               => p_rowid_id_recs(i).id
      ,p_delete_mode                  => g_zap_deletion_mode
      ,p_session_date                 => p_rowid_id_recs(i).effective_date
      ,p_validation_start_date        => hr_api.g_sot
      ,p_validation_end_date          => hr_api.g_eot
      );
      l_id := p_rowid_id_recs(i).id;
    end if;
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_input_values;
-- ----------------------------------------------------------------------------
-- |----------------------------< del_formula_rules >-------------------------|
-- ----------------------------------------------------------------------------
procedure del_formula_rules
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_formula_rules';
  i                     number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
      pay_formula_result_rules_pkg.delete_row
      (p_rowid                        => p_rowid_id_recs(i).rowid
      );
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_formula_rules;
-- ----------------------------------------------------------------------------
-- |----------------------------< del_status_rules >-------------------------|
-- ----------------------------------------------------------------------------
procedure del_status_rules
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_status_rules';
  i                     number;
  l_id                  number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    if l_id is null or l_id <> p_rowid_id_recs(i).id then
      pay_status_rules_pkg.delete_row
      (x_rowid                     => p_rowid_id_recs(i).rowid
      ,p_session_date              => p_rowid_id_recs(i).effective_date
      ,p_delete_mode               => g_zap_deletion_mode
      ,p_status_processing_rule_id => p_rowid_id_recs(i).id
      );
      l_id := p_rowid_id_recs(i).id;
    end if;
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_status_rules;
-- ----------------------------------------------------------------------------
-- |--------------------------< del_iterative_rules >-------------------------|
-- ----------------------------------------------------------------------------
procedure del_iterative_rules
  (p_id_ovn_recs                  in        t_id_ovn_recs
  ) is
  --
  l_proc                  varchar2(72) := g_package||'del_iterative_rules';
  i                       number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_ovn                   number;
  l_id                    number;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  i := p_id_ovn_recs.first;
  loop
    exit when not p_id_ovn_recs.exists(i);
    --
    if l_id is null or l_id <> p_id_ovn_recs(i).id then
      l_ovn := p_id_ovn_recs(i).ovn;
      l_effective_start_date := null;
      l_effective_end_date   := null;
      --
      pay_itr_del.del
      (p_effective_date              => p_id_ovn_recs(i).effective_date
      ,p_datetrack_mode              => g_zap_deletion_mode
      ,p_iterative_rule_id           => p_id_ovn_recs(i).id
      ,p_object_version_number       => l_ovn
      ,p_effective_start_date        => l_effective_start_date
      ,p_effective_end_date          => l_effective_end_date
      );
      --
      l_id := p_id_ovn_recs(i).id;
    end if;
    --
    i := p_id_ovn_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 100);
end del_iterative_rules;
-- ----------------------------------------------------------------------------
-- -------------------------< del_ele_type_usages >---------------------------|
-- ----------------------------------------------------------------------------
procedure del_ele_type_usages
  (p_id_ovn_recs                in        t_id_ovn_recs
  ) is
  --
  l_proc                  varchar2(72)  := g_package||'del_ele_type_usages';
  i                       number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_ovn                   number;
  l_id                    number;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  i := p_id_ovn_recs.first;
  loop
    exit when not p_id_ovn_recs.exists(i);
    --
    if l_id is null or l_id <> p_id_ovn_recs(i).id then
      l_ovn := p_id_ovn_recs(i).ovn;
      l_effective_start_date  := null;
      l_effective_end_date    := null;
      --
      pay_etu_del.del
      (p_effective_date               => p_id_ovn_recs(i).effective_date
      ,p_datetrack_mode               => g_zap_deletion_mode
      ,p_element_type_usage_id        => p_id_ovn_recs(i).id
      ,p_object_version_number        => l_ovn
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
      --
      l_id := p_id_ovn_recs(i).id;
    end if;
    --
    i := p_id_ovn_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 100);
end del_ele_type_usages;
-- ----------------------------------------------------------------------------
-- |-----------------------< del_gu_bal_exclusions >--------------------------|
-- ----------------------------------------------------------------------------
procedure del_gu_bal_exclusions
  (p_id_ovn_recs                in        t_id_ovn_recs
  ) is
  --
  l_proc    varchar2(72) := g_package||'del_gu_bal_exclusions';
  i         number;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  i := p_id_ovn_recs.first;
  loop
    exit when not p_id_ovn_recs.exists(i);
    --
      pay_gbe_del.del
      (p_grossup_balances_id          => p_id_ovn_recs(i).id
      ,p_object_version_number        => p_id_ovn_recs(i).ovn
      );
    --
    i := p_id_ovn_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 100);
end del_gu_bal_exclusions;
-- ----------------------------------------------------------------------------
-- |-------------------------< del_bal_attributes >---------------------------|
-- ----------------------------------------------------------------------------
procedure del_bal_attributes
  (p_id_ovn_recs                in        t_id_ovn_recs
  ) is
  --
  l_proc    varchar2(72) := g_package||'del_bal_attributes';
  i         number;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  i := p_id_ovn_recs.first;
  loop
    exit when not p_id_ovn_recs.exists(i);
    --
      pay_balance_attribute_api.delete_balance_attribute
      (p_balance_attribute_id => p_id_ovn_recs(i).id
      );
    --
    i := p_id_ovn_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'||l_proc, 100);
end del_bal_attributes;
-- ----------------------------------------------------------------------------
-- |------------------------------< del_formulas >----------------------------|
-- ----------------------------------------------------------------------------
procedure del_formulas
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_formulas';
  i                     number;
  l_formula_id          number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    if l_formula_id is null or l_formula_id <> p_rowid_id_recs(i).id then
      l_formula_id := p_rowid_id_recs(i).id;
      --
      ff_formulas_f_pkg.delete_row
      (x_rowid                        => p_rowid_id_recs(i).rowid
      ,x_formula_id                   => l_formula_id
      ,x_dt_delete_mode               => g_zap_deletion_mode
      ,x_validation_start_date        => hr_api.g_sot
      ,x_validation_end_date          => hr_api.g_eot
      );
      --
      l_formula_id := p_rowid_id_recs(i).id;
    end if;
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_formulas;
-- ----------------------------------------------------------------------------
-- |----------------------------< del_formula_info >--------------------------|
-- ----------------------------------------------------------------------------
procedure del_formula_info
  (p_rowid_id_recs                 in     t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'del_formula_info';
  i                     number;
  l_formula_id          number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    -- Delete the compiled information and usages table rows before the
    -- formula row.
    --
    l_formula_id := p_rowid_id_recs(i).id;
    delete from ff_compiled_info_f where formula_id = l_formula_id;
    --
    delete from ff_fdi_usages_f where formula_id = l_formula_id;
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
end del_formula_info;
-- ----------------------------------------------------------------------------
-- |-------------------------< drop_formula_packages >------------------------|
-- ----------------------------------------------------------------------------
procedure drop_formula_packages
  (p_rowid_id_recs                 in out nocopy t_rowid_id_recs
  ) is
  l_proc                varchar2(72) := g_package||'drop_formula_packages';
  i                     number;
  j                     number;
  k                     number;
  --
  -- Cursor to get formula package names. It carries out a LIKE query to get
  -- the name of an object of the appropriate type.
  --
  cursor csr_package_names
  (p_package_name in varchar2
  ,p_object_type in varchar2
  ) is
  select object_name package_name
  from   user_objects
  where  object_name like p_package_name
  and    object_type = p_object_type
  ;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Delete records with duplicate id values.
  --
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    j := p_rowid_id_recs.next(i);
    loop
      exit when not p_rowid_id_recs.exists(j);
      --
      if p_rowid_id_recs(i).id = p_rowid_id_recs(j).id then
        k := j;
        j := p_rowid_id_recs.next(j);
        p_rowid_id_recs.delete(k);
      else
        j := p_rowid_id_recs.next(j);
      end if;
    end loop;
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  --
  -- Get the package names, and drop the packages.
  --
  i := p_rowid_id_recs.first;
  loop
    exit when not p_rowid_id_recs.exists(i);
    --
    -- Handle FFP packages.
    --
    for crec in csr_package_names
    (p_package_name => 'FFP' || p_rowid_id_recs(i).id || '_%'
    ,p_object_type  => 'PACKAGE'
    )
    loop
      execute immediate 'DROP PACKAGE ' || crec.package_name;
    end loop;
    --
    -- Drop FFW package bodies only.
    --
    for crec in csr_package_names
    (p_package_name => 'FFW' || p_rowid_id_recs(i).id || '_%'
    ,p_object_type  => 'PACKAGE BODY'
    )
    loop
      execute immediate 'DROP PACKAGE BODY ' || crec.package_name;
    end loop;
    --
    i := p_rowid_id_recs.next(i);
  end loop;
  hr_utility.set_location('Leaving:'|| l_proc, 100);
exception
  when others then
    hr_utility.set_location('Leaving:'|| l_proc, 110);
    if csr_package_names%isopen then
      close csr_package_names;
    end if;
end drop_formula_packages;
-- ----------------------------------------------------------------------------
-- |-----------------------------< zap_core_objects >-------------------------|
-- ----------------------------------------------------------------------------
procedure zap_core_objects
  (p_all_core_objects         in     pay_element_template_util.t_core_objects
  ,p_drop_formula_packages    in     boolean
  ) is
  l_proc                    varchar2(72) := g_package||'zap_core_objects';
  --
  -- Generation tables.
  --
  l_sf_core_objects         pay_element_template_util.t_core_objects;
  l_sbt_core_objects        pay_element_template_util.t_core_objects;
  l_sdb_core_objects        pay_element_template_util.t_core_objects;
  l_set_core_objects        pay_element_template_util.t_core_objects;
  l_ssr_core_objects        pay_element_template_util.t_core_objects;
  l_sbc_core_objects        pay_element_template_util.t_core_objects;
  l_siv_core_objects        pay_element_template_util.t_core_objects;
  l_sbf_core_objects        pay_element_template_util.t_core_objects;
  l_spr_core_objects        pay_element_template_util.t_core_objects;
  l_sfr_core_objects        pay_element_template_util.t_core_objects;
  l_sir_core_objects        pay_element_template_util.t_core_objects;
  l_seu_core_objects        pay_element_template_util.t_core_objects;
  l_sgb_core_objects        pay_element_template_util.t_core_objects;
  l_sba_core_objects        pay_element_template_util.t_core_objects;
  --
  -- Deletion tables for the generated objects.
  --
  l_sf_rowid_id_recs        t_rowid_id_recs;
  l_sbt_rowid_id_recs       t_rowid_id_recs;
  l_sdb_rowid_id_recs       t_rowid_id_recs;
  l_set_rowid_id_recs       t_rowid_id_recs;
  l_ssr_rowid_id_recs       t_rowid_id_recs;
  l_sbc_rowid_id_recs       t_rowid_id_recs;
  l_siv_rowid_id_recs       t_rowid_id_recs;
  l_sbf_rowid_id_recs       t_rowid_id_recs;
  l_spr_rowid_id_recs       t_rowid_id_recs;
  l_sfr_rowid_id_recs       t_rowid_id_recs;
  l_null_rowid_id_recs      t_rowid_id_recs;
  l_sir_id_ovn_recs         t_id_ovn_recs;
  l_seu_id_ovn_recs         t_id_ovn_recs;
  l_sgb_id_ovn_recs         t_id_ovn_recs;
  l_sba_id_ovn_recs         t_id_ovn_recs;
  l_null_id_ovn_recs        t_id_ovn_recs;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Create the table of generated objects.
  --
  create_generation_tables
  (p_all_core_objects             => p_all_core_objects
  ,p_index_by_core_object_id      => true
  ,p_sf_core_objects              => l_sf_core_objects
  ,p_sbt_core_objects             => l_sbt_core_objects
  ,p_sdb_core_objects             => l_sdb_core_objects
  ,p_set_core_objects             => l_set_core_objects
  ,p_ssr_core_objects             => l_ssr_core_objects
  ,p_sbc_core_objects             => l_sbc_core_objects
  ,p_siv_core_objects             => l_siv_core_objects
  ,p_sbf_core_objects             => l_sbf_core_objects
  ,p_spr_core_objects             => l_spr_core_objects
  ,p_sfr_core_objects             => l_sfr_core_objects
  ,p_sir_core_objects             => l_sir_core_objects
  ,p_seu_core_objects             => l_seu_core_objects
  ,p_sgb_core_objects             => l_sgb_core_objects
  ,p_sba_core_objects             => l_sba_core_objects
  );
  --
  -- Lock the generated objects in lock ladder order.
  --
  hr_utility.set_location(l_proc, 20);
  core_objects_lock
  (p_core_object_type             => g_sf_lookup_type
  ,p_core_objects                 => l_sf_core_objects
  ,p_rowid_id_recs                => l_sf_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sbt_lookup_type
  ,p_core_objects                 => l_sbt_core_objects
  ,p_rowid_id_recs                => l_sbt_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sdb_lookup_type
  ,p_core_objects                 => l_sdb_core_objects
  ,p_rowid_id_recs                => l_sdb_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_set_lookup_type
  ,p_core_objects                 => l_set_core_objects
  ,p_rowid_id_recs                => l_set_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_ssr_lookup_type
  ,p_core_objects                 => l_ssr_core_objects
  ,p_rowid_id_recs                => l_ssr_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sbc_lookup_type
  ,p_core_objects                 => l_sbc_core_objects
  ,p_rowid_id_recs                => l_sbc_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_siv_lookup_type
  ,p_core_objects                 => l_siv_core_objects
  ,p_rowid_id_recs                => l_siv_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sbf_lookup_type
  ,p_core_objects                 => l_sbf_core_objects
  ,p_rowid_id_recs                => l_sbf_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_spr_lookup_type
  ,p_core_objects                 => l_spr_core_objects
  ,p_rowid_id_recs                => l_spr_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sfr_lookup_type
  ,p_core_objects                 => l_sfr_core_objects
  ,p_rowid_id_recs                => l_sfr_rowid_id_recs
  ,p_id_ovn_recs                  => l_null_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sir_lookup_type
  ,p_core_objects                 => l_sir_core_objects
  ,p_rowid_id_recs                => l_null_rowid_id_recs
  ,p_id_ovn_recs                  => l_sir_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_seu_lookup_type
  ,p_core_objects                 => l_seu_core_objects
  ,p_rowid_id_recs                => l_null_rowid_id_recs
  ,p_id_ovn_recs                  => l_seu_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sgb_lookup_type
  ,p_core_objects                 => l_sgb_core_objects
  ,p_rowid_id_recs                => l_null_rowid_id_recs
  ,p_id_ovn_recs                  => l_sgb_id_ovn_recs
  );
  core_objects_lock
  (p_core_object_type             => g_sba_lookup_type
  ,p_core_objects                 => l_sba_core_objects
  ,p_rowid_id_recs                => l_null_rowid_id_recs
  ,p_id_ovn_recs                  => l_sba_id_ovn_recs
  );
  --
  -- Delete the generated objects in child-first order.
  -- The formulas are deleted in two parts. This is because
  -- the formulas can be attached to input values and also the database
  -- items of the input values can be used in formulas.
  --
  del_bal_attributes
  (p_id_ovn_recs                  => l_sba_id_ovn_recs
  );
  del_gu_bal_exclusions
  (p_id_ovn_recs                  => l_sgb_id_ovn_recs
  );
  del_ele_type_usages
  (p_id_ovn_recs                  => l_seu_id_ovn_recs
  );
  del_iterative_rules
  (p_id_ovn_recs                  => l_sir_id_ovn_recs
  );
  del_formula_rules
  (p_rowid_id_recs                => l_sfr_rowid_id_recs
  );
  del_status_rules
  (p_rowid_id_recs                => l_spr_rowid_id_recs
  );
  del_formula_info
  (p_rowid_id_recs                => l_sf_rowid_id_recs
  );
  del_input_values
  (p_rowid_id_recs                => l_siv_rowid_id_recs
  );
  del_formulas
  (p_rowid_id_recs                => l_sf_rowid_id_recs
  );
  del_balance_classis
  (p_rowid_id_recs                => l_sbc_rowid_id_recs
  );
  del_sub_classi_rules
  (p_rowid_id_recs                => l_ssr_rowid_id_recs
  );
  del_element_types
  (p_rowid_id_recs                => l_set_rowid_id_recs
  );
  del_defined_balances
  (p_rowid_id_recs                => l_sdb_rowid_id_recs
  );
  del_balance_types
  (p_rowid_id_recs                => l_sbt_rowid_id_recs
  );
  hr_utility.set_location(l_proc, 30);
  if p_drop_formula_packages then
    drop_formula_packages
    (p_rowid_id_recs                => l_sf_rowid_id_recs
    );
  end if;
  hr_utility.set_location('Leaving:' || l_proc, 100);
end zap_core_objects;
--
end pay_element_template_gen;

/
