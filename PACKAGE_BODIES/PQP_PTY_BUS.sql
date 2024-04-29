--------------------------------------------------------
--  DDL for Package Body PQP_PTY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PTY_BUS" as
/* $Header: pqptyrhi.pkb 120.0.12000000.1 2007/01/16 04:29:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pty_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_pension_type_id             number         default null;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_contribution_conv_rule >------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_contribution_conv_rule
  (p_pension_type_id              in pqp_pension_types_f.pension_type_id%TYPE
  ,p_contribution_conversion_rule in pqp_pension_types_f.contribution_conversion_rule%TYPE
  ,p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_contribution_conv_rule';
  l_api_updating   boolean;
  l_lookup_type    varchar2(50); -- added for UK
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.contribution_conversion_rule,
       hr_api.g_varchar2) <> nvl(p_contribution_conversion_rule,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then

    --  If contribution_conversion_rule is not null then
    --  Check if the contribution_conversion_rule value exists in hr_lookups
    --  where the lookup_type is 'PQP_NL_CONVERSION_RULE'
    --
    if p_contribution_conversion_rule is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_NL_CONVERSION_RULE'
           ,p_lookup_code           => p_contribution_conversion_rule
           ) then
        --  Error: Invalid Contribution Conversion Rule
        fnd_message.set_name('PQP', 'PQP_230808_INVALID_CONTR_RULE');
        fnd_message.raise_error;
      end if;
    end if;
 end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.CONTRIBUTION_CONVERSION_RULE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_contribution_conv_rule;

--
-- ---------------------------------------------------------------------------------
-- |------------------------< chk_threshold_conv_rule >-----------------------------|
-- ---------------------------------------------------------------------------------
--
procedure chk_threshold_conv_rule
  (p_pension_type_id              in pqp_pension_types_f.pension_type_id%TYPE
  ,p_threshold_conversion_rule in pqp_pension_types_f.threshold_conversion_rule%TYPE
  ,p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_threshold_conv_rule';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.threshold_conversion_rule,
       hr_api.g_varchar2) <> nvl(p_threshold_conversion_rule,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If threshold_conversion_rule is not null then
    --  Check if the threshold_conversion_rule value exists in hr_lookups
    --  where the lookup_type is 'PQP_NL_CONVERSION_RULE'
    --
    if p_threshold_conversion_rule is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_NL_CONVERSION_RULE'
           ,p_lookup_code           => p_threshold_conversion_rule
           ) then
        --  Error: Invalid Threshold Conversion Rule
        fnd_message.set_name('PQP', 'PQP_230809_INVALID_THRES_RULE');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.THRESHOLD_CONVERSION_RULE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_threshold_conv_rule;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_pension_category >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_pension_category
  (p_pension_type_id       in pqp_pension_types_f.pension_type_id%TYPE
  ,p_pension_category      in pqp_pension_types_f.pension_category%TYPE
  ,p_effective_date        in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_pension_category';
  l_api_updating   boolean;

--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.pension_category,
       hr_api.g_varchar2) <> nvl(p_pension_category,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then

        --
        --  If pension_category is not null then
        --  Check if the pension_category value exists in hr_lookups
        --  where the lookup_type is 'PQP_PENSION_CATEGORY'
        --
        if p_pension_category is not null then
          if hr_api.not_exists_in_dt_hrstanlookups
               (p_effective_date        => p_effective_date
               ,p_validation_start_date => p_validation_start_date
               ,p_validation_end_date   => p_validation_end_date
               ,p_lookup_type           => 'PQP_PENSION_CATEGORY'
               ,p_lookup_code           => p_pension_category
               ) then
            --  Error: Invalid Pension Category
            fnd_message.set_name('PQP', 'PQP_230810_INVALID_PEN_CAT');
            fnd_message.raise_error;
          end if;
        end if;

  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PENSION_CATEGORY'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_pension_category;

--
-- ------------------------------------------------------------------------------
-- |-------------------------< chk_pension_provider >----------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_pension_provider
  (p_pension_type_id       in pqp_pension_types_f.pension_type_id%TYPE
  ,p_pension_provider_type in pqp_pension_types_f.pension_provider_type%TYPE
  ,p_effective_date        in date
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_pension_provider';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.pension_provider_type,
       hr_api.g_varchar2) <> nvl(p_pension_provider_type,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If pension_provider_type is not null then
    --  Check if the pension_provider_type value exists in hr_lookups
    --  where the lookup_type is 'PQP_NL_PENSION_PROVIDER_TYPE'
    --
    if p_pension_provider_type is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_NL_PENSION_PROVIDER_TYPE'
           ,p_lookup_code           => p_pension_provider_type
           ) then
        --  Error: Invalid Pension Provider Type
        fnd_message.set_name('PQP', 'PQP_230811_INV_PRVDR_TYPE');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PENSION_PROVIDER_TYPE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_pension_provider;
--
-- ------------------------------------------------------------------------------
-- |-------------------------< chk_salary_calc_method >--------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_salary_calc_method
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_salary_calculation_method in pqp_pension_types_f.salary_calculation_method%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_salary_calc_method';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.salary_calculation_method,
       hr_api.g_varchar2) <> nvl(p_salary_calculation_method,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If salary_calculation_method is not null then
    --  Check if the salary_calculation_method value exists in hr_lookups
    --  where the lookup_type is 'PQP_NL_SALARY_CALC_METHOD'
    --
    if p_salary_calculation_method is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_NL_SALARY_CALC_METHOD'
           ,p_lookup_code           => p_salary_calculation_method
           ) then
        --  Error: Invalid Salary Calculation Method
        fnd_message.set_name('PQP', 'PQP_230812_SALARY_CALC_METHOD');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.SALARY_CALCULATION_METHOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_salary_calc_method;
--
-- ------------------------------------------------------------------------------
-- |-------------------------< chk_pension_type_name >---------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_pension_type_name
  (p_pension_type_id       in pqp_pension_types_f.pension_type_id%TYPE
  ,p_pension_type_name     in pqp_pension_types_f.pension_type_name%TYPE
  ,p_effective_date        in date
  ,p_business_group_id     in pqp_pension_types_f.business_group_id%TYPE
  ,p_legislation_code      in pqp_pension_types_f.legislation_code%TYPE
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  Cursor csr_pension_type
   (c_pension_type_name in pqp_pension_types_f.pension_type_name%TYPE,
    c_business_group_id in pqp_pension_types_f.business_group_id%TYPE,
    c_legislation_code in pqp_pension_types_f.legislation_code%TYPE,
    c_effective_date   in date,
    c_validation_start_date in date,
    c_validation_end_date in date
   ) Is
  select pension_type_name,
         business_group_id,
         legislation_code,
         effective_start_date,
         effective_start_date,
         effective_end_date
    from pqp_pension_types_f
   where upper(pension_type_name) = upper(c_pension_type_name)
   and
   (( business_group_id IS NOT NULL
      AND business_group_id = c_business_group_id
    )
    OR ( legislation_code IS NOT NULL AND legislation_code = c_legislation_code)
    OR (business_group_id IS NULL AND legislation_code IS NULL)
    )
    and c_effective_date between effective_start_date and effective_end_date;

  l_proc               varchar2(72)  :=  g_package||'chk_pension_type_name';
  l_api_updating       boolean;
  l_pension_type_name  pqp_pension_types_f.pension_type_name%TYPE;
  l_business_group_id  pqp_pension_types_f.business_group_id%TYPE;
  l_legislation_code   pqp_pension_types_f.legislation_code%TYPE;
  l_effective_date     date;
  l_validation_start_date date;
  l_validation_end_date date;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- During insert check to see if the pension type name exists
  -- already in the pqp_pension_types_f table.
  --
  if p_pension_type_id is null then
     open csr_pension_type
     (
     c_pension_type_name      => p_pension_type_name,
     c_business_group_id      => p_business_group_id,
     c_legislation_code       => p_legislation_code,
     c_effective_date         => p_effective_date,
     c_validation_start_date  => p_validation_start_date,
     c_validation_end_date    => p_validation_end_date
     );


     fetch csr_pension_type Into
     l_pension_type_name,
     l_business_group_id,
     l_legislation_code,
     l_effective_date,
     l_validation_start_date,
     l_validation_end_date;

     if csr_pension_type%FOUND then
        close csr_pension_type;
        hr_utility.set_location(' Pension Type Name already exists in table',15);
        --  Error: Pension Name already exists in the table
        fnd_message.set_name('PQP', 'PQP_230813_PEN_TYPE_EXISTS');
        fnd_message.raise_error;
     else
        close csr_pension_type;
     end if;

  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PENSION_TYPE_NAME'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_pension_type_name;
--
-- ------------------------------------------------------------------------------
-- |-------------------------< chk_provider_assignment >-------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_provider_assignment
  (p_pension_type_id       in pqp_pension_types_f.pension_type_id%TYPE
  ,p_effective_date        in date
  ,p_leg_code              in pqp_pension_types_f.legislation_code%TYPE
  ) is
--
  Cursor csr_org_info_nl
   (c_pension_type_id in pqp_pension_types_f.pension_type_id%TYPE) Is
  select 'x'
    from hr_organization_information
   where org_information_context = 'PQP_NL_PENSION_TYPES'
     and org_information1 = to_char(c_pension_type_id);

-- added for UK
  Cursor csr_org_info_gb
   (c_pension_type_id in pqp_pension_types_f.pension_type_id%TYPE) Is
  select 'x'
    from hr_organization_information
   where org_information_context = 'PQP_GB_PENSION_TYPES_INFO'
     and org_information1 = to_char(c_pension_type_id);

-- added for HU
  Cursor csr_org_info_hu
   (c_pension_type_id in pqp_pension_types_f.pension_type_id%TYPE) Is
  select 'x'
    from hr_organization_information
   where org_information_context = 'HU_PENSION_TYPES_INFO'
     and org_information1 = to_char(c_pension_type_id);

  l_proc               varchar2(72)  :=  g_package||'chk_provider_assignment';
  l_api_updating       boolean;
  l_org_info_exits     varchar2(5);
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- During insert check to see if the pension type name exists
  -- already in the pqp_pension_types_f table.
  --

  if(p_leg_code = 'NL') then
      open csr_org_info_nl (c_pension_type_id => p_pension_type_id);
      fetch csr_org_info_nl Into l_org_info_exits;
      if csr_org_info_nl%FOUND then
         close csr_org_info_nl;
         --  Error: Pension Name has been assigned to a provider
         fnd_message.set_name('PQP', 'PQP_230814_PEN_TYPE_ASGED');
         fnd_message.raise_error;
      else
         close csr_org_info_nl;
      end if;
  end if;

  if(p_leg_code = 'GB') then
      open csr_org_info_gb (c_pension_type_id => p_pension_type_id);
      fetch csr_org_info_gb Into l_org_info_exits;
      if csr_org_info_gb%FOUND then
         close csr_org_info_gb;
         --  Error: Pension Name has been assigned to a provider
         fnd_message.set_name('PQP', 'PQP_230814_PEN_TYPE_ASGED');
         fnd_message.raise_error;
      else
         close csr_org_info_gb;
      end if;
  end if;

  if(p_leg_code = 'HU') then
      open csr_org_info_hu (c_pension_type_id => p_pension_type_id);
      fetch csr_org_info_hu Into l_org_info_exits;
      if csr_org_info_hu%FOUND then
         close csr_org_info_hu;
         --  Error: Pension Name has been assigned to a provider
         fnd_message.set_name('PQP', 'PQP_230814_PEN_TYPE_ASGED');
         fnd_message.raise_error;
      else
         close csr_org_info_hu;
      end if;
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PENSION_TYPE_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_provider_assignment;

--
-- ------------------------------------------------------------------------------
-- |----------------------< chk_special_pension_type_code >-------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_special_pension_type_code
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_special_pension_type_code in pqp_pension_types_f.special_pension_type_code%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_special_pension_type_code';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.special_pension_type_code,
       hr_api.g_varchar2) <> nvl(p_special_pension_type_code,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If special_pension_type_code is not null then
    --  Check if the special_pension_type_code value exists in hr_lookups
    --  where the lookup_type is 'PQP_SPECIAL_PENSION_TYPE_CODE'
    --
    if p_special_pension_type_code is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_SPECIAL_PENSION_TYPE_CODE'
           ,p_lookup_code           => p_special_pension_type_code
           ) then
        --  Error: Invalid Special Pension Type Code
        fnd_message.set_name('PQP', 'PQP_230022_INV_SPL_PEN_TYPE');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.SPECIAL_PENSION_TYPE_CODE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_special_pension_type_code;

--
-- ------------------------------------------------------------------------------
-- |-----------------------< chk_pension_sub_category >------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_pension_sub_category
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_pension_sub_category      in pqp_pension_types_f.pension_sub_category%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_pension_sub_category';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.pension_sub_category,
       hr_api.g_varchar2) <> nvl(p_pension_sub_category,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If pension_sub_category is not null then
    --  Check if the pension_sub_category value exists in hr_lookups
    --  where the lookup_type is 'PQP_PENSION_SUB_CATEGORY'
    --
    if p_pension_sub_category is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_PENSION_SUB_CATEGORY'
           ,p_lookup_code           => p_pension_sub_category
           ) then
        --  Error: Invalid Pension Sub Category
        fnd_message.set_name('PQP', 'PQP_230023_INV_PEN_SUB_CAT');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PENSION_SUB_CATEGORY'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_pension_sub_category;

--
-- ------------------------------------------------------------------------------
-- |-----------------------< chk_pension_basis_calc_method >-------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_pension_basis_calc_method
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_pension_basis_calc_method in pqp_pension_types_f.pension_basis_calc_method%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_pension_basis_calc_method';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.pension_basis_calc_method,
       hr_api.g_varchar2) <> nvl(p_pension_basis_calc_method,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If pension_basis_calc_method is not null then
    --  Check if the pension_basis_calc_method value exists in hr_lookups
    --  where the lookup_type is 'PQP_PENSION_BASIS_CALC_MTHD'
    --
    if p_pension_basis_calc_method is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_PENSION_BASIS_CALC_MTHD'
           ,p_lookup_code           => p_pension_basis_calc_method
           ) then
        --  Error: Invalid Pension Basis Calculation Method
        fnd_message.set_name('PQP', 'PQP_230024_INV_PEN_BASIS_CALC');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PENSION_BASIS_CALC_METHOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_pension_basis_calc_method;

--
-- ------------------------------------------------------------------------------
-- |----------------------< chk_prev_year_bonus_include >---------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_prev_year_bonus_include
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_previous_year_bonus_included in pqp_pension_types_f.previous_year_bonus_included%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_prev_year_bonus_include';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.previous_year_bonus_included,
       hr_api.g_varchar2) <> nvl(p_previous_year_bonus_included,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If previous_year_bonus_included is not null then
    --  Check if the previous_year_bonus_included value exists in hr_lookups
    --  where the lookup_type is 'PQP_YES_NO'
    --
    if p_previous_year_bonus_included is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_YES_NO'
           ,p_lookup_code           => p_previous_year_bonus_included
           ) then
        --  Error: Invalid Previous Year Bonus Included
        fnd_message.set_name('PQP', 'PQP_230025_PREV_YR_BONUS_INCL');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PREVIOUS_YEAR_BONUS_INCLUDED'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_prev_year_bonus_include;

--
-- ------------------------------------------------------------------------------
-- |-----------------------< chk_recurring_bonus_period >---------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_recurring_bonus_period
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_recurring_bonus_period    in pqp_pension_types_f.recurring_bonus_period%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_recurring_bonus_period';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.recurring_bonus_period,
       hr_api.g_varchar2) <> nvl(p_recurring_bonus_period,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If recurring_bonus_period is not null then
    --  Check if the recurring_bonus_period value exists in hr_lookups
    --  where the lookup_type is 'PQP_BONUS_PERIOD'
    --
    if p_recurring_bonus_period is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_BONUS_PERIOD'
           ,p_lookup_code           => p_recurring_bonus_period
           ) then
        --  Error: Invalid Recurring Bonus Period
        fnd_message.set_name('PQP', 'PQP_230026_INV_RECUR_BONUS_PER');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.RECURRING_BONUS_PERIOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_recurring_bonus_period;

--
-- ------------------------------------------------------------------------------
-- |--------------------< chk_non_recurring_bonus_period >---------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_non_recurring_bonus_period
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_non_recurring_bonus_period in pqp_pension_types_f.non_recurring_bonus_period%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_non_recurring_bonus_period';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.non_recurring_bonus_period,
       hr_api.g_varchar2) <> nvl(p_non_recurring_bonus_period,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If non_recurring_bonus_period is not null then
    --  Check if the non_recurring_bonus_period value exists in hr_lookups
    --  where the lookup_type is 'PQP_BONUS_PERIOD'
    --
    if p_non_recurring_bonus_period is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_BONUS_PERIOD'
           ,p_lookup_code           => p_non_recurring_bonus_period
           ) then
        --  Error: Invalid Non Recurring Bonus Period
        fnd_message.set_name('PQP', 'PQP_230027_INV_NON_RECUR_BONUS');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.NON_RECURRING_BONUS_PERIOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_non_recurring_bonus_period;

--
-- ------------------------------------------------------------------------------
-- |---------------------< chk_pension_salary_balance >----------------------|
------------------------------------------------------------------------------
--
procedure chk_pension_salary_balance
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_pension_salary_balance in pqp_pension_types_f.pension_salary_balance%TYPE
  ,p_business_group_id         in pqp_pension_types_f.business_group_id%TYPE
  ,p_legislation_code          in pqp_pension_types_f.legislation_code%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--

  Cursor csr_chk_for_dimension
   (c_balance_type_id   in pqp_pension_types_f.pension_salary_balance%TYPE
   ,c_business_group_id in pqp_pension_types_f.business_group_id%TYPE
   ,c_legislation_code  in pqp_pension_types_f.legislation_code%TYPE)
   Is
   Select 1 from pay_defined_balances
      where balance_dimension_id =
      (select balance_dimension_id from pay_balance_dimensions
         where database_item_suffix = '_ASG_RUN'
         and (( business_group_id IS NOT NULL
                AND business_group_id = c_business_group_id
              )
              OR (legislation_code IS NOT NULL AND legislation_code = c_legislation_code)
              OR (business_group_id IS NULL AND legislation_code IS NULL)
             )
      )
      and balance_type_id = c_balance_type_id
      and (( business_group_id IS NOT NULL
             AND business_group_id = c_business_group_id
           )
           OR ( legislation_code IS NOT NULL AND legislation_code = c_legislation_code)
           OR (business_group_id IS NULL AND legislation_code IS NULL)
          );

  l_proc           varchar2(72)  :=  g_package||'chk_pension_salary_balance';
  l_api_updating   boolean;
  l_dim_exists     number;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.pension_salary_balance,
       hr_api.g_number) <> nvl(p_pension_salary_balance,
                                 hr_api.g_number))
    or
      (p_pension_type_id is null)) then
    --
    --  If pension_salary_balance is not null and the legislation is NL then
    --  Check if the pension_salary_balance refers to a valid balance
    --  which has a _ASG_RUN dimension defined in defined balances
    --
    if p_pension_salary_balance is not null AND
       (p_legislation_code is not null and p_legislation_code = 'NL')then

      hr_utility.set_location('Entering:'|| l_proc||' bal '||p_pension_salary_balance, 15);
      Open csr_chk_for_dimension(c_balance_type_id   =>  p_pension_salary_balance
	                          ,c_business_group_id =>  p_business_group_id
				  ,c_legislation_code  =>  p_legislation_code);

	Fetch csr_chk_for_dimension into l_dim_exists;

	if csr_chk_for_dimension%NOTFOUND then
	   -- Error: Invalid Pension Salary Balance
	   close csr_chk_for_dimension;
           fnd_message.set_name('PQP', 'PQP_230028_INV_PEN_SAL_BALANCE');
           fnd_message.raise_error;
	else
	   close csr_chk_for_dimension;
        end if;
      end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.PENSION_SALARY_BALANCE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_pension_salary_balance;

--
-- ------------------------------------------------------------------------------
-- |-------------------------< chk_ee_age_threshold >---------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_ee_age_threshold
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_ee_age_threshold          in pqp_pension_types_f.ee_age_threshold%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_ee_age_threshold';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.ee_age_threshold,
       hr_api.g_varchar2) <> nvl(p_ee_age_threshold,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If ee_age_threshold is not null then
    --  Check if the ee_age_threshold value exists in hr_lookups
    --  where the lookup_type is 'PQP_YES_NO'
    --
    if p_ee_age_threshold is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_YES_NO'
           ,p_lookup_code           => p_ee_age_threshold
           ) then
        --  Error: Invalid Age Dependant Employee Threshold
        fnd_message.set_name('PQP', 'PQP_230130_INV_EE_AGE_THRESH');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.EE_AGE_THRESHOLD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_ee_age_threshold;

--
-- ------------------------------------------------------------------------------
-- |-------------------------< chk_er_age_threshold >---------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_er_age_threshold
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_er_age_threshold          in pqp_pension_types_f.ee_age_threshold%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_er_age_threshold';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.er_age_threshold,
       hr_api.g_varchar2) <> nvl(p_er_age_threshold,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If er_age_threshold is not null then
    --  Check if the er_age_threshold value exists in hr_lookups
    --  where the lookup_type is 'PQP_YES_NO'
    --
    if p_er_age_threshold is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_YES_NO'
           ,p_lookup_code           => p_er_age_threshold
           ) then
        --  Error: Invalid Age Dependant Employer Threshold
        fnd_message.set_name('PQP', 'PQP_230131_INV_ER_AGE_THRESH');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.ER_AGE_THRESHOLD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_er_age_threshold;

--
-- ------------------------------------------------------------------------------
-- |-----------------------< chk_ee_age_contribution >--------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_ee_age_contribution
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_ee_age_contribution       in pqp_pension_types_f.ee_age_threshold%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_ee_age_contribution';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.ee_age_contribution,
       hr_api.g_varchar2) <> nvl(p_ee_age_contribution,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If ee_age_contribution is not null then
    --  Check if the ee_age_contribution value exists in hr_lookups
    --  where the lookup_type is 'PQP_YES_NO'
    --
    if p_ee_age_contribution is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_YES_NO'
           ,p_lookup_code           => p_ee_age_contribution
           ) then
        --  Error: Invalid Age Dependant Employee Contribution
        fnd_message.set_name('PQP', 'PQP_230132_INV_EE_AGE_CONTRIB');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.EE_AGE_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_ee_age_contribution;

--
-- ------------------------------------------------------------------------------
-- |------------------------< chk_er_age_contribution >--------------------------|
-- ------------------------------------------------------------------------------
--
procedure chk_er_age_contribution
  (p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
  ,p_er_age_contribution       in pqp_pension_types_f.ee_age_threshold%TYPE
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is
--
  l_proc           varchar2(72)  :=  g_package||'chk_er_age_contribution';
  l_api_updating   boolean;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective date'
    ,p_argument_value => p_effective_date
    );
  --
  -- Only proceed with validation if:
  -- a) During update, the value has actually changed to
  --    another not null value.
  -- b) During insert, the type_id is not null.
  --
  if (((p_pension_type_id is not null) and
       nvl(pqp_pty_shd.g_old_rec.er_age_contribution,
       hr_api.g_varchar2) <> nvl(p_er_age_contribution,
                                 hr_api.g_varchar2))
    or
      (p_pension_type_id is null)) then
    --
    --  If er_age_contribution is not null then
    --  Check if the er_age_contribution value exists in hr_lookups
    --  where the lookup_type is 'PQP_YES_NO'
    --
    if p_er_age_contribution is not null then
      if hr_api.not_exists_in_dt_hrstanlookups
           (p_effective_date        => p_effective_date
           ,p_validation_start_date => p_validation_start_date
           ,p_validation_end_date   => p_validation_end_date
           ,p_lookup_type           => 'PQP_YES_NO'
           ,p_lookup_code           => p_er_age_contribution
           ) then
        --  Error: Invalid Age Dependant Employer Contribution
        fnd_message.set_name('PQP', 'PQP_230133_INV_ER_AGE_CONTRIB');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PQP_PENSION_TYPES_F.ER_AGE_CONTRIBUTION'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 30);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 40);
end chk_er_age_contribution;

--
--  ---------------------------------------------------------------------------
--  |----------------------< set_end_date_fpus >--------------------------|
--  ---------------------------------------------------------------------------
--

Procedure set_end_date_fpus
      (
       p_pension_type_id           in pqp_pension_types_f.pension_type_id%TYPE
      ,p_pension_sub_category      in pqp_pension_types_f.pension_sub_category%TYPE
      ,p_effective_date            in date
      ,p_validation_start_date     in date
      ,p_validation_end_date       out nocopy date
      ) IS

  cursor c_get_end_date is
  select nvl(end_date_active,null)
  from   fnd_lookup_values
  where  lookup_type = 'PQP_PENSION_SUB_CATEGORY'
  and    lookup_code = p_pension_sub_category
  and    p_effective_date between start_date_active
  and    nvl(end_date_active,hr_api.g_eot)
  and    nvl(enabled_flag,'N') = 'Y';


  l_end_date_active date;
  l_proc varchar2(50) := g_package||'set_end_date_fpus';

Begin

   hr_utility.set_location(' entering  :'||   l_proc, 10);

  open  c_get_end_date;
  fetch c_get_end_date into l_end_date_active;
  hr_utility.set_location(' l_end_date_active  :'||   l_end_date_active, 20);
  if (c_get_end_date%FOUND and l_end_date_active is not null) then
      close c_get_end_date;
      hr_utility.set_location(' l_end_date_active  :'||   l_end_date_active, 30);
      p_validation_end_date := l_end_date_active;
      hr_utility.set_location(' p_validation_end_date  :'||   p_validation_end_date, 40);
  else
      close c_get_end_date;
  end if;

End set_end_date_fpus;



--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_pension_type_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pqp_pension_types_f pty
     where pty.pension_type_id = p_pension_type_id
       and pbg.business_group_id = pty.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  l_legislation_code  varchar2(150);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pension_type_id'
    ,p_argument_value     => p_pension_type_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id
                       , l_legislation_code;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     hr_multi_message.add
       (p_associated_column1
         => nvl(p_associated_column1,'PENSION_TYPE_ID')
       );
     --
  else
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id
      (p_security_group_id => l_security_group_id
      );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_pension_type_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pqp_pension_types_f pty
     where pty.pension_type_id = p_pension_type_id
       and pbg.business_group_id (+) = pty.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'pension_type_id'
    ,p_argument_value     => p_pension_type_id
    );
  --
  if ( nvl(pqp_pty_bus.g_pension_type_id, hr_api.g_number)
       = p_pension_type_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_pty_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pqp_pty_bus.g_pension_type_id             := p_pension_type_id;
    pqp_pty_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_ddf >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Developer Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data values
--   are all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Developer Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_ddf
  (p_rec in pqp_pty_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pension_type_id is not null)  and (
    nvl(pqp_pty_shd.g_old_rec.pty_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information_category, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information1, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information2, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information3, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information4, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information5, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information6, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information7, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information8, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information9, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information10, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information11, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information12, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information13, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information14, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information15, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information16, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information17, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information18, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information19, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pty_information20, hr_api.g_varchar2) ))
    or (p_rec.pension_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Pension Type Developer DF'
      ,p_attribute_category              => p_rec.pty_information_category
      ,p_attribute1_name                 => 'PTY_INFORMATION1'
      ,p_attribute1_value                => p_rec.pty_information1
      ,p_attribute2_name                 => 'PTY_INFORMATION2'
      ,p_attribute2_value                => p_rec.pty_information2
      ,p_attribute3_name                 => 'PTY_INFORMATION3'
      ,p_attribute3_value                => p_rec.pty_information3
      ,p_attribute4_name                 => 'PTY_INFORMATION4'
      ,p_attribute4_value                => p_rec.pty_information4
      ,p_attribute5_name                 => 'PTY_INFORMATION5'
      ,p_attribute5_value                => p_rec.pty_information5
      ,p_attribute6_name                 => 'PTY_INFORMATION6'
      ,p_attribute6_value                => p_rec.pty_information6
      ,p_attribute7_name                 => 'PTY_INFORMATION7'
      ,p_attribute7_value                => p_rec.pty_information7
      ,p_attribute8_name                 => 'PTY_INFORMATION8'
      ,p_attribute8_value                => p_rec.pty_information8
      ,p_attribute9_name                 => 'PTY_INFORMATION9'
      ,p_attribute9_value                => p_rec.pty_information9
      ,p_attribute10_name                => 'PTY_INFORMATION10'
      ,p_attribute10_value               => p_rec.pty_information10
      ,p_attribute11_name                => 'PTY_INFORMATION11'
      ,p_attribute11_value               => p_rec.pty_information11
      ,p_attribute12_name                => 'PTY_INFORMATION12'
      ,p_attribute12_value               => p_rec.pty_information12
      ,p_attribute13_name                => 'PTY_INFORMATION13'
      ,p_attribute13_value               => p_rec.pty_information13
      ,p_attribute14_name                => 'PTY_INFORMATION14'
      ,p_attribute14_value               => p_rec.pty_information14
      ,p_attribute15_name                => 'PTY_INFORMATION15'
      ,p_attribute15_value               => p_rec.pty_information15
      ,p_attribute16_name                => 'PTY_INFORMATION16'
      ,p_attribute16_value               => p_rec.pty_information16
      ,p_attribute17_name                => 'PTY_INFORMATION17'
      ,p_attribute17_value               => p_rec.pty_information17
      ,p_attribute18_name                => 'PTY_INFORMATION18'
      ,p_attribute18_value               => p_rec.pty_information18
      ,p_attribute19_name                => 'PTY_INFORMATION19'
      ,p_attribute19_value               => p_rec.pty_information19
      ,p_attribute20_name                => 'PTY_INFORMATION20'
      ,p_attribute20_value               => p_rec.pty_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< chk_df >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates all the Descriptive Flexfield values.
--
-- Prerequisites:
--   All other columns have been validated.  Must be called as the
--   last step from insert_validate and update_validate.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in pqp_pty_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.pension_type_id is not null)  and (
    nvl(pqp_pty_shd.g_old_rec.pty_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_pty_shd.g_old_rec.pty_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pty_attribute20, hr_api.g_varchar2) ))
    or (p_rec.pension_type_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Pension Type DF'
      ,p_attribute_category              => p_rec.pty_attribute_category
      ,p_attribute1_name                 => 'PTY_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pty_attribute1
      ,p_attribute2_name                 => 'PTY_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pty_attribute2
      ,p_attribute3_name                 => 'PTY_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pty_attribute3
      ,p_attribute4_name                 => 'PTY_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pty_attribute4
      ,p_attribute5_name                 => 'PTY_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pty_attribute5
      ,p_attribute6_name                 => 'PTY_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pty_attribute6
      ,p_attribute7_name                 => 'PTY_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pty_attribute7
      ,p_attribute8_name                 => 'PTY_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pty_attribute8
      ,p_attribute9_name                 => 'PTY_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pty_attribute9
      ,p_attribute10_name                => 'PTY_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pty_attribute10
      ,p_attribute11_name                => 'PTY_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pty_attribute11
      ,p_attribute12_name                => 'PTY_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pty_attribute12
      ,p_attribute13_name                => 'PTY_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pty_attribute13
      ,p_attribute14_name                => 'PTY_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pty_attribute14
      ,p_attribute15_name                => 'PTY_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pty_attribute15
      ,p_attribute16_name                => 'PTY_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pty_attribute16
      ,p_attribute17_name                => 'PTY_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pty_attribute17
      ,p_attribute18_name                => 'PTY_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pty_attribute18
      ,p_attribute19_name                => 'PTY_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pty_attribute19
      ,p_attribute20_name                => 'PTY_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pty_attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
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
  ,p_rec             in pqp_pty_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_pty_shd.api_updating
      (p_pension_type_id                  => p_rec.pension_type_id
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
  (p_datetrack_mode                in varchar2
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
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'validation_end_date'
    ,p_argument_value => p_validation_end_date
    );
  --
    --
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
  (p_pension_type_id                  in number
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
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'validation_end_date'
      ,p_argument_value => p_validation_end_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'pension_type_id'
      ,p_argument_value => p_pension_type_id
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
-- |----------------------< chk_startup_action >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--  This procedure will check that the current action is allowed according
--  to the current startup mode.
--
-- ----------------------------------------------------------------------------
PROCEDURE chk_startup_action
  (p_insert               IN boolean
  ,p_business_group_id    IN number
  ,p_legislation_code     IN varchar2
  ,p_legislation_subgroup IN varchar2 DEFAULT NULL) IS
--
BEGIN
  --
  -- Call the supporting procedure to check startup mode
  -- EDIT_HERE: The following call should be edited if certain types of rows
  -- are not permitted.
  IF (p_insert) THEN
    hr_startup_data_api_support.chk_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  ELSE
    hr_startup_data_api_support.chk_upd_del_startup_action
      (p_generic_allowed   => TRUE
      ,p_startup_allowed   => TRUE
      ,p_user_allowed      => TRUE
      ,p_business_group_id => p_business_group_id
      ,p_legislation_code  => p_legislation_code
      ,p_legislation_subgroup => p_legislation_subgroup
      );
  END IF;
  --
END chk_startup_action;


-- ----------------------------------------------------------------------------
-- |---------------------------< get_legislation_code >------------------------|
-- ----------------------------------------------------------------------------

FUNCTION get_legislation_code
                 (p_business_group_id IN NUMBER
                 ) RETURN VARCHAR2 IS
   --declare local variables
   l_legislation_code  per_business_groups.legislation_code%TYPE;

   CURSOR c_get_leg_code IS
   SELECT legislation_code
    FROM  per_business_groups_perf
    WHERE business_group_id =p_business_group_id;

 BEGIN
   OPEN c_get_leg_code;
   LOOP
      FETCH c_get_leg_code INTO l_legislation_code;
      EXIT WHEN c_get_leg_code%NOTFOUND;
   END LOOP;
   CLOSE c_get_leg_code;
   RETURN (l_legislation_code);
 EXCEPTION
 ---------
 WHEN OTHERS THEN
 RETURN(NULL);
 END;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pqp_pty_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in out nocopy date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
  l_legislation_code varchar2(150);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(true
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pqp_pty_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- after validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --

    IF p_rec.business_group_id IS NOT NULL THEN
      --Get the legislation Code from Business Group Id
      l_legislation_code := get_legislation_code(p_rec.business_group_id);
    ELSE
      l_legislation_code := p_rec.legislation_code;
    END IF;


  -- Check if the Pension Type Name is Unique within the table
  -- pqp_pension_types_f
  --
  chk_pension_type_name
  (p_pension_type_id       => p_rec.pension_type_id
  ,p_pension_type_name     => p_rec.pension_type_name
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => p_rec.business_group_id
  ,p_legislation_code      => l_legislation_code
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );

  --
  -- Validate the Pension Category Lookup Code
  --
  chk_pension_category
  (p_pension_type_id       => p_rec.pension_type_id
  ,p_pension_category      => p_rec.pension_category
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );

   if(l_legislation_code = 'NL') then

      --
      -- Validate the Contribution Conversion Rule Lookup Code
      --

      chk_contribution_conv_rule
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_contribution_conversion_rule => p_rec.contribution_conversion_rule
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );


      --
      -- Validate the Threshold Conversion Rule Lookup Code
      --
      chk_threshold_conv_rule
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_threshold_conversion_rule => p_rec.threshold_conversion_rule
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Pension Provider Type Lookup Code
      --
      chk_pension_provider
      (p_pension_type_id       => p_rec.pension_type_id
      ,p_pension_provider_type => p_rec.pension_provider_type
      ,p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      );

      --
      -- Validate the Salary Calculation Method Lookup Code
      --
      chk_salary_calc_method
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_salary_calculation_method => p_rec.salary_calculation_method
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Special Pension Type Code
      --
      chk_special_pension_type_code
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_special_pension_type_code => p_rec.special_pension_type_code
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );


      --
      -- Validate the Pension Sub Category
      --
      chk_pension_sub_category
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_pension_sub_category      => p_rec.pension_sub_category
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );


      --
      -- Validate the Pension Basis Calculation Method
      --
      chk_pension_basis_calc_method
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_pension_basis_calc_method => p_rec.pension_basis_calc_method
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );


      --
      -- Validate the Previous Year Bonus Included
      --
      chk_prev_year_bonus_include
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_previous_year_bonus_included => p_rec.previous_year_bonus_included
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );


      --
      -- Validate the Recurring Bonus Period
      --
      chk_recurring_bonus_period
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_recurring_bonus_period       => p_rec.recurring_bonus_period
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );


      --
      -- Validate the Non Recurring Bonus Period
      --
      chk_non_recurring_bonus_period
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_non_recurring_bonus_period   => p_rec.non_recurring_bonus_period
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );


      --
      -- Validate the Pension Salary Balance
      --
      chk_pension_salary_balance
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_pension_salary_balance    => p_rec.pension_salary_balance
      ,p_business_group_id         => p_rec.business_group_id
      ,p_legislation_code          => l_legislation_code
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employee Threshold
      --
      chk_ee_age_threshold
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_ee_age_threshold          => p_rec.ee_age_threshold
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employer Threshold
      --
      chk_er_age_threshold
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_er_age_threshold          => p_rec.er_age_threshold
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employee Contribution
      --
      chk_ee_age_contribution
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_ee_age_contribution       => p_rec.ee_age_contribution
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employer Contribution
      --
      chk_er_age_contribution
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_er_age_contribution       => p_rec.er_age_contribution
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      if (p_rec.pension_sub_category is not null and
          p_rec.pension_sub_category = 'FPU_S') then
          --
          -- Set End date for FPU_S.
          --
          set_end_date_fpus
          (
           p_pension_type_id           => p_rec.pension_type_id
          ,p_pension_sub_category      => p_rec.pension_sub_category
          ,p_effective_date            => p_effective_date
          ,p_validation_start_date     => p_validation_start_date
          ,p_validation_end_date       => p_validation_end_date
          );

          hr_utility.set_location(' p_validation_end_date  :'||   p_validation_end_date, 20);



      end if;

  end if;      -- end of Validations for NL

  --
  --
  -- Validate Dependent Attributes
  --
  --
  pqp_pty_bus.chk_ddf(p_rec);
  --
  pqp_pty_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);

exception
when others then
hr_utility.set_location('error occured : '||SQLERRM,15);
raise;
End insert_validate;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pqp_pty_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in out nocopy date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
  l_legislation_code  varchar2(150);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  chk_startup_action(false
                    ,p_rec.business_group_id
                    ,p_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     hr_api.validate_bus_grp_id
       (p_business_group_id => p_rec.business_group_id
       ,p_associated_column1 => pqp_pty_shd.g_tab_nam
                                || '.BUSINESS_GROUP_ID');
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );

  --
  -- Validate the Pension Category Lookup Code
  --
  chk_pension_category
  (p_pension_type_id       => p_rec.pension_type_id
  ,p_pension_category      => p_rec.pension_category
  ,p_effective_date        => p_effective_date
  ,p_validation_start_date => p_validation_start_date
  ,p_validation_end_date   => p_validation_end_date
  );

      IF p_rec.business_group_id IS NOT NULL THEN
      --Get the legislation Code from Business Group Id
      l_legislation_code := get_legislation_code(p_rec.business_group_id);
    ELSE
      l_legislation_code := p_rec.legislation_code;
    END IF;


   if(l_legislation_code = 'NL') then
      --
      -- Validate the Contribution Conversion Rule Lookup Code
      --
      chk_contribution_conv_rule
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_contribution_conversion_rule => p_rec.contribution_conversion_rule
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );
      --
      -- Validate the Threshold Conversion Rule Lookup Code
      --
      chk_threshold_conv_rule
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_threshold_conversion_rule => p_rec.threshold_conversion_rule
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Pension Provider Type Lookup Code
      --
      chk_pension_provider
      (p_pension_type_id       => p_rec.pension_type_id
      ,p_pension_provider_type => p_rec.pension_provider_type
      ,p_effective_date        => p_effective_date
      ,p_validation_start_date => p_validation_start_date
      ,p_validation_end_date   => p_validation_end_date
      );
      --
      -- Validate the Salary Calculation Method Lookup Code
      --
      chk_salary_calc_method
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_salary_calculation_method => p_rec.salary_calculation_method
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Pension Basis Calculation Method
      --
      chk_pension_basis_calc_method
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_pension_basis_calc_method => p_rec.pension_basis_calc_method
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );


      --
      -- Validate the Previous Year Bonus Included
      --
      chk_prev_year_bonus_include
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_previous_year_bonus_included => p_rec.previous_year_bonus_included
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );


      --
      -- Validate the Recurring Bonus Period
      --
      chk_recurring_bonus_period
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_recurring_bonus_period       => p_rec.recurring_bonus_period
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );


      --
      -- Validate the Non Recurring Bonus Period
      --
      chk_non_recurring_bonus_period
      (p_pension_type_id              => p_rec.pension_type_id
      ,p_non_recurring_bonus_period   => p_rec.non_recurring_bonus_period
      ,p_effective_date               => p_effective_date
      ,p_validation_start_date        => p_validation_start_date
      ,p_validation_end_date          => p_validation_end_date
      );


      --
      -- Validate the Pension Salary Balance
      --
      chk_pension_salary_balance
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_pension_salary_balance    => p_rec.pension_salary_balance
      ,p_business_group_id         => p_rec.business_group_id
      ,p_legislation_code          => l_legislation_code
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employee Threshold
      --
      chk_ee_age_threshold
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_ee_age_threshold          => p_rec.ee_age_threshold
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employer Threshold
      --
      chk_er_age_threshold
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_er_age_threshold          => p_rec.er_age_threshold
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employee Contribution
      --
      chk_ee_age_contribution
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_ee_age_contribution       => p_rec.ee_age_contribution
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      --
      -- Validate the Age Dependant Employer Contribution
      --
      chk_er_age_contribution
      (p_pension_type_id           => p_rec.pension_type_id
      ,p_er_age_contribution       => p_rec.er_age_contribution
      ,p_effective_date            => p_effective_date
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
      );

      hr_utility.set_location(' pension_sub_category :'||
      p_rec.pension_sub_category, 10);

      if (p_rec.pension_sub_category is not null and
          p_rec.pension_sub_category = 'FPU_S') then
          --
          -- Set End date for FPU_S.
          --
          set_end_date_fpus
          (
           p_pension_type_id           => p_rec.pension_type_id
          ,p_pension_sub_category      => p_rec.pension_sub_category
          ,p_effective_date            => p_effective_date
          ,p_validation_start_date     => p_validation_start_date
          ,p_validation_end_date       => p_validation_end_date
          );


      end if;

  end if;

  pqp_pty_bus.chk_ddf(p_rec);
  --
  pqp_pty_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pqp_pty_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc                  VARCHAR2(72) := g_package||'delete_validate';
  l_legislation_code      VARCHAR2(30);
  l_is_abp_pt             NUMBER;
  l_is_pggm_pt            NUMBER;
  l_org_info_exists       NUMBER;
  l_pggm_org_info_exists  NUMBER;
  l_pggm_scheme           NUMBER;
  l_asg_info_exists       NUMBER;
  l_max_org_end_dt        DATE;
  l_max_asg_end_dt        DATE;

  --cursor to check that the pension type is a ABP Pension type
  CURSOR c_chk_abp_pt(c_pension_type_id  IN  pqp_pension_types_f.pension_type_id%TYPE) IS
     SELECT 1
       FROM pqp_pension_types_f
     WHERE  pension_type_id = c_pension_type_id
       AND  special_pension_type_code = 'ABP';

  --cursor to check that the pension type is a PGGM Pension type
  CURSOR c_chk_pggm_pt(c_pension_type_id  IN  pqp_pension_types_f.pension_type_id%TYPE) IS
     SELECT 1
       FROM pqp_pension_types_f
     WHERE  pension_type_id = c_pension_type_id
       AND  special_pension_type_code = 'PGGM';

  --cursor to check if an org info row exists for the PT
  CURSOR c_chk_org_info(c_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE) IS
     SELECT 1
       FROM hr_organization_information
     WHERE  org_information_context = 'PQP_NL_ABP_PT'
       AND  org_information3  =  to_char(c_pension_type_id);

  --cursor to check if an org info row exists for the PT
  CURSOR c_chk_pggm_org_info(c_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE) IS
     SELECT 1
       FROM hr_organization_information
     WHERE  org_information_context = 'PQP_NL_PGGM_PT'
       AND  org_information3  =  to_char(c_pension_type_id);

  --cursor to check if an asg eit row exists for the PT
  CURSOR c_chk_asg_info(c_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE) IS
     SELECT 1
       FROM per_assignment_extra_info
     WHERE  aei_information_category = 'NL_ABP_PI'
       AND  information_type         = 'NL_ABP_PI'
       AND  aei_information3         = to_char(c_pension_type_id);

   --cursor to get the end date for the org eit row for this PT
   CURSOR c_org_info_end_dt(c_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE) IS
      SELECT fnd_date.canonical_to_date(nvl(org_information2,'4712/12/31')) org_info_end_dt
        FROM hr_organization_information
      WHERE  org_information3 = to_char(c_pension_type_id)
        AND  org_information_context = 'PQP_NL_ABP_PT';

   --cursor to get the end date for the org eit row for this PT
   CURSOR c_pggm_org_info_end_dt(c_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE) IS
      SELECT fnd_date.canonical_to_date(nvl(org_information2,'4712/12/31')) org_info_end_dt
        FROM hr_organization_information
      WHERE  org_information3 = to_char(c_pension_type_id)
        AND  org_information_context = 'PQP_NL_PGGM_PT';

   --cursor to get the end date for the asg eit row for this PT
   CURSOR c_asg_info_end_dt(c_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE) IS
      SELECT fnd_date.canonical_to_date(nvl(aei_information2,'4712/12/31')) asg_info_end_dt
        FROM per_assignment_extra_info
      WHERE  aei_information3 = to_char(c_pension_type_id)
        AND  aei_information_category  = 'NL_ABP_PI'
        AND  information_type          = 'NL_ABP_PI';

    --
    -- CURSOR to check if a PGGM Scheme Exists
    --
    CURSOR c_pggm_scheme (
           c_pension_type_id IN pqp_pension_types_f.pension_type_id%TYPE) IS
    SELECT 1
      FROM pay_element_type_extra_info
     WHERE eei_information_category = 'PQP_NL_PGGM_DEDUCTION'
       AND eei_information2         = fnd_number.number_to_canonical(c_pension_type_id);

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
  chk_startup_action(false
                    ,pqp_pty_shd.g_old_rec.business_group_id
                    ,pqp_pty_shd.g_old_rec.legislation_code
                    );
  IF hr_startup_data_api_support.g_startup_mode
                     NOT IN ('GENERIC','STARTUP') THEN
     --
     -- Validate Important Attributes
     --
     --
     -- After validating the set of important attributes,
     -- if Multiple Message Detection is enabled and at least
     -- one error has been found then abort further validation.
     --
     hr_multi_message.end_validation_set;
  END IF;
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode          => p_datetrack_mode
    ,p_validation_start_date   => p_validation_start_date
    ,p_validation_end_date     => p_validation_end_date
    ,p_pension_type_id         => p_rec.pension_type_id
    );
  --
  --
  -- Check if the pension type has been assigned to a provider
  --
  If p_datetrack_mode ='ZAP' Then

      IF p_rec.business_group_id IS NOT NULL THEN
        l_legislation_code := hr_api.return_legislation_code (
                                p_business_group_id => p_rec.business_group_id
                              );
      ELSE
        l_legislation_code := p_rec.legislation_code;
      END IF;


    chk_provider_assignment
     (p_pension_type_id    => p_rec.pension_type_id
     ,p_effective_date     => p_effective_date
     ,p_leg_code           => l_legislation_code --added for UK
     );
  End If;

  --
  -- For NL ABP Pension Types perform extra ORG and ASG EIT Validations
  --
  OPEN c_chk_abp_pt(p_rec.pension_type_id);
  FETCH c_chk_abp_pt INTO l_is_abp_pt;
  IF c_chk_abp_pt%FOUND THEN
    CLOSE c_chk_abp_pt;
    hr_utility.set_location('ABP PT'||l_proc,10);
    -- if the mode is ZAP, then dont allow a delete if a row exists
    -- in the org or asg EIT for this PT
    If p_datetrack_mode = 'ZAP' Then
       --check if there exists a row in the ORG EIT for the PT
       hr_utility.set_location('Delete Mode ZAP'||l_proc,20);
       OPEN c_chk_org_info(p_rec.pension_type_id);
       FETCH c_chk_org_info INTO l_org_info_exists;
       If c_chk_org_info%FOUND THEN
          CLOSE c_chk_org_info;
          hr_utility.set_location('Found org info for the PT'||l_proc,30);
          fnd_message.set_name('PQP','PQP_230048_ORG_INFO_EXISTS');
          hr_multi_message.add();
       Else
          CLOSE c_chk_org_info;
       End If;

       --check if there exists a row in the ASG EIT for the PT
       OPEN c_chk_asg_info(p_rec.pension_type_id);
       FETCH c_chk_asg_info INTO l_asg_info_exists;
       If c_chk_asg_info%FOUND THEN
          CLOSE c_chk_asg_info;
          hr_utility.set_location('Found ASG info for the PT'||l_proc,40);
          fnd_message.set_name('PQP','PQP_230049_ASG_INFO_EXISTS');
          hr_multi_message.add();
       Else
          CLOSE c_chk_asg_info;
       End If;

    -- if the date track mode is DELETE (END DATE)
    -- first find the max end date in the ORG/ASG EIT rows and then
    -- error out with a message to inform the user to atleast end date
    -- on this maximum end date

    Elsif p_datetrack_mode = 'DELETE' Then
       --find the maximum end date in the ORG/ASG EIT for this PT
       hr_utility.set_location('Datetrack mode DELETE'||l_proc,50);
       l_max_org_end_dt := p_effective_date;
       l_max_asg_end_dt := p_effective_date;
       -- loop through all org info rows and fetch the end date greatest than the eff date
       FOR temp_rec in c_org_info_end_dt(p_rec.pension_type_id)
         LOOP
         hr_utility.set_location('in org info loop'||p_effective_date||temp_rec.org_info_end_dt,10);
           If temp_rec.org_info_end_dt > l_max_org_end_dt THEN
              l_max_org_end_dt := temp_rec.org_info_end_dt;
           End If;
         END LOOP;

       If l_max_org_end_dt <> p_effective_date THEN
          hr_utility.set_location('Found future dates org eit rows'||l_proc,60);
          fnd_message.set_name('PQP','PQP_230050_FUTURE_ORG_INFO');
          fnd_message.set_token('ENDDATE',to_char(l_max_org_end_dt));
          hr_multi_message.add();
       End If;

       -- loop through all asg info rows and fetch the  end date greatest than the eff date
       FOR temp_rec in c_asg_info_end_dt(p_rec.pension_type_id)
         LOOP
           If temp_rec.asg_info_end_dt > l_max_asg_end_dt THEN
              l_max_asg_end_dt := temp_rec.asg_info_end_dt;
           End If;
         END LOOP;
--       hr_utility.trace_off;
       If l_max_asg_end_dt <> p_effective_date THEN
          hr_utility.set_location('found future dates asg eit rows'||l_proc,70);
          fnd_message.set_name('PQP','PQP_230051_FUTURE_ASG_INFO');
          fnd_message.set_token('ENDDATE',to_char(l_max_asg_end_dt));
          hr_multi_message.add();
       End If;

     End If; -- end of date track mode DELETE/ZAP validations

  ELSE
    CLOSE c_chk_abp_pt;
  END IF;

  --
  -- For NL PGGM Pension type perform extra validations
  -- Check if the pension type has been attached to an org
  -- Please Note: This is only for the NL Legislation
  --
  OPEN c_chk_pggm_pt(p_rec.pension_type_id);
  FETCH c_chk_pggm_pt
   INTO l_is_pggm_pt;
  --
  IF c_chk_pggm_pt%FOUND THEN
    hr_utility.set_location('PGGM PT'||l_proc,10);
    -- Do not allow a delete if a row exists
    -- in the org EIT for this PT

       --
       -- Check if there exists a row in the ORG EIT for the PT
       --
       hr_utility.set_location('Delete Mode ZAP'||l_proc,20);
       OPEN c_chk_pggm_org_info(p_rec.pension_type_id);
       FETCH c_chk_pggm_org_info
        INTO l_pggm_org_info_exists;
       --
       IF c_chk_pggm_org_info%FOUND THEN
          CLOSE c_chk_pggm_org_info;
          hr_utility.set_location('Found org info for the PT'||l_proc,30);
          fnd_message.set_name('PQP','PQP_230048_ORG_INFO_EXISTS');
          hr_multi_message.add();
       ELSE
          CLOSE c_chk_pggm_org_info;
       END IF;

   ELSE

       --
       -- Check if a PGGM Scheme exists for the PT
       --
       OPEN c_pggm_scheme(p_rec.pension_type_id);
      FETCH c_pggm_scheme
       INTO l_pggm_scheme;

       IF c_pggm_scheme%FOUND THEN
          CLOSE c_pggm_scheme;
          hr_utility.set_location('Found scheme info for the PT'||l_proc,30);
          fnd_message.set_name('PQP','PQP_2300XX_SCHEME_INFO_EXISTS');
          hr_multi_message.add();
       ELSE
          CLOSE c_pggm_scheme;
       END IF;


   END IF;

   CLOSE c_chk_pggm_pt;

  hr_utility.set_location(' Leaving:'||l_proc, 80);

End delete_validate;
--

end pqp_pty_bus;


/
