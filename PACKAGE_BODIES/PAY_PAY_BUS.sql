--------------------------------------------------------
--  DDL for Package Body PAY_PAY_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAY_BUS" as
/* $Header: pypayrhi.pkb 120.0.12000000.3 2007/03/08 09:23:27 mshingan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pay_bus.';  -- Global package name
g_exists  varchar2(1);

--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_payroll_id                  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_payroll_id                           in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_all_payrolls_f pay
     where pay.payroll_id = p_payroll_id
       and pbg.business_group_id = pay.business_group_id;
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
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'payroll_id'
    ,p_argument_value     => p_payroll_id
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
         => nvl(p_associated_column1,'PAYROLL_ID')
       );
  --
  else
  --
    close csr_sec_grp;
    --
    -- Set the security_group_id in CLIENT_INFO
    --
    hr_api.set_security_group_id(p_security_group_id => l_security_group_id );
    --
    -- Set the sessions legislation context in HR_SESSION_DATA
    --
    hr_api.set_legislation_context(l_legislation_code);
  --
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
  (p_payroll_id                           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , pay_all_payrolls_f pay
     where pay.payroll_id = p_payroll_id
       and pbg.business_group_id = pay.business_group_id;
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
    ,p_argument           => 'payroll_id'
    ,p_argument_value     => p_payroll_id
    );
  --
  if ( nvl(pay_pay_bus.g_payroll_id, hr_api.g_number) = p_payroll_id) then
  --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_pay_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  --
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
    --
    end if;
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_pay_bus.g_payroll_id        := p_payroll_id;
    pay_pay_bus.g_legislation_code  := l_legislation_code;
  --
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
--
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
--
procedure chk_ddf
  (p_rec in pay_pay_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.payroll_id is not null)  and (
    nvl(pay_pay_shd.g_old_rec.prl_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information_category, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information1, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information1, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information2, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information2, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information3, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information3, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information4, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information4, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information5, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information5, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information6, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information6, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information7, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information7, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information8, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information8, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information9, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information9, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information10, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information10, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information11, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information11, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information12, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information12, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information13, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information13, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information14, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information14, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information15, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information15, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information16, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information16, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information17, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information17, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information18, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information18, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information19, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information19, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information20, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information20, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information21, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information21, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information22, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information22, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information23, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information23, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information24, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information24, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information25, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information25, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information26, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information26, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information27, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information27, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information28, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information28, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information29, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information29, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.prl_information30, hr_api.g_varchar2) <>
    nvl(p_rec.prl_information30, hr_api.g_varchar2) ))
    or (p_rec.payroll_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --

    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'Payroll Developer DF'
      ,p_attribute_category              => p_rec.prl_information_category
      ,p_attribute1_name                 => 'PRL_INFORMATION1'
      ,p_attribute1_value                => p_rec.prl_information1
      ,p_attribute2_name                 => 'PRL_INFORMATION2'
      ,p_attribute2_value                => p_rec.prl_information2
      ,p_attribute3_name                 => 'PRL_INFORMATION3'
      ,p_attribute3_value                => p_rec.prl_information3
      ,p_attribute4_name                 => 'PRL_INFORMATION4'
      ,p_attribute4_value                => p_rec.prl_information4
      ,p_attribute5_name                 => 'PRL_INFORMATION5'
      ,p_attribute5_value                => p_rec.prl_information5
      ,p_attribute6_name                 => 'PRL_INFORMATION6'
      ,p_attribute6_value                => p_rec.prl_information6
      ,p_attribute7_name                 => 'PRL_INFORMATION7'
      ,p_attribute7_value                => p_rec.prl_information7
      ,p_attribute8_name                 => 'PRL_INFORMATION8'
      ,p_attribute8_value                => p_rec.prl_information8
      ,p_attribute9_name                 => 'PRL_INFORMATION9'
      ,p_attribute9_value                => p_rec.prl_information9
      ,p_attribute10_name                => 'PRL_INFORMATION10'
      ,p_attribute10_value               => p_rec.prl_information10
      ,p_attribute11_name                => 'PRL_INFORMATION11'
      ,p_attribute11_value               => p_rec.prl_information11
      ,p_attribute12_name                => 'PRL_INFORMATION12'
      ,p_attribute12_value               => p_rec.prl_information12
      ,p_attribute13_name                => 'PRL_INFORMATION13'
      ,p_attribute13_value               => p_rec.prl_information13
      ,p_attribute14_name                => 'PRL_INFORMATION14'
      ,p_attribute14_value               => p_rec.prl_information14
      ,p_attribute15_name                => 'PRL_INFORMATION15'
      ,p_attribute15_value               => p_rec.prl_information15
      ,p_attribute16_name                => 'PRL_INFORMATION16'
      ,p_attribute16_value               => p_rec.prl_information16
      ,p_attribute17_name                => 'PRL_INFORMATION17'
      ,p_attribute17_value               => p_rec.prl_information17
      ,p_attribute18_name                => 'PRL_INFORMATION18'
      ,p_attribute18_value               => p_rec.prl_information18
      ,p_attribute19_name                => 'PRL_INFORMATION19'
      ,p_attribute19_value               => p_rec.prl_information19
      ,p_attribute20_name                => 'PRL_INFORMATION20'
      ,p_attribute20_value               => p_rec.prl_information20
      ,p_attribute21_name                => 'PRL_INFORMATION21'
      ,p_attribute21_value               => p_rec.prl_information21
      ,p_attribute22_name                => 'PRL_INFORMATION22'
      ,p_attribute22_value               => p_rec.prl_information22
      ,p_attribute23_name                => 'PRL_INFORMATION23'
      ,p_attribute23_value               => p_rec.prl_information23
      ,p_attribute24_name                => 'PRL_INFORMATION24'
      ,p_attribute24_value               => p_rec.prl_information24
      ,p_attribute25_name                => 'PRL_INFORMATION25'
      ,p_attribute25_value               => p_rec.prl_information25
      ,p_attribute26_name                => 'PRL_INFORMATION26'
      ,p_attribute26_value               => p_rec.prl_information26
      ,p_attribute27_name                => 'PRL_INFORMATION27'
      ,p_attribute27_value               => p_rec.prl_information27
      ,p_attribute28_name                => 'PRL_INFORMATION28'
      ,p_attribute28_value               => p_rec.prl_information28
      ,p_attribute29_name                => 'PRL_INFORMATION29'
      ,p_attribute29_value               => p_rec.prl_information29
      ,p_attribute30_name                => 'PRL_INFORMATION30'
      ,p_attribute30_value               => p_rec.prl_information30
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
  (p_rec in pay_pay_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.payroll_id is not null)  and (
    nvl(pay_pay_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(pay_pay_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.payroll_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PAY'
      ,p_descflex_name                   => 'PAY_PAYROLLS'
      ,p_attribute_category              => p_rec.attribute_category
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
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
--
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
  ,p_rec             in out nocopy pay_pay_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_pay_shd.api_updating
      (p_payroll_id                       => p_rec.payroll_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;

  if nvl(p_rec.gl_set_of_books_id, hr_api.g_number) <>
     nvl(pay_pay_shd.g_old_rec.gl_set_of_books_id, hr_api.g_number) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'GL_SET_OF_BOOKS_ID'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.period_type, hr_api.g_varchar2) <>
     nvl(pay_pay_shd.g_old_rec.period_type, hr_api.g_varchar2) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'PERIOD_TYPE'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.organization_id, hr_api.g_number) <>
     nvl(pay_pay_shd.g_old_rec.organization_id, hr_api.g_number) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'ORGANIZATION_ID'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.cut_off_date_offset , hr_api.g_number) <>
     nvl(pay_pay_shd.g_old_rec.cut_off_date_offset, hr_api.g_number) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'CUT_OFF_DATE_OFFSET'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.direct_deposit_date_offset , hr_api.g_number) <>
     nvl(pay_pay_shd.g_old_rec.direct_deposit_date_offset, hr_api.g_number) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'DIRECT_DEPOSIT_DATE_OFFSET'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.first_period_end_date , hr_api.g_date) <>
     nvl(pay_pay_shd.g_old_rec.first_period_end_date, hr_api.g_date) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'FIRST_PERIOD_END_DATE'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.pay_advice_date_offset , hr_api.g_number) <>
     nvl(pay_pay_shd.g_old_rec.pay_advice_date_offset, hr_api.g_number) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'PAY_ADVICE_DATE_OFFSET'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.pay_date_offset , hr_api.g_number) <>
     nvl(pay_pay_shd.g_old_rec.pay_date_offset, hr_api.g_number) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'PAY_DATE_OFFSET'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.midpoint_offset , hr_api.g_number) <>
     nvl(pay_pay_shd.g_old_rec.midpoint_offset, hr_api.g_number) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'MIDPOINT_OFFSET'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.payroll_type , hr_api.g_varchar2) <>
     nvl(pay_pay_shd.g_old_rec.payroll_type, hr_api.g_varchar2) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'PAYROLL_TYPE'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;

  if nvl(p_rec.period_reset_years, hr_api.g_varchar2) <>
     nvl(pay_pay_shd.g_old_rec.period_reset_years, hr_api.g_varchar2) then
  --
     hr_api.argument_changed_error
     (p_api_name => l_proc
     ,p_argument => 'PERIOD_RESET_YEARS'
     ,p_base_table => pay_pay_shd.g_tab_nam
     );
  --
  end if;
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
  (p_org_payment_method_id         in number default hr_api.g_number
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
  If ((nvl(p_org_payment_method_id, hr_api.g_number) <> hr_api.g_number) and
      NOT (dt_api.check_min_max_dates
            (p_base_table_name => 'pay_org_payment_methods_f'
            ,p_base_key_column => 'ORG_PAYMENT_METHOD_ID'
            ,p_base_key_value  => p_org_payment_method_id
            ,p_from_date       => p_validation_start_date
            ,p_to_date         => p_validation_end_date))) Then
     fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
     fnd_message.set_token('TABLE_NAME','org payment methods');
     hr_multi_message.add
       (p_associated_column1 => pay_pay_shd.g_tab_nam || '.ORG_PAYMENT_METHOD_ID');
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
  (p_payroll_id                       in number
  ,p_datetrack_mode                   in varchar2
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ) Is
--
  l_proc        varchar2(72)    := g_package||'dt_delete_validate';

  l_rows_exist  Exception;
  l_table_name  all_tables.table_name%TYPE;

--
Begin
  --
  -- Ensure that the p_datetrack_mode argument is not null
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
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
      ,p_argument       => 'payroll_id'
      ,p_argument_value => p_payroll_id
      );
    --
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'per_all_assignments_f'
       ,p_base_key_column => 'payroll_id'
       ,p_base_key_value  => p_payroll_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
    --
         l_table_name := 'PER_ALL_ASSIGNMENTS_F';
	 raise l_rows_exist;
    --
    End If;
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'pay_element_links_f'
       ,p_base_key_column => 'payroll_id'
       ,p_base_key_value  => p_payroll_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
    --
         l_table_name := 'PAY_ELEMENT_LINKS_F';
	 raise l_rows_exist;
    --
    End If;
    --
    If (dt_api.rows_exist
       (p_base_table_name => 'hr_all_positions_f'
       ,p_base_key_column => 'pay_freq_payroll_id'
       ,p_base_key_value  => p_payroll_id
       ,p_from_date       => p_validation_start_date
       ,p_to_date         => p_validation_end_date
       )) Then
    --
         l_table_name := 'HR_ALL_POSITIONS_F';
	 raise l_rows_exist;
    --
    End If;
    --
    hr_utility.set_location('Leaving:'||l_proc, 50);
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
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_default_payment_method_id >-------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to validate the business rules for column
--   default_payment_method_id.
-------------------------------------------------------------------------------
procedure chk_default_payment_method_id
(
   p_effective_date            in date
  ,p_business_group_id         in number
  ,p_default_payment_method_id in number
) is
  --
  cursor csr_chk_parent is
    select opm.effective_start_date
          ,opm.effective_end_date
      from pay_org_payment_methods_f opm
     where opm.org_payment_method_id = p_default_payment_method_id
     order by opm.effective_start_date
     for update;
  --
  cursor csr_pay_catg_ass_remun is
    select null
      from pay_org_payment_methods_f opm, pay_payment_types pt
          ,pay_defined_balances dfb, pay_balance_types bt
     where opm.org_payment_method_id = p_default_payment_method_id
       and opm.business_group_id +0 = p_business_group_id
       and pt.payment_type_id = opm.payment_type_id
       and pt.category in ('CA','CH')
       and dfb.defined_balance_id = opm.defined_balance_id
       and bt.balance_type_id = dfb.balance_type_id
       and bt.assignment_remuneration_flag = 'Y'
       and p_effective_date between opm.effective_start_date
       and opm.effective_end_date;
  --
  v_start_date date;
  v_end_date   date;
  v_count      number;
  --
begin
  --
  open csr_chk_parent;
  loop
    fetch csr_chk_parent into v_start_date, v_end_date;
    v_count := csr_chk_parent%rowcount;
    exit when csr_chk_parent%notfound;
  end loop;
  close csr_chk_parent;
  --
  -- Payment method must exist in PAY_ORG_PAYMENT_METHODS_F
  --
  if v_count = 0 then
    fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
    fnd_message.set_token('COLUMN','DEFAULT_PAYMENT_METHOD_ID');
    fnd_message.set_token('TABLE','PAY_ORG_PAYMENT_METHODS_F');
    fnd_message.raise_error;
  end if;
  --
  -- Payment method must be valid for the lifetime of payroll
  --
  if v_start_date > p_effective_date or v_end_date   < hr_api.g_eot then
  --
    fnd_message.set_name('PAY', 'HR_7096_PAYM_PYRLL_DFLT_INVID');
    fnd_message.raise_error;
  --
  end if;
  --
  -- Payment Method category must be either 'Cash' or 'Cheque' and
  -- balance remuneration must be 'Yes'
  --
  open csr_pay_catg_ass_remun;
  fetch csr_pay_catg_ass_remun into g_exists;
  if csr_pay_catg_ass_remun%notfound then
    --
    close csr_pay_catg_ass_remun;
    fnd_message.set_name('PAY', 'PAY_34175_PRL_CATG_ASS_REM');
    fnd_message.raise_error;
    --
  end if;
  close csr_pay_catg_ass_remun;
  --
end chk_default_payment_method_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_period_type >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to validate the business rules for column
--   period_type.
-------------------------------------------------------------------------------
procedure chk_period_type
(
  p_period_type        in varchar2
 ,p_legislation_code   in varchar2
 ,p_basic_period_type  out nocopy varchar2
 ,p_periods_per_period out nocopy number
) is
  --
  cursor csr_chk_parent is
    select null
      from per_time_period_types tpt
     where tpt.period_type = p_period_type;
  --
  cursor csr_basic_period_type is
    select tpr.basic_period_type
          ,tpr.periods_per_period
      from per_time_period_rules tpr
          ,per_time_period_types tpt
     where tpr.number_per_fiscal_year = tpt.number_per_fiscal_year
       and tpt.period_type = p_period_type;
  --
begin
  --
  -- Period Type must exist in PER_TIME_PERIOD_TYPES
  --
  open csr_chk_parent;
  fetch csr_chk_parent into g_exists;
  if csr_chk_parent%notfound then
    --
    close csr_chk_parent;
    fnd_message.set_name('PAY','PAY_6601_PAYROLL_INV_PERIOD_TP');
    fnd_message.raise_error;
    --
  end if;
  close csr_chk_parent;
  --
  open csr_basic_period_type;
  fetch csr_basic_period_type into p_basic_period_type, p_periods_per_period;
  if csr_basic_period_type%notfound then
    --
    close csr_basic_period_type;
    fnd_message.set_name('PAY', 'ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE','chk_period_type');
    fnd_message.set_token('STEP', 1);
    fnd_message.raise_error;
    --
  end if;
  close csr_basic_period_type;
  --
  -- For 'GB' legislation, the basic period type must not be Semi-Month.
  --
  if (p_legislation_code = 'GB' and p_basic_period_type = 'SM') then
    --
    fnd_message.set_name('PAY','PAY_34176_PRL_INVLD_GB_PRD');
    fnd_message.raise_error;
    --
  end if;
  --
end chk_period_type;
--
/*
 * Validate the p_consolidation_set_id parameter and return
 * business_group_id and payroll_id values at the same time.
 */
