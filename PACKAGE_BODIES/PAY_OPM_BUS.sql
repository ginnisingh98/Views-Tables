--------------------------------------------------------
--  DDL for Package Body PAY_OPM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_OPM_BUS" as
/* $Header: pyopmrhi.pkb 120.4 2005/11/07 01:38:13 pgongada noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_opm_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_org_payment_method_id       number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_org_payment_method_id                in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_org_payment_methods_f opm
     where opm.org_payment_method_id = p_org_payment_method_id
       and pbg.business_group_id = opm.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
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
    ,p_argument           => 'org_payment_method_id'
    ,p_argument_value     => p_org_payment_method_id
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
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
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
  (p_org_payment_method_id                in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pay_org_payment_methods_f opm
     where opm.org_payment_method_id = p_org_payment_method_id
       and pbg.business_group_id = opm.business_group_id;
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
    ,p_argument           => 'org_payment_method_id'
    ,p_argument_value     => p_org_payment_method_id
    );
  --
  if ( nvl(pay_opm_bus.g_org_payment_method_id, hr_api.g_number)
       = p_org_payment_method_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_opm_bus.g_legislation_code;
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
    pay_opm_bus.g_org_payment_method_id:= p_org_payment_method_id;
    pay_opm_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in pay_opm_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.org_payment_method_id is not null)  and (
    nvl(pay_opm_shd.g_old_rec.pmeth_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information_category, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information1, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information2, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information3, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information4, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information5, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information6, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information7, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information8, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information9, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information10, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information11, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information12, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information13, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information14, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information15, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information16, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information17, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information18, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information19, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.pmeth_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pmeth_information20, hr_api.g_varchar2) ))
    or (p_rec.org_payment_method_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Paymeth Developer DF'
      ,p_attribute_category              => p_rec.PMETH_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'PMETH_INFORMATION1'
      ,p_attribute1_value                => p_rec.pmeth_information1
      ,p_attribute2_name                 => 'PMETH_INFORMATION2'
      ,p_attribute2_value                => p_rec.pmeth_information2
      ,p_attribute3_name                 => 'PMETH_INFORMATION3'
      ,p_attribute3_value                => p_rec.pmeth_information3
      ,p_attribute4_name                 => 'PMETH_INFORMATION4'
      ,p_attribute4_value                => p_rec.pmeth_information4
      ,p_attribute5_name                 => 'PMETH_INFORMATION5'
      ,p_attribute5_value                => p_rec.pmeth_information5
      ,p_attribute6_name                 => 'PMETH_INFORMATION6'
      ,p_attribute6_value                => p_rec.pmeth_information6
      ,p_attribute7_name                 => 'PMETH_INFORMATION7'
      ,p_attribute7_value                => p_rec.pmeth_information7
      ,p_attribute8_name                 => 'PMETH_INFORMATION8'
      ,p_attribute8_value                => p_rec.pmeth_information8
      ,p_attribute9_name                 => 'PMETH_INFORMATION9'
      ,p_attribute9_value                => p_rec.pmeth_information9
      ,p_attribute10_name                => 'PMETH_INFORMATION10'
      ,p_attribute10_value               => p_rec.pmeth_information10
      ,p_attribute11_name                => 'PMETH_INFORMATION11'
      ,p_attribute11_value               => p_rec.pmeth_information11
      ,p_attribute12_name                => 'PMETH_INFORMATION12'
      ,p_attribute12_value               => p_rec.pmeth_information12
      ,p_attribute13_name                => 'PMETH_INFORMATION13'
      ,p_attribute13_value               => p_rec.pmeth_information13
      ,p_attribute14_name                => 'PMETH_INFORMATION14'
      ,p_attribute14_value               => p_rec.pmeth_information14
      ,p_attribute15_name                => 'PMETH_INFORMATION15'
      ,p_attribute15_value               => p_rec.pmeth_information15
      ,p_attribute16_name                => 'PMETH_INFORMATION16'
      ,p_attribute16_value               => p_rec.pmeth_information16
      ,p_attribute17_name                => 'PMETH_INFORMATION17'
      ,p_attribute17_value               => p_rec.pmeth_information17
      ,p_attribute18_name                => 'PMETH_INFORMATION18'
      ,p_attribute18_value               => p_rec.pmeth_information18
      ,p_attribute19_name                => 'PMETH_INFORMATION19'
      ,p_attribute19_value               => p_rec.pmeth_information19
      ,p_attribute20_name                => 'PMETH_INFORMATION20'
      ,p_attribute20_value               => p_rec.pmeth_information20
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
  (p_rec in pay_opm_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.org_payment_method_id is not null)  and (
    nvl(pay_opm_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pay_opm_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.org_payment_method_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'PAY_ORG_PAYMENT_METHODS'
      ,p_attribute_category              => p_rec.ATTRIBUTE_CATEGORY
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
  ,p_rec             in pay_opm_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  hr_utility.set_location(l_proc, 5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_opm_shd.api_updating
      (p_org_payment_method_id            => p_rec.org_payment_method_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     pay_opm_shd.g_old_rec.business_group_id then
     l_argument := 'business_group_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  if nvl(p_rec.payment_type_id, hr_api.g_number) <>
     pay_opm_shd.g_old_rec.payment_type_id then
     l_argument := 'payment_type_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.defined_balance_id, hr_api.g_number) <>
     nvl(pay_opm_shd.g_old_rec.defined_balance_id, hr_api.g_number) then
     l_argument := 'defined_balance_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 35);
  --
  if nvl(p_rec.org_payment_method_name, hr_api.g_varchar2) <>
     nvl(pay_opm_shd.g_old_rec.org_payment_method_name, hr_api.g_varchar2) then
     l_argument := 'org_payment_method_name';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
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
  l_integrity_error Exception;
  l_table_name      all_tables.table_name%TYPE;
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
  When l_integrity_error Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
  (p_org_payment_method_id            in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc	varchar2(72) 	:= g_package||'dt_delete_validate';
  l_rows_exist	Exception;
  l_table_name	all_tables.table_name%TYPE;
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
      ,p_argument       => 'org_payment_method_id'
      ,p_argument_value => p_org_payment_method_id
      );
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_org_pay_method_usages_f'
       ,p_base_key_column => 'org_payment_method_id'
       ,p_base_key_value  => p_org_payment_method_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         l_table_name := 'org pay method usages';
         Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_personal_payment_methods_f'
       ,p_base_key_column => 'org_payment_method_id'
       ,p_base_key_value  => p_org_payment_method_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         l_table_name := 'personal payment methods';
         Raise l_rows_exist;
    End If;
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_run_type_org_methods_f'
       ,p_base_key_column => 'org_payment_method_id'
       ,p_base_key_value  => p_org_payment_method_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
         l_table_name := 'run type org methods';
         Raise l_rows_exist;
    End If;
    -- If (dt_api.rows_exist
    --    (p_base_table_name => 'pay_all_payrolls_f'
    --    ,p_base_key_column => 'default_payment_method_id'
    --    ,p_base_key_value  => p_org_payment_method_id
    --    ,p_from_date       => p_validation_start_date
    --    ,p_to_date         => p_validation_end_date
    --    )) Then
    --      l_table_name := 'payrolls';
    --      Raise l_rows_exist;
    -- End If;
    --
  End If;
  --
Exception
  When l_rows_exist Then
    --
    -- A referential integrity check was violated therefore
    -- we must error
    --
    fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
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
-- |----------------------< chk_external_account_id >-------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Check that the external_account_id is not null and that it refers to a
--    row on the parent PAY_EXTERNAL_ACCOUNTS table.
--    Also cross validate the TERRITORY_CODE with that of Payment Type's.
--
--    If there is more than one payment methods with the given category
--    then it can be null.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_external_account_id
--    p_payment_type_id
--    p_business_group_id
--    p_effective_date
--    p_org_payment_method_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the external_account_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the external_account_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_external_account_id
  (p_external_account_id   in pay_org_payment_methods_f.external_account_id%TYPE
  ,p_payment_type_id       in pay_org_payment_methods_f.payment_type_id%TYPE
  ,p_business_group_id     in pay_org_payment_methods_f.business_group_id%TYPE
  ,p_effective_date        in date
  ,p_org_payment_method_id in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ,p_object_version_number in pay_org_payment_methods_f.object_version_number%TYPE
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_external_account_id';
  l_api_updating boolean;
  l_dummy        number;
  --
  cursor csr_ext_acc_id_exists is
    select null
      from pay_external_accounts exa
     where exa.external_account_id = p_external_account_id
       and exists
             (select null
                from pay_payment_types pty
               where pty.payment_type_id = p_payment_type_id
                 and ((pty.territory_code is not null
                       and pty.territory_code = exa.territory_code)
                      or (pty.territory_code is null
                          and exists
                                (select null
                                   from per_business_groups pbg
                                  where pbg.business_group_id = p_business_group_id
                                    and pbg.legislation_code = exa.territory_code))));
--
  cursor csr_ext_chk is
    select count (*)
      from pay_org_payment_methods_f pop,
           pay_payment_types pyt
     where pop.payment_type_id = pyt.payment_type_id
       and pyt.category =
           ( select pyt.category
               from pay_payment_types pyt
              where pyt.payment_type_id = p_payment_type_id)
       and (p_org_payment_method_id is null
           or pop.org_payment_method_id <> p_org_payment_method_id )
       and pop.external_account_id is not null
       and p_effective_date between pop.effective_start_date and pop.effective_end_date
       and pop.business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --    Check mandatory external_account_id exists
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'payment_type_id'
    ,p_argument_value               => p_payment_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'business_group_id'
    ,p_argument_value               => p_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                   => l_proc
    ,p_argument                   => 'effective_date'
    ,p_argument_value             => p_effective_date
    );
  --
  open csr_ext_chk;
  fetch csr_ext_chk into l_dummy;
  close csr_ext_chk;
  --
  if p_external_account_id is null and l_dummy > 2 then
     return;
  end if;
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'external_account_id'
    ,p_argument_value               => p_external_account_id
    );
  --
  l_api_updating := pay_opm_shd.api_updating
    (p_effective_date          => p_effective_date,
     p_org_payment_method_id   => p_org_payment_method_id,
     p_object_version_number   => p_object_version_number
    );
  --
  hr_utility.set_location(l_proc,10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_opm_shd.g_old_rec.external_account_id,hr_api.g_number) <>
       nvl(p_external_account_id,hr_api.g_number))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,20);
     --
     --  Check external_account_id exists within PAY_EXTERNAL_ACCOUNTS.
     --  Also it check the territory_code of the PAY_EXTERNAL_ACCOUNTS.
     --
     open csr_ext_acc_id_exists;
     fetch csr_ext_acc_id_exists into l_dummy;
     if csr_ext_acc_id_exists%notfound then
        close csr_ext_acc_id_exists;
        pay_opm_shd.constraint_error('PAY_ORG_PAYMENT_METHODS_F_FK2');
     end if;
     close csr_ext_acc_id_exists;
     --
     hr_utility.set_location(l_proc,30);
     --
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_external_account_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_currency_code >----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Check that the currency_code is not null and that it refers to a
--    row on the FND_CURRENCIES_VL table.
--    Check whether it is same as of Payment type's (only if it is not null).
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_currency_code
--    p_payment_type_id
--    p_effective_date
--    p_org_payment_method_id
--    p_object_version_number
--
--  Post Success:
--    Processing continues if the currency_code is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the currency_code is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_currency_code
  (p_currency_code         in pay_org_payment_methods_f.currency_code%TYPE
  ,p_payment_type_id       in pay_org_payment_methods_f.payment_type_id%TYPE
  ,p_effective_date        in date
  ,p_org_payment_method_id in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ,p_object_version_number in pay_org_payment_methods_f.object_version_number%TYPE
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_currency_code';
  l_api_updating boolean;
  l_dummy        number;
  --
  cursor csr_currency_code_exists is
    select null
      from fnd_currencies_vl cur
     where cur.enabled_flag = 'Y'
       and cur.currency_flag = 'Y'
       and p_effective_date between nvl(start_date_active,p_effective_date)
           and nvl(end_date_active,p_effective_date)
       and exists
             (select null
                from pay_payment_types pty
               where pty.payment_type_id = p_payment_type_id
                 and (pty.currency_code is null
                      or (pty.currency_code is not null
                          and pty.currency_code = p_currency_code)));
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --    Check mandatory currency_code exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'currency_code'
    ,p_argument_value               => p_currency_code
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'payment_type_id'
    ,p_argument_value               => p_payment_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                   => l_proc
    ,p_argument                   => 'effective_date'
    ,p_argument_value             => p_effective_date
    );
  --
  l_api_updating := pay_opm_shd.api_updating
    (p_effective_date          => p_effective_date,
     p_org_payment_method_id   => p_org_payment_method_id,
     p_object_version_number   => p_object_version_number
    );
  --
  hr_utility.set_location(l_proc,10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_opm_shd.g_old_rec.currency_code,hr_api.g_varchar2) <>
       nvl(p_currency_code,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,20);
     --
     --  Check currency_code exists within FND_CURRENCIES_VL.
     --  Also checks whether Paymen Type's
     --
     open csr_currency_code_exists;
     fetch csr_currency_code_exists into l_dummy;
     if csr_currency_code_exists%notfound then
        close csr_currency_code_exists;
        -- RAISE ERROR MESSAGE
        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'CURRENCY_CODE');
        fnd_message.raise_error;
     end if;
     close csr_currency_code_exists;
     --
     hr_utility.set_location(l_proc,30);
     --
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_currency_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_payment_type_id >---------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Check that the payment_type_id is not null and that it refers to a
--    row on the parent PAY_PAYMENT_TYPES table.
--    Also cross validate whether this is a valid Payment Type for the
--    business group.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_payment_type_id
--    p_business_group_id
--    p_org_payment_method_id
--
--  Post Success:
--    Processing continues if the payment_type_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the payment_type_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_payment_type_id
  (p_payment_type_id       in pay_org_payment_methods_f.payment_type_id%TYPE
  ,p_business_group_id     in pay_org_payment_methods_f.business_group_id%TYPE
  ,p_org_payment_method_id in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_payment_type_id';
  l_dummy        number;
  --
  cursor csr_pay_type_id_exists is
    select null
      from pay_payment_types pyt
     where pyt.payment_type_id = p_payment_type_id
       and ((pyt.territory_code is null)
            or exists
            (select null
               from pay_legislation_rules lgr
              where lgr.legislation_code = pyt.territory_code
                and lgr.rule_type = 'E'))
       and not exists
            (select 'x'
               from pay_payment_types pyt2,
                    per_business_groups pbg
              where pyt2.category = pyt.category
                and pbg.business_group_id = p_business_group_id
                and pyt2.territory_code = pbg.legislation_code
                and pyt.territory_code is null
                and pyt2.payment_type_id <> pyt.payment_type_id);
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --    Check mandatory payment_type_id exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'payment_type_id'
    ,p_argument_value               => p_payment_type_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'business_group_id'
    ,p_argument_value               => p_business_group_id
    );
  --
  --
  hr_utility.set_location(l_proc,10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (p_org_payment_method_id is null) then
     --
     hr_utility.set_location(l_proc,20);
     --
     --  Check payment_type_id is a valid entry within PAY_PAYMENT_TYPES.
     --
     open csr_pay_type_id_exists;
     fetch csr_pay_type_id_exists into l_dummy;
     if csr_pay_type_id_exists%notfound then
        close csr_pay_type_id_exists;
        -- RAISE ERROR MESSAGE
        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'PAYMENT_TYPE_ID');
        fnd_message.raise_error;
     end if;
     close csr_pay_type_id_exists;
     --
     hr_utility.set_location(l_proc,30);
     --
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_payment_type_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_defined_balance_id >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Check that the defined_balance_id is not null and that it refers to a
--    row on the parent PAY_DEFINED_BALANCES table.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_defined_balance_id
--    p_business_group_id
--    p_org_payment_method_id
--
--  Post Success:
--    Processing continues if the defined_balance_id is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the defined_balance_id is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_defined_balance_id
  (p_defined_balance_id    in pay_org_payment_methods_f.defined_balance_id%TYPE
  ,p_business_group_id     in pay_org_payment_methods_f.business_group_id%TYPE
  ,p_org_payment_method_id in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_defined_balance_id';
  l_dummy        number;
  --
  cursor csr_def_bal_id_exists is
              select  db.defined_balance_id
                from  pay_defined_balances db,
                      pay_balance_dimensions bd,
         	      pay_balance_types bt
               where  nvl(db.business_group_id,p_business_group_id) = p_business_group_id
                 and  ((db.legislation_code is null)
                       or exists
                          (select null
                             from per_business_groups pbg
                            where pbg.business_group_id = p_business_group_id
                              and pbg.legislation_code = db.legislation_code))
                 and  db.balance_dimension_id = bd.balance_dimension_id
                 and  db.balance_type_id      = bt.balance_type_id
                 and  bd.payments_flag = 'Y'
                 and  bt.assignment_remuneration_flag = 'Y'
               order  by db.business_group_id,db.legislation_code;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --    Check mandatory defined_balance_id exists
  --
  -- hr_api.mandatory_arg_error
  --   (p_api_name                     => l_proc
  --   ,p_argument                     => 'defined_balance_id'
  --   ,p_argument_value               => p_defined_balance_id
  --   );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'business_group_id'
    ,p_argument_value               => p_business_group_id
    );
  --
  --
  hr_utility.set_location(l_proc,10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (p_org_payment_method_id is null and p_defined_balance_id is not null) then
     --
     hr_utility.set_location(l_proc,20);
     --
     --  Check payment_type_id is a valid entry within PAY_DEFINED_BALANCES.
     --
     open csr_def_bal_id_exists;
     fetch csr_def_bal_id_exists into l_dummy;
     if ((csr_def_bal_id_exists%notfound) or (l_dummy<>p_defined_balance_id)) then
        close csr_def_bal_id_exists;
        -- RAISE ERROR MESSAGE
        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'DEFINED_BALANCE_ID');
        fnd_message.raise_error;
     end if;
     close csr_def_bal_id_exists;
     --
     hr_utility.set_location(l_proc,30);
     --
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_defined_balance_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_org_payment_method_name >-----------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Check that the org_payment_method_name is not null.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_org_payment_method_name
--    p_business_group_id
--    p_org_payment_method_id
--
--  Post Success:
--    Processing continues if the org_payment_method_name is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the org_payment_method_name is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_org_payment_method_name
  (p_org_payment_method_name in pay_org_payment_methods_f.org_payment_method_name%TYPE
  ,p_business_group_id       in pay_org_payment_methods_f.business_group_id%TYPE
  ,p_org_payment_method_id   in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_org_payment_method_name';
  l_api_updating boolean;
  l_dummy        number;
  --
  cursor csr_org_pay_meth_name_exists is
     select  null
       from  pay_org_payment_methods_f opm
      where  upper(opm.org_payment_method_name) = upper(p_org_payment_method_name)
        and  (p_org_payment_method_id is null
             or p_org_payment_method_id <> opm.org_payment_method_id)
        and  opm.business_group_id = p_business_group_id;
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --    Check mandatory org_payment_method_name exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'org_payment_method_name'
    ,p_argument_value               => p_org_payment_method_name
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                   => l_proc
    ,p_argument                   => 'business_group_id'
    ,p_argument_value             => p_business_group_id
    );
  --
  hr_utility.set_location(l_proc,10);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if (p_org_payment_method_id is null) then
     --
     hr_utility.set_location(l_proc,20);
     --
     --
     open csr_org_pay_meth_name_exists;
     fetch csr_org_pay_meth_name_exists into l_dummy;
     if csr_org_pay_meth_name_exists%found then
        close csr_org_pay_meth_name_exists;
        -- RAISE ERROR MESSAGE
        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'ORG_PAYMENT_METHOD_NAME');
        fnd_message.raise_error;
     end if;
     close csr_org_pay_meth_name_exists;
     --
     hr_utility.set_location(l_proc,30);
     --
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_org_payment_method_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_pre_payment >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Description:
--    Checks whether there is any pre_payments exists from the validation date
--    onwards.
--
--  Pre-Requisites:
--    None
--
--  In Parameters:
--    p_validation_start_date
--    p_org_payment_method_id
--
--  Post Success:
--    Processing continues if the p_validation_start_date is valid.
--
--  Post Failure:
--    An application error is raised and processing is terminated if
--    the p_validation_start_date is invalid.
--
--  Access Status:
--    Internal Row Handler Use Only.
--
Procedure chk_pre_payment
  (p_validation_start_date   in date
  ,p_org_payment_method_id   in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ) is
--
  l_proc         varchar2(72) := g_package||'chk_pre_payment';
  l_api_updating boolean;
  l_dummy        number;
  --
  cursor csr_pre_payment_exists is
     select  null
       from  pay_pre_payments ppm
          ,  pay_assignment_actions paa
          ,  pay_payroll_actions ppa
      where  ppm.org_payment_method_id = p_org_payment_method_id
        and  ppm.assignment_action_id = paa.assignment_action_id
        and  paa.payroll_action_id = ppa.payroll_action_id
        and ppa.action_type in ('P', 'U')
        and  ppa.effective_date >= p_validation_start_date;
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  hr_api.mandatory_arg_error
    (p_api_name                   => l_proc
    ,p_argument                   => 'validation_start_date'
    ,p_argument_value             => p_validation_start_date
    );
  --
  hr_utility.set_location(l_proc,10);
  --
  --
     --
     --
     open csr_pre_payment_exists;
     fetch csr_pre_payment_exists into l_dummy;
     if csr_pre_payment_exists%found then
        close csr_pre_payment_exists;
        -- RAISE ERROR MESSAGE
        fnd_message.set_name('PAY', 'HR_6226_PAYM_PPS_EXIST');
        fnd_message.raise_error;
     end if;
     close csr_pre_payment_exists;
     --
     --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End chk_pre_payment;
-- ----------------------------------------------------------------------------
-- |---------------------< chk_costing_enabled >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   check the costing is enabled for the given legislation.
-------------------------------------------------------------------------------
procedure chk_costing_enabled
(
p_business_group_id		in	number
,p_transfer_to_gl_flag		in	varchar2
,p_cost_payment			in	varchar2
,p_cost_cleared_payment         in	varchar2
,p_cost_cleared_void_payment    in	varchar2
,p_exclude_manual_payment       in	varchar2
) is
--
l_proc             varchar2(72) := g_package||'chk_costing_enabled';
l_legislation_code varchar2(3);
l_flag             varchar2(1);
l_flag_name	   varchar2(30);
--
cursor csr_chk_leg_field_info is
   select lfi.rule_mode
     from pay_legislative_field_info lfi
    where lfi.validation_type = 'TAB_PAGE_PROPERTY'
      and lfi.validation_name = 'DISPLAY'
      and lfi.rule_type = 'DISPLAY'
      and lfi.field_name = 'COSTING_TAB'
      and lfi.target_location = 'PAYWSDPM'
      and lfi.legislation_code = l_legislation_code;
begin
	hr_utility.set_location(l_proc,10);
	--
	l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
	--
	open csr_chk_leg_field_info;
	fetch csr_chk_leg_field_info into l_flag;
	if (csr_chk_leg_field_info % NOTFOUND or
	    l_flag = 'N' or l_flag is null ) then
	--
	    if(NVL(p_transfer_to_gl_flag, 'N') = 'Y' or
               NVL(p_cost_payment, 'N') = 'Y' or
               NVL(p_cost_cleared_payment, 'N') = 'Y' or
               NVL(p_cost_cleared_void_payment, 'N') = 'Y' or
               NVL(p_exclude_manual_payment, 'N') = 'Y') then
	    --

			if NVL(p_transfer_to_gl_flag, 'N') = 'Y' then
				l_flag_name := 'P_TRANSFER_TO_GL_FLAG';
			elsif NVL(p_cost_payment, 'N') = 'Y' then
				l_flag_name := 'P_COST_PAYMENT';
			elsif NVL(p_cost_cleared_payment, 'N') = 'Y' then
				l_flag_name := 'P_COST_CLEARED_PAYMENT';
			elsif NVL(p_cost_cleared_void_payment, 'N') = 'Y' then
				l_flag_name := 'P_COST_CLEARED_VOID_PAYMENT';
			elsif NVL(p_exclude_manual_payment, 'N') = 'Y' then
				l_flag_name := 'P_EXCLUDE_MANUAL_PAYMENT';
			end if;

			fnd_message.set_name('PAY', 'PAY_34525_CST_FLAG_NT_ALLWD');
			fnd_message.set_token('CST_FLAG',l_flag_name);
			fnd_message.raise_error;
	    --
	    end if;
	 --
	 end if;
end chk_costing_enabled;
-- ----------------------------------------------------------------------------
-- |------------------------< chk_cost_payment >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   cost_payment if specified must be either 'Y' or 'N'.
-------------------------------------------------------------------------------
procedure chk_cost_payment
(
  p_effective_date            in date
 ,p_cost_payment              in varchar2
) is
begin
  if (p_cost_payment is not null) then
  --
	if hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_cost_payment) then
	--
		fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
		fnd_message.set_token('COLUMN','COST_PAYMENT');
		fnd_message.set_token('LOOKUP_TYPE','YES_NO');
		fnd_message.raise_error;
	--
	end If;
        --
  --
  end if;
end chk_cost_payment;
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_cost_cleared_payment >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   cost_payment_cleared if specified must be either 'Y' or 'N'.
--   It ensures that when cost_cleared_payment is 'Y' then the cost_payment
--   should be 'Y'.
-------------------------------------------------------------------------------
--
procedure chk_cost_cleared_payment
(
  p_effective_date            in date
 ,p_cost_cleared_payment      in varchar2
 ,p_cost_payment              in varchar2
) is
begin
  if(p_cost_cleared_payment is not null) then
  --
	if hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_cost_cleared_payment) then
	--
		fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
		fnd_message.set_token('COLUMN','COST_CLEARED_PAYMENT');
		fnd_message.set_token('LOOKUP_TYPE','YES_NO');
		fnd_message.raise_error;
	--
        end If;
	--
	if (p_cost_cleared_payment = 'Y') and (p_cost_payment <> 'Y') then
	--
		fnd_message.set_name('PAY', 'PAY_33415_CST_CLRCST_SYNC');
		fnd_message.set_token('PARAMETER1','COST_PAYMENT');
		fnd_message.set_token('PARAMETER2','COST_CLEARED_PAYMENT');
		fnd_message.raise_error;
	--
	end If;
   --
   end if;
end chk_cost_cleared_payment;
--
--
-- ----------------------------------------------------------------------------
-- |------------------< chk_cost_cleared_void_payment >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   cost_cleared_void_payment if specified must be either 'Y' or 'N'.
--   It ensures that when cost_cleared_void_payment is 'Y' then
--   cost_cleared_payment should set to 'Y'
-------------------------------------------------------------------------------
procedure chk_cost_cleared_void_payment
(
  p_effective_date            in date
 ,p_cost_cleared_void_payment in varchar2
 ,p_cost_cleared_payment      in varchar2
) is
begin
  if (p_cost_cleared_void_payment is not null) then
  --
	if hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_cost_cleared_void_payment) then
	--
		fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
		fnd_message.set_token('COLUMN','COST_CLEARED_VOID_PAYMENT');
		fnd_message.set_token('LOOKUP_TYPE','YES_NO');
		fnd_message.raise_error;
	--
	end If;
	--
	If ((p_cost_cleared_void_payment = 'Y') and (p_cost_cleared_payment <> 'Y')) then
	--
		fnd_message.set_name('PAY', 'PAY_33415_CST_CSTCLR_SYNC');
		fnd_message.set_token('PARAMETER1','COST_CLEARED_PAYMENT');
		fnd_message.set_token('PARAMETER2','COST_CLEARED_VOID_PAYMENT');
		fnd_message.raise_error;
	--
	end If;
  --
  end if;
end chk_cost_cleared_void_payment;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_exclude_manual_payment >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Exclude_manual_payment if specified must be either 'Y' or 'N'.
--   It ensures that when exclude_manual_payment is 'Y' then
--   cost_payment should set to 'Y'
-------------------------------------------------------------------------------
procedure chk_exclude_manual_payment
(
  p_effective_date		in date
 ,p_exclude_manual_payment	in varchar2
 ,p_cost_payment		in varchar2
) is
begin
  if (p_exclude_manual_payment  is not null) then
  --
	if hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_exclude_manual_payment) then
	--
		fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
		fnd_message.set_token('COLUMN','EXCLUDE_MANUAL_PAYMENT');
		fnd_message.set_token('LOOKUP_TYPE','YES_NO');
		fnd_message.raise_error;
	--
        end if;
	--
	If ((p_exclude_manual_payment = 'Y') and (p_cost_payment <> 'Y')) then
	--
		fnd_message.set_name('PAY', 'PAY_33415_CST_CSTCLR_SYNC');
		fnd_message.set_token('PARAMETER1','COST_PAYMENT');
		fnd_message.set_token('PARAMETER2','EXCLUDE_MANUAL_PAYMENT');
		fnd_message.raise_error;
	--
	end If;
  --
  end If;
end chk_exclude_manual_payment;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_transfer_to_gl_flag >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   transfer_to_gl_flag if specified must be either 'Y' or 'N'.
--   It ensures that when transfer_to_gl_flag is 'Y' then
--   cost_payment should set to 'Y'.
-------------------------------------------------------------------------------
procedure chk_transfer_to_gl_flag
(
  p_effective_date            in date
 ,p_transfer_to_gl_flag       in varchar2
 ,p_cost_payment	      in varchar2
) is
begin
  if(p_transfer_to_gl_flag is not null) then
  --
	if hr_api.not_exists_in_hr_lookups
	(p_effective_date
	,'YES_NO'
	,p_transfer_to_gl_flag) then
	--
		fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
		fnd_message.set_token('COLUMN','TRANSFER_TO_GL_FLAG');
		fnd_message.set_token('LOOKUP_TYPE','YES_NO');
		fnd_message.raise_error;
	--
	end If;
	--
	If ((p_transfer_to_gl_flag = 'Y') and (p_cost_payment <> 'Y')) then
	--
		fnd_message.set_name('PAY', 'PAY_33415_CST_CSTCLR_SYNC');
		fnd_message.set_token('PARAMETER1','COST_PAYMENT');
		fnd_message.set_token('PARAMETER2','TRANSFER_TO_GL_FLAG');
		fnd_message.raise_error;
	--
	end If;
  --
  end if;
--
end chk_transfer_to_gl_flag;
--
--
-- ---------------------------------------------------------------------------
-- |-------------------------------< chk_delete >----------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Check if there is no child row exists in
--    PAY_ORG_PAYMENT_METHODS_TL,
--    PAY_ORG_METHOD_USAGES_F,
--    PAY_PRE_PAYMENTS,
--    PAY_RUN_TYPE_ORG_METHODS,
--    PAY_PAYROLL_ACTIONS,
--    PAY_ALL_PAYROLLS_F,
--    and
--    PAY_PERSONAL_PAYMENT_METHODS_F
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_org_payment_method_id
--    p_effective_date
--    p_business_group_id
--    p_datetrack_mode
--    p_validation_start_date
--    p_validation_end_date
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_delete
  (p_org_payment_method_id     in pay_org_payment_methods_f.org_payment_method_id%TYPE
  ,p_business_group_id         in pay_org_payment_methods_f.business_group_id%TYPE
  ,p_datetrack_mode            in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_exists   varchar2(1);
--
  cursor csr_pre_payment_exists is
    select null
    from   pay_pre_payments ppt,
           pay_assignment_actions paa,
           pay_payroll_actions ppa
    where  ppt.org_payment_method_id = p_org_payment_method_id
    and    ppt.assignment_action_id = paa.assignment_action_id
    and    paa.payroll_action_id = ppa.payroll_action_id
    and    (p_datetrack_mode = hr_api.g_zap
           or (p_datetrack_mode = hr_api.g_delete
               and p_effective_date < ppa.effective_date));
--
  cursor csr_org_pay_methods_tl_exists is
    select null
    from   pay_org_payment_methods_f_tl opt
    where  opt.org_payment_method_id = p_org_payment_method_id
    and    p_datetrack_mode = hr_api.g_zap;
--
  cursor csr_payroll_actions_exists is
    select null
    from   pay_payroll_actions ppa
    where  ppa.org_payment_method_id = p_org_payment_method_id
    and    (p_datetrack_mode = hr_api.g_zap
           or (p_datetrack_mode = hr_api.g_delete
               and p_effective_date < ppa.effective_date));
--
  cursor csr_payrolls_exists is
    select null
    from   pay_all_payrolls_f ppa
    where  ppa.default_payment_method_id = p_org_payment_method_id
    and    ppa.business_group_id = p_business_group_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
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
    -- Ensure the arguments are not null
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'effective_date'
      ,p_argument_value => p_effective_date
      );
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'business_group_id'
      ,p_argument_value => p_business_group_id
      );
    --
    --
    open csr_pre_payment_exists;
    --
    fetch csr_pre_payment_exists into l_exists;
    --
    If csr_pre_payment_exists%found Then
      --
      close csr_pre_payment_exists;
      --
      fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
      fnd_message.set_token('TABLE_NAME', 'PAY_PRE_PAYMENTS');
      fnd_message.raise_error;
      --
    End If;
    --
    close csr_pre_payment_exists;
    --
    hr_utility.set_location(l_proc, 10);
    --
    --
    open csr_org_pay_methods_tl_exists;
    --
    fetch csr_org_pay_methods_tl_exists into l_exists;
    --
    If csr_org_pay_methods_tl_exists%found Then
      --
      close csr_org_pay_methods_tl_exists;
      --
      fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
      fnd_message.set_token('TABLE_NAME', 'PAY_ORG_PAYMENT_METHODS_F_TL');
      fnd_message.raise_error;
      --
    End If;
    --
    close csr_org_pay_methods_tl_exists;
    --
    hr_utility.set_location(l_proc, 20);
    --
    --
    open csr_payroll_actions_exists;
    --
    fetch csr_payroll_actions_exists into l_exists;
    --
    If csr_payroll_actions_exists%found Then
      --
      close csr_payroll_actions_exists;
      --
      fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
      fnd_message.set_token('TABLE_NAME', 'PAY_PAYROLL_ACTIONS');
      fnd_message.raise_error;
      --
    End If;
    --
    close csr_payroll_actions_exists;
    --
    hr_utility.set_location(l_proc, 30);
    --
    --
  End If;
  --
  open csr_payrolls_exists;
  --
  fetch csr_payrolls_exists into l_exists;
  --
  If csr_payrolls_exists%found Then
    --
    close csr_payrolls_exists;
    --
    if (p_datetrack_mode = hr_api.g_zap) then
       fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
       fnd_message.set_token('TABLE_NAME', 'PAY_ALL_PAYROLLS_F');
       fnd_message.raise_error;
    else
       fnd_message.set_name('PAY','HR_6739_PAYM_NO_METH');
       fnd_message.raise_error;
    end if;
    --
  End If;
  --
  close csr_payrolls_exists;
  --
  hr_utility.set_location(l_proc, 35);
  --
  --Bug No. 4644827
  If ( pay_maintain_bank_acct.chk_account_exists(
            p_org_payment_method_id    =>p_org_payment_method_id,
            p_validation_start_date    =>p_validation_start_date,
            p_validation_end_date      =>p_validation_end_date
           ))Then
    --
    fnd_message.set_name('PAY', 'PAY_52999_METHOD_USED_FOR_CE');
    fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in pay_opm_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc	varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  hr_utility.set_location(l_proc,10);
  --
  pay_opm_bus.chk_external_account_id(p_external_account_id => p_rec.external_account_id
                                     ,p_payment_type_id => p_rec.payment_type_id
                                     ,p_business_group_id => p_rec.business_group_id
                                     ,p_effective_date => p_effective_date
                                     ,p_org_payment_method_id => p_rec.org_payment_method_id
                                     ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,15);
  --
  pay_opm_bus.chk_currency_code(p_currency_code => p_rec.currency_code
                               ,p_payment_type_id => p_rec.payment_type_id
                               ,p_effective_date => p_effective_date
                               ,p_org_payment_method_id => p_rec.org_payment_method_id
                               ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  --
  pay_opm_bus.chk_payment_type_id(p_payment_type_id => p_rec.payment_type_id
                                 ,p_business_group_id => p_rec.business_group_id
                                 ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc,25);
  --
  pay_opm_bus.chk_defined_balance_id(p_defined_balance_id => p_rec.defined_balance_id
                                    ,p_business_group_id => p_rec.business_group_id
                                    ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc,30);
  --
  pay_opm_bus.chk_org_payment_method_name(p_org_payment_method_name => p_rec.org_payment_method_name
                                          ,p_business_group_id => p_rec.business_group_id
                                          ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc,35);
  --
  pay_opm_bus.chk_costing_enabled(p_business_group_id		=> p_rec.business_group_id
				 ,p_transfer_to_gl_flag		=> p_rec.transfer_to_gl_flag
				 ,p_cost_payment		=> p_rec.cost_payment
				 ,p_cost_cleared_payment        => p_rec.cost_cleared_payment
				 ,p_cost_cleared_void_payment   => p_rec.cost_cleared_void_payment
				 ,p_exclude_manual_payment      => p_rec.exclude_manual_payment);
  --
  hr_utility.set_location(l_proc,40);
  --
  pay_opm_bus.chk_cost_payment(p_effective_date => p_effective_date
			      ,p_cost_payment => NVL(p_rec.cost_payment, 'N'));
  --
  hr_utility.set_location(l_proc,45);
  --
  pay_opm_bus.chk_cost_cleared_payment(p_effective_date => p_effective_date
				      ,p_cost_cleared_payment => NVL(p_rec.cost_cleared_payment, 'N')
				      ,p_cost_payment => NVL(p_rec.cost_payment,'N'));
  --
  hr_utility.set_location(l_proc,50);
  --
  pay_opm_bus.chk_cost_cleared_void_payment(p_effective_date => p_effective_date
			      ,p_cost_cleared_void_payment => NVL(p_rec.cost_cleared_void_payment, 'N')
			      ,p_cost_cleared_payment      => NVL(p_rec.cost_cleared_payment,'N'));
  --
  hr_utility.set_location(l_proc,55);
  --
  pay_opm_bus.chk_exclude_manual_payment(p_effective_date => p_effective_date
			      ,p_exclude_manual_payment => NVL(p_rec.exclude_manual_payment, 'N')
			      ,p_cost_payment => NVL(p_rec.cost_payment, 'N'));
  --
  hr_utility.set_location(l_proc,60);
  --
  pay_opm_bus.chk_transfer_to_gl_flag(p_effective_date => p_effective_date
				,p_transfer_to_gl_flag => NVL(p_rec.transfer_to_gl_flag,'N')
				,p_cost_payment => NVL(p_rec.cost_payment, 'N'));
  --
  pay_opm_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc,70);
  --
  pay_opm_bus.chk_df(p_rec);
  --
  hr_utility.set_location(l_proc,75);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in pay_opm_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc	varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
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
  --
  hr_utility.set_location(l_proc,10);
  --
  pay_opm_bus.chk_external_account_id(p_external_account_id => p_rec.external_account_id
                                     ,p_payment_type_id => p_rec.payment_type_id
                                     ,p_business_group_id => p_rec.business_group_id
                                     ,p_effective_date => p_effective_date
                                     ,p_org_payment_method_id => p_rec.org_payment_method_id
                                     ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,15);
  --
  pay_opm_bus.chk_currency_code(p_currency_code => p_rec.currency_code
                               ,p_payment_type_id => p_rec.payment_type_id
                               ,p_effective_date => p_effective_date
                               ,p_org_payment_method_id => p_rec.org_payment_method_id
                               ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  --
  pay_opm_bus.chk_pre_payment(p_validation_start_date => p_validation_start_date
                             ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  --
  hr_utility.set_location(l_proc,25);
  --
  pay_opm_bus.chk_costing_enabled(p_business_group_id		=> p_rec.business_group_id
				 ,p_transfer_to_gl_flag		=> p_rec.transfer_to_gl_flag
				 ,p_cost_payment		=> p_rec.cost_payment
				 ,p_cost_cleared_payment        => p_rec.cost_cleared_payment
				 ,p_cost_cleared_void_payment   => p_rec.cost_cleared_void_payment
				 ,p_exclude_manual_payment      => p_rec.exclude_manual_payment);
  --
  hr_utility.set_location(l_proc,30);
  --
  pay_opm_bus.chk_cost_payment(p_effective_date => p_effective_date
			      ,p_cost_payment => NVL(p_rec.cost_payment, 'N'));
  --
  hr_utility.set_location(l_proc,45);
  --
  pay_opm_bus.chk_cost_cleared_payment(p_effective_date => p_effective_date
				      ,p_cost_cleared_payment => NVL(p_rec.cost_cleared_payment, 'N')
				      ,p_cost_payment => NVL(p_rec.cost_payment, 'N'));
  --
  hr_utility.set_location(l_proc,50);
  --
  pay_opm_bus.chk_cost_cleared_void_payment(p_effective_date => p_effective_date
			      ,p_cost_cleared_void_payment => NVL(p_rec.cost_cleared_void_payment, 'N')
			      ,p_cost_cleared_payment      => NVL(p_rec.cost_cleared_payment, 'N'));
  --
  hr_utility.set_location(l_proc,55);
  --
  pay_opm_bus.chk_exclude_manual_payment(p_effective_date => p_effective_date
			      ,p_exclude_manual_payment => NVL(p_rec.exclude_manual_payment, 'N')
			      ,p_cost_payment => NVL(p_rec.cost_payment, 'N'));
  --
  hr_utility.set_location(l_proc,60);
  --
  pay_opm_bus.chk_transfer_to_gl_flag(p_effective_date => p_effective_date
				,p_transfer_to_gl_flag => NVL(p_rec.transfer_to_gl_flag, 'N')
				,p_cost_payment => NVL(p_rec.cost_payment,'N'));
  --
  hr_utility.set_location(l_proc,65);
  --
  pay_opm_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc,70);
  --
  pay_opm_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_opm_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc	varchar2(72) := g_package||'delete_validate';
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
    ,p_org_payment_method_id            => p_rec.org_payment_method_id
    );
  --
  pay_opm_bus.chk_delete(p_datetrack_mode => p_datetrack_mode
                        ,p_effective_date => p_effective_date
                        ,p_org_payment_method_id => p_rec.org_payment_method_id
                        ,p_business_group_id => p_rec.business_group_id
                        ,p_validation_start_date => p_validation_start_date
                        ,p_validation_end_date => p_validation_end_date);
  --
  pay_opm_bus.chk_pre_payment(p_validation_start_date => p_validation_start_date
                             ,p_org_payment_method_id => p_rec.org_payment_method_id);
  --
  hr_utility.set_location(l_proc,30);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_opm_bus;

/
