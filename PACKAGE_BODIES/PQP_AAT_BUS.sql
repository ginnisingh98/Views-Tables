--------------------------------------------------------
--  DDL for Package Body PQP_AAT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_AAT_BUS" as
/* $Header: pqaatrhi.pkb 120.2.12010000.3 2009/07/01 10:58:37 dchindar ship $ */
--
-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+
--
g_package  varchar2(33) := '  pqp_aat_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_assignment_attribute_id     number         default null;
--
--  --------------------------------------------------------------------------+
--  |----------------------< set_security_group_id >--------------------------|
--  --------------------------------------------------------------------------+
--
Procedure set_security_group_id
  (p_assignment_attribute_id              in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pqp_assignment_attributes_f aat
     where aat.assignment_attribute_id = p_assignment_attribute_id
       and pbg.business_group_id = aat.business_group_id;
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
    ,p_argument           => 'assignment_attribute_id'
    ,p_argument_value     => p_assignment_attribute_id
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
--  --------------------------------------------------------------------------+
--  |---------------------< return_legislation_code >-------------------------|
--  --------------------------------------------------------------------------+
--
Function return_legislation_code
  (p_assignment_attribute_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , pqp_assignment_attributes_f aat
     where aat.assignment_attribute_id = p_assignment_attribute_id
       and pbg.business_group_id = aat.business_group_id;
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
    ,p_argument           => 'assignment_attribute_id'
    ,p_argument_value     => p_assignment_attribute_id
    );
  --
  if ( nvl(pqp_aat_bus.g_assignment_attribute_id, hr_api.g_number)
       = p_assignment_attribute_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pqp_aat_bus.g_legislation_code;
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
    pqp_aat_bus.g_assignment_attribute_id:= p_assignment_attribute_id;
    pqp_aat_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------------< chk_ddf >----------------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
procedure chk_ddf
  (p_rec in pqp_aat_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.assignment_attribute_id is not null)  and (
    nvl(pqp_aat_shd.g_old_rec.aat_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information_category, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information1, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information1, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information2, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information2, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information3, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information3, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information4, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information4, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information5, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information5, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information6, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information6, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information7, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information7, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information8, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information8, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information9, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information9, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information10, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information10, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information11, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information11, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information12, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information12, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information13, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information13, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information14, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information14, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information15, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information15, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information16, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information16, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information17, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information17, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information18, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information18, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information19, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information19, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_information20, hr_api.g_varchar2) <>
    nvl(p_rec.aat_information20, hr_api.g_varchar2) ))
    or (p_rec.assignment_attribute_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Extra Details Of Service DDF'
      ,p_attribute_category              => p_rec.aat_information_category
      ,p_attribute1_name                 => 'AAT_INFORMATION1'
      ,p_attribute1_value                => p_rec.aat_information1
      ,p_attribute2_name                 => 'AAT_INFORMATION2'
      ,p_attribute2_value                => p_rec.aat_information2
      ,p_attribute3_name                 => 'AAT_INFORMATION3'
      ,p_attribute3_value                => p_rec.aat_information3
      ,p_attribute4_name                 => 'AAT_INFORMATION4'
      ,p_attribute4_value                => p_rec.aat_information4
      ,p_attribute5_name                 => 'AAT_INFORMATION5'
      ,p_attribute5_value                => p_rec.aat_information5
      ,p_attribute6_name                 => 'AAT_INFORMATION6'
      ,p_attribute6_value                => p_rec.aat_information6
      ,p_attribute7_name                 => 'AAT_INFORMATION7'
      ,p_attribute7_value                => p_rec.aat_information7
      ,p_attribute8_name                 => 'AAT_INFORMATION8'
      ,p_attribute8_value                => p_rec.aat_information8
      ,p_attribute9_name                 => 'AAT_INFORMATION9'
      ,p_attribute9_value                => p_rec.aat_information9
      ,p_attribute10_name                => 'AAT_INFORMATION10'
      ,p_attribute10_value               => p_rec.aat_information10
      ,p_attribute11_name                => 'AAT_INFORMATION11'
      ,p_attribute11_value               => p_rec.aat_information11
      ,p_attribute12_name                => 'AAT_INFORMATION12'
      ,p_attribute12_value               => p_rec.aat_information12
      ,p_attribute13_name                => 'AAT_INFORMATION13'
      ,p_attribute13_value               => p_rec.aat_information13
      ,p_attribute14_name                => 'AAT_INFORMATION14'
      ,p_attribute14_value               => p_rec.aat_information14
      ,p_attribute15_name                => 'AAT_INFORMATION15'
      ,p_attribute15_value               => p_rec.aat_information15
      ,p_attribute16_name                => 'AAT_INFORMATION16'
      ,p_attribute16_value               => p_rec.aat_information16
      ,p_attribute17_name                => 'AAT_INFORMATION17'
      ,p_attribute17_value               => p_rec.aat_information17
      ,p_attribute18_name                => 'AAT_INFORMATION18'
      ,p_attribute18_value               => p_rec.aat_information18
      ,p_attribute19_name                => 'AAT_INFORMATION19'
      ,p_attribute19_value               => p_rec.aat_information19
      ,p_attribute20_name                => 'AAT_INFORMATION20'
      ,p_attribute20_value               => p_rec.aat_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
--
-- ---------------------------------------------------------------------------+
-- |------------------------------< chk_df >----------------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
procedure chk_df
  (p_rec in pqp_aat_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.assignment_attribute_id is not null)  and (
    nvl(pqp_aat_shd.g_old_rec.assignment_attribute_id, hr_api.g_number) <>
    nvl(p_rec.assignment_attribute_id, hr_api.g_number)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute_category, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute1, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute2, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute3, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute4, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute5, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute6, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute7, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute8, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute9, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute10, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute11, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute12, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute13, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute14, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute15, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute16, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute17, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute18, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute19, hr_api.g_varchar2)  or
    nvl(pqp_aat_shd.g_old_rec.aat_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.aat_attribute20, hr_api.g_varchar2) ))
    or (p_rec.assignment_attribute_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PQP'
      ,p_descflex_name                   => 'Extra Details Of Service DF'
      ,p_attribute_category              => p_rec.aat_attribute_category
      ,p_attribute1_name                 => 'AAT_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.aat_attribute1
      ,p_attribute2_name                 => 'AAT_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.aat_attribute2
      ,p_attribute3_name                 => 'AAT_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.aat_attribute3
      ,p_attribute4_name                 => 'AAT_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.aat_attribute4
      ,p_attribute5_name                 => 'AAT_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.aat_attribute5
      ,p_attribute6_name                 => 'AAT_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.aat_attribute6
      ,p_attribute7_name                 => 'AAT_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.aat_attribute7
      ,p_attribute8_name                 => 'AAT_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.aat_attribute8
      ,p_attribute9_name                 => 'AAT_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.aat_attribute9
      ,p_attribute10_name                => 'AAT_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.aat_attribute10
      ,p_attribute11_name                => 'AAT_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.aat_attribute11
      ,p_attribute12_name                => 'AAT_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.aat_attribute12
      ,p_attribute13_name                => 'AAT_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.aat_attribute13
      ,p_attribute14_name                => 'AAT_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.aat_attribute14
      ,p_attribute15_name                => 'AAT_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.aat_attribute15
      ,p_attribute16_name                => 'AAT_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.aat_attribute16
      ,p_attribute17_name                => 'AAT_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.aat_attribute17
      ,p_attribute18_name                => 'AAT_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.aat_attribute18
      ,p_attribute19_name                => 'AAT_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.aat_attribute19
      ,p_attribute20_name                => 'AAT_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.aat_attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_df;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure chk_non_updateable_args
  (p_effective_date  in date
  ,p_rec             in pqp_aat_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pqp_aat_shd.api_updating
      (p_assignment_attribute_id          => p_rec.assignment_attribute_id
      ,p_effective_date                   => p_effective_date
      ,p_object_version_number            => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
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
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_work_pattern_cols >------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that if one of the work pattern columns
--   is entered, then the other one is not left NULL.
--   Added for bugfix 2651375
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_work_pattern_cols
  (p_work_pattern       in varchar2
  ,p_start_day          in varchar2
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_work_pattern_cols';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 5);

  if p_work_pattern is not null
     or
     p_start_day is not null then
    --
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'Work_Pattern'
      ,p_argument_value => p_work_pattern
      );

    hr_api.mandatory_arg_error
      (p_api_name       => l_proc
      ,p_argument       => 'Start_Day'
      ,p_argument_value => p_start_day
      );
    --
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 10);
--
end chk_work_pattern_cols;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_private_company_car >------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that an assignment does not have both a
--   private and a company car.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_private_company_car
  (p_primary_company_car   in number,
   p_secondary_company_car in number,
   p_private_car           in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_private_company_car';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 5);

  if (p_private_car is not null) and
     (p_primary_company_car is not null or
      p_secondary_company_car is not null) then
  --
    hr_utility.set_message(8303, 'PQP_230519_INVALID_OWNERSHIPS');
    hr_utility.raise_error;
  --
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 10);
--
end chk_private_company_car;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_primary_exists >-----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that an assignment does not have a
--   secondary company car without a primary company car.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_primary_exists
  (p_primary_company_car   in number,
   p_secondary_company_car in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_primary_exists';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 5);

  if p_primary_company_car is null and
     p_secondary_company_car is not null then
  --
    hr_utility.set_message(8303, 'PQP_230525_PRIMARY_CAR_NULL');
    hr_utility.raise_error;
  --
  end if;

  hr_utility.set_location(' Leaving: '|| l_proc, 10);
--
end chk_primary_exists;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_prim_sec_duplicate >-------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the same car is not assigned as
--   both primary and secondary car to the same person
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_prim_sec_duplicate
  (p_primary_company_car   in number,
   p_secondary_company_car in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_prim_sec_duplicate';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 5);

  if p_primary_company_car = p_secondary_company_car then
  --
    hr_utility.set_message(8303, 'PQP_230524_PRI_SEC_CAR_MATCH');
    hr_utility.raise_error;
  --
  end if;

  hr_utility.set_location(' Leaving: '|| l_proc, 10);
--
end chk_prim_sec_duplicate;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_company_car_duplicate_asg >------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the same car is not given to more
--   than one assignment at a time.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_company_car_duplicate_asg
  (p_primary_company_car   in number,
   p_secondary_company_car in number,
   p_assignment_id         in number,
   p_validation_start_date in date,
   p_validation_end_date   in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_company_car_duplicate_asg';
  l_result   number;

  cursor csr_asg_duplicate is
  select 1
  from pqp_assignment_attributes_f
  where (assignment_id > p_assignment_id OR assignment_id < p_assignment_id) -- for bug 6871534
  and (primary_company_car in (p_primary_company_car, p_secondary_company_car) or
       secondary_company_car in (p_primary_company_car, p_secondary_company_car))
  and p_validation_start_date <= effective_end_date
  and p_validation_end_date >= effective_start_date;

--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 5);

  open csr_asg_duplicate;
  fetch csr_asg_duplicate into l_result;

  if csr_asg_duplicate%found then
  --
    close csr_asg_duplicate;

    hr_utility.set_message(8303, 'PQP_230526_VEH_ASG_DUP');
    hr_utility.raise_error;
  --
  else
  --
    close csr_asg_duplicate;
  --
  end if;

  hr_utility.set_location(' Leaving: '|| l_proc, 10);
--
end chk_company_car_duplicate_asg;
--
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_asg_overlap >--------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that one assignment cannot have
--   more than one date overlapping record in the assignment attribute table
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_asg_overlap
  (p_assignment_attribute_id in number,
   p_assignment_id           in number,
   p_validation_start_date   in date,
   p_validation_end_date     in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_asg_overlap';
  l_result   number;

  cursor csr_asg_duplicate is
  select 1
  from pqp_assignment_attributes_f
  where assignment_id = p_assignment_id
  and assignment_attribute_id <> nvl(p_assignment_attribute_id, -1)
  and p_validation_start_date <= effective_end_date
  and p_validation_end_date >= effective_start_date;

Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 5);

  open csr_asg_duplicate;
  fetch csr_asg_duplicate into l_result;

  if csr_asg_duplicate%found then
  --
    close csr_asg_duplicate;

    hr_utility.set_message(8303, 'PQP_230528_ASG_ATTR_DUP');
    hr_utility.raise_error;
  --
  else
  --
    close csr_asg_duplicate;
  --
  end if;

  hr_utility.set_location(' Leaving: '|| l_proc, 10);
--
end chk_asg_overlap;
--
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_table_exists >-------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that the Rates table ( Comp/Private)
--   are valid for that BG.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_table_exists
  (p_rates_table_id    in number,
   p_business_group_id in number
  ) IS
--
  l_proc     varchar2(72) := g_package || ' chk_table_exists';
  l_dummy    varchar2(1);

  CURSOR cur_tbl IS
  SELECT 'x'
    FROM pay_user_tables
   WHERE user_table_id     = p_rates_table_id
     AND business_group_id = p_business_group_id;
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 5);

OPEN cur_tbl;
  FETCH cur_tbl INTO l_dummy;
   IF cur_tbl%NOTFOUND THEN
    -- Error
    CLOSE cur_tbl;
    fnd_message.set_name('PQP', 'PQP_230527_RATES_TABLE_INVALID');
    fnd_message.raise_error;
   END IF;

CLOSE cur_tbl;

hr_utility.set_location(' Leaving: '|| l_proc, 10);
--
end chk_table_exists;

--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_is_teacher >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate tp_is_teacher against
--   HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE is 'PQP_GB_TEACHER_JOB_STATUS'.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--   p_tp_is_teacher
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_is_teacher
  (p_assignment_attribute_id    in number
  ,p_tp_is_teacher              in varchar2
  ,p_effective_date             in date
  ,p_validation_start_date      in date
  ,p_validation_end_date        in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_tp_is_teacher';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);

  if (((p_assignment_attribute_id is not null) and
       nvl(pqp_aat_shd.g_old_rec.tp_is_teacher,
       hr_api.g_varchar2) <> nvl(p_tp_is_teacher,
                                 hr_api.g_varchar2))
     or
        (p_assignment_attribute_id is null)) then

    hr_utility.set_location(l_proc, 20);
    --
    if p_tp_is_teacher is not null then
      if hr_api.not_exists_in_dt_hr_lookups
           (p_effective_date            => p_effective_date
           ,p_validation_start_date     => p_validation_start_date
           ,p_validation_end_date       => p_validation_end_date
           ,p_lookup_type               => 'PQP_GB_TEACHER_JOB_STATUS'
           ,p_lookup_code               => p_tp_is_teacher
           ) then

             -- Invalid Job Status
             fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
             fnd_message.set_token('COLUMN_NAME', 'TP_IS_TEACHER');
             fnd_message.raise_error;
      end if;
           hr_utility.set_location(l_proc, 30);
    end if;
  end if;
  hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_is_teacher;
--
-- ---------------------------------------------------------------------------+
-- |----------< chk_tp_headteacher_grp_code    >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate tp_headteacher_grp_code  against
--   the condition that it should be a valid numeric code with length equals to 2.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_assignment_attribute_id
--   p_tp_is_teacher
--
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application warning will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+

Procedure chk_tp_headteacher_grp_code
  (p_assignment_attribute_id    in number
  ,p_tp_is_teacher		in varchar2
  ,p_tp_headteacher_grp_code    in number
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_tp_headteacher_grp_code';
--
Begin
--
  hr_utility.set_location(' Entering: '|| l_proc, 10);

   if (((p_assignment_attribute_id is not null) and
       nvl(pqp_aat_shd.g_old_rec.tp_is_teacher,
       hr_api.g_varchar2) <> nvl(p_tp_is_teacher,
                                 hr_api.g_varchar2))
     or
        (p_assignment_attribute_id is null)) then

    hr_utility.set_location(l_proc, 20);
    --
    --115.19 changed the range from 0 to 99 to 1 to 99
    --for the HeadTeacher Group Code as length of the numeric code is 2
    -- and it cannot be possibly '00'
    if p_tp_is_teacher is not null then
      if ((p_tp_headteacher_grp_code IS NOT NULL) and ( p_tp_headteacher_grp_code  NOT BETWEEN  1 and 99 )) THEN
             -- Invalid headteacher group code
             fnd_message.set_name( 'PQP','PQP_230204_TP_INVALID_GRP_CODE');
             fnd_message.set_token('COLUMN_NAME', 'TP_HEADTEACHER_GRP_CODE' );
             fnd_message.raise_error;
      end if;
           hr_utility.set_location(l_proc, 30);
    end if;
   end if;
    hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_headteacher_grp_code;
--


-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_elected_pension >-------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate tp_elected_pension against
--   HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE is 'YES_NO'.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--   p_tp_elected_pension
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_elected_pension
  (p_assignment_attribute_id    in number
  ,p_tp_elected_pension         in varchar2
  ,p_effective_date             in date
  ,p_validation_start_date      in date
  ,p_validation_end_date        in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_tp_elected_pension';
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 10);

  if (((p_assignment_attribute_id is not null) and
       nvl(pqp_aat_shd.g_old_rec.tp_elected_pension,
       hr_api.g_varchar2) <> nvl(p_tp_elected_pension,
                                 hr_api.g_varchar2))
     or
        (p_assignment_attribute_id is null)) then

    hr_utility.set_location(l_proc, 20);
    --
    if p_tp_elected_pension is not null then
      if hr_api.not_exists_in_dt_hr_lookups
           (p_effective_date            => p_effective_date
           ,p_validation_start_date     => p_validation_start_date
           ,p_validation_end_date       => p_validation_end_date
           ,p_lookup_type               => 'YES_NO'
           ,p_lookup_code               => p_tp_elected_pension
           ) then

        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'TP_ELECTED_PENSION');
        fnd_message.raise_error;

      end if;
      hr_utility.set_location(l_proc, 30);
    end if;
  end if;

hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_elected_pension;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_safeguarded_grade >-----------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate tp_safeguarded_grade against
--   the format ANN where A is upper case aplha and N is number.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_tp_safeguarded_grade
--   p_tp_safeguarded_grade_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_safeguarded_grade
  (p_assignment_attribute_id    in number
  ,p_tp_safeguarded_grade       in varchar2
  ,p_tp_safeguarded_grade_id    in number
  ,p_effective_date             in date
  ,p_validation_start_date      in date
  ,p_validation_end_date        in date
  ) IS
--
  Cursor ChkFormat is
  Select 'Y'
  From dual
  Where length(nvl(p_tp_safeguarded_grade,'x')) <= 3
    and ascii( substr(p_tp_safeguarded_grade,1,1)) between 65 and 90
    and (-- Either both 2nd and 3rd chars are alpha
         (ascii( substr(p_tp_safeguarded_grade,2,1)) between 65 and 90
          AND
          ascii( substr(p_tp_safeguarded_grade,3,1)) between 65 and 90
         )
         OR -- 2nd and 3rd chars r both numbers
         (ascii( substr(p_tp_safeguarded_grade,2,1)) between 48 and 57
          AND
          ascii( substr(p_tp_safeguarded_grade,3,1)) between 48 and 57
         )
        );
--
  Cursor ChkGradeValid is
  Select 'Y'
  From per_grades pg
  Where pg.grade_id = p_tp_safeguarded_grade_id;
--
  l_proc        varchar2(72) := g_package || 'chk_tp_safeguarded_grade';
  l_FormatValid char(1) := 'N';
  l_GradeValid  char(1) := 'N';
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 10);

  if (((p_assignment_attribute_id is not null) and
       nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_grade,
       hr_api.g_varchar2) <> nvl(p_tp_safeguarded_grade,
                                 hr_api.g_varchar2))
     or
        (p_assignment_attribute_id is null)) then

    hr_utility.set_location(l_proc, 20);
    --
    if p_tp_safeguarded_grade is not null then
      --
      begin
       open ChkFormat;
       fetch ChkFormat into l_FormatValid;
       close ChkFormat;
      exception
       when others then
         l_FormatValid := 'N';
      end;
      --
      if l_FormatValid = 'N' then
        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'TP_SAFEGUARDED_GRADE');
        fnd_message.raise_error;
      else -- l_FormatValid = 'Y'
        -- Validate the grade
        begin
          open ChkGradeValid;
          fetch ChkGradeValid into l_GradeValid;
          close ChkGradeValid;
        exception
          when others then
            l_GradeValid := 'N';
        end;
        --
        if l_GradeValid = 'N' then
          fnd_message.set_name('PAY', 'PQP_230573_INVALID_GRADE');
          fnd_message.raise_error;
        end if;
      end if; -- l_FormatValid = 'N'
      hr_utility.set_location(l_proc, 30);
    end if; -- p_tp_safeguarded_grade is not null
  end if; -- (((p_assignment_attribute_id is not null) and

hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_safeguarded_grade;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_job_status_change >--------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check if the job status change is valid.
--   The rules governing the job status change are defined in the
--   design document.
--
-- Pre Conditions:
--
-- In Arguments:
--   New Job Status
--   Old Job Status
--   Assignment Id
--   Effective Date
--   Datetrack Mode
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_job_status_change
  (p_new_job_status        in varchar2
  ,p_old_job_status        in varchar2
  ,p_assignment_id         in number
  ,p_effective_date        in date
  ,p_datetrack_mode        in varchar2
  ) IS

-- Cursor Declaration

  Cursor C_TCHR_TTR6_History Is
  Select '1'
  From pqp_assignment_attributes_f
  Where assignment_id = p_assignment_id
    and effective_end_date < p_effective_date
    and (  tp_is_teacher = 'TCHR'
        or tp_is_teacher = 'TTR6');


  Cursor C_TTR6_Future Is
  Select '1'
  From pqp_assignment_attributes_f
  Where assignment_id = p_assignment_id
    and effective_start_date > p_effective_date
    and tp_is_teacher = 'TTR6';

-- Local Variable Declaration
  l_proc        varchar2(72) := g_package || 'chk_job_status_change';

  l_Temp                varchar2(1);
  l_TCHR_TTR6_history   boolean := FALSE;
  l_TTR6_future         boolean := FALSE;
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 5);
--

 -- Check only if tp_is_teacher has changed and is not null
 if (nvl(p_old_job_status,hr_api.g_varchar2) <>
     nvl(p_new_job_status,hr_api.g_varchar2)
    ) and
    (p_new_job_status is not null)
 then -- 0

  /* Evaluate history and future flags. These flag values can be
     re-used in UPDATE mode checks.
  */
  --
  -- Check 'TCHR' and 'TTR6' history
  --
  open C_TCHR_TTR6_History;
  fetch C_TCHR_TTR6_History into l_Temp;
  if C_TCHR_TTR6_History%FOUND then
    l_TCHR_TTR6_history := TRUE;
  end if;
  close C_TCHR_TTR6_History;
  --
  -- Check 'TTR6' future
  --
  open C_TTR6_Future;
  fetch C_TTR6_Future into l_Temp;
  if C_TTR6_Future%FOUND then
    l_TTR6_future := TRUE;
  end if;
  close C_TTR6_Future;

  -- Mode : CORRECTION -------------------------------------------+
  if p_datetrack_mode = hr_api.g_correction then
  -- 1

    /* For new = 'TTR6'
       Rules Handled : 2 and 6 Refer design doc for rules table */
    if p_new_job_status = 'TTR6' then
    -- 2

      if l_TCHR_TTR6_History then
      -- 3
        pqp_aat_shd.constraint_error
        (p_constraint_name => 'PQP_INVALID_JOB_STATUS');
      end if; -- 3

      if l_TTR6_Future then
      -- 4
        pqp_aat_shd.constraint_error
        (p_constraint_name => 'PQP_INVALID_JOB_STATUS');
      end if; -- 4
      --
    end if; -- 2

    /* For old = 'NONT' and new = 'TCHR'
       Rules Handled : 1. Refer design doc for rules table */
    if p_old_job_status = 'NONT' and p_new_job_status = 'TCHR' then
    -- 5
      if l_TTR6_Future then
      -- 6
        pqp_aat_shd.constraint_error
        (p_constraint_name => 'PQP_INVALID_JOB_STATUS');
      end if; -- 6

    end if; -- 5

  end if; -- 1


  -- Mode : UPDATE  -------------------------------------------+
  /* For old = 'TCHR' and new = 'TTR6'
       Rules Handled : 8(Golder Rule) Refer design doc for rules table */
  if (p_datetrack_mode = hr_api.g_update or
      p_datetrack_mode = hr_api.g_update_override or
      p_datetrack_mode = hr_api.g_update_change_insert) then
  -- 7
    if p_old_job_status = 'TCHR' and p_new_job_status = 'TTR6' then
    -- 8
      pqp_aat_shd.constraint_error
      (p_constraint_name => 'PQP_INVALID_JOB_STATUS');
    end if; -- 8

  end if; -- 7

  if (p_datetrack_mode = hr_api.g_update or
      p_datetrack_mode = hr_api.g_update_change_insert) then
  -- 11

    /* For old = 'NONT' and (new = 'TTR6' or 'TCHR')
       Rules Handled : 3 and 4(partly) Refer design doc for rules table */
    if p_old_job_status = 'NONT' and
      (p_new_job_status = 'TCHR' or p_new_job_status = 'TTR6') then
    -- 12

      if l_TTR6_Future then
      -- 13
        pqp_aat_shd.constraint_error
        (p_constraint_name => 'PQP_INVALID_JOB_STATUS');
      end if; -- 13

      /* For old = 'NONT' and new = 'TTR6'
       Rules Handled : 4(remaining part) Refer design doc for rules table */
      if p_new_job_status = 'TTR6' and l_TCHR_TTR6_History then
      -- 14
        pqp_aat_shd.constraint_error
        (p_constraint_name => 'PQP_INVALID_JOB_STATUS');
      end if; -- 14

    end if; -- 12

  end if; -- If 11

 end if; -- 0
--
hr_utility.set_location(' Leaving: '|| l_proc, 10);
--
end chk_job_status_change;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_col_dependencies >------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate the following 2 rules :
--      1) If Job Status is not null then Elected pension flag should
--              be not null as well.
--      2) If either Elected pension flag or safeguarded grade are
--              not null then job status should be not null as well.
--
-- Pre Conditions:
--
-- In Arguments:
--   Job Status
--   Elected Pension Flag
--   Safeguarded Grade
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_col_dependencies
  (p_tp_is_teacher              in varchar2
  ,p_tp_elected_pension         in varchar2
  ,p_tp_safeguarded_grade       in varchar2
  ,p_tp_fast_track              in varchar2
  ) IS