procedure chk_consolidation_set_id
(
   p_consolidation_set_id in  number,
   p_business_group_id    out nocopy number
) is
begin

   -- Get the business_group_id using consolidation set.
   select con.business_group_id
   into   p_business_group_id
   from   pay_consolidation_sets con
   where  con.consolidation_set_id = p_consolidation_set_id;


exception
  when no_data_found then
    fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
    fnd_message.set_token('COLUMN','CONSOLIDATION_SET_ID');
    fnd_message.set_token('TABLE','PAY_CONSOLIDATION_SETS');
    fnd_message.raise_error;
end chk_consolidation_set_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_legislation_rules >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to retrieve the legislation rules with rule type:
--   PAYWSDPG_OFFSET4, PAYWSDPG_OFFSET2, PAYWSDPG_OFFSET3, PDO, ADVANCE
-------------------------------------------------------------------------------
procedure get_legislation_rules
(
   p_legislation_code  in varchar2
  ,p_rule_type         in varchar2 default null
  ,p_cutoff_date_rule  out nocopy varchar2
  ,p_dd_date_rule      out nocopy varchar2
  ,p_pay_adv_date_rule out nocopy varchar2
  ,p_pay_date_rule     out nocopy varchar2
  ,p_arrears_flag_rule out nocopy varchar2
) is
  --
  cursor c_get_legislation_rule is
    select rule_type, rule_mode
      from pay_legislation_rules lru
     where lru.legislation_code = p_legislation_code
       and lru.rule_type = nvl(p_rule_type,lru.rule_type);
  --
