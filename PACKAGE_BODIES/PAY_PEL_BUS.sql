--------------------------------------------------------
--  DDL for Package Body PAY_PEL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEL_BUS" as
/* $Header: pypelrhi.pkb 120.7.12010000.3 2008/10/03 08:41:56 ankagarw ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pel_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_element_link_id             number         default null;
g_eot      date := hr_api.g_eot;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_element_link_id                      in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_element_links_f pel
     where pel.element_link_id = p_element_link_id
       and pbg.business_group_id = pel.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id per_business_groups.SECURITY_GROUP_ID%TYPE;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'element_link_id'
    ,p_argument_value     => p_element_link_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
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
         => nvl(p_associated_column1,'ELEMENT_LINK_ID')
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
  (p_element_link_id                      in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_element_links_f pel
     where pel.element_link_id = p_element_link_id
       and pbg.business_group_id = pel.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  per_business_groups.LEGISLATION_CODE%TYPE;
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
    ,p_argument           => 'element_link_id'
    ,p_argument_value     => p_element_link_id
    );
  --
  if ( nvl(pay_pel_bus.g_element_link_id, hr_api.g_number)
       = p_element_link_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pel_bus.g_legislation_code;
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

    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_pel_bus.g_element_link_id             := p_element_link_id;
    pay_pel_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in pay_pel_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.element_link_id is not null)  and (
    nvl(pay_pel_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pay_pel_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.element_link_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'ATTRIBUTE_CATEGORY'
      ,p_attribute1_name                 => 'ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.attribute1
      ,p_attribute2_name                 => 'ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.attribute2
      ,p_attribute3_name                 => 'ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.attribute3
      ,p_attribute4_name                 => 'ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.attribute4
      ,p_attribute5_name                 => 'ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.attribute5
      ,p_attribute6_name                 => 'ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.attribute6
      ,p_attribute7_name                 => 'ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.attribute7
      ,p_attribute8_name                 => 'ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.attribute8
      ,p_attribute9_name                 => 'ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.attribute9
      ,p_attribute10_name                => 'ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.attribute10
      ,p_attribute11_name                => 'ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.attribute11
      ,p_attribute12_name                => 'ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.attribute12
      ,p_attribute13_name                => 'ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.attribute13
      ,p_attribute14_name                => 'ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.attribute14
      ,p_attribute15_name                => 'ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.attribute15
      ,p_attribute16_name                => 'ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.attribute16
      ,p_attribute17_name                => 'ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.attribute17
      ,p_attribute18_name                => 'ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.attribute18
      ,p_attribute19_name                => 'ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.attribute19
      ,p_attribute20_name                => 'ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.attribute20
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
  ,p_rec             in pay_pel_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_pel_shd.api_updating
      (p_element_link_id                  => p_rec.element_link_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
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
  (p_payroll_id                    in number default hr_api.g_number
  ,p_element_type_id               in number default hr_api.g_number
  ,p_datetrack_mode                in varchar2
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
  If ((nvl(p_payroll_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_all_payrolls_f'
            ,p_base_key_column => 'PAYROLL_ID'
            ,p_base_key_value  => p_payroll_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','all payrolls');
     hr_multi_message.add
       (p_associated_column1 => pay_pel_shd.g_tab_nam || '.PAYROLL_ID');
  End If;
  If ((nvl(p_element_type_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_element_types_f'
            ,p_base_key_column => 'ELEMENT_TYPE_ID'
            ,p_base_key_value  => p_element_type_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','element types');
     hr_multi_message.add
       (p_associated_column1 => pay_pel_shd.g_tab_nam || '.ELEMENT_TYPE_ID');
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
  (p_element_link_id                  in number
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
      ,p_argument       => 'element_link_id'
      ,p_argument_value => p_element_link_id
      );
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_link_input_values_f'
       ,p_base_key_column => 'element_link_id'
       ,p_base_key_value  => p_element_link_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','link input values');
         hr_multi_message.add;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_element_entries_f'
       ,p_base_key_column => 'element_link_id'
       ,p_base_key_value  => p_element_link_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         fnd_message.set_name('PAY','HR_7215_DT_CHILD_EXISTS');
         fnd_message.set_token('TABLE_NAME','element entries');
         hr_multi_message.add;
    End If;
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
--  ---------------------------------------------------------------------------
--  |---------------------< chk_asg_link_usages >-------------------------|
--  ---------------------------------------------------------------------------

Procedure chk_asg_link_usages
(p_business_group_id     in   number,
 p_people_group_id       in    number,
 p_element_link_id       in    number,
 p_effective_start_date  in date,
 p_effective_end_date    in date)
 is
--
  l_proc   varchar2(72) := g_package || 'chk_asg_link_usages';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  pay_asg_link_usages_pkg.insert_alu
  (p_business_group_id,
   p_people_group_id,
   p_element_link_id,
   p_effective_start_date,
   p_effective_end_date);
--
hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_asg_link_usages;

--
--  ---------------------------------------------------------------------------
--  |---------------------------< chk_defaults >------------------------------|
--  ---------------------------------------------------------------------------

Procedure chk_defaults
  ( p_element_type_id              in number
   ,p_qualifying_age               in out nocopy varchar2
   ,p_qualifying_length_of_service in out nocopy varchar2
   ,p_qualifying_units             in out nocopy varchar2
   ,p_multiply_value_flag          in out nocopy varchar2
   ,p_standard_link_flag           in out nocopy varchar2
   ,p_effective_date               in date
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_defaults';

  cursor csr_Defaults is
  select qualifying_age,qualifying_length_of_service,qualifying_units,
         standard_link_flag,multiply_value_flag
  from pay_element_types_f
  where element_type_id = p_element_type_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if p_qualifying_age is not null and
    (p_qualifying_age < 0 or length(p_qualifying_age) > 2) then
      fnd_message.set_name('PAY', 'PAY_33096_QUALI_AGE_CHECK');
      fnd_message.raise_error;
  end if;

  begin
    if p_qualifying_length_of_service is not null
       and (p_qualifying_length_of_service < 0
            or to_number(p_qualifying_length_of_service,'9999.99')
                         <> to_number(p_qualifying_length_of_service)) then
         fnd_message.set_name('PAY', 'PAY_33097_QUALI_LOS_CHECK');
         fnd_message.raise_error;
    end if;
  exception
    when others then
    fnd_message.set_name('PAY', 'PAY_33097_QUALI_LOS_CHECK');
    fnd_message.raise_error;
  end;

  if p_qualifying_units is not null then
    if hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'QUALIFYING_UNITS'
	,p_qualifying_units) then
      --
      fnd_message.set_name('PAY', 'PAY_33098_QUALI_UNIT_CHECK');
      fnd_message.raise_error;
      --
    end if;
  end if;


  for rec in csr_Defaults
  loop
    p_qualifying_age := nvl(p_qualifying_age,rec.qualifying_age);
    p_qualifying_length_of_service :=
      nvl(p_qualifying_length_of_service,rec.qualifying_length_of_service);
    p_qualifying_units := nvl(p_qualifying_units,rec.qualifying_units);
    p_multiply_value_flag :=
      nvl(p_multiply_value_flag,rec.multiply_value_flag);
    p_standard_link_flag := nvl(p_standard_link_flag,rec.standard_link_flag);
  end loop;

  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_defaults;

--
--  ---------------------------------------------------------------------------
--  |-------------------------<chk_link_input_values>-------------------------|
--  ---------------------------------------------------------------------------

Procedure chk_link_input_values
  (p_element_type_id in number,
   p_element_link_id in number,
   p_effective_date in date
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_link_input_values';
  cursor csr_InputValues is
  select effective_start_date,
	 effective_end_date,
	 input_value_id,
	 default_value,max_value,
	 min_value,warning_or_error
  from	 pay_input_values_f
  where  element_type_id = p_element_type_id
  and p_effective_date between effective_start_date and effective_end_date;

  l_link_input_value_id  	number;
  l_effective_start_date	date;
  l_effective_end_date		date;
  l_object_version_number	number;
  l_pay_basis_warning		boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  for rec in csr_InputValues
  loop
    pay_link_input_values_api.create_liv_internal
    (p_effective_date   =>      p_effective_date
    ,p_element_link_id  =>      p_element_link_id
    ,p_input_value_id   =>      rec.input_value_id
    ,p_costed_flag      =>      'N'
    ,p_default_value    =>      rec.default_value
    ,p_max_value        =>      rec.max_value
    ,p_min_value        =>      rec.min_value
    ,p_warning_or_error =>      rec.warning_or_error
    ,p_link_input_value_id =>   l_link_input_value_id
    ,p_effective_start_date =>  l_effective_start_date
    ,p_effective_end_date  =>   l_effective_end_date
    ,p_object_version_number => l_object_version_number
    ,p_pay_basis_warning   =>   l_pay_basis_warning
    );
  end loop;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_link_input_values;

--
--  ---------------------------------------------------------------------------
--  |---------------------------<chk_end_date>--------------------------------|
--  ---------------------------------------------------------------------------
Procedure chk_end_date
  (p_element_type_id           in number,
   p_element_link_id           in number,
   p_effective_start_date      in date,
   p_effective_end_date        in out nocopy date,
   p_organization_id           in number,
   p_people_group_id           in number,
   p_job_id                    in number,
   p_position_id               in number,
   p_grade_id                  in number,
   p_location_id               in number,
   p_link_to_all_payrolls_flag in varchar2,
   p_payroll_id                in number,
   p_employment_category       in varchar2,
   p_pay_basis_id              in number,
   p_business_group_id         in number
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_end_date';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  p_effective_end_date := pay_element_links_pkg.max_end_date
                         (p_element_type_id,
			  p_element_link_id,
			  p_effective_start_date,
			  p_effective_end_date,
			  p_organization_id,
			  p_people_group_id,
			  p_job_id,
			  p_position_id,
			  p_grade_id,
			  p_location_id,
			  p_link_to_all_payrolls_flag,
			  p_payroll_id,
			  p_employment_category,
			  p_pay_basis_id,
			  p_business_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_end_date;

--
--  ---------------------------------------------------------------------------
--  |---------------------<chk_standard_entries>-------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_standard_entries
  ( p_business_group_id		in number
   ,p_element_link_id		in number
   ,p_element_type_id		in number
   ,p_effective_start_date	in date
   ,p_effective_end_date	in date
   ,p_payroll_id		in number
   ,p_link_to_all_payrolls_flag in varchar2
   ,p_job_id			in number
   ,p_grade_id			in number
   ,p_position_id		in number
   ,p_organization_id		in number
   ,p_location_id		in number
   ,p_pay_basis_id		in number
   ,p_employment_category	in varchar2
   ,p_people_group_id		in number
   ) is
--
  l_proc   varchar2(72) := g_package || 'chk_standard_entries';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  hrentmnt.maintain_entries_el
  (p_business_group_id,
   p_element_link_id,
   p_element_type_id,
   p_effective_start_date,
   p_effective_end_date,
   p_payroll_id,
   p_link_to_all_payrolls_flag,
   p_job_id,
   p_grade_id,
   p_position_id,
   p_organization_id,
   p_location_id,
   p_pay_basis_id,
   p_employment_category,
   p_people_group_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_standard_entries;

--
--  ---------------------------------------------------------------------------
--  |--------------------------<chk_ben_contri>-------------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a link cannot be created
--   if there are benefit contributions set up for the element as
--   of effective date
--
-- In Arguments:
-- p_element_type_id
-- p_effective_start_date
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_ben_contri
  (p_element_type_id 		in number,
   p_effective_start_date 	in date
  ) is
--
  cursor csr_ben_contri_used is
  select '1'
    from ben_benefit_classifications bbc, pay_element_types_f pet
   where bbc.benefit_classification_id(+) = pet.benefit_classification_id
     and element_type_id = p_element_type_id
     and p_effective_start_date between pet.effective_start_date
     and pet.effective_end_date
     and nvl(contributions_used,'N') = 'Y';

  cursor csr_BenContri is
  select '1'
    from ben_benefit_contributions_f
   where element_type_id = p_element_type_id
     and p_effective_start_date between effective_start_date
     and effective_end_date;

  l_proc      varchar2(72) := g_package || 'chk_ben_contri';
  l_exists    varchar2(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  Open csr_ben_contri_used;
  Fetch csr_ben_contri_used into l_exists;
  If csr_ben_contri_used%found then
    --
    Open csr_BenContri;
    Fetch csr_BenContri into l_exists;
    If csr_BenContri%notfound then
      Close csr_ben_contri_used;
      Close csr_BenContri;
      fnd_message.set_name('PAY', 'PAY_33086_LINK_NO_EFF_CONTRI');
      fnd_message.raise_error;
    End If;
    Close csr_BenContri;
    --
  End If;
  Close csr_ben_contri_used;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ben_contri;

--  ---------------------------------------------------------------------------
--  |--------------------------<chk_emp_cat>----------------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the entered employment category is
--   the valid one
--
-- In Arguments:
-- p_employment_category
-- p_effective_date
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_emp_cat
  (p_employment_category	in varchar2,
   p_effective_date 	        in date
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_emp_cat';
  l_dummy  varchar(1);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  If p_employment_category is not null Then
    If hr_api.not_exists_in_hr_lookups
       (p_effective_date
       ,'EMP_CAT'
       ,p_employment_category) Then
       --
       fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
       fnd_message.set_token('COLUMN','EMPLOYMENT_CATEGORY');
       fnd_message.set_token('LOOKUP_TYPE','EMP_CAT');
       fnd_message.raise_error;
       --
    End If;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_emp_cat;
--
--  ---------------------------------------------------------------------------
--  |--------------------------<chk_org_unit>---------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_org_unit
  (p_business_group_id 	in number,
   p_organization_id 	in number,
   p_effective_date     in date
-- Bug 6010954. removed the p_location_id parameter.
--   p_location_id        in out nocopy number
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_org_unit';
  l_dummy   hr_all_organization_units.location_id%TYPE;

  cursor csr_OrgUnit is
  select location_id
  from hr_all_organization_units
  where business_group_id = p_business_group_id
  and organization_id = p_organization_id
  and p_effective_date
  between date_from and nvl(date_to, g_eot) ;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open csr_OrgUnit;
  fetch csr_OrgUnit into l_dummy;
  if csr_OrgUnit%notfound then
    close csr_OrgUnit;
    fnd_message.set_name('PAY', 'PAY_33087_LINK_ORG_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_OrgUnit;

  --p_location_id := nvl(p_location_id,l_dummy);
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_org_unit;

--  ---------------------------------------------------------------------------
--  |-----------------------------<chk_position>------------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a position is the one valid
--   for the business group
--
-- In Arguments:
-- p_business_group_id
-- p_position_id
-- p_organization_id
-- p_job_id
-- p_effective_date
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_position
  (p_business_group_id 	in number,
   p_position_id 	in number,
   p_organization_id    in number,
   p_job_id             in number,
   p_effective_date     in date
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_position';
  l_dummy   varchar2(1);

  cursor csr_position is
  select 'X'
  from per_positions pos, per_jobs job, hr_organization_units org
  where pos.position_id = p_position_id
  and pos.business_group_id +0 = p_business_group_id
  and job.job_id = pos.job_id and org.organization_id = pos.organization_id
  and p_effective_date between pos.date_effective
  and nvl(pos.date_end, g_eot)
  and (p_organization_id is null or p_organization_id =pos.organization_id)
  and (p_job_id is null or p_job_id = pos.job_id);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open csr_position;
  fetch csr_position into l_dummy;
  if csr_position%notfound then
    close csr_position;
    fnd_message.set_name('PAY', 'PAY_33094_LINK_POS_INVALID');
    fnd_message.raise_error;
  end if;
  close csr_position;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_position;

--  ---------------------------------------------------------------------------
--  |-----------------------------<chk_job_id>--------------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a job is the one valid
--
--
-- In Arguments:
-- p_business_group_id
-- p_job_id
-- p_grade_id
-- p_effective_date
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_job_id
  (p_business_group_id  in number,
   p_job_id 		in number,
   p_effective_date     in date
   ) is
--
  l_proc   varchar2(72) := g_package || 'chk_job_id';
  l_dummy   varchar2(1);

  cursor csr_jobs
  is
  select 'X'
  from per_jobs_v job
  where job.business_group_id +0 = p_business_group_id
  and p_effective_date between job.date_from and nvl(job.date_to, g_eot)
  and job.job_id = p_job_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open csr_jobs;
  fetch csr_jobs into l_dummy;
  if csr_jobs%notfound then
    close csr_jobs;
    fnd_message.set_name('PAY', 'PAY_33452_FK_DATA_INACTIVE');
    fnd_message.set_token('COLUMN','Job Id');
    fnd_message.set_token('TABLE','per_jobs');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.raise_error;
  end if;
  close csr_jobs;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_job_id;
--
--
--  ---------------------------------------------------------------------------
--  |-----------------------------<chk_grade_id>------------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a job is the one valid
--
--
-- In Arguments:
-- p_business_group_id
-- p_job_id
-- p_grade_id
-- p_effective_date
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_grade_id
  (p_business_group_id  in number,
   p_grade_id           in number,
   p_effective_date     in date
   ) is
--
  l_proc   varchar2(72) := g_package || 'chk_grade_id';
  l_dummy   varchar2(1);

  cursor csr_grades
  is
  select 'X'
  from per_grades grade
  where grade.grade_id = p_grade_id
  and p_effective_date
  between grade.date_from and nvl (grade.date_to,g_eot);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open csr_grades;
  fetch csr_grades into l_dummy;
  if csr_grades%notfound then
    close csr_grades;
    fnd_message.set_name('PAY', 'PAY_33452_FK_DATA_INACTIVE');
    fnd_message.set_token('COLUMN','Grade Id');
    fnd_message.set_token('TABLE','per_grades');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.raise_error;
  end if;
  close csr_grades;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_grade_id;

--  ---------------------------------------------------------------------------
--  |------------------------<chk_people_group_id>----------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a position is the one valid
--   for the business group
--
-- In Arguments:
-- p_people_group_id
-- p_effective_date
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_people_group_id
  (p_people_group_id 	in number,
   p_effective_date     in date
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_people_group_id';
  l_dummy   varchar2(1);

  cursor csr_people_group_id is
  select 'X'
  from pay_people_groups ppg
  where people_group_id = p_people_group_id
  and p_effective_date between nvl(ppg.start_date_active,p_effective_date)
  and nvl(ppg.end_date_active, g_eot);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open csr_people_group_id;
  fetch csr_people_group_id into l_dummy;
  if csr_people_group_id%notfound then
    close csr_people_group_id;
    fnd_message.set_name('PAY', 'PAY_33452_FK_DATA_INACTIVE');
    fnd_message.set_token('COLUMN','People Group Id');
    fnd_message.set_token('TABLE','pay_people_groups');
    fnd_message.set_token('PROCEDURE',l_proc);
    fnd_message.raise_error;
  end if;
  close csr_people_group_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_people_group_id;

--
--  ---------------------------------------------------------------------------
--  |---------------------<chk_linktoallpr>-----------------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that a the link to all payrolls if Yes
--   then a payroll id is not specified
--
-- In Arguments:
-- p_link_to_all_payrolls_flag
-- p_payroll_id
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_linktoallpr
  (p_link_to_all_payrolls_flag 	in varchar2,
   p_payroll_id 		in number
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_linktoallpr';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if p_link_to_all_payrolls_flag = 'Y' and p_payroll_id is not null then
    fnd_message.set_name('PAY', 'PAY_33088_LINK_ALL_PAYROLLS');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_linktoallpr;

--
--  ---------------------------------------------------------------------------
--  |---------------------------<chk_costable_type>---------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure the following
-- If the link is for an element whose primary classification has costable_flag
--  set to 'N', then the costable_type must be "Not Costed".
-- The costable type of the link can be 'Distributed' only if the element type
--  has a PAY_VALUE of UOM 'Money', and it is not already a member of a
--  distribution set. (there cannot be a complete reverse test on defintion
--  of the distribution set, since these can be defined in terms of
--  classifications only).
-- If the costable type is 'Not Costed' then costing,balancing and distribution
--  set must be null. Transfer_to_GL must be 'N'.
-- If the costable type is 'Costed' or 'Fixed Costed', then distribution set
--  must be null. Costing is optional, balancing is mandatory and
-- transfer_to_GL defaults to 'Y', but can be changed.
-- If the costable type is 'Distributed', then:
--       1. A distribution set must be specified. The credit/debit type of
--          the classifications of elements in that set must match that
--          of the type for the link. Consequently, an empty distribution
--          set cannot be entered (the set being date-effectively empty, due
--          to end dates on all member elements should be considered).
--       2. Costing is optional.
--          If it is null, then all costing comes from the components of the
--          distribution set. If it's not null, then that is used to override
--          the appropriate segments of the cost codes of the components of
--          the distribution set (see costing LLD for details).
--       3. Balancing is mandatory.
--       4. Transfers_to_GL defaults to 'Y'.
--
-- In Arguments:
-- p_element_link_id
-- p_business_group_id
-- p_element_type_id
-- p_costable_type
-- p_element_set_id
-- p_transfer_to_gl
-- p_balancing_keyflex_id
-- p_cost_allocation_keyflex_id
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_costable_type
  (p_effective_date             in date,
   p_element_link_id 		in number,
   p_business_group_id 		in number,
   p_element_type_id 		in number,
   p_costable_type 		in varchar2,
   p_element_set_id		in number,
   p_transfer_to_gl 		in varchar2,
   p_balancing_keyflex_id 	in number,
   p_cost_allocation_keyflex_id in number
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_costable_type';
  l_costable_flag pay_element_classifications.costable_flag%TYPE;
  l_uom          pay_input_values_f.UOM%TYPE;

  l_leg_code     per_business_groups.legislation_code%TYPE;
  l_costing_dc   pay_element_classifications.costing_debit_or_credit%TYPE;

  l_dummy        pay_element_sets.element_set_id%TYPE;

  cursor csr_CostableFlag is
  select costable_flag from pay_element_classifications
  where classification_id in (select distinct classification_id
                              from pay_element_types_f
			      where element_type_id = p_element_type_id
                              and p_effective_date between effective_start_date
			      and effective_end_date);

  cursor csr_PayValue is
  select UOM
  from pay_input_values_f
  where element_type_id = p_element_type_id
  and upper(name) like 'PAY VALUE'
  and p_effective_date between effective_start_date and effective_end_date;


  cursor csr_legcode_cr_db_type is
  select distinct pec.costing_debit_or_credit, pbg.legislation_code
  from pay_element_classifications pec, pay_element_types_f pet,
       per_business_groups pbg
  where pec.classification_id = pet.classification_id
  and pet.business_group_id = pbg.business_group_id (+)
  and pet.element_type_id = p_element_type_id;


  cursor csr_cr_db_class(p_costing_dc varchar2,p_leg_code varchar2) is
  select element_set.element_set_id
  from pay_element_sets element_set
  where element_set_id = p_element_set_id
  and element_set.element_set_type = 'D' and
  /* the element set is within the users responsibility area */
  ( element_set.business_group_id +0 = p_business_group_id
    or (element_set.business_group_id is null
    and element_set.legislation_code = p_leg_code))
  and /* either the link is not distributed costing or all of the
         classifications in the set have the same costing debit or credit flag
         as the link elements classification */
  exists (
  /* check the classifications of elements in the set that are specified
     directly by name */
  select 1
  from pay_element_type_rules rule, pay_element_types_f type,
       pay_element_classifications class
  where element_set.element_set_id = rule.element_set_id
  and class.classification_id = type.classification_id
  and type.element_type_id = rule.element_type_id
  and class.costing_debit_or_credit = p_costing_dc
  and p_effective_date between type.effective_start_date
  and type.effective_end_date
  union all
  /* check the element classifications specified in the set */
  select 1
  from pay_ele_classification_rules class_rule,
       pay_element_classifications class2
  where class_rule.element_set_id = element_set.element_set_id
  and class2.classification_id = class_rule.classification_id
  and class2.costing_debit_or_credit = p_costing_dc)
  and
  /* the element set is not empty
  (as far as this user is concerned) */
  exists (
           /* check that there are elements directly included in
	   the set or (see second half of union statement) */
  select 1
  from pay_element_type_rules rule2, pay_element_types_f type2
  where element_set.element_set_id=rule2.element_set_id
  and rule2.element_type_id=type2.element_type_id
  and rule2.include_or_exclude = 'I'
  and (type2.business_group_id = p_business_group_id
  or (type2.business_group_id is null
  and type2.legislation_code = p_leg_code))
  and p_effective_date between type2.effective_start_date
  and type2.effective_end_date
  union all
  /* check that there are elements with the classification that is included
     in the set */
  select 1
  from pay_element_types_f type3, pay_ele_classification_rules class_rule2
  where class_rule2.element_set_id = element_set.element_set_id
  and class_rule2.classification_id = type3.classification_id
  and (type3.business_group_id = p_business_group_id
  or (type3.business_group_id is null
  and type3.legislation_code = p_leg_code))
  and p_effective_date between type3.effective_start_date
  and type3.effective_end_date );
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open csr_CostableFlag;
  Fetch csr_CostableFlag into l_costable_flag;
  close csr_CostableFlag;

  open csr_PayValue;
  fetch csr_PayValue into l_uom;
  close csr_PayValue;

  open csr_legcode_cr_db_type;
  fetch csr_legcode_cr_db_type into l_costing_dc,l_leg_code;
  close csr_legcode_cr_db_type;

  if l_costable_flag = 'N' and p_costable_type <> 'N' then
    fnd_message.set_name('PAY','PAY_33089_COST_FLAG_TYPE_MISMATCH');
    fnd_message.set_token('TABLE_NAME','pay_element_links_f');
    fnd_message.raise_error;
  end if;

  if p_costable_type = 'N'
     and
     (p_transfer_to_gl <> 'N'
      or p_cost_allocation_keyflex_id is not null
      or p_balancing_keyflex_id is not null
      or p_element_set_id is not null) then
        fnd_message.set_name('PAY','PAY_33091_COST_BAL_ELESET_NC');
        fnd_message.raise_error;
  elsif (p_costable_type = 'C' or p_costable_type = 'F')
          and
         ( p_element_set_id is not null or p_balancing_keyflex_id is null) then
	   fnd_message.set_name('PAY','PAY_33092_BAL_MAND_ELE_SET_NM');
           fnd_message.raise_error;
  elsif p_costable_type = 'D' then
     if p_element_set_id is null or p_balancing_keyflex_id is null
     then
       fnd_message.set_name('PAY','PAY_33095_LINK_MAN_BAL_ELE_SET');
       fnd_message.raise_error;
     elsif l_uom <> 'M' then
       fnd_message.set_name('PAY','PAY_33090_UOM_COST_TYPE_DISTRI');
       fnd_message.raise_error;
     elsif pay_element_links_pkg.element_in_distribution_set
           ( p_element_type_id,
             p_business_group_id,
             l_leg_code) then
       fnd_message.set_name('PAY','PAY_6462_LINK_DIST_IN_DIST');
       fnd_message.raise_error;
     else
       open csr_cr_db_class(l_costing_dc,l_leg_code);
       fetch csr_cr_db_class into l_dummy;
       if csr_cr_db_class%notfound then
         fnd_message.set_name('PAY','PAY_33451_CR_DB_CLASS_MISMA');
         fnd_message.raise_error;
       end if;
       close csr_cr_db_class;
     end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);