-- Local Variable Declaration
  l_proc        varchar2(72) := g_package || 'chk_job_status_change';

--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 10);
--
  -- Rule 1
  if p_tp_is_teacher is not null then
    if p_tp_elected_pension is null then
      fnd_message.set_name('PQP', 'PQP_230563_PENSION_FLAG_NULL');
      fnd_message.raise_error;
    end if;
  end if;
  hr_utility.set_location(l_proc, 20);

  -- Rule 2
  /*  BUG # 2215296 :
      Removed following condition from if statement below as
      elected pension flag is being set to 'N' when it is null.
      (p_tp_elected_pension is not null) or
  */
  if (p_tp_safeguarded_grade is not null) then
    if p_tp_is_teacher is null then
      fnd_message.set_name('PQP', 'PQP_230562_JOB_STATUS_NULL');
      fnd_message.raise_error;
    end if;
  end if;

  -- Rule 3
  if p_tp_fast_track = 'Y' and p_tp_safeguarded_grade is not null then
    fnd_message.set_name('PQP', 'PQP_230574_CAREER_COMBI_ERR');
    fnd_message.raise_error;
  end if;


hr_utility.set_location(' Leaving: '|| l_proc, 30);
--
end chk_tp_col_dependencies;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_safeguarded_rate >------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate tp_safeguarded_rate_type and
--   tp_safeguarded_rate_id against table pay_rates
--
-- Pre Conditions:
--
-- In Arguments:
--   p_tp_safeguarded_rate_type
--   p_tp_safeguarded_rate_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_safeguarded_rate
  (p_assignment_attribute_id    in number
  ,p_tp_safeguarded_grade       in varchar2
  ,p_tp_safeguarded_rate_type   in varchar2
  ,p_tp_safeguarded_rate_id     in number
  ) IS
