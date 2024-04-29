--------------------------------------------------------
--  DDL for Package Body OTA_TMT_BUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TMT_BUS1" as
/* $Header: ottmtrhi.pkb 115.6 2002/11/26 17:09:48 hwinsor noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tmt_bus1.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_tp_measurement_code>---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure chk_tp_measurement_code
  (p_effective_date            in     date
  ,p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ) is
--
 l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package||'chk_tp_measurement_code';
--
 cursor csr_tp_measurement_code is
        select null
        from OTA_TP_MEASUREMENT_TYPES
        where tp_measurement_code = p_tp_measurement_code
        and   business_group_id   = p_business_group_id;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_code'
    ,p_argument_value =>  p_tp_measurement_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  -- Check that the lookup code is valid
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  if hr_api.not_exists_in_hr_lookups
    (p_effective_date   =>   p_effective_date
    ,p_lookup_type      =>   'OTA_PLAN_MEASUREMENT_TYPE'
    ,p_lookup_code      =>   p_tp_measurement_code
    ) then
    -- Error, lookup not available
    fnd_message.set_name('OTA', 'OTA_13800_TMT_INV_MEAS_TYPE');
    fnd_message.raise_error;
    end if;
  --
  -- Check that the combination is unique
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  open  csr_tp_measurement_code;
  fetch csr_tp_measurement_code into l_exists;
  if csr_tp_measurement_code%FOUND then
    close csr_tp_measurement_code;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13801_TMT_DUP_MEAS_TYPE');
    fnd_message.raise_error;
  end if;
  close csr_tp_measurement_code;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end chk_tp_measurement_code;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_del_tp_measurement_code>-----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_del_tp_measurement_code
  (p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ) is
--
 l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package||'chk_del_tp_measurement_code';
--
 cursor csr_del_tp_measurement_code is
        select null
        from PER_BUDGETS pb
            ,PER_BUDGET_VERSIONS pbv
            ,PER_BUDGET_ELEMENTS pbe
            ,PER_BUDGET_VALUES   pbva
        where pb.unit                  = p_tp_measurement_code
        and   pb.business_group_id     = p_business_group_id
        and   pb.budget_type_code      = 'OTA_BUDGET'
        and   pb.budget_id             = pbv.budget_id
        and   pbv.budget_version_id    = pbe.budget_version_id
        and   pbe.budget_element_id    = pbva.budget_element_id;
--
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_code'
    ,p_argument_value =>  p_tp_measurement_code
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_type_id'
    ,p_argument_value =>  p_tp_measurement_type_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  -- Check that the code can be deleted
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  open  csr_del_tp_measurement_code;
  fetch csr_del_tp_measurement_code into l_exists;
  if csr_del_tp_measurement_code%FOUND then
    close csr_del_tp_measurement_code;
    hr_utility.set_location(' Step:'|| l_proc, 60);
    fnd_message.set_name('OTA', 'OTA_13813_TMT_NO_DEL_BUDGET');
    fnd_message.raise_error;
  end if;
  close csr_del_tp_measurement_code;
--
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end chk_del_tp_measurement_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------------<chk_unit>-----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_unit
  (p_effective_date            in     date
  ,p_unit                      in     ota_tp_measurement_types.unit%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ) is
--
 l_exists varchar2(1);
 l_proc  varchar2(72) :=      g_package||'chk_unit';
 l_api_updating   boolean;

 cursor csr_chk_no_cost_recs is
        select null
        from   OTA_TRAINING_PLAN_COSTS
        where  business_group_id      = p_business_group_id
        and    tp_measurement_type_id = p_tp_measurement_type_id;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_unit'
    ,p_argument_value =>  p_unit
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  l_api_updating := ota_tmt_shd.api_updating
    (p_tp_measurement_type_id  => p_tp_measurement_type_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  if ((l_api_updating and
       nvl(ota_tmt_shd.g_old_rec.unit, hr_api.g_varchar2) <>
       nvl(p_unit, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 50);
    --
    -- Validate that the code exists in the lookups view
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date   =>   p_effective_date
      ,p_lookup_type      =>   'UNITS'
      ,p_lookup_code      =>   p_unit
      ) then
      -- Error, lookup not available
      hr_utility.set_location(l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13804_INV_UNIT_TYPE');
      fnd_message.raise_error;
    elsif      (p_unit <> 'I')
          and  (p_unit <>  'M')
          and  (p_unit <> 'N') then
    -- Error, lookup not in sub list of allowed values
      hr_utility.set_location(l_proc, 70);
      fnd_message.set_name('OTA', 'OTA_13804_INV_UNIT_TYPE');
      fnd_message.raise_error;
    End if;
  End if;
  --
  -- but changes are only allowed if there are no current recs in costs
  --
  If l_api_updating
       and nvl(ota_tmt_shd.g_old_rec.unit, hr_api.g_varchar2) <>
       nvl(p_unit, hr_api.g_varchar2) then
    hr_utility.set_location(' Step:'|| l_proc, 80);
    open  csr_chk_no_cost_recs;
    fetch csr_chk_no_cost_recs into l_exists;
    If csr_chk_no_cost_recs%FOUND then
      close csr_chk_no_cost_recs;
      hr_utility.set_location(' Step:'|| l_proc, 90);
      fnd_message.set_name('OTA', 'OTA_13803_TMT_UNIT_UPD_COST');
      fnd_message.raise_error;
    End if;
    close csr_chk_no_cost_recs;
  End if;
  hr_utility.set_location(' Leaving:'||l_proc, 100);
--
end chk_unit;
-- ----------------------------------------------------------------------------
-- |-----------------------------------<chk_budget_level>----------------------|
-- ----------------------------------------------------------------------------
Procedure chk_budget_level
  (p_effective_date            in     date
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_budget_level              in     ota_tp_measurement_types.budget_level%TYPE
  ,p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ) is
--
 l_exists varchar2(1);
 l_proc  varchar2(72) :=      g_package||'chk_budget_level';
 l_api_updating   boolean;

 cursor csr_upd_tp_budget_level is
        select null
        from   PER_BUDGETS pb
              ,PER_BUDGET_VERSIONS pbs
              ,PER_BUDGET_ELEMENTS pbe
        where pb.unit                = p_tp_measurement_code
        and   pb.business_group_id   = p_business_group_id
        and   pb.budget_type_code    = 'OTA_BUDGET'
        and   pb.budget_id           = pbs.budget_id
        and   pbs.budget_version_id  = pbe.budget_version_id;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_code'
    ,p_argument_value =>  p_tp_measurement_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_budget_level'
    ,p_argument_value =>  p_budget_level
    );
  --
  l_api_updating := ota_tmt_shd.api_updating
    (p_tp_measurement_type_id  => p_tp_measurement_type_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  if (l_api_updating and
       nvl(ota_tmt_shd.g_old_rec.budget_level, hr_api.g_varchar2) <>
       nvl(p_budget_level, hr_api.g_varchar2))
    or (NOT l_api_updating)
  then
    hr_utility.set_location(l_proc, 60);
    --
    -- Validate that the code exists in the lookups view
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date   =>   p_effective_date
      ,p_lookup_type      =>  'OTA_TRAINING_PLAN_BUDGET_LEVEL'
      ,p_lookup_code      =>   p_budget_level
      ) then
      -- Error, lookup not available
      hr_utility.set_location(l_proc, 70);
      fnd_message.set_name('OTA', 'OTA_13805_TMT_INV_BUDGET');
      fnd_message.raise_error;
    End if;
    --
  End if;
  --
  -- but changes are only allowed if there are no current recs in budget elements
  --
  If l_api_updating
     and nvl(ota_tmt_shd.g_old_rec.budget_level, hr_api.g_varchar2) <>
     nvl(p_budget_level, hr_api.g_varchar2) then
    hr_utility.set_location(' Step:'|| l_proc, 80);
    open  csr_upd_tp_budget_level;
    fetch csr_upd_tp_budget_level into l_exists;
    If csr_upd_tp_budget_level%FOUND then
      close csr_upd_tp_budget_level;
      hr_utility.set_location(' Step:'|| l_proc, 90);
      fnd_message.set_name('OTA', 'OTA_13806_TMT_UPD_BUDGET');
      fnd_message.raise_error;
    End if;
    close csr_upd_tp_budget_level;
  --
  End if;
  --
--
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end chk_budget_level;
-- ----------------------------------------------------------------------------
-- |-------------------<chk_budget_cost_combination>---------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_budget_cost_combination
  (p_budget_level              in     ota_tp_measurement_types.budget_level%TYPE
  ,p_cost_level                in     ota_tp_measurement_types.cost_level%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ) is
--
 l_exists varchar2(1);
 l_proc  varchar2(72) :=      g_package||'chk_budget_cost_combination';
 l_api_updating   boolean;

Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_budget_level'
    ,p_argument_value =>  p_budget_level
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_cost_level'
    ,p_argument_value =>  p_cost_level
    );
  hr_utility.set_location(' Step:'|| l_proc, 30);

  l_api_updating := ota_tmt_shd.api_updating
    (p_tp_measurement_type_id  => p_tp_measurement_type_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If either budget level or cost level is changing, or this is an
  -- insert, check the combinations
  --
  if ((l_api_updating and
       nvl(ota_tmt_shd.g_old_rec.budget_level, hr_api.g_varchar2) <>
       nvl(p_budget_level, hr_api.g_varchar2)
       or
       nvl(ota_tmt_shd.g_old_rec.cost_level, hr_api.g_varchar2) <>
       nvl(p_cost_level, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 50);
    --
    -- Validate that the combinations exist
    --
    If (p_cost_level = 'PLAN' and (   p_budget_level = 'EVENT'
                                  or p_budget_level = 'ACTIVITY' ))
    then
      -- Error, combination invalid
      hr_utility.set_location(l_proc, 60);
      fnd_message.set_name('OTA', 'OTA_13807_TMT_BUDGET_COST_COMB');
      fnd_message.raise_error;
    End if;
    --
  End if;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end chk_budget_cost_combination;
-- ----------------------------------------------------------------------------
-- |-----------------------------------<chk_cost_level>------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_cost_level
  (p_effective_date            in     date
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_cost_level                in     ota_tp_measurement_types.cost_level%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ) is
--
 l_exists varchar2(1);
 l_proc  varchar2(72) :=      g_package||'chk_cost_level';
 l_api_updating   boolean;

 cursor csr_upd_cost_level is
        select null
        from  OTA_TRAINING_PLAN_COSTS
        where tp_measurement_type_id = p_tp_measurement_type_id
        and   business_group_id      = p_business_group_id;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_cost_level'
    ,p_argument_value =>  p_cost_level
    );
  --
  l_api_updating := ota_tmt_shd.api_updating
    (p_tp_measurement_type_id  => p_tp_measurement_type_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  if (l_api_updating and
       nvl(ota_tmt_shd.g_old_rec.cost_level, hr_api.g_varchar2) <>
       nvl(p_cost_level, hr_api.g_varchar2))
    or (NOT l_api_updating)
  then
    hr_utility.set_location(l_proc, 60);
    --
    -- Validate that the code exists in the lookups view
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date   =>   p_effective_date
      ,p_lookup_type      =>  'OTA_TRAINING_PLAN_COST_LEVEL'
      ,p_lookup_code      =>   p_cost_level
      ) then
      -- Error, lookup not available
      hr_utility.set_location(l_proc, 70);
      fnd_message.set_name('OTA', 'OTA_13808_TMT_INV_COST');
      fnd_message.raise_error;
    End if;
    --
  End if;
  --
  -- but changes are only allowed if there are no current recs in cost table
  --
  If l_api_updating
    and nvl(ota_tmt_shd.g_old_rec.cost_level, hr_api.g_varchar2) <>
    nvl(p_cost_level, hr_api.g_varchar2) then
    hr_utility.set_location(' Step:'|| l_proc, 80);
    open  csr_upd_cost_level;
    fetch csr_upd_cost_level into l_exists;
    If csr_upd_cost_level%FOUND then
      close csr_upd_cost_level;
      hr_utility.set_location(' Step:'|| l_proc, 90);
      fnd_message.set_name('OTA', 'OTA_13809_TMT_UPD_COSTS');
      fnd_message.raise_error;
    End if;
    close csr_upd_cost_level;
  --
  End if;
  --
--
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end chk_cost_level;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_many_budget_values_flag>------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_many_budget_values_flag
  (p_effective_date            in     date
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_many_budget_values_flag   in     ota_tp_measurement_types.many_budget_values_flag%TYPE
  ,p_tp_measurement_code       in     ota_tp_measurement_types.tp_measurement_code%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ) is
--
 l_exists varchar2(1);
 l_proc  varchar2(72) :=      g_package||'chk_many_budget_values_flag';
 l_api_updating   boolean;

 cursor csr_upd_tp_budget_flag is
        select count(pba.budget_value_id)
        from   PER_BUDGETS pb
              ,PER_BUDGET_VERSIONS pbv
              ,PER_BUDGET_ELEMENTS pbe
              ,PER_BUDGET_VALUES   pba
        where pb.unit                = p_tp_measurement_code
        and   pb.business_group_id   = p_business_group_id
        and   pb.budget_id           = pbv.budget_id
        and   pbv.budget_version_id  = pbe.budget_version_id
        and   pbe.budget_element_id  = pba.budget_element_id
        and   pb.budget_type_code    = 'OTA_BUDGET'
        group by pb.budget_id
        having count(pba.budget_value_id) >= 2;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_code'
    ,p_argument_value =>  p_tp_measurement_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_effective_date'
    ,p_argument_value =>  p_effective_date
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_many_budget_values_flag'
    ,p_argument_value =>  p_many_budget_values_flag
    );
  --
  l_api_updating := ota_tmt_shd.api_updating
    (p_tp_measurement_type_id  => p_tp_measurement_type_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- If this is a changing update, or a new insert, test
  --
  if ((l_api_updating and
       nvl(ota_tmt_shd.g_old_rec.many_budget_values_flag, hr_api.g_varchar2) <>
       nvl(p_many_budget_values_flag, hr_api.g_varchar2))
    or (NOT l_api_updating))
  then
    hr_utility.set_location(l_proc, 60);
    --
    -- Validate that the code exists in the lookups view
    --
    if hr_api.not_exists_in_hr_lookups
      (p_effective_date   =>   p_effective_date
      ,p_lookup_type      =>  'YES_NO'
      ,p_lookup_code      =>   p_many_budget_values_flag
      ) then
      -- Error, lookup not available
      hr_utility.set_location(l_proc, 70);
      fnd_message.set_name('OTA', 'OTA_13810_TMT_INV_MANY_BUDGETS');
      fnd_message.raise_error;
    End if;
    --
  End if;
  --
  -- but changes to 'N' are only allowed if there zero or 1 recs in budget elements
  --
  If l_api_updating
     and p_many_budget_values_flag = 'N'
     and (nvl(ota_tmt_shd.g_old_rec.many_budget_values_flag, hr_api.g_varchar2) <>
         nvl(p_many_budget_values_flag, hr_api.g_varchar2))  then
    hr_utility.set_location(' Step:'|| l_proc, 80);
    open  csr_upd_tp_budget_flag;
    fetch csr_upd_tp_budget_flag into l_exists;
    if csr_upd_tp_budget_flag%FOUND then
      close csr_upd_tp_budget_flag;
      fnd_message.set_name('OTA', 'OTA_13811_TMT_INV_UPD_FLAG');
      fnd_message.raise_error;
    else
      close csr_upd_tp_budget_flag;
    End if;
  --
  End if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end chk_many_budget_values_flag;
-- ----------------------------------------------------------------------------
-- |----------------------<chk_item_type_usage_id>----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_item_type_usage_id
  (p_item_type_usage_id        in     ota_tp_measurement_types.item_type_usage_id%TYPE
  ,p_business_group_id         in     ota_tp_measurement_types.business_group_id%TYPE
  ,p_object_version_number     in     ota_tp_measurement_types.object_version_number%TYPE
  ,p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ) is
--
 l_exists         varchar2(1);
 l_proc           varchar2(72) :=      g_package||'chk_item_type_usage_id';
 l_api_updating   boolean;

 cursor csr_chk_item_type is
        select null
        from   HR_SUMMARY_ITEM_TYPE_USAGE
        where  item_type_usage_id    = p_item_type_usage_id
        and    business_group_id     = p_business_group_id;
Begin
--
-- check mandatory parameters have been set
--
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_business_group_id'
    ,p_argument_value =>  p_business_group_id
    );
  l_api_updating := ota_tmt_shd.api_updating
    (p_tp_measurement_type_id  => p_tp_measurement_type_id
    ,p_object_version_number   => p_object_version_number
    );
  --
  -- It can always change to null
  -- If this is a changing update, or a new insert, test
  --
  If p_item_type_usage_id is not null then
    If ((l_api_updating and
         nvl(ota_tmt_shd.g_old_rec.item_type_usage_id, hr_api.g_number) <>
         nvl(p_item_type_usage_id, hr_api.g_number))
      or (NOT l_api_updating))
    Then
      -- Test that it exists in hr_summary
      hr_utility.set_location(l_proc, 10);
      --
      open  csr_chk_item_type;
      fetch csr_chk_item_type into l_exists;
      If csr_chk_item_type%NOTFOUND then
        -- Error, item type does not exist.
        close csr_chk_item_type;
        hr_utility.set_location(' Step:'|| l_proc, 20);
        fnd_message.set_name('OTA', 'OTA_13812_TMT_INV_CALC');
        fnd_message.raise_error;
      End if;
      close csr_chk_item_type;
      --
    End if;
  End if;
    --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
end chk_item_type_usage_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_del_tp_measurement_type_id>--------------------|
-- ----------------------------------------------------------------------------
Procedure chk_del_tp_measurement_type_id
  (p_tp_measurement_type_id    in     ota_tp_measurement_types.tp_measurement_type_id%TYPE
  ) is
--
 l_exists varchar2(1);
  l_proc  varchar2(72) :=      g_package||'chk_del_tp_measurement_type_id';

 cursor csr_del_tp_measurement_type_id is
        select null
        from OTA_TRAINING_PLAN_COSTS
        where tp_measurement_type_id = p_tp_measurement_type_id;
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_tp_measurement_type_id'
    ,p_argument_value =>  p_tp_measurement_type_id
    );
  --
  -- Check that the code can be deleted
  --
  open  csr_del_tp_measurement_type_id;
  fetch csr_del_tp_measurement_type_id into l_exists;
  if csr_del_tp_measurement_type_id%FOUND then
    close csr_del_tp_measurement_type_id;
    hr_utility.set_location(' Step:'|| l_proc, 10);
    fnd_message.set_name('OTA', 'OTA_13802_TMT_DEL_COST');
    fnd_message.raise_error;
  end if;
  close csr_del_tp_measurement_type_id;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
end chk_del_tp_measurement_type_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------------<chk_legislative_setup>----------------|
-- ----------------------------------------------------------------------------
Procedure chk_legislative_setup(
  p_legislation_code        in per_business_groups.legislation_code%TYPE
 ,p_tp_measurement_code     in ota_tp_measurement_types.tp_measurement_code%TYPE
 ,p_unit                    in ota_tp_measurement_types.unit%TYPE
 ,p_budget_level            in ota_tp_measurement_types.budget_level%TYPE
 ,p_cost_level              in ota_tp_measurement_types.cost_level%TYPE
 ,p_many_budget_values_flag in ota_tp_measurement_types.many_budget_values_flag%TYPE
 ,p_object_version_number   in ota_tp_measurement_types.object_version_number%TYPE
 ,p_tp_measurement_type_id  in ota_tp_measurement_types.tp_measurement_type_id%TYPE
) is
--
 l_exists varchar2(1);
 l_proc  varchar2(72) :=      g_package||'chk_legislative_setup';
 l_api_updating   boolean;
--
Begin
--
-- check mandatory parameters have been set
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'tp_measurement_code'
    ,p_argument_value =>  p_tp_measurement_code
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 10);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_unit'
    ,p_argument_value =>  p_unit
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 20);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_cost_level'
    ,p_argument_value =>  p_cost_level
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 30);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_budget_level'
    ,p_argument_value =>  p_budget_level
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 40);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_many_budget_values_flag'
    ,p_argument_value =>  p_many_budget_values_flag
    );
  --
  hr_utility.set_location(' Step:'|| l_proc, 50);
  hr_api.mandatory_arg_error
    (p_api_name       =>  l_proc
    ,p_argument       => 'p_legislation_code'
    ,p_argument_value =>  p_legislation_code
    );
  --
  -- French Specific setup
  --
  if p_legislation_code = 'FR' then
    if    p_tp_measurement_code = 'FR_SALARY_PER_CATEGORY'
       or p_tp_measurement_code = 'FR_DELEGATES_PER_CATEGORY'
       or p_tp_measurement_code = 'FR_NUMBER_EVENTS'
       or p_tp_measurement_code = 'FR_DURATION_HOURS'
       or p_tp_measurement_code = 'FR_ACTUAL_HOURS' then
      --
      -- Test each measurement type individually for setup
      --
      if (  p_tp_measurement_code = 'FR_SALARY_PER_CATEGORY'
            and (p_unit <> 'M' or p_budget_level <> 'PLAN'
            or p_cost_level <> 'NONE' ) )
        or
         (  p_tp_measurement_code = 'FR_DELEGATES_PER_CATEGORY'
            and (p_unit <> 'I' or p_budget_level = 'PLAN'
            or p_cost_level <> 'NONE' ) )
        or
         (  p_tp_measurement_code = 'FR_NUMBER_EVENTS'
            and (p_unit <> 'I' or p_budget_level <> 'ACTIVITY'
            or p_cost_level <> 'NONE' or p_many_budget_values_flag = 'Y' ) )
        or
         (  p_tp_measurement_code = 'FR_DURATION_HOURS'
            and (p_unit <> 'N' or p_budget_level = 'PLAN'
            or p_cost_level <> 'NONE'  or p_many_budget_values_flag = 'Y' ) )
        or
         (  p_tp_measurement_code = 'FR_ACTUAL_HOURS'
            and (p_unit <> 'N' or p_cost_level <> 'DELEGATE' ) ) then
        --
        -- Error, legislative setup not correct
        --
        hr_utility.set_location(l_proc, 70);
        fnd_message.set_name('OTA', 'OTA_13876_TMT_INV_SETUP');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
end chk_legislative_setup;
--
end ota_tmt_bus1;

/