end chk_costable_type;

--
--  ---------------------------------------------------------------------------
--  |---------------------<chk_costable_type_for_upd>-------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the costable type if updated is
--   for lifetime of the element link
--
-- In Arguments:
-- p_costable_type
-- p_datetrack_mode
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------


procedure chk_costable_type_for_upd
(p_costable_type  in varchar2,
 p_datetrack_mode in varchar2)
 is
   l_proc   varchar2(72) := g_package || 'chk_costable_type_for_upd';
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  if pay_pel_shd.g_old_rec.costable_type <> p_costable_type
     and p_datetrack_mode = hr_api.g_update then
     fnd_message.set_name('PAY', 'PAY_6466_LINK_NO_COST_UPD2');
     fnd_message.raise_error;
  end if;
    hr_utility.set_location(' Leaving:'||l_proc,20);
end;

--
--  ---------------------------------------------------------------------------
--  |------------------------<chk_standard_link_flag>-------------------------|
--  ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure the following business rules are
--   satisfied when the standard link flag is updated from No to Yes:
--       1. the change will not take place over the lifetime of the link.
--          (ie. there exist date-effective updates to the link).
--       2. no entries exist for the link.
--       3. no salary basis is associated with the standard link element.
--   We also check in this procedure that the standard link flag is never set
--   to 'Y' for elements whose processing type is non-recurring.
--
-- In Arguments:
-- p_element_type_id
-- p_business_group_id
-- p_element_link_id
-- p_standard_link_flag
-- p_effective_date
-- p_datetrack_mode
--
-- Post Success:
--   No Error is raised
--
-- Post Failure:
--   Errors are raised
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------