--
  Cursor ChkRate is
  Select 'Y'
  From pay_rates pr
  Where pr.rate_type = p_tp_safeguarded_rate_type
    and pr.rate_id = p_tp_safeguarded_rate_id;
--
  l_proc        varchar2(72) := g_package || 'chk_tp_safeguarded_rate';
  l_RateValid char(1) := 'N';
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 10);


  if (((p_assignment_attribute_id is not null) and
       (nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_rate_type,hr_api.g_varchar2)
        <> nvl(p_tp_safeguarded_rate_type,hr_api.g_varchar2)
       )
       or
       (nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_rate_id,hr_api.g_number)
        <> nvl(p_tp_safeguarded_rate_id,hr_api.g_number)
       )
       or
       (nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_grade,hr_api.g_varchar2)
        <> nvl(p_tp_safeguarded_grade,hr_api.g_varchar2)
       )
      )
      or
      (p_assignment_attribute_id is null)
     ) then

    hr_utility.set_location(l_proc, 20);
    --

      if ((p_tp_safeguarded_rate_type = 'G' and p_tp_safeguarded_grade IS NULL ) or
         (p_tp_safeguarded_rate_type = 'SP' and p_tp_safeguarded_grade  IS NULL ) or
	 (p_tp_safeguarded_rate_type = 'SN' and p_tp_safeguarded_grade IS  NOT NULL )) then

	   --raise error message;
	   fnd_message.set_name('PQP', 'PQP_230207_RATE_GRADE_COMB_ERR');
           fnd_message.raise_error;

      end if;



    if (p_tp_safeguarded_rate_id is not null
        or
        p_tp_safeguarded_rate_type is not  null
       )
      and
      --added SN in the following condition to take care for the condition Safeguarded and No Rate requirement
       nvl(p_tp_safeguarded_rate_type,'AbXy') not in ('G','SP','SN') then
        -- invalid rate type selected
        fnd_message.set_name('PQP', 'PQP_230568_INVALID_RATE_TYPE');
        fnd_message.raise_error;
    else
      if p_tp_safeguarded_rate_id is not null then

        begin
         open ChkRate;
         fetch ChkRate into l_RateValid;
         close ChkRate;
        exception
         when others then
           l_RateValid := 'N';
        end;

        if l_RateValid = 'N' then

           -- invalid grade or scale rate selected
           fnd_message.set_name('PQP', 'PQP_230569_INVALID_PAY_RATE');
           fnd_message.raise_error;

        end if;
        hr_utility.set_location(l_proc, 30);
	-- the else part is commented out as it is no longer required to check if the  rate id is null
	--even if the p_safeguarded_rate_type is null because p_safeguarded_rate_type can now be null  even if the rate id is null.i.e.
	--salary not safeguarded at all.If the salary is safeguarded  the Default value for the p_safeguarded_rate_type is SN in which
	--case there will not be any value for grade or rate name.
     /*
      else -- p_tp_safeguarded_rate_id is null
       --if p_tp_safeguarded_grade is not null then
          -- invalid grade or scale rate selected
       --   fnd_message.set_name('PQP', 'PQP_230569_INVALID_PAY_RATE');
         -- fnd_message.raise_error;
        --end if;
   */
      end if; -- p_tp_safeguarded_rate_id is not null

     end if; -- p_tp_safeguarded_rate_type is not null ...
   end if;


hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_safeguarded_rate;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_spinal_point >----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate tp_safeguarded_spinal_point_id
--
-- Pre Conditions:
--
-- In Arguments:
--   p_tp_safeguarded_rate_type
--   p_tp_safeguarded_spinal_point_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_spinal_point
  (p_assignment_attribute_id    in number
  ,p_tp_safeguarded_grade       in varchar2
  ,p_tp_safeguarded_rate_type   in varchar2
  ,p_tp_spinal_point_id         in number
  ) IS
--
  Cursor ChkSpinalPoint is
  Select 'Y'
  From per_spinal_points psp
  Where psp.spinal_point_id = p_tp_spinal_point_id;
--
  l_proc        varchar2(72) := g_package || 'chk_tp_spinal_point';
  l_SPValid     char(1) := 'N';
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 10);

  if (((p_assignment_attribute_id is not null) and
       nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_spinal_point_id,hr_api.g_number)
        <> nvl(p_tp_spinal_point_id,hr_api.g_number))
      or
      (p_assignment_attribute_id is null)
     ) then

    hr_utility.set_location(l_proc, 20);
    --
    if p_tp_spinal_point_id is not null then

      begin
       open ChkSpinalPoint;
       fetch ChkSpinalPoint into l_SPValid;
       close ChkSpinalPoint;
      exception
       when others then
         l_SPValid := 'N';
      end;

      if l_SPValid = 'N' then

         -- invalid spinal point selected
         fnd_message.set_name('PQP', 'PQP_230570_INVALID_SPINAL_PNT');
         fnd_message.raise_error;

      end if; -- l_SPValid = 'N'

      hr_utility.set_location(l_proc, 30);

    else -- p_tp_spinal_point_id is null
      if nvl(p_tp_safeguarded_rate_type,'AbXy') = 'SP' and
         p_tp_safeguarded_grade is not null then

        -- spinal point id must be supplied if rate type is SP
        fnd_message.set_name('PQP', 'PQP_230571_SPINAL_POINT_MUST');
        fnd_message.raise_error;

      end if; -- tp_safeguarded_rate_type = 'SP'
    end if; -- p_tp_spinal_point_id is not null
  end if; -- (((p_assignment_attribute_id is not null) and...

hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_spinal_point;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_grade_spine >-----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to check if tp_safeguarded_spinal_point_id is
--   valid for the given grade and pay scale.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_tp_safeguarded_grade
--   p_tp_safeguarded_grade_id
--   p_tp_safeguarded_rate_type
--   p_tp_safeguarded_rate_id
--   p_tp_spinal_point_id
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_grade_spine
  (p_assignment_attribute_id    in number
  ,p_tp_safeguarded_grade       in varchar2
  ,p_tp_safeguarded_grade_id    in number
  ,p_tp_safeguarded_rate_type   in varchar2
  ,p_tp_safeguarded_rate_id     in number
  ,p_tp_spinal_point_id         in number
  ,p_validation_start_date      in date
  ,p_validation_end_date        in date
  ) IS
--
  Cursor ChkGradeSpine is
  Select 'Y'
  From pay_rates pr
      ,per_grade_spines_f pgs
      ,per_spinal_point_steps_f psps
  Where pr.parent_spine_id = pgs.parent_spine_id
    and psps.grade_spine_id = pgs.grade_spine_id
    and pgs.grade_id = p_tp_safeguarded_grade_id
    and pr.rate_id = p_tp_safeguarded_rate_id
    and psps.spinal_point_id = p_tp_spinal_point_id
    and p_validation_start_date <= psps.effective_end_date
    and p_validation_end_date >= psps.effective_start_date;


--
  l_proc        varchar2(72) := g_package || 'chk_tp_grade_spine';
  l_GSValid     char(1) := 'N';
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 10);

  if (((p_assignment_attribute_id is not null)
       and
       (nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_spinal_point_id,hr_api.g_number)
        <> nvl(p_tp_spinal_point_id,hr_api.g_number)
        or
        nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_rate_id,hr_api.g_number)
        <> nvl(p_tp_safeguarded_rate_id,hr_api.g_number)
        or
        nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_rate_type,hr_api.g_varchar2)
        <> nvl(p_tp_safeguarded_rate_type,hr_api.g_varchar2)
        or
        nvl(pqp_aat_shd.g_old_rec.tp_safeguarded_grade,hr_api.g_varchar2)
        <> nvl(p_tp_safeguarded_grade,hr_api.g_varchar2)
       )
      )
      or
      (p_assignment_attribute_id is null)
     ) then

    hr_utility.set_location(l_proc, 20);
    --
    if ((p_tp_spinal_point_id is not null) or
        (p_tp_safeguarded_rate_id is not null) or
        (p_tp_safeguarded_grade is not null)
--        or        (p_tp_safeguarded_rate_type is not null)
       )
       and
       p_tp_safeguarded_rate_type = 'SP' then

      -- Now check if the spinal point is valid for this Scale Rate.
      begin
        open ChkGradeSpine;
        fetch ChkGradeSpine into l_GSValid;
        close ChkGradeSpine;
      exception
        when others then
          l_GSValid := 'N';
      end;

      if l_GSValid = 'N' then
        -- spinal point is not valid for this grade and scale rate
        fnd_message.set_name('PQP', 'PQP_230572_INVALID_GRADE_SPINE');
        fnd_message.raise_error;
      end if;

      hr_utility.set_location(l_proc, 30);
    end if; -- (p_tp_spinal_point_id is not null) or
  end if; -- (((p_assignment_attribute_id is not null) and...

hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_grade_spine;
--
-- ---------------------------------------------------------------------------+
-- |-----------------------< chk_tp_fast_track >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to validate tp_fast_track against
--   HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE is 'YES_NO'.
--
-- Pre Conditions:
--
-- In Arguments:
--   p_effective_date
--   p_tp_fast_track
--
-- Post Success:
--   Processing continues
--
-- Post Failure:
--    An application error will be raised and processing is
--    terminated
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure chk_tp_fast_track
  (p_assignment_attribute_id    in number
  ,p_tp_fast_track              in varchar2
  ,p_effective_date             in date
  ,p_validation_start_date      in date
  ,p_validation_end_date        in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_tp_fast_track';
--
Begin
--
hr_utility.set_location(' Entering: '|| l_proc, 10);

  if (((p_assignment_attribute_id is not null) and
       nvl(pqp_aat_shd.g_old_rec.tp_fast_track,
       hr_api.g_varchar2) <> nvl(p_tp_fast_track,
                                 hr_api.g_varchar2))
     or
        (p_assignment_attribute_id is null)) then

    hr_utility.set_location(l_proc, 20);
    --
    if p_tp_fast_track is not null then
      if hr_api.not_exists_in_dt_hr_lookups
           (p_effective_date            => p_effective_date
           ,p_validation_start_date     => p_validation_start_date
           ,p_validation_end_date       => p_validation_end_date
           ,p_lookup_type               => 'YES_NO'
           ,p_lookup_code               => p_tp_fast_track
           ) then

        fnd_message.set_name('PAY', 'HR_7462_PLK_INVLD_VALUE');
        fnd_message.set_token('COLUMN_NAME', 'TP_FAST_TRACK');
        fnd_message.raise_error;

      end if;
      hr_utility.set_location(l_proc, 30);
    end if;
  end if;

hr_utility.set_location(' Leaving: '|| l_proc, 40);
--
end chk_tp_fast_track;
--
--
-- ---------------------------------------------------------------------------+
-- |--------------------------< dt_update_validate >--------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
-- |--------------------------< dt_delete_validate >--------------------------|
-- ---------------------------------------------------------------------------+
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
-- ---------------------------------------------------------------------------+
Procedure dt_delete_validate
  (p_assignment_attribute_id          in number
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
      ,p_argument       => 'assignment_attribute_id'
      ,p_argument_value => p_assignment_attribute_id
      );
    --
  --
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
-- ---------------------------------------------------------------------------+
-- |---------------------------< insert_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure insert_validate
  (p_rec                   in pqp_aat_shd.g_rec_type
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
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  pqp_aat_bus.chk_ddf(p_rec);
  --
  pqp_aat_bus.chk_df(p_rec);
  --

  --
  -- Added for Bugfix 2651375
  -- Check that if one of the work pattern cols is entered, then the
  -- other one is not left NULL
  --
  chk_work_pattern_cols
    (p_work_pattern     => p_rec.work_pattern
    ,p_start_day        => p_rec.start_day
    );

  --
  -- Check that both company and private vehicles have not
  -- been entered.
  --
  chk_private_company_car(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car,
        p_private_car           => p_rec.private_car
        );

  --
  -- Check the same car is not both the primary and secondary car
  --
  chk_prim_sec_duplicate(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car
        );

  --
  -- Check that primary car exists if secondary has been entered
  --
  chk_primary_exists(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car
        );

  --
  -- Check the same car has not been assigned to multiple people
  --
  IF p_rec.primary_company_car IS NOT NULL AND p_rec.secondary_company_car IS NOT NULL THEN -- for bug 6871534
  chk_company_car_duplicate_asg(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car,
        p_assignment_id         => p_rec.assignment_id,
        p_validation_start_date => p_validation_start_date,
        p_validation_end_date   => p_validation_end_date
        );
  End IF;

  --
  -- Check that there are not date overlapping records
  -- for the same assignment
  --
  chk_asg_overlap(
        p_assignment_attribute_id => p_rec.assignment_attribute_id,
        p_assignment_id           => p_rec.assignment_id,
        p_validation_start_date   => p_validation_start_date,
        p_validation_end_date     => p_validation_end_date
        );

  --
  -- Check if the rates table exist in PAY_USER_TABLES
  --
  IF p_rec.company_car_rates_table_id IS NOT NULL THEN
    chk_table_exists(
       p_rates_table_id    => p_rec.company_car_rates_table_id
      ,p_business_group_id => p_rec.business_group_id);
  END IF;

  IF p_rec.private_car_rates_table_id IS NOT NULL THEN
    chk_table_exists(
       p_rates_table_id    => p_rec.private_car_rates_table_id
      ,p_business_group_id => p_rec.business_group_id);
  END IF;

  --
  -- Check that the teacher flag has a value of either Y or N
  --
    chk_tp_is_teacher
        (p_assignment_attribute_id      => p_rec.assignment_attribute_id
        ,p_tp_is_teacher                => p_rec.tp_is_teacher
        ,p_effective_date               => p_effective_date
        ,p_validation_start_date        => p_validation_start_date
        ,p_validation_end_date          => p_validation_end_date
        );


-- added the following check procedure to check if the head teacher grp code is valid or not
    chk_tp_headteacher_grp_code
        (p_assignment_attribute_id     => p_rec.assignment_attribute_id
        ,p_tp_is_teacher	       => p_rec.tp_is_teacher
        ,p_tp_headteacher_grp_code     => p_rec.tp_headteacher_grp_code
        );

  --
  -- Check that the elected pension flag has a value of either Y or N
  --
  chk_tp_elected_pension
      (p_assignment_attribute_id        => p_rec.assignment_attribute_id
      ,p_tp_elected_pension             => p_rec.tp_elected_pension
      ,p_effective_date                 => p_effective_date
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      );
  --
  -- Check that the fast track flag has a value of either Y or N
  --
  chk_tp_fast_track
      (p_assignment_attribute_id        => p_rec.assignment_attribute_id
      ,p_tp_fast_track                  => p_rec.tp_fast_track
      ,p_effective_date                 => p_effective_date
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      );
  --
  chk_tp_safeguarded_grade
      (p_assignment_attribute_id        => p_rec.assignment_attribute_id
      ,p_tp_safeguarded_grade           => p_rec.tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_rec.tp_safeguarded_grade_id
      ,p_effective_date                 => p_effective_date
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      );
  --
  -- Check that interdependencies of TP columns are valid.
  --
  chk_tp_col_dependencies
    (p_tp_is_teacher                    => p_rec.tp_is_teacher
    ,p_tp_elected_pension               => p_rec.tp_elected_pension
    ,p_tp_safeguarded_grade             => p_rec.tp_safeguarded_grade
    ,p_tp_fast_track                    => p_rec.tp_fast_track
    );
  --
  -- Check that grade or scale rate is valid
  --
  chk_tp_safeguarded_rate
    (p_assignment_attribute_id  => p_rec.assignment_attribute_id
    ,p_tp_safeguarded_grade     => p_rec.tp_safeguarded_grade
    ,p_tp_safeguarded_rate_type => p_rec.tp_safeguarded_rate_type
    ,p_tp_safeguarded_rate_id   => p_rec.tp_safeguarded_rate_id
    );
  --
  -- Check that the spinal point is valid
  --
  chk_tp_spinal_point
    (p_assignment_attribute_id  => p_rec.assignment_attribute_id
    ,p_tp_safeguarded_grade     => p_rec.tp_safeguarded_grade
    ,p_tp_safeguarded_rate_type => p_rec.tp_safeguarded_rate_type
    ,p_tp_spinal_point_id       => p_rec.tp_safeguarded_spinal_point_id
    );
  --
  -- Check that the spinal point is valid for the selected pay scale and grade
  --
  chk_tp_grade_spine
    (p_assignment_attribute_id  => p_rec.assignment_attribute_id
    ,p_tp_safeguarded_grade     => p_rec.tp_safeguarded_grade
    ,p_tp_safeguarded_grade_id  => p_rec.tp_safeguarded_grade_id
    ,p_tp_safeguarded_rate_type => p_rec.tp_safeguarded_rate_type
    ,p_tp_safeguarded_rate_id   => p_rec.tp_safeguarded_rate_id
    ,p_tp_spinal_point_id       => p_rec.tp_safeguarded_spinal_point_id
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date      => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< update_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure update_validate
  (p_rec                     in pqp_aat_shd.g_rec_type
  ,p_effective_date          in date
  ,p_datetrack_mode          in varchar2
  ,p_validation_start_date   in date
  ,p_validation_end_date     in date
  ) is
--
  l_proc        varchar2(72) := g_package||'update_validate';
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
  pqp_aat_bus.chk_ddf(p_rec);
  --
  pqp_aat_bus.chk_df(p_rec);

  --
  -- Added for Bugfix 2651375
  -- Check that if one of the work pattern cols is entered, then the
  -- other one is not left NULL
  --
  chk_work_pattern_cols
    (p_work_pattern     => p_rec.work_pattern
    ,p_start_day        => p_rec.start_day
    );

  --
  -- Check that both company and private vehicles have not
  -- been entered.
  --
  chk_private_company_car(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car,
        p_private_car           => p_rec.private_car
        );

  --
  -- Check the same car is not both the primary and secondary car
  --
  chk_prim_sec_duplicate(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car
        );

  --
  -- Check that primary car exists if secondary has been entered
  --
  chk_primary_exists(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car
        );

  --
  -- Check the same car has not been assigned to multiple people
  --
  IF p_rec.primary_company_car IS NOT NULL AND p_rec.secondary_company_car IS NOT NULL THEN -- for bug 6871534
  chk_company_car_duplicate_asg(
        p_primary_company_car   => p_rec.primary_company_car,
        p_secondary_company_car => p_rec.secondary_company_car,
        p_assignment_id         => p_rec.assignment_id,
        p_validation_start_date => p_validation_start_date,
        p_validation_end_date   => p_validation_end_date
        );
  END IF;
  --
  -- Check that there are not date overlapping records
  -- for the same assignment
  --
  chk_asg_overlap(
        p_assignment_attribute_id => p_rec.assignment_attribute_id,
        p_assignment_id           => p_rec.assignment_id,
        p_validation_start_date   => p_validation_start_date,
        p_validation_end_date     => p_validation_end_date
        );

  --
  -- Check if the rates table exist in PAY_USER_TABLES
  --
  IF p_rec.company_car_rates_table_id IS NOT NULL THEN
    chk_table_exists(
       p_rates_table_id    => p_rec.company_car_rates_table_id
      ,p_business_group_id => p_rec.business_group_id);
  END IF;

  IF p_rec.private_car_rates_table_id IS NOT NULL THEN
    chk_table_exists(
       p_rates_table_id    => p_rec.private_car_rates_table_id
      ,p_business_group_id => p_rec.business_group_id);
  END IF;

  --
  -- Check that the teacher flag has a value of either Y or N
  --
  chk_tp_is_teacher
        (p_assignment_attribute_id      => p_rec.assignment_attribute_id
        ,p_tp_is_teacher                => p_rec.tp_is_teacher
        ,p_effective_date               => p_effective_date
        ,p_validation_start_date        => p_validation_start_date
        ,p_validation_end_date          => p_validation_end_date
        );

  --


  -- added the following check procedure to check if the head teacher grp code is valid or not

  chk_tp_headteacher_grp_code
        (p_assignment_attribute_id      => p_rec.assignment_attribute_id
        ,p_tp_is_teacher		=> p_rec.tp_is_teacher
        ,p_tp_headteacher_grp_code      => p_rec.tp_headteacher_grp_code
        );
  -- Check that the teacher flag OR job status change is valid
  --

  chk_job_status_change
    (p_new_job_status   => p_rec.tp_is_teacher
    ,p_old_job_status   => pqp_aat_shd.g_old_rec.tp_is_teacher
    ,p_assignment_id    => p_rec.assignment_id
    ,p_effective_date   => p_effective_date
    ,p_datetrack_mode   => p_datetrack_mode
    );

  --
  -- Check that the elected pension flag has a value of either Y or N
  --
  chk_tp_elected_pension
        (p_assignment_attribute_id      => p_rec.assignment_attribute_id
        ,p_tp_elected_pension           => p_rec.tp_elected_pension
        ,p_effective_date               => p_effective_date
        ,p_validation_start_date        => p_validation_start_date
        ,p_validation_end_date          => p_validation_end_date
      );
  --
  -- Check that the fast track flag has a value of either Y or N
  --
  chk_tp_fast_track
      (p_assignment_attribute_id        => p_rec.assignment_attribute_id
      ,p_tp_fast_track                  => p_rec.tp_fast_track
      ,p_effective_date                 => p_effective_date
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      );
  --
  -- Check that the safeguarded grade is of the correct format
  --
  chk_tp_safeguarded_grade
      (p_assignment_attribute_id        => p_rec.assignment_attribute_id
      ,p_tp_safeguarded_grade           => p_rec.tp_safeguarded_grade
      ,p_tp_safeguarded_grade_id        => p_rec.tp_safeguarded_grade_id
      ,p_effective_date                 => p_effective_date
      ,p_validation_start_date          => p_validation_start_date
      ,p_validation_end_date            => p_validation_end_date
      );
  --
  -- Check that interdependencies of TP columns are valid.
  --
  chk_tp_col_dependencies
    (p_tp_is_teacher                    => p_rec.tp_is_teacher
    ,p_tp_elected_pension               => p_rec.tp_elected_pension
    ,p_tp_safeguarded_grade             => p_rec.tp_safeguarded_grade
    ,p_tp_fast_track                    => p_rec.tp_fast_track
    );
  --
  -- Check that grade or scale rate is valid
  --
  chk_tp_safeguarded_rate
    (p_assignment_attribute_id  => p_rec.assignment_attribute_id
    ,p_tp_safeguarded_grade     => p_rec.tp_safeguarded_grade
    ,p_tp_safeguarded_rate_type => p_rec.tp_safeguarded_rate_type
    ,p_tp_safeguarded_rate_id   => p_rec.tp_safeguarded_rate_id
    );
  --
  -- Check that the spinal point is valid
  --
  chk_tp_spinal_point
    (p_assignment_attribute_id  => p_rec.assignment_attribute_id
    ,p_tp_safeguarded_grade     => p_rec.tp_safeguarded_grade
    ,p_tp_safeguarded_rate_type => p_rec.tp_safeguarded_rate_type
    ,p_tp_spinal_point_id       => p_rec.tp_safeguarded_spinal_point_id
    );
  --
  -- Check that the spinal point is valid for the selected pay scale and grade
  --
  chk_tp_grade_spine
    (p_assignment_attribute_id  => p_rec.assignment_attribute_id
    ,p_tp_safeguarded_grade     => p_rec.tp_safeguarded_grade
    ,p_tp_safeguarded_grade_id  => p_rec.tp_safeguarded_grade_id
    ,p_tp_safeguarded_rate_type => p_rec.tp_safeguarded_rate_type
    ,p_tp_safeguarded_rate_id   => p_rec.tp_safeguarded_rate_id
    ,p_tp_spinal_point_id       => p_rec.tp_safeguarded_spinal_point_id
    ,p_validation_start_date    => p_validation_start_date
    ,p_validation_end_date      => p_validation_end_date
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ---------------------------------------------------------------------------+
-- |---------------------------< delete_validate >----------------------------|
-- ---------------------------------------------------------------------------+
Procedure delete_validate
  (p_rec                    in pqp_aat_shd.g_rec_type
  ,p_effective_date         in date
  ,p_datetrack_mode         in varchar2
  ,p_validation_start_date  in date
  ,p_validation_end_date    in date
  ) is
--
  l_proc        varchar2(72) := g_package||'delete_validate';
  l_asg         number;

  cursor c_asg is
  select assignment_id
  from pqp_assignment_attributes_f
  where assignment_attribute_id = p_rec.assignment_attribute_id
  and p_effective_date between effective_start_date
                       and effective_end_date;

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
    ,p_assignment_attribute_id          => p_rec.assignment_attribute_id
    );
  --

  --
  -- Check that there are not date overlapping records
  -- for the same assignment
  --

  if p_datetrack_mode in ('DELETE_NEXT_CHANGE', 'FUTURE_CHANGE') then
  --
    open c_asg;
    fetch c_asg into l_asg;
    close c_asg;

    chk_asg_overlap(
        p_assignment_attribute_id => p_rec.assignment_attribute_id,
        p_assignment_id           => l_asg,
        p_validation_start_date   => p_validation_start_date,
        p_validation_end_date     => p_validation_end_date
        );
  --
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pqp_aat_bus;

/