begin
  --
  for l_rules in c_get_legislation_rule
  loop
    if l_rules.rule_type = 'PAYWSDPG_OFFSET4' then
      --
      p_cutoff_date_rule := l_rules.rule_mode;
      --
    elsif l_rules.rule_type = 'PAYWSDPG_OFFSET2' then
      --
      p_dd_date_rule := l_rules.rule_mode;
      --
    elsif l_rules.rule_type = 'PAYWSDPG_OFFSET3' then
      --
      p_pay_adv_date_rule := l_rules.rule_mode;
      --
    elsif l_rules.rule_type = 'PDO' then
      --
      p_pay_date_rule := l_rules.rule_mode;
      --
    elsif l_rules.rule_type = 'ADVANCE' then
      --
      p_arrears_flag_rule := l_rules.rule_mode;
      --
    end if;
  end loop;
  --
end get_legislation_rules;
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_date_offsets >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to validate the business rules for date offsets
--   depending on a set of legislation rules.
-------------------------------------------------------------------------------
procedure chk_date_offsets
(
  p_pay_date_offset            in number
 ,p_direct_deposit_date_offset in number
 ,p_pay_advice_date_offset     in number
 ,p_cut_off_date_offset        in number
 ,p_legislation_code           in varchar2
 ,p_basic_period_type          in varchar2
 ,p_periods_per_period         in number
 ,p_arrears_flag_rule          out nocopy varchar2
) is
 --
 l_max_offset        number;
 l_cutoff_date_rule  pay_legislation_rules.rule_mode%type;
 l_dd_date_rule      pay_legislation_rules.rule_mode%type;
 l_pay_adv_date_rule pay_legislation_rules.rule_mode%type;
 l_pay_date_rule     pay_legislation_rules.rule_mode%type;
 --