procedure chk_standard_link_flag
  (p_element_type_id    in number,
   p_business_group_id  in number,
   p_element_link_id 	in number,
   p_standard_link_flag in varchar2,
   p_effective_date     in date,
   p_datetrack_mode 	in varchar2
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_standard_link_flag';
  l_dummy  varchar2(1);
  l_processing_type varchar2(30);
  l_pay_basis_exists number;

  cursor csr_DateEffRecs is
    select null
    from pay_element_entries_f
    where element_link_id = p_element_link_id;

  cursor csr_ProcessingType is
    select processing_type
    from pay_element_types_f
    where element_type_id = p_element_type_id
    and p_effective_date between effective_start_date and effective_end_date;

  /* commented the below block for bug no : 6764215

   cursor csr_pay_basis_exists is
    select 1
    from
      pay_input_values_f piv
     ,per_pay_bases      ppb
    where
        piv.element_type_id = p_element_type_id
    and p_effective_date between piv.effective_start_date
                             and piv.effective_end_date
    and ppb.input_value_id = piv.input_value_id
    and ppb.business_group_id = p_business_group_id;

   */
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Only check for change of standard link flag if not inserting
  if (p_datetrack_mode <> hr_api.g_insert)
  then
    if pay_pel_shd.g_old_rec.standard_link_flag = 'N'
       and p_standard_link_flag = 'Y' then
      hr_utility.set_location(l_proc,20);
      open csr_DateEffRecs;
      fetch csr_DateEffRecs into l_dummy;
      if (csr_DateEffRecs%found or p_datetrack_mode = hr_api.g_update) then
        close csr_DateEffRecs;
        fnd_message.set_name('PAY', 'PAY_6733_LINK_NO_UPD_STAN_FLAG');
        fnd_message.raise_error;
      end if;
      close csr_DateEffRecs;
    end if;
  end if;
  --
  -- Bugfix 5012412
  -- Match standard link flag against processing type
  if (p_standard_link_flag = 'Y') then
    hr_utility.set_location(l_proc,30);
    --
    open csr_ProcessingType;
    fetch csr_ProcessingType into l_processing_type;
    close csr_ProcessingType;
    --
    if (l_processing_type = 'N')
    then
      hr_utility.set_location(l_proc,40);
      -- Standard link flag can only be 'Y' if processing type is 'R', i.e. recurring
      fnd_message.set_name('PAY', 'PAY_33296_INVLD_STD_LINK_FLAG');
      fnd_message.raise_error;
    end if;
    --
    hr_utility.set_location(l_proc,40);
    --
    -- #5512101.
    -- Check to see if salary basis exists for this element type.

    /* commented the below block for bug no : 6764215

    open csr_pay_basis_exists;
    fetch csr_pay_basis_exists into l_pay_basis_exists;
    if csr_pay_basis_exists%found then
      close csr_pay_basis_exists;
      fnd_message.set_name('PAY', 'PAY_33093_LINK_NO_PAY_BASIS');
      fnd_message.raise_error;
    end if;
    close csr_pay_basis_exists;

    */
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);

