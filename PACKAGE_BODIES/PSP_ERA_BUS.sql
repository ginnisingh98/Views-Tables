--------------------------------------------------------
--  DDL for Package Body PSP_ERA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ERA_BUS" as
/* $Header: PSPEARHB.pls 120.2 2006/03/26 01:08 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_era_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_effort_report_approval_id   number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_effort_report_approval_id            in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- psp_eff_report_approvals and PER_BUSINESS_GROUPS_PERF
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , psp_eff_report_approvals era
         , psp_eff_report_details erd
	 , psp_eff_reports per
     where era.effort_report_approval_id = p_effort_report_approval_id
     and   era.effort_report_detail_id = erd.effort_report_detail_id
     and   erd.effort_report_id = per.effort_report_id
     and   pbg.business_group_id = per.business_group_id ;
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
    ,p_argument           => 'effort_report_approval_id'
    ,p_argument_value     => p_effort_report_approval_id
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
        => nvl(p_associated_column1,'EFFORT_REPORT_APPROVAL_ID')
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
  (p_effort_report_approval_id            in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- EDIT_HERE  In the following cursor statement add join(s) between
  -- psp_eff_report_approvals and PER_BUSINESS_GROUPS_PERF
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , psp_eff_report_approvals era
         , psp_eff_report_details erd
	 , psp_eff_reports per
     where era.effort_report_approval_id = p_effort_report_approval_id
     and   era.effort_report_detail_id = erd.effort_report_detail_id
     and   erd.effort_report_id = per.effort_report_id
     and   pbg.business_group_id = per.business_group_id ;
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
    ,p_argument           => 'effort_report_approval_id'
    ,p_argument_value     => p_effort_report_approval_id
    );
  --
  if ( nvl(psp_era_bus.g_effort_report_approval_id, hr_api.g_number)
       = p_effort_report_approval_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := psp_era_bus.g_legislation_code;
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
    psp_era_bus.g_effort_report_approval_id   := p_effort_report_approval_id;
    psp_era_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in psp_era_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.effort_report_approval_id is not null)  and (
    nvl(psp_era_shd.g_old_rec.pera_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information_category, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information1, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information2, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information3, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information4, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information5, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information6, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information7, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information8, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information9, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information10, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information11, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information12, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information13, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information14, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information15, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information16, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information17, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information18, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information19, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.pera_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pera_information20, hr_api.g_varchar2)))
    or (p_rec.effort_report_approval_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PSP'
      ,p_descflex_name                   => 'Effort Approval DF'
      ,p_attribute_category              => p_rec.pera_information_category
      ,p_attribute1_name                 => 'PERA_INFORMATION1'
      ,p_attribute1_value                => p_rec.pera_information1
      ,p_attribute2_name                 => 'PERA_INFORMATION2'
      ,p_attribute2_value                => p_rec.pera_information2
      ,p_attribute3_name                 => 'PERA_INFORMATION3'
      ,p_attribute3_value                => p_rec.pera_information3
      ,p_attribute4_name                 => 'PERA_INFORMATION4'
      ,p_attribute4_value                => p_rec.pera_information4
      ,p_attribute5_name                 => 'PERA_INFORMATION5'
      ,p_attribute5_value                => p_rec.pera_information5
      ,p_attribute6_name                 => 'PERA_INFORMATION6'
      ,p_attribute6_value                => p_rec.pera_information6
      ,p_attribute7_name                 => 'PERA_INFORMATION7'
      ,p_attribute7_value                => p_rec.pera_information7
      ,p_attribute8_name                 => 'PERA_INFORMATION8'
      ,p_attribute8_value                => p_rec.pera_information8
      ,p_attribute9_name                 => 'PERA_INFORMATION9'
      ,p_attribute9_value                => p_rec.pera_information9
      ,p_attribute10_name                => 'PERA_INFORMATION10'
      ,p_attribute10_value               => p_rec.pera_information10
      ,p_attribute11_name                => 'PERA_INFORMATION11'
      ,p_attribute11_value               => p_rec.pera_information11
      ,p_attribute12_name                => 'PERA_INFORMATION12'
      ,p_attribute12_value               => p_rec.pera_information12
      ,p_attribute13_name                => 'PERA_INFORMATION13'
      ,p_attribute13_value               => p_rec.pera_information13
      ,p_attribute14_name                => 'PERA_INFORMATION14'
      ,p_attribute14_value               => p_rec.pera_information14
      ,p_attribute15_name                => 'PERA_INFORMATION15'
      ,p_attribute15_value               => p_rec.pera_information15
      ,p_attribute16_name                => 'PERA_INFORMATION16'
      ,p_attribute16_value               => p_rec.pera_information16
      ,p_attribute17_name                => 'PERA_INFORMATION17'
      ,p_attribute17_value               => p_rec.pera_information17
      ,p_attribute18_name                => 'PERA_INFORMATION18'
      ,p_attribute18_value               => p_rec.pera_information18
      ,p_attribute19_name                => 'PERA_INFORMATION19'
      ,p_attribute19_value               => p_rec.pera_information19
      ,p_attribute20_name                => 'PERA_INFORMATION20'
      ,p_attribute20_value               => p_rec.pera_information20
      );
  end if;

  if ((p_rec.effort_report_approval_id is not null)  and (
    nvl(psp_era_shd.g_old_rec.eff_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information_category, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information1, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information1, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information2, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information2, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information3, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information3, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information4, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information4, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information5, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information5, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information6, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information6, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information7, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information7, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information8, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information8, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information9, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information9, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information10, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information10, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information11, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information11, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information12, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information12, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information13, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information13, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information14, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information14, hr_api.g_varchar2)  or
    nvl(psp_era_shd.g_old_rec.eff_information15, hr_api.g_varchar2) <>
    nvl(p_rec.eff_information15, hr_api.g_varchar2 )))
    or (p_rec.effort_report_approval_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PSP'
      ,p_descflex_name                   => 'Effort Report DF'
      ,p_attribute_category              => p_rec.eff_information_category
      ,p_attribute1_name                => 'EFF_INFORMATION1'
      ,p_attribute1_value               => p_rec.eff_information1
      ,p_attribute2_name                => 'EFF_INFORMATION2'
      ,p_attribute2_value               => p_rec.eff_information2
      ,p_attribute3_name                => 'EFF_INFORMATION3'
      ,p_attribute3_value               => p_rec.eff_information3
      ,p_attribute4_name                => 'EFF_INFORMATION4'
      ,p_attribute4_value               => p_rec.eff_information4
      ,p_attribute5_name                => 'EFF_INFORMATION5'
      ,p_attribute5_value               => p_rec.eff_information5
      ,p_attribute6_name                => 'EFF_INFORMATION6'
      ,p_attribute6_value               => p_rec.eff_information6
      ,p_attribute7_name                => 'EFF_INFORMATION7'
      ,p_attribute7_value               => p_rec.eff_information7
      ,p_attribute8_name                => 'EFF_INFORMATION8'
      ,p_attribute8_value               => p_rec.eff_information8
      ,p_attribute9_name                => 'EFF_INFORMATION9'
      ,p_attribute9_value               => p_rec.eff_information9
      ,p_attribute10_name                => 'EFF_INFORMATION10'
      ,p_attribute10_value               => p_rec.eff_information10
      ,p_attribute11_name                => 'EFF_INFORMATION11'
      ,p_attribute11_value               => p_rec.eff_information11
      ,p_attribute12_name                => 'EFF_INFORMATION12'
      ,p_attribute12_value               => p_rec.eff_information12
      ,p_attribute13_name                => 'EFF_INFORMATION13'
      ,p_attribute13_value               => p_rec.eff_information13
      ,p_attribute14_name                => 'EFF_INFORMATION14'
      ,p_attribute14_value               => p_rec.eff_information14
      ,p_attribute15_name                => 'EFF_INFORMATION15'
      ,p_attribute15_value               => p_rec.eff_information15
      );
    end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  (p_rec in psp_era_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT psp_era_shd.api_updating
      (p_effort_report_approval_id         => p_rec.effort_report_approval_id
      ,p_object_version_number             => p_rec.object_version_number
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in psp_era_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  --
  psp_era_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in psp_era_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- EDIT_HERE: As this table does not have a mandatory business_group_id
  -- column, ensure client_info is populated by calling a suitable
  -- ???_???_bus.set_security_group_id procedure, or add one of the following
  -- comments:
  -- "-- No business group context.  HR_STANDARD_LOOKUPS used for validation."
  -- "-- CLIENT_INFO not set.  No lookup validation or joins to HR_LOOKUPS."
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  psp_era_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in psp_era_shd.g_rec_type
  ) is
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
end psp_era_bus;

/