begin
  --
  get_legislation_rules
    (p_legislation_code  => p_legislation_code
    ,p_cutoff_date_rule  => l_cutoff_date_rule
    ,p_dd_date_rule      => l_dd_date_rule
    ,p_pay_adv_date_rule => l_pay_adv_date_rule
    ,p_pay_date_rule     => l_pay_date_rule
    ,p_arrears_flag_rule => p_arrears_flag_rule
    );
  --
  if p_cut_off_date_offset <> 0 and l_cutoff_date_rule = 'N' then
    fnd_message.set_name('PAY','PAY_34174_PRL_INVALID_LEG_RULE');
    fnd_message.set_token('COLUMN','Cut Off Date Offset');
    fnd_message.raise_error;
  end if;
  --
  if p_direct_deposit_date_offset <> 0 and l_dd_date_rule = 'N' then
    fnd_message.set_name('PAY','PAY_34174_PRL_INVALID_LEG_RULE');
    fnd_message.set_token('COLUMN','Direct Deposit Date Offset');
    fnd_message.raise_error;
  end if;
  --
  if p_pay_advice_date_offset <> 0 and l_pay_adv_date_rule = 'N' then
    fnd_message.set_name('PAY','PAY_34174_PRL_INVALID_LEG_RULE');
    fnd_message.set_token('COLUMN','Pay Advice Date Offset');
    fnd_message.raise_error;
  end if;
  --
  if l_pay_date_rule = 'N' then
    --
    -- Calculate the maximum allowable offset which will result
    -- in a pay date within the period.
    --
    if p_basic_period_type = 'SM' then
      --
      l_max_offset := -12;
      --
    elsif p_basic_period_type = 'W' then
      --
      l_max_offset := (-7 * p_periods_per_period) + 1;
      --
    elsif p_basic_period_type = 'CM' then
      --
      l_max_offset := (-31 * p_periods_per_period) + 1;
      --
    end if;
    --
    -- Make sure the offset is set such that the pay date will
    -- lie within the period ie. is between 0 and the maximum
    -- allowable offset.
    --
    if p_pay_date_offset > 0 or p_pay_date_offset < l_max_offset then
      --
      fnd_message.set_name('PAY', 'PAY_6992_PAY_OFFSET_RANGE');
      fnd_message.set_token('MAX_OFFSET', to_char(l_max_offset), false);
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  --
end chk_date_offsets;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------< chk_negative_pay_allowed_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Negative Pay Allowed must be either 'Y' or 'N'.
-------------------------------------------------------------------------------
procedure chk_negative_pay_allowed_flag
(
  p_effective_date            in date
 ,p_negative_pay_allowed_flag in varchar2
) is
begin
  if hr_api.not_exists_in_hr_lookups
    (p_effective_date
    ,'YES_NO'
    ,p_negative_pay_allowed_flag) then
    --
    fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN','NEGATIVE_PAY_ALLOWED_FLAG');
    fnd_message.set_token('LOOKUP_TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end If;
end chk_negative_pay_allowed_flag;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_number_of_years >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to validate the business rules for the column
--   number_of_years.
-------------------------------------------------------------------------------
procedure chk_number_of_years
(
   p_effective_date  in date
  ,p_number_of_years in number
  ,p_payroll_id      in number default null
) is
--
  cursor csr_current_values is
    select prl.payroll_name
          ,prl.number_of_years
          ,min(effective_start_date) min_payroll_start_date
          ,max(prl.effective_end_date) max_payroll_end_date
      from pay_payrolls_f prl
     where prl.payroll_id = p_payroll_id
     group by prl.payroll_name, prl.number_of_years;
--
  l_values_rec             csr_current_values%rowtype;
  l_max_payroll_years      number;
--
begin
   --
   -- The number of years must be greater than zero.
   --
   if p_number_of_years <= 0 then
     --
     fnd_message.set_name('PAY','HR_6485_PAYROLL_YEARS');
     fnd_message.raise_error;
     --
   end if;
   --
   -- Make sure that the number of years can only be increased NB. if the current
   -- row has not been committed then do not need to check
   if p_payroll_id is not null then
     --
     open csr_current_values;
     fetch csr_current_values into l_values_rec;
     close csr_current_values;
     --
     if p_number_of_years < l_values_rec.number_of_years then
       --
       fnd_message.set_name('PAY', 'HR_6495_PAY_UPD_YEARS');
       fnd_message.raise_error;
       --
     end if;
     --
     -- The number of years should be within the lifetime of the payroll
     --
     l_max_payroll_years :=
       round(months_between(l_values_rec.max_payroll_end_date,l_values_rec.min_payroll_start_date))/12;

     if p_number_of_years > l_max_payroll_years then
       --
       fnd_message.set_name('PAY','PAY_34165_PAYROLL_YEARS');
       fnd_message.set_token('YEARS',to_char(l_max_payroll_years));
       fnd_message.raise_error;
       --
     end if;
     --
   end if;
   --
end chk_number_of_years;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_payroll_name >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Payroll Name must be unique within a business group.
-------------------------------------------------------------------------------
procedure chk_payroll_name
(
  p_payroll_name      in varchar2
 ,p_business_group_id in number
 ,p_payroll_id        in number default null
) is
--
begin
  --
  pay_payrolls_f_pkg.chk_payroll_unique
    (p_payroll_id
    ,p_payroll_name
    ,p_business_group_id
    );
  --
end chk_payroll_name;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_arrears_flag >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to validate the business rules of column
--   arrears_flag.
-------------------------------------------------------------------------------
procedure chk_arrears_flag
(
  p_effective_date    in date
 ,p_arrears_flag      in varchar2
 ,p_arrears_flag_rule in varchar2
) is
begin
  if hr_api.not_exists_in_hr_lookups
    (p_effective_date
    ,'YES_NO'
    ,p_arrears_flag) then
    --
    fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN','ARREARS_FLAG');
    fnd_message.set_token('LOOKUP_TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
  if (p_arrears_flag = 'Y' and p_arrears_flag_rule is null) then
    --
    fnd_message.set_name('PAY','PAY_34174_PRL_INVALID_LEG_RULE');
    fnd_message.set_token('COLUMN','Arrears Flag');
    fnd_message.raise_error;
    --
  end if;
  --
end chk_arrears_flag;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_payroll_type >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Payroll Type must correspond to the lookup codes for lookup type
--   'PAYROLL_TYPE' in HR_LOOKUPS.
-------------------------------------------------------------------------------
procedure chk_payroll_type
(
  p_effective_date    in date
 ,p_payroll_type      in varchar2
) is
begin
   --
   -- Check that the value supplied for payroll type exists in HR_LOOKUPS
   --
   if hr_api.not_exists_in_hr_lookups
    (p_effective_date
    ,'PAYROLL_TYPE'
    ,p_payroll_type) then
    --
    fnd_message.set_name('PAY','HR_51901_INVALID_PAYROLL_TYPE');
    fnd_message.raise_error;
    --
  end if;
  --
end chk_payroll_type;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_multi_assignments_flag >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is used to validate the business rules for column
--   multi_assignments_flag.
-------------------------------------------------------------------------------
procedure chk_multi_assignments_flag
(
  p_effective_date         in date
 ,p_multi_assignments_flag in varchar2
 ,p_legislation_code       in varchar2
) is
--
  cursor get_legislation_rule is
  select rule_mode
    from pay_legislative_field_info lfi
   where lfi.validation_name = 'ITEM_PROPERTY'
     and lfi.validation_type = 'DISPLAY'
     and lfi.rule_type = 'DISPLAY'
     and lfi.field_name = 'MULTI_ASSIGNMENTS_FLAG'
     and lfi.target_location = 'PAYWSDPG'
     and lfi.legislation_code = p_legislation_code;
--
  l_rule_mode pay_legislative_field_info.rule_mode%type;
--
begin
  --
  -- Multi_assignments_flag must be NULL when there is no legislation rule
  -- or rule_mode is 'N'.
  --
  open get_legislation_rule;
  fetch get_legislation_rule into l_rule_mode;
  if get_legislation_rule%notfound then
    --
    close get_legislation_rule;
    fnd_message.set_name('PAY','PAY_34174_PRL_INVALID_LEG_RULE');
    fnd_message.set_token('COLUMN','Multi Assignments Flag');
    fnd_message.raise_error;
    --
  elsif l_rule_mode = 'N' then
    --
    close get_legislation_rule;
    fnd_message.set_name('PAY','PAY_34174_PRL_INVALID_LEG_RULE');
    fnd_message.set_token('COLUMN','Multi Assignments Flag');
    fnd_message.raise_error;
    --
  end if;
  close get_legislation_rule;
  --
  -- Multi_assignments_flag must exist in HR_LOOKUPS
  --
  if hr_api.not_exists_in_hr_lookups
    (p_effective_date
    ,'YES_NO'
    ,p_multi_assignments_flag) then
    --
    fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN','MULTI_ASSIGNMENTS_FLAG');
    fnd_message.set_token('LOOKUP_TYPE','YES_NO');
    fnd_message.raise_error;
    --
  end if;
  --
end chk_multi_assignments_flag;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_period_reset_years >------------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   Period Reset Years cannot be greater than Number Of Years.
-------------------------------------------------------------------------------
procedure chk_period_reset_years
(
  p_period_reset_years in varchar2
 ,p_number_of_years    in number
) is
--
  l_proc varchar2(72) := g_package||'chk_period_reset_years';
--
begin
  --
  if (fnd_profile.value('PAY_PERIOD_RESET_YEARS') <> 'Y' and
      p_period_reset_years is not null)  then
      --
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
      --
  end if;
  --
  if  p_number_of_years is not null and p_period_reset_years not in ('N','L','F') then
  --
    fnd_message.set_name('PAY','PAY_34177_RESET_YRS_INVALID');
    fnd_message.raise_error;
  --
  end if;
  --
end chk_period_reset_years;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< chk_workload_shifting_level >----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   workload shifting level must be one of the code of the lookup type
--   WORKLOAD_SHIFTING_LEVEL.
-------------------------------------------------------------------------------
procedure chk_workload_shifting_level
(
  p_effective_date            in date
 ,p_workload_shifting_level   in varchar2
) is
begin
  if hr_api.not_exists_in_hr_lookups
    (p_effective_date
    ,'WORKLOAD_SHIFTING_LEVEL'
    ,p_workload_shifting_level) then
    --
    fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
    fnd_message.set_token('COLUMN','WORKLOAD_SHIFTING_LEVEL');
    fnd_message.set_token('LOOKUP_TYPE','WORKLOAD_SHIFTING_LEVEL');
    fnd_message.raise_error;
    --
  end If;
end chk_workload_shifting_level;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_keyflex_and_other_ids >-----------------------|
-- ----------------------------------------------------------------------------
--
-- Description
--   This procedure is to used for foreign key validation of -
--     cost_allocation_keyflex_id
--     suspense_account_keyflex_id
--     gl_set_of_books_id
--     soft_coding_keyflex_id
--     organization_id
-------------------------------------------------------------------------------
procedure chk_keyflex_and_other_ids
(
  p_cost_allocation_keyflex_id  in number   default null
 ,p_suspense_account_keyflex_id in number   default null
 ,p_gl_set_of_books_id          in number   default null
 ,p_soft_coding_keyflex_id      in number   default null
 ,p_organization_id             in number   default null
 ,p_datetrack_mode              in varchar2 default null
) is
--
  cursor csr_chk_keyflexs(p_cost_kff_id number) is
    select null
      from pay_cost_allocation_keyflex
     where cost_allocation_keyflex_id = p_cost_kff_id;
--
  cursor csr_chk_set_of_books is
    select null
      from gl_sets_of_books
     where set_of_books_id = p_gl_set_of_books_id;
--
  cursor csr_chk_soft_coding_kff is
    select null
      from hr_soft_coding_keyflex
     where soft_coding_keyflex_id = p_soft_coding_keyflex_id;
--
  cursor csr_chk_org is
    select null
      from hr_organization_units
     where organization_id = p_organization_id;
--
begin
  --
  if (p_datetrack_mode = hr_api.g_insert and
      p_cost_allocation_keyflex_id is not null)
  or ((p_datetrack_mode <> hr_api.g_insert) and
      (p_cost_allocation_keyflex_id <>
      nvl(pay_pay_shd.g_old_rec.COST_ALLOCATION_KEYFLEX_ID, hr_api.g_number)))
  then
    --
    open csr_chk_keyflexs (p_cost_allocation_keyflex_id);
    fetch csr_chk_keyflexs into g_exists;
    if csr_chk_keyflexs%notfound then
      --
      close csr_chk_keyflexs;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','COST_ALLOCATION_KEYFLEX_ID');
      fnd_message.set_token('TABLE','PAY_COST_ALLOCATION_KEYFLEX');
      fnd_message.raise_error;
      --
    end if;
    close csr_chk_keyflexs;
    --
  end if;
  --
  if (p_datetrack_mode = hr_api.g_insert and
      p_suspense_account_keyflex_id is not null)
  or ((p_datetrack_mode <> hr_api.g_insert) and
      (p_suspense_account_keyflex_id <>
      nvl(pay_pay_shd.g_old_rec.suspense_account_keyflex_id, hr_api.g_number)))
  then
    --
    open csr_chk_keyflexs (p_suspense_account_keyflex_id);
    fetch csr_chk_keyflexs into g_exists;
    if csr_chk_keyflexs%notfound then
      --
      close csr_chk_keyflexs;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','SUSPENSE_ACCOUNT_KEYFLEX_ID');
      fnd_message.set_token('TABLE','PAY_COST_ALLOCATION_KEYFLEX');
      fnd_message.raise_error;
      --
    end if;
    close csr_chk_keyflexs;
    --
  end if;
  --
  if (p_datetrack_mode = hr_api.g_insert and
      p_soft_coding_keyflex_id is not null)
  or ((p_datetrack_mode <> hr_api.g_insert) and
      (p_soft_coding_keyflex_id <>
      nvl(pay_pay_shd.g_old_rec.soft_coding_keyflex_id, hr_api.g_number)))
  then
    --
    open csr_chk_soft_coding_kff;
    fetch csr_chk_soft_coding_kff into g_exists;
    if csr_chk_soft_coding_kff%notfound then
      --
      close csr_chk_soft_coding_kff;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','SOFT_CODING_KEYFLEX_ID');
      fnd_message.set_token('TABLE','HR_SOFT_CODING_KEYFLEX');
      fnd_message.raise_error;
      --
    end if;
    close csr_chk_soft_coding_kff;
    --
  end if;
  --
  if (p_datetrack_mode = hr_api.g_insert and
      p_gl_set_of_books_id is not null)
  then
    --
    open csr_chk_set_of_books;
    fetch csr_chk_set_of_books into g_exists;
    if csr_chk_set_of_books%notfound then
      --
      close csr_chk_set_of_books;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','GL_SET_OF_BOOKS_ID');
      fnd_message.set_token('TABLE','GL_SETS_OF_BOOKS');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_chk_set_of_books;
  end if;
  --
  if (p_datetrack_mode = hr_api.g_insert and
      p_organization_id is not null)
  then
    open csr_chk_org;
    fetch csr_chk_org into g_exists;
    if csr_chk_org%notfound then
      --
      close csr_chk_org;
      fnd_message.set_name('PAY','PAY_33085_INVALID_FK');
      fnd_message.set_token('COLUMN','ORGANIZATION_ID');
      fnd_message.set_token('TABLE','HR_ORGANIZATION_UNITS');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_chk_org;
  end if;
  --
end chk_keyflex_and_other_ids;
--
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                   in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ,p_validation_start_date in date
  ,p_validation_end_date   in date
  ) is
--
  l_proc        varchar2(72) := g_package||'insert_validate';
  l_business_group_id number(15);

  l_basic_period_type  per_time_period_rules.basic_period_type%type;
  l_periods_per_period per_time_period_rules.periods_per_period%type;
  l_arrears_flag_rule  pay_legislation_rules.rule_mode%type;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check the consolidation_set_id and get the respective business group.
  --
  pay_pay_bus.chk_consolidation_set_id(p_rec.consolidation_set_id,
                            l_business_group_id);
  p_rec.business_group_id := l_business_group_id;

  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pay_shd.g_tab_nam
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

  if p_rec.default_payment_method_id is not null then
    --
    chk_default_payment_method_id
      (p_effective_date            => p_effective_date
      ,p_business_group_id         => p_rec.business_group_id
      ,p_default_payment_method_id => p_rec.default_payment_method_id
      );
    --
  end if;

  g_legislation_code := hr_api.return_legislation_code(p_rec.business_group_id);

  chk_period_type
    (p_period_type        => p_rec.period_type
    ,p_legislation_code   => g_legislation_code
    ,p_basic_period_type  => l_basic_period_type
    ,p_periods_per_period => l_periods_per_period
    );

  chk_date_offsets
    (p_pay_date_offset            => p_rec.pay_date_offset
    ,p_direct_deposit_date_offset => p_rec.direct_deposit_date_offset
    ,p_pay_advice_date_offset     => p_rec.pay_advice_date_offset
    ,p_cut_off_date_offset        => p_rec.cut_off_date_offset
    ,p_legislation_code           => g_legislation_code
    ,p_basic_period_type          => l_basic_period_type
    ,p_periods_per_period         => l_periods_per_period
    ,p_arrears_flag_rule          => l_arrears_flag_rule
    );

  chk_negative_pay_allowed_flag
    (p_effective_date            => p_effective_date
    ,p_negative_pay_allowed_flag => p_rec.negative_pay_allowed_flag
    );

  chk_number_of_years
    (p_effective_date  => p_effective_date
    ,p_number_of_years => p_rec.number_of_years
    );

  chk_payroll_name
    (p_payroll_name      => p_rec.payroll_name
    ,p_business_group_id => p_rec.business_group_id
    );

  if p_rec.arrears_flag is not null then
    --
    chk_arrears_flag
      (p_effective_date    => p_effective_date
      ,p_arrears_flag      => p_rec.arrears_flag
      ,p_arrears_flag_rule => l_arrears_flag_rule
      );
    --
  end if;

  if p_rec.payroll_type is not null then
    --
    chk_payroll_type
      (p_effective_date    => p_effective_date
      ,p_payroll_type      => p_rec.payroll_type
      );
    --
  end if;

--  if p_rec.multi_assignments_flag is not null then
-- bug 5609830 / 5144323
-- if condition changed to call the validation only when the
-- multi assignment flag value equal to Y.
  if p_rec.multi_assignments_flag = 'Y' then
    --
    chk_multi_assignments_flag
      (p_effective_date         => p_effective_date
      ,p_multi_assignments_flag => p_rec.multi_assignments_flag
      ,p_legislation_code       => g_legislation_code
      );
    --
  end if;

  if p_rec.period_reset_years is not null then
    --
    chk_period_reset_years
      (p_period_reset_years => p_rec.period_reset_years
      ,p_number_of_years    => p_rec.number_of_years
      );
    --
  end if;

  chk_keyflex_and_other_ids
    (p_cost_allocation_keyflex_id  => p_rec.cost_allocation_keyflex_id
    ,p_suspense_account_keyflex_id => p_rec.suspense_account_keyflex_id
    ,p_gl_set_of_books_id          => p_rec.gl_set_of_books_id
    ,p_soft_coding_keyflex_id      => p_rec.soft_coding_keyflex_id
    ,p_organization_id             => p_rec.organization_id
    ,p_datetrack_mode              => hr_api.g_insert
    );
  --
  chk_workload_shifting_level
    (p_effective_date		=> p_effective_date
    ,p_workload_shifting_level	=> p_rec.workload_shifting_level);
  --
  pay_pay_bus.chk_ddf(p_rec);
  --
  pay_pay_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                     in out nocopy pay_pay_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc              varchar2(72) := g_package||'update_validate';
  l_dummy             varchar2(15);
  l_arrears_flag_rule pay_legislation_rules.rule_mode%type;
  l_business_group_id pay_all_payrolls_f.business_group_id%type;

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => pay_pay_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');

  hr_multi_message.end_validation_set;
  --
  if p_rec.default_payment_method_id <>
     nvl(pay_pay_shd.g_old_rec.default_payment_method_id, hr_api.g_number) then
    pay_pay_bus.chk_default_payment_method_id
      (p_effective_date            => p_effective_date
      ,p_business_group_id         => p_rec.business_group_id
      ,p_default_payment_method_id => p_rec.default_payment_method_id
      );
  end if;
  --
  if p_rec.consolidation_set_id <>
    nvl(pay_pay_shd.g_old_rec.consolidation_set_id, hr_api.g_number) then
    --
    pay_pay_bus.chk_consolidation_set_id( p_rec.consolidation_set_id,
                                          l_business_group_id );
         if (l_business_group_id <> p_rec.business_group_id) then
	        --
		fnd_message.set_name('PAY', 'PAY_KR_INV_CS_BG');
	        fnd_message.raise_error;
		--
	 end if;
     --
  End if;
  --
  --
  if p_rec.negative_pay_allowed_flag <>
     nvl(pay_pay_shd.g_old_rec.negative_pay_allowed_flag, hr_api.g_varchar2) then
    --
    pay_pay_bus.chk_negative_pay_allowed_flag
      (p_effective_date            => p_effective_date
      ,p_negative_pay_allowed_flag => p_rec.negative_pay_allowed_flag
      );
    --
  end if;
  --
  if p_rec.number_of_years <> pay_pay_shd.g_old_rec.number_of_years then
    --
    pay_pay_bus.chk_number_of_years
      (p_effective_date  => p_effective_date
      ,p_number_of_years => p_rec.number_of_years
      ,p_payroll_id      => p_rec.payroll_id
      );
    --
  end if;
  --
  if p_rec.payroll_name <> pay_pay_shd.g_old_rec.payroll_name then
    --
    pay_pay_bus.chk_payroll_name
      (p_payroll_name      => p_rec.payroll_name
      ,p_business_group_id => p_rec.business_group_id
      ,p_payroll_id        => p_rec.payroll_id
      );
    --
  end if;
  --
  pay_pay_bus.get_legislation_rules
    (p_legislation_code  => g_legislation_code
    ,p_rule_type         => 'ADVANCE'
    ,p_cutoff_date_rule  => l_dummy
    ,p_dd_date_rule      => l_dummy
    ,p_pay_adv_date_rule => l_dummy
    ,p_pay_date_rule     => l_dummy
    ,p_arrears_flag_rule => l_arrears_flag_rule
    );
  --
  if p_rec.arrears_flag <> nvl(pay_pay_shd.g_old_rec.arrears_flag, hr_api.g_varchar2) then
    --
    pay_pay_bus.chk_arrears_flag
      (p_effective_date    => p_effective_date
      ,p_arrears_flag      => p_rec.arrears_flag
      ,p_arrears_flag_rule => l_arrears_flag_rule
      );
    --
  end if;
  --
  if p_rec.multi_assignments_flag <>
     nvl(pay_pay_shd.g_old_rec.multi_assignments_flag, hr_api.g_varchar2) then
    --
    pay_pay_bus.chk_multi_assignments_flag
      (p_effective_date         => p_effective_date
      ,p_multi_assignments_flag => p_rec.multi_assignments_flag
      ,p_legislation_code       => g_legislation_code
      );
    --
  end if;
  --
  pay_pay_bus.chk_keyflex_and_other_ids
    (p_cost_allocation_keyflex_id  => p_rec.cost_allocation_keyflex_id
    ,p_suspense_account_keyflex_id => p_rec.suspense_account_keyflex_id
    ,p_soft_coding_keyflex_id      => p_rec.soft_coding_keyflex_id
    ,p_datetrack_mode              => p_datetrack_mode
    );

  --
    chk_workload_shifting_level
    (p_effective_date		=> p_effective_date
    ,p_workload_shifting_level	=> p_rec.workload_shifting_level);
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
  pay_pay_bus.dt_update_validate
    (p_org_payment_method_id          => p_rec.default_payment_method_id
    ,p_datetrack_mode                 => p_datetrack_mode
    ,p_validation_start_date          => p_validation_start_date
    ,p_validation_end_date            => p_validation_end_date
    );
  --
  pay_pay_bus.chk_non_updateable_args
    (p_effective_date  => p_effective_date
    ,p_rec             => p_rec
    );
  --
  hr_multi_message.end_validation_set;
  --
  pay_pay_bus.chk_ddf(p_rec);
  --
  pay_pay_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                    in pay_pay_shd.g_rec_type
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
    ,p_payroll_id                       => p_rec.payroll_id
    );
  --
  --Added to check for the other validations.
  --
    pay_payrolls_f_pkg.validate_delete_payroll
     ( p_payroll_id                => p_rec.payroll_id
      ,p_default_payment_method_id => pay_pay_shd.g_old_rec.default_payment_method_id
      ,p_dt_delete_mode            => p_datetrack_mode
      ,p_validation_start_date     => p_validation_start_date
      ,p_validation_end_date       => p_validation_end_date
     );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End delete_validate;
--

end pay_pay_bus;

/