end chk_standard_link_flag;

--
--  ---------------------------------------------------------------------------
--  |------------------------<chk_date_eff_delete>----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_date_eff_delete
  (p_element_link_id in number,
   p_delete_mode in varchar2,
   p_validation_start_date in date
 ) is
--
  l_proc   varchar2(72) := g_package || 'chk_date_eff_delete';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  pay_element_links_pkg.check_deletion_allowed(p_element_link_id,p_delete_mode,
                                               p_validation_start_date);

  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_date_eff_delete;

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_pel_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pel_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --

  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  --

  if p_rec.standard_link_flag = 'Y'
  then
    pay_pel_bus.chk_standard_link_flag
    (p_element_type_id    => p_rec.element_type_id
    ,p_business_group_id  => p_rec.business_group_id
    ,p_element_link_id    => p_rec.element_link_id
    ,p_standard_link_flag => p_rec.standard_link_flag
    ,p_effective_date     => p_effective_date
    ,p_datetrack_mode     => p_datetrack_mode
    );
  end if;

  pay_pel_bus.chk_ben_contri
  (p_element_type_id 	  => p_rec.element_type_id
  ,p_effective_start_date => p_effective_date
  );

  pay_pel_bus.chk_emp_cat
  (p_employment_category	=> p_rec.employment_category,
   p_effective_date 	        => p_effective_date
  );


  if p_rec.job_id is not null then
    pay_pel_bus.chk_job_id
    (p_business_group_id 	=> p_rec.business_group_id,
     p_job_id 			=> p_rec.job_id,
     p_effective_date   	=> p_effective_date
   );
  end if;

  if p_rec.organization_id is not null then
    chk_org_unit
      (p_business_group_id  => p_rec.business_group_id
      ,p_organization_id    => p_rec.organization_id
      ,p_effective_date     => p_effective_date
      );
  end if;

  if p_rec.grade_id is not null then
     pay_pel_bus.chk_grade_id
    (p_business_group_id => p_rec.business_group_id,
     p_grade_id          => p_rec.grade_id,
     p_effective_date    => p_effective_date
    );
  end if;

  if p_rec.people_group_id is not null then
     pay_pel_bus.chk_people_group_id
     (p_people_group_id => p_rec.people_group_id,
      p_effective_date  => p_effective_date
     );
  end if;


  if p_rec.position_id is not null then
    pay_pel_bus.chk_position
    (p_business_group_id => p_rec.business_group_id
    ,p_position_id 	=> p_rec.position_id
    ,p_organization_id 	=> p_rec.organization_id
    ,p_job_id 		=> p_rec.job_id
    ,p_effective_date   => p_effective_date
    );
  end if;

  pay_pel_bus.chk_linktoallpr
  (p_link_to_all_payrolls_flag 	=> p_rec.link_to_all_payrolls_flag
  ,p_payroll_id 		=> p_rec.payroll_id
  );

  pay_pel_bus.chk_costable_type
  (p_effective_date             => p_effective_date
  ,p_element_link_id 		=> p_rec.element_link_id
  ,p_business_group_id 		=> p_rec.business_group_id
  ,p_element_type_id 		=> p_rec.element_type_id
  ,p_costable_type 		=> p_rec.costable_type
  ,p_element_set_id		=> p_rec.element_set_id
  ,p_transfer_to_gl 		=> p_rec.transfer_to_gl_flag
  ,p_balancing_keyflex_id 	=> p_rec.balancing_keyflex_id
  ,p_cost_allocation_keyflex_id => p_rec.cost_allocation_keyflex_id
  );


end insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_pel_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';

  l_qualifying_age                pay_element_links_f.qualifying_age%TYPE;
  l_qualifying_length_of_service
                     pay_element_links_f.qualifying_length_of_service%TYPE;
  l_qualifying_units           pay_element_links_f.qualifying_units%TYPE;
  l_multiply_value_flag        pay_element_links_f.multiply_value_flag%TYPE;
  l_standard_link_flag         pay_element_links_f.standard_link_flag%TYPE;


--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pel_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  -- Call the datetrack update integrity operation
  --
  dt_update_validate
    (p_payroll_id                     => p_rec.payroll_id
    ,p_element_type_id                => p_rec.element_type_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  -- Bug 5512101. Batch Element Link support.
  -- Ensure that the element link is complete.
  --
  pay_batch_object_status_pkg.chk_complete_status
    (p_object_type                  => 'EL'
    ,p_object_id                    => p_rec.element_link_id
    );

  -- Check for Standard link flag update
  pay_pel_bus.chk_standard_link_flag
    (p_element_type_id    => p_rec.element_type_id
    ,p_business_group_id  => p_rec.business_group_id
    ,p_element_link_id    => p_rec.element_link_id
    ,p_standard_link_flag => p_rec.standard_link_flag
    ,p_effective_date     => p_effective_date
    ,p_datetrack_mode     => p_datetrack_mode
    );

  -- Check for Costable type updation
  pay_pel_bus.chk_costable_type_for_upd
  (p_costable_type  => p_rec.costable_type ,
   p_datetrack_mode => p_datetrack_mode);

  -- Check qualifying conditions

  l_qualifying_age               := p_rec.qualifying_age;
  l_qualifying_length_of_service := p_rec.qualifying_length_of_service;
  l_qualifying_units             := p_rec.qualifying_units;
  l_multiply_value_flag          := p_rec.multiply_value_flag;
  l_standard_link_flag           := p_rec.standard_link_flag;


  pay_pel_bus.chk_defaults
  (p_element_type_id              => null
  ,p_qualifying_age               => l_qualifying_age
  ,p_qualifying_length_of_service => l_qualifying_length_of_service
  ,p_qualifying_units             => l_qualifying_units
  ,p_multiply_value_flag          => l_multiply_value_flag
  ,p_standard_link_flag           => l_standard_link_flag
  ,p_effective_date		  => p_effective_date
  );



  -- Check for general checks for costable type
  pay_pel_bus.chk_costable_type
  (p_effective_date             => p_effective_date,
   p_element_link_id 		=> p_rec.element_link_id,
   p_business_group_id 		=> p_rec.business_group_id,
   p_element_type_id 		=> p_rec.element_type_id,
   p_costable_type 		=> p_rec.costable_type ,
   p_element_set_id		=> p_rec.element_set_id,
   p_transfer_to_gl 		=> p_rec.transfer_to_gl_flag ,
   p_balancing_keyflex_id 	=> p_rec.balancing_keyflex_id ,
   p_cost_allocation_keyflex_id => p_rec.cost_allocation_keyflex_id
  );
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_pel_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  dt_delete_validate
    (p_datetrack_mode                   => p_datetrack_mode
    ,p_validation_start_date            => p_validation_start_date
    ,p_validation_end_date              => p_validation_end_date
    ,p_element_link_id                  => p_rec.element_link_id
    );

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_pel_bus;

/
