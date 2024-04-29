--------------------------------------------------------
--  DDL for Package Body HR_PDT_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PDT_BUS" as
/* $Header: hrpdtrhi.pkb 120.4.12010000.2 2008/08/06 08:46:56 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_pdt_bus.';  -- Global package name
g_debug    boolean      := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_person_deployment_id        number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_person_deployment_id                 in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , hr_person_deployments pdt
     where pdt.person_deployment_id = p_person_deployment_id
         and pbg.business_group_id = pdt.to_business_group_id;
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
    ,p_argument           => 'person_deployment_id'
    ,p_argument_value     => p_person_deployment_id
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
     fnd_message.raise_error;
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
  (p_person_deployment_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf     pbg
         , hr_person_deployments pdt
     where pdt.person_deployment_id = p_person_deployment_id
         and pbg.business_group_id = pdt.to_business_group_id;
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
    ,p_argument           => 'person_deployment_id'
    ,p_argument_value     => p_person_deployment_id
    );
  --
  if ( nvl(hr_pdt_bus.g_person_deployment_id, hr_api.g_number)
       = p_person_deployment_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := hr_pdt_bus.g_legislation_code;
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
    hr_pdt_bus.g_person_deployment_id        := p_person_deployment_id;
    hr_pdt_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in hr_pdt_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.person_deployment_id is not null)  and (
    nvl(hr_pdt_shd.g_old_rec.per_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.per_information_category, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information1, hr_api.g_varchar2) <>
    nvl(p_rec.per_information1, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information2, hr_api.g_varchar2) <>
    nvl(p_rec.per_information2, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information3, hr_api.g_varchar2) <>
    nvl(p_rec.per_information3, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information4, hr_api.g_varchar2) <>
    nvl(p_rec.per_information4, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information5, hr_api.g_varchar2) <>
    nvl(p_rec.per_information5, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information6, hr_api.g_varchar2) <>
    nvl(p_rec.per_information6, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information7, hr_api.g_varchar2) <>
    nvl(p_rec.per_information7, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information8, hr_api.g_varchar2) <>
    nvl(p_rec.per_information8, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information9, hr_api.g_varchar2) <>
    nvl(p_rec.per_information9, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information10, hr_api.g_varchar2) <>
    nvl(p_rec.per_information10, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information11, hr_api.g_varchar2) <>
    nvl(p_rec.per_information11, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information12, hr_api.g_varchar2) <>
    nvl(p_rec.per_information12, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information13, hr_api.g_varchar2) <>
    nvl(p_rec.per_information13, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information14, hr_api.g_varchar2) <>
    nvl(p_rec.per_information14, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information15, hr_api.g_varchar2) <>
    nvl(p_rec.per_information15, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information16, hr_api.g_varchar2) <>
    nvl(p_rec.per_information16, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information17, hr_api.g_varchar2) <>
    nvl(p_rec.per_information17, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information18, hr_api.g_varchar2) <>
    nvl(p_rec.per_information18, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information19, hr_api.g_varchar2) <>
    nvl(p_rec.per_information19, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information20, hr_api.g_varchar2) <>
    nvl(p_rec.per_information20, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information21, hr_api.g_varchar2) <>
    nvl(p_rec.per_information21, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information22, hr_api.g_varchar2) <>
    nvl(p_rec.per_information22, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information23, hr_api.g_varchar2) <>
    nvl(p_rec.per_information23, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information24, hr_api.g_varchar2) <>
    nvl(p_rec.per_information24, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information25, hr_api.g_varchar2) <>
    nvl(p_rec.per_information25, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information26, hr_api.g_varchar2) <>
    nvl(p_rec.per_information26, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information27, hr_api.g_varchar2) <>
    nvl(p_rec.per_information27, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information28, hr_api.g_varchar2) <>
    nvl(p_rec.per_information28, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information29, hr_api.g_varchar2) <>
    nvl(p_rec.per_information29, hr_api.g_varchar2)  or
    nvl(hr_pdt_shd.g_old_rec.per_information30, hr_api.g_varchar2) <>
    nvl(p_rec.per_information30, hr_api.g_varchar2) ))
    or (p_rec.person_deployment_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Person Developer DF'
      ,p_attribute_category              => p_rec.per_information_category
      ,p_attribute1_name                 => 'PER_INFORMATION1'
      ,p_attribute1_value                => p_rec.per_information1
      ,p_attribute2_name                 => 'PER_INFORMATION2'
      ,p_attribute2_value                => p_rec.per_information2
      ,p_attribute3_name                 => 'PER_INFORMATION3'
      ,p_attribute3_value                => p_rec.per_information3
      ,p_attribute4_name                 => 'PER_INFORMATION4'
      ,p_attribute4_value                => p_rec.per_information4
      ,p_attribute5_name                 => 'PER_INFORMATION5'
      ,p_attribute5_value                => p_rec.per_information5
      ,p_attribute6_name                 => 'PER_INFORMATION6'
      ,p_attribute6_value                => p_rec.per_information6
      ,p_attribute7_name                 => 'PER_INFORMATION7'
      ,p_attribute7_value                => p_rec.per_information7
      ,p_attribute8_name                 => 'PER_INFORMATION8'
      ,p_attribute8_value                => p_rec.per_information8
      ,p_attribute9_name                 => 'PER_INFORMATION9'
      ,p_attribute9_value                => p_rec.per_information9
      ,p_attribute10_name                => 'PER_INFORMATION10'
      ,p_attribute10_value               => p_rec.per_information10
      ,p_attribute11_name                => 'PER_INFORMATION11'
      ,p_attribute11_value               => p_rec.per_information11
      ,p_attribute12_name                => 'PER_INFORMATION12'
      ,p_attribute12_value               => p_rec.per_information12
      ,p_attribute13_name                => 'PER_INFORMATION13'
      ,p_attribute13_value               => p_rec.per_information13
      ,p_attribute14_name                => 'PER_INFORMATION14'
      ,p_attribute14_value               => p_rec.per_information14
      ,p_attribute15_name                => 'PER_INFORMATION15'
      ,p_attribute15_value               => p_rec.per_information15
      ,p_attribute16_name                => 'PER_INFORMATION16'
      ,p_attribute16_value               => p_rec.per_information16
      ,p_attribute17_name                => 'PER_INFORMATION17'
      ,p_attribute17_value               => p_rec.per_information17
      ,p_attribute18_name                => 'PER_INFORMATION18'
      ,p_attribute18_value               => p_rec.per_information18
      ,p_attribute19_name                => 'PER_INFORMATION19'
      ,p_attribute19_value               => p_rec.per_information19
      ,p_attribute20_name                => 'PER_INFORMATION20'
      ,p_attribute20_value               => p_rec.per_information20
      ,p_attribute21_name                => 'PER_INFORMATION21'
      ,p_attribute21_value               => p_rec.per_information21
      ,p_attribute22_name                => 'PER_INFORMATION22'
      ,p_attribute22_value               => p_rec.per_information22
      ,p_attribute23_name                => 'PER_INFORMATION23'
      ,p_attribute23_value               => p_rec.per_information23
      ,p_attribute24_name                => 'PER_INFORMATION24'
      ,p_attribute24_value               => p_rec.per_information24
      ,p_attribute25_name                => 'PER_INFORMATION25'
      ,p_attribute25_value               => p_rec.per_information25
      ,p_attribute26_name                => 'PER_INFORMATION26'
      ,p_attribute26_value               => p_rec.per_information26
      ,p_attribute27_name                => 'PER_INFORMATION27'
      ,p_attribute27_value               => p_rec.per_information27
      ,p_attribute28_name                => 'PER_INFORMATION28'
      ,p_attribute28_value               => p_rec.per_information28
      ,p_attribute29_name                => 'PER_INFORMATION29'
      ,p_attribute29_value               => p_rec.per_information29
      ,p_attribute30_name                => 'PER_INFORMATION30'
      ,p_attribute30_value               => p_rec.per_information30
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
  (p_rec in hr_pdt_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error       exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT hr_pdt_shd.api_updating
      (p_person_deployment_id              => p_rec.person_deployment_id
      ,p_object_version_number             => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  if nvl(p_rec.from_business_group_id,hr_api.g_number)
        <> nvl(hr_pdt_shd.g_old_rec.from_business_group_id,hr_api.g_number) then
     l_argument := 'from_business_group';
     raise l_error;
  end if;
  --
  if nvl(p_rec.to_business_group_id,hr_api.g_number)
        <> nvl(hr_pdt_shd.g_old_rec.to_business_group_id,hr_api.g_number) then
     l_argument := 'to_business_group';
     raise l_error;
  end if;
  --
  if nvl(p_rec.from_person_id,hr_api.g_number)
        <> nvl(hr_pdt_shd.g_old_rec.from_person_id,hr_api.g_number) then
     l_argument := 'from_person_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.permanent,hr_api.g_number)
        <> nvl(hr_pdt_shd.g_old_rec.permanent,hr_api.g_number) then
     l_argument := 'permanent';
     raise l_error;
  end if;
  --
  --
  hr_utility.set_location(' Leaving : '|| l_proc, 30);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
End chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_business_groups >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that both from and to business group ids exist
--    in per_business_groups
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_from_business_group_id
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--     is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_business_groups
  (p_from_business_group_id in hr_person_deployments.from_business_group_id%type
  ,p_to_business_group_id in hr_person_deployments.to_business_group_id%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_business_groups';
  l_dummy       number;
  --
  cursor csr_bg_exists(p_bg_id in number) is
  select 1
  from   per_business_groups_perf
  where  business_group_id = p_bg_id;
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'from_business_group_id'
    ,p_argument_value => p_from_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  open csr_bg_exists(p_from_business_group_id);
  fetch csr_bg_exists into l_dummy;
  if csr_bg_exists%notfound then
     close csr_bg_exists;
     fnd_message.set_name('PER','HR_449627_PDT_FROM_BG_NOTEXIST');
     hr_multi_message.add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.FROM_BUSINESS_GROUP_ID');
  else
     close csr_bg_exists;
  end if;
  --
  open csr_bg_exists(p_to_business_group_id);
  fetch csr_bg_exists into l_dummy;
  if csr_bg_exists%notfound then
     close csr_bg_exists;
     fnd_message.set_name('PER','HR_449628_PDT_TO_BG_NOTEXIST');
     hr_multi_message.add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID');
  else
     close csr_bg_exists;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
end chk_business_groups;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_from_person_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the from person id exists on the start date in
--    the from business group in per_all_people_f
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_from_person_id
--    p_from_business_group_id
--    p_start_date
--
--  Post Success :
--    Processing continues if the  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--     is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_from_person_id
  (p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ,p_from_person_id         in hr_person_deployments.from_person_id%type
  ,p_from_business_group_id in hr_person_deployments.from_business_group_id%type
  ,p_start_date             in date
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_from_person_id';
  l_dummy       number;
  l_api_updating     boolean;
  --
  cursor csr_check_person(p_person_id number, p_effective_date in date) is
  select 1
  from   per_all_people_f per,
         per_periods_of_service pds
  where  per.person_id = p_person_id
  and    p_effective_date between
         per.effective_start_date and per.effective_end_date
  and    per.business_group_id = p_from_business_group_id
  and    pds.person_id = per.person_id
  and    p_start_date between
         pds.date_start and nvl(pds.actual_termination_date,hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'from_business_group_id'
    ,p_argument_value => p_from_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'from_person_id'
    ,p_argument_value => p_from_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.FROM_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    --
    --  Only proceed with validation if:
    --  a) rec is being inserted or
    --  b) rec is updating and the g_old_rec is not current value
    --
    if ( (l_api_updating and (hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating)
    then
      open csr_check_person(p_from_person_id, p_start_date);
      fetch csr_check_person into l_dummy;
      if csr_check_person%notfound then
         close csr_check_person;
         --
         fnd_message.set_name('PER','HR_449629_PDT_FR_PER_NOTEXIST');
         fnd_message.raise_error;
      else
         close csr_check_person;
      end if;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.FROM_PERSON_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_from_person_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_to_person_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that if specified, the to person id exists on the
--   start date in to business group in per_all_people_f, and the to_person_id is
--   not of type EMP,CWK, or APL on the start_date or in the future
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_to_person_id
--    p_to_business_group_id
--    p_start_date
--    p_status
--
--  Post Success :
--    Processing continues if the to_person_id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    to_person_id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_to_person_id
  (p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ,p_to_person_id           in hr_person_deployments.to_person_id%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_start_date             in date
  ,p_status                 in hr_person_deployments.status%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_to_person_id';
  l_dummy       number;
  l_api_updating     boolean;
  --
  cursor csr_check_person(p_person_id number) is
  select per.person_id
  from   per_all_people_f per
  where  per.person_id = p_person_id
  and    p_start_date between
         per.effective_start_date and per.effective_end_date
  and    per.business_group_id = p_to_business_group_id;
  --
  cursor csr_check_per_type(p_person_id number) is
  select ptu.person_type_id
  from   per_person_type_usages_f ptu,
         per_person_types ppt
  where  ptu.person_id = p_person_id
  and    ptu.person_type_id = ppt.person_type_id
  and    ppt.system_person_type in ('EMP','CWK','APL')
  and    ptu.effective_end_date >= p_start_date;
  --
  cursor csr_check_per_type2(p_person_id number) is
  select ptu.person_type_id
  from   per_person_type_usages_f ptu,
         per_person_types ppt
  where  ptu.person_id = p_person_id
  and    ptu.person_type_id = ppt.person_type_id
  and    ppt.system_person_type in ('EMP','CWK','APL')
  and    ptu.effective_start_date > p_start_date
  and not exists (select 1
                  from   per_person_type_usages_f ptu1,
                         per_person_types ppt1
                  where  ptu.person_type_usage_id = ptu1.person_type_usage_id
                  and    ptu1.person_type_id = ppt1.person_type_id
                  and    ppt1.system_person_type in ('EMP','CWK','APL')
                  and    ptu1.effective_start_date = p_start_date);
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'status'
    ,p_argument_value => p_status
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.FROM_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    --
    --  Only proceed with validation if:
    --  a) rec is being inserted or
    --  b) rec is updating and the g_old_rec is not current value
    --
    if ( (l_api_updating and
         (       hr_pdt_shd.g_old_rec.start_date <> p_start_date
          or nvl(hr_pdt_shd.g_old_rec.to_person_id,hr_api.g_number)
                 <> nvl(p_to_person_id,hr_api.g_number)))
        or not l_api_updating)
    then
      if p_to_person_id is not null then

	open csr_check_person(p_to_person_id);
	fetch csr_check_person into l_dummy;
	if csr_check_person%notfound then
	   close csr_check_person;
	   --
	   fnd_message.set_name('PER','HR_449630_PDT_TO_PER_NOTEXIST');
	   fnd_message.raise_error;
	else
	   close csr_check_person;
	   --
           -- only check person type in host if we are in DRAFT status or
           -- upon initiation when DRAFT becomes ACTIVE
           --
           if  p_status='DRAFT' then
             --
	     open csr_check_per_type(p_to_person_id);
	     fetch csr_check_per_type into l_dummy;
	     if csr_check_per_type%found then
	       close csr_check_per_type;
	       fnd_message.set_name('PER','HR_449631_PDT_TO_PER_FUT_PER');
	       fnd_message.raise_error;
	     else
	       close csr_check_per_type;
	     end if;  --check future person types
             --
           elsif p_status='ACTIVE' and hr_pdt_shd.g_old_rec.status='DRAFT' then
             --
	     open csr_check_per_type2(p_to_person_id);
	     fetch csr_check_per_type2 into l_dummy;
	     if csr_check_per_type2%found then
	       close csr_check_per_type2;
	       fnd_message.set_name('PER','HR_449631_PDT_TO_PER_FUT_PER');
	       fnd_message.raise_error;
	     else
	       close csr_check_per_type2;
	     end if;  --check future person types
             --
          end if;  --status checks
	end if;  --check person
	--
      end if; --to_person_id not null
      --
      if p_to_person_id is null and (p_status='ACTIVE' or p_status='COMPLETE') then
        fnd_message.set_name('PER','HR_449632_PDT_TO_PER_NULL');
        fnd_message.raise_error;
      end if; --status check
      --
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.TO_PERSON_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_to_person_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_person_type_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that person type is valid in the to business group
--    and is of type EMP, and is active
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--  p_person_type_id
--  p_to_business_group_id
--
--  Post Success :
--    Processing continues if the person type id  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    person type id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_person_type_id
  (p_person_type_id         in hr_person_deployments.person_type_id%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc             varchar2(72) := g_package||'chk_';
  l_api_updating     boolean;
  l_sys_type         per_person_types.system_person_type%type;
  l_bg_id            per_person_types.business_group_id%type;
  l_active_flag      per_person_types.active_flag%type;
  --
  cursor csr_check_per_type is
  select system_person_type,business_group_id,active_flag
  from   per_person_types
  where  person_type_id = p_person_type_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if (( (l_api_updating and
         (nvl(hr_pdt_shd.g_old_rec.person_type_id,hr_api.g_number)
                          <> nvl(p_person_type_id,hr_api.g_number)))
        or not l_api_updating)
        and p_person_type_id is not null) then
          --
	  open csr_check_per_type;
	  fetch csr_check_per_type into l_sys_type,l_bg_id,l_active_flag;
	  if csr_check_per_type%notfound then
	     close csr_check_per_type;
	     fnd_message.set_name('PER','HR_7513_PER_TYPE_INVALID');
	     fnd_message.raise_error;
          else
	    close csr_check_per_type;
	    --
	    if l_sys_type <> 'EMP' then
	      fnd_message.set_name('PER','HR_7513_PER_TYPE_INVALID');
	      fnd_message.raise_error;
	    end if;
	    if l_bg_id <> p_to_business_group_id then
	      fnd_message.set_name('PER','HR_7974_PER_TYPE_INV_BUS_GROUP');
	      fnd_message.raise_error;
	    end if;
	    if l_active_flag <> 'Y' then
	      fnd_message.set_name('PER','HR_7973_PER_TYPE_NOT_ACTIVE');
	      fnd_message.raise_error;
	    end if;
          end if;  --csr notfound

    end if; --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.PERSON_TYPE_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_person_type_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_start_end_date >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the start date is not greater than the end date
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_start_date
--    p_end_date
--
--  Post Success :
--    Processing continues if the dates are valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    dates are invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_start_end_date
  (p_start_date             in hr_person_deployments.start_date%type
  ,p_end_date               in hr_person_deployments.end_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ,p_status                 in hr_person_deployments.status%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_start_end_date';
  l_api_updating     boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.END_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
         (   hr_pdt_shd.g_old_rec.start_date <> p_start_date
          or nvl(hr_pdt_shd.g_old_rec.end_date,hr_api.g_date)
                 <> nvl(p_end_date,hr_api.g_date)))
        or not l_api_updating) then
      --
      -- bug fix 5665505
      -- commented the following code
      /*
      -- Added check for COMPLETED deployments: Bug 5494622
      if (p_status = 'COMPLETE' and p_start_date > nvl(p_end_date,hr_api.g_eot))
       then
        fnd_message.set_name('PER','HR_449621_PDT_CHG_DATES');
        fnd_message.raise_error;
      end if;

      if (p_status <> 'COMPLETE' and p_start_date >= nvl(p_end_date,hr_api.g_eot))
       then
        fnd_message.set_name('PER','HR_449621_PDT_CHG_DATES');
        fnd_message.raise_error;
      end if;
      --
      */
     -- added the following piece of code
     -- bug fix 5665505
     --
     if p_start_date > nvl(p_end_date,hr_api.g_eot)
	 then
	  fnd_message.set_name('PER','HR_449621_PDT_CHG_DATES');
	  fnd_message.raise_error;
	end if;
	--
      -- End of Additions
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.END_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_start_end_date;
--
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_start_date >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This function validates that the deployment start date is not greater
--    than the employee start date.
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_start_date
--    p_person_id
--
--  Post Success :
--    Processing continues if the dates are valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    dates are invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
FUNCTION chk_start_date
  (p_person_id in HR_PERSON_DEPLOYMENTS.FROM_PERSON_ID%type
  ,p_start_date in HR_PERSON_DEPLOYMENTS.START_DATE%type
  ) RETURN VARCHAR2
   is

 -- Declare Cursor

 cursor csr_get_min_st_date is
 select min(effective_start_date) from per_all_people_f
 where person_id = p_person_id;

 -- Declare Local Variables

 l_emp_date_start date;
 l_dep_start_date date;



 begin

 l_dep_start_date := trunc(p_start_date);

 open csr_get_min_st_date;
 fetch csr_get_min_st_date into l_emp_date_start;

 if csr_get_min_st_date%notfound then
 fnd_message.set_name('PER','HR_449629_PDT_FR_PER_NOTEXIST');
 fnd_message.raise_error;
 end if;

 if(l_dep_start_date < l_emp_date_start) then
 return 'Y';
 else return 'N';
 end if;

 end chk_start_date;

--  ---------------------------------------------------------------------------
--  |------------------------< chk_permanent >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that permanent is a valid value of 'Y','N' or null
--    If PERMANENT='Y', then end date must be null
--    If PERMANENT='Y', the from_person_id cannot have a future person record change
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_permanent
--    p_from_person_id
--    p_end_date
--
--  Post Success :
--    Processing continues if the  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--     is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_permanent
  (p_permanent              in hr_person_deployments.permanent%type
  ,p_from_person_id         in hr_person_deployments.from_person_id%type
  ,p_end_date               in hr_person_deployments.end_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_permanent';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_fut_home_per is
  select 1
  from   per_all_people_f
  where  person_id = p_from_person_id
  and    effective_start_date > nvl(p_end_date,hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'from_person_id'
    ,p_argument_value => p_from_person_id
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.END_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          nvl(hr_pdt_shd.g_old_rec.end_date,hr_api.g_date)
              <> nvl(p_end_date,hr_api.g_date))
        or not l_api_updating) then
      --
      if (p_permanent <> 'Y' and p_permanent <> 'N' and p_permanent is not null) then
        fnd_message.set_name('PER','HR_449633_PDT_PERM_INVALID');
        fnd_message.raise_error;
      end if;
      --
      if (p_permanent is not null and p_permanent = 'Y') then
        if nvl(p_end_date,hr_api.g_date) <> hr_api.g_date then
          fnd_message.set_name('PER','HR_449634_PDT_PERM_NO_END');
          fnd_message.raise_error;
        end if;
        --
        open csr_check_fut_home_per;
        fetch csr_check_fut_home_per into l_dummy;
        if csr_check_fut_home_per%found then
          fnd_message.set_name('PER','HR_449635_PDT_HOME_FUTPER');
          fnd_message.raise_error;
        end if;
        --
      end if;
      --
    end if;  --api updating
  end if;  --multi mesage
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.PERMANENT'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_permanent;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_deployment_reason >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that deployment reason exists as a lookup code on
--    HR_LEG_LOOKUPS for the lookup type 'HR_DEPLOYMENT_REASONS' with an enabled flag
--    set to 'Y' and start_date of the deployment between start_date_active and
--     end_date_active on HR_LEG_LOOKUPS
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_deployment_reason
--    p_start_date
--
--  Post Success :
--    Processing continues if the deployment reason is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    deployment reason is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_deployment_reason
  (p_deployment_reason      in hr_person_deployments.deployment_reason%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_deployment_reason';
  l_api_updating     boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
           (   hr_pdt_shd.g_old_rec.start_date <> p_start_date
            or nvl(hr_pdt_shd.g_old_rec.deployment_reason,hr_api.g_varchar2)
                <> nvl(p_deployment_reason,hr_api.g_varchar2)))
        or not l_api_updating) then
      --
      if  p_deployment_reason is not null
      and hr_api.not_exists_in_leg_lookups
            (p_effective_date        => p_start_date
            ,p_lookup_type           => 'HR_DEPLOYMENT_REASONS'
            ,p_lookup_code           => p_deployment_reason
             )
      then
        fnd_message.set_name('PER','HR_449636_PDT_REAS_NOTEXIST');
        fnd_message.raise_error;
      end if;
     end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.DEPLOYMENT_REASON'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_deployment_reason;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_employee_number >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that employee number is not set unless to
--    to business group has manual numbering or automatic global numbering.
--    If to_person_id is specified, the employee number if specified must be the same
--    number as the to_person_id
--    The number specified must be unique.
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_employee_number
--    p_to_business_group_id
--    p_to_person_id
--
--  Post Success :
--    Processing continues if the employee number is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    employee number is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_employee_number
  (p_employee_number in hr_person_deployments.employee_number%type
  ,p_to_business_group_id in hr_person_deployments.to_business_group_id%type
  ,p_to_person_id in hr_person_deployments.to_person_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc             varchar2(72) := g_package||'chk_employee_number';
  l_api_updating     boolean;
  l_dummy            number;
  l_numgen_method    per_all_people_f.employee_number%type;
  l_host_empnum      per_all_people_f.employee_number%type;
  l_global_num_set   fnd_profile_option_values.profile_option_value%type;
  --
  cursor csr_numgen_method is
  select pbg.method_of_generation_emp_num
  from   per_business_groups pbg
  where  pbg.business_group_id=p_to_business_group_id;
  --
  cursor csr_check_host_number is
  select employee_number
  from   per_all_people_f
  where  person_id = p_to_person_id
  and    effective_end_date = hr_api.g_eot;
  --
  cursor csr_check_num_unique is
  select 1
  from   per_all_people_f
  where  effective_end_date = hr_api.g_eot
  and    employee_number=p_employee_number
  and    business_group_id = p_to_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_PERSON_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
           (nvl(hr_pdt_shd.g_old_rec.employee_number,hr_api.g_varchar2)
                <> nvl(p_employee_number,hr_api.g_varchar2)))
        or not l_api_updating) then
      --
      if p_employee_number is not null then
        --get num gen method
        open csr_numgen_method;
        fetch csr_numgen_method into l_numgen_method;
        close csr_numgen_method;
        --
        l_global_num_set := fnd_profile.value('PER_GLOBAL_EMP_NUM');
        --
        if l_numgen_method='N'
           or (l_numgen_method='A' and l_global_num_set <> 'Y') then
           fnd_message.set_name('PER','HR_449637_PDT_NUMGENMETH');
           fnd_message.raise_error;
        end if;
        --
        if p_to_person_id is not null then
          open csr_check_host_number;
          fetch csr_check_host_number into l_host_empnum;
          close csr_check_host_number;
          --
          if l_host_empnum <> p_employee_number then
            fnd_message.set_name('PER','HR_449638_PDT_NUM_HOST');
            fnd_message.raise_error;
          end if;
        elsif p_to_person_id is null
          and not(l_numgen_method = 'A' and l_global_num_set = 'Y') then
	  --
	  --check that number is not used already in ToBG
	  --
	  open csr_check_num_unique;
	  fetch csr_check_num_unique into l_dummy;
          if csr_check_num_unique%found then
            close csr_check_num_unique;
            fnd_message.set_name('PER','HR_449639_PDT_NUM_USED');
            fnd_message.raise_error;
          else
            close csr_check_num_unique;
          end if;
        end if;  --p_to_person_id not null
      end if;  --p_employee_number not null
    end if; --api updating
  end if; --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.EMPLOYEE_NUMBER'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_employee_number;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_leaving_reason >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that leaving reason exists as a lookup code on
--    HR_LEG_LOOKUPS for the lookup type 'LEAV_REAS' with an enabled flag
--    set to 'Y' and start_date of the deployment between start_date_active and
--     end_date_active on HR_LEG_LOOKUPS
--    A value cannot be entered if PERMANENT='Y'
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_leaving_reason
--    p_to_business_group_id
--    p_permanent
--
--  Post Success :
--    Processing continues if the leaving_reason is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    leaving_reason is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_leaving_reason
  (p_leaving_reason         in hr_person_deployments.leaving_reason%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_permanent              in hr_person_deployments.permanent%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_leaving_reason';
  l_api_updating     boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
           (nvl(hr_pdt_shd.g_old_rec.leaving_reason,hr_api.g_varchar2)
                <> nvl(p_leaving_reason,hr_api.g_varchar2)))
        or not l_api_updating) then
      --
      if p_leaving_reason is not null then
        if nvl(p_permanent,'N') = 'Y' then
          fnd_message.set_name('PER','HR_449640_PDT_PERM_LEAV_REAS');
          fnd_message.raise_error;
        end if;
        --
        if hr_api.not_exists_in_leg_lookups
             (p_effective_date        => p_start_date
             ,p_lookup_type           => 'LEAV_REAS'
             ,p_lookup_code           => p_leaving_reason
              ) then
           fnd_message.set_name('PER','HR_7485_PDS_INV_LR');
           fnd_message.raise_error;
        end if;  -- lookup validation
      end if;  --leaving reason not null
    end if; --api updating
  end if; --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.LEAVING_REASON'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_leaving_reason;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_leaving_person_type_id >-------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that leaving person type exists in the
--    to business group and is active and of type EX_EMP.
--    A value cannot be specified if PERMANENT='Y'
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--  p_leaving_person_type_id
--  p_to_business_group_id
--  p_permanent
--
--  Post Success :
--    Processing continues if the leaving person type id  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    leaving person type id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_leaving_person_type_id
  (p_leaving_person_type_id in hr_person_deployments.leaving_person_type_id%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_permanent              in hr_person_deployments.permanent%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc             varchar2(72) := g_package||'chk_';
  l_api_updating     boolean;
  l_sys_type         per_person_types.system_person_type%type;
  l_bg_id            per_person_types.business_group_id%type;
  l_active_flag      per_person_types.active_flag%type;
  --
  cursor csr_check_per_type is
  select system_person_type,business_group_id,active_flag
  from   per_person_types
  where  person_type_id = p_leaving_person_type_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if (( (l_api_updating and
         (nvl(hr_pdt_shd.g_old_rec.leaving_person_type_id,hr_api.g_number)
                          <> nvl(p_leaving_person_type_id,hr_api.g_number)))
        or not l_api_updating)
        and p_leaving_person_type_id is not null) then
          --
	  if nvl(p_permanent,'N') = 'Y' then
	    fnd_message.set_name('PER','HR_449641_PDT_PERM_LEAV_TYPE');
	    fnd_message.raise_error;
	  end if;
          --
	  open csr_check_per_type;
	  fetch csr_check_per_type into l_sys_type,l_bg_id,l_active_flag;
	  if csr_check_per_type%notfound then
	     close csr_check_per_type;
	     fnd_message.set_name('PER','HR_7513_PER_TYPE_INVALID');
	     fnd_message.raise_error;
          else
	    close csr_check_per_type;
	    --
	    if l_sys_type <> 'EX_EMP' then
	      fnd_message.set_name('PER','HR_7513_PER_TYPE_INVALID');
	      fnd_message.raise_error;
	    end if;
	    if l_bg_id <> p_to_business_group_id then
	      fnd_message.set_name('PER','HR_7974_PER_TYPE_INV_BUS_GROUP');
	      fnd_message.raise_error;
	    end if;
	    if l_active_flag <> 'Y' then
	      fnd_message.set_name('PER','HR_7973_PER_TYPE_NOT_ACTIVE');
	      fnd_message.raise_error;
	    end if;
          end if;  --csr notfound

    end if; --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.LEAVING_PERSON_TYPE_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_leaving_person_type_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_status >-----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that status exists as a lookup code on
--    HR_LEG_LOOKUPS for the lookup type 'HR_DEPLOYMENT_STATUSES' with an enabled flag
--    set to 'Y' and start_date of the deployment between start_date_active and
--     end_date_active on HR_LEG_LOOKUPS
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_status
--    p_start_date
--
--  Post Success :
--    Processing continues if the status is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    status is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_status
  (p_status in hr_person_deployments.status%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_status';
  l_api_updating     boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'status'
    ,p_argument_value => p_status
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.STATUS'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
         (hr_pdt_shd.g_old_rec.status <> p_status))
        or not l_api_updating) then
       --
       if hr_api.not_exists_in_leg_lookups
            (p_effective_date        => p_start_date
            ,p_lookup_type           => 'HR_DEPLOYMENT_STATUSES'
            ,p_lookup_code           => p_status
             ) then
           fnd_message.set_name('PER','HR_7485_PDS_INV_LR');
           fnd_message.raise_error;
       end if;
       --
       if not l_api_updating and (p_status='ACTIVE' or p_status='COMPLETE') then
           fnd_message.set_name('PER','HR_449642_PDT_INS_STATUS');
           fnd_message.raise_error;
       end if;

    end if;  --api updating
  end if; --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.STATUS'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_status;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_deplymt_policy_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that deplymt policy id is null.
--    The parameter is not supported for initial release of global transfer functionality
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_deplymt_policy_id
--
--  Post Success :
--    Processing continues if the deplymt policy id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    deplymt policy id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_deplymt_policy_id
  (p_deplymt_policy_id in hr_person_deployments.deplymt_policy_id%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_deplymt_policy_id';
  l_api_updating     boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if p_deplymt_policy_id is not null then
     fnd_message.set_name('PER','HR_449643_PDT_INV_POLICY');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.DEPLYMT_POLICY_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_deplymt_policy_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_retain_direct_reports >--------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that retain_direct_reports is a valid value
--    of 'Y','N' or null
--    It must be null if the employee has no direct reports
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_retain_direct_reports
--    p_from_person_id
--    p_to_business_group_id
--    p_from_business_group_id
--
--  Post Success :
--    Processing continues if the  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--     is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_retain_direct_reports
  (p_retain_direct_reports              in hr_person_deployments.retain_direct_reports%type
  ,p_from_person_id         in hr_person_deployments.from_person_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_from_business_group_id in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_retain_direct_reports';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_directs(p_person_id number) is
  select 1
  from   per_all_assignments_f
  where  supervisor_id = p_person_id
  and    p_start_date between effective_start_date and effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'from_person_id'
    ,p_argument_value => p_from_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.FROM_PERSON_ID'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N') = 'N'
    and p_from_business_group_id <> p_to_business_group_id then
        fnd_message.set_name('PER','HR_449644_PDT_RETAIN_REPS');
        fnd_message.raise_error;
    end if;
    --
    if ( (l_api_updating and
          nvl(hr_pdt_shd.g_old_rec.retain_direct_reports,hr_api.g_varchar2)
              <> nvl(p_retain_direct_reports,hr_api.g_varchar2))
        or not l_api_updating) then
      --
      if (p_retain_direct_reports <> 'Y'
          and p_retain_direct_reports <> 'N'
          and p_retain_direct_reports is not null) then
            fnd_message.set_name('PER','HR_449645_PDT_RET_REPS_INV');
            fnd_message.raise_error;
      end if;
      --
    end if;  --api updating
  end if;  --multi mesage
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.RETAIN_DIRECT_REPORTS'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_retain_direct_reports;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_organization_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the org is a valid internal HR organization
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_organization_id
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the organization is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    organization is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_organization_id
  (p_organization_id        in hr_person_deployments.organization_id%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_organization_id';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_int_org is
  select   1
  from     hr_all_organization_units
  where    organization_id     = p_organization_id
  and      internal_external_flag = 'INT';
  --
  -- following detects match on Host BG as well
  -- Since a proposal creates a primary asg, this is OK for asgrhi validation
  --
  cursor csr_check_hr_org is
  select   1
  from     per_organization_units
  where    organization_id = p_organization_id
      UNION
  select   1
  from     per_business_groups_perf
  where    business_group_id = p_to_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'organization_id'
    ,p_argument_value => p_organization_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          hr_pdt_shd.g_old_rec.organization_id <> p_organization_id)
        or not l_api_updating) then
      --
      open csr_check_int_org;
      fetch csr_check_int_org into l_dummy;
      if csr_check_int_org%notfound then
         close csr_check_int_org;
         fnd_message.set_name('PER','HR_34983_ASG_INVALID_ORG');
         fnd_message.raise_error;
      else
         close csr_check_int_org;
      end if;
      --
     open csr_check_hr_org;
     fetch csr_check_hr_org into l_dummy;
     if csr_check_hr_org%notfound then
        close csr_check_hr_org;
        fnd_message.set_name('PER','HR_51277_ASG_INV_HR_ORG');
        fnd_message.raise_error;
     else
        close csr_check_hr_org;
     end if;
    end if; --api updating
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.ORGANIZATION_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_organization_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_location_id >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that location is valid and active on the start date
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_location_id
--    p_start_date
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the location is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    location is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_location_id
  (p_location_id            in hr_person_deployments.location_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
   ) is
  --
  l_proc        varchar2(72) := g_package||'chk_location_id';
  l_api_updating     boolean;
  l_inactive_date    date;
  --
  cursor csr_check_loc is
  select inactive_date
  from   hr_locations_all
  where  location_id = p_location_id
  and    nvl(business_group_id,p_to_business_group_id)=p_to_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (nvl(hr_pdt_shd.g_old_rec.location_id,hr_api.g_number)
              <> nvl(p_location_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_location_id is not null then
	open csr_check_loc;
	fetch csr_check_loc into l_inactive_date;
	if csr_check_loc%notfound then
	   close csr_check_loc;
	   fnd_message.set_name('PER','HR_7382_ASG_NON_EXIST_LOCATION');
	   fnd_message.raise_error;
	else
	   close csr_check_loc;
	   if p_start_date < l_inactive_date then
	      fnd_message.set_name('PER','HR_51215_ASG_INACT_LOCATION');
	      fnd_message.raise_error;
	   end if;
	end if;  -- csr_check_loc notfound
	--
      end if;  --location not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.LOCATION_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_location_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_job_id >-----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that job exists in the host BG as of the
--   start date of deployment
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_job_id
--    p_to_business_group_id
--    p_start_date
--
--  Post Success :
--    Processing continues if the job is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    job is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_job_id
  (p_job_id                 in hr_person_deployments.job_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_job_id';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_job is
  select 1
  from   per_jobs job,
         per_job_groups jgr
  where  job.job_id = p_job_id
  and    p_start_date between job.date_from and nvl(job.date_to,hr_api.g_eot)
  and    job.job_group_id  = jgr.job_group_id
  and    jgr.internal_name = 'HR_'||jgr.business_group_id
  and    (jgr.business_group_id = job.business_group_id
      or jgr.business_group_id is null)
  and    job.business_group_id = p_to_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (nvl(hr_pdt_shd.g_old_rec.job_id,hr_api.g_number)
              <> nvl(p_job_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_job_id is not null then
        open csr_check_job;
        fetch csr_check_job into l_dummy;
        if csr_check_job%notfound then
           close csr_check_job;
	   fnd_message.set_name('PER','HR_51172_ASG_INV_DT_JOB');
	   fnd_message.raise_error;
        else
           close csr_check_job;
        end if;
      end if;  --job not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.JOB_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_job_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_position_id >------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that position exists in the host BG as of the
--   start date of deployment
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_position_id
--    p_to_business_group_id
--    p_start_date
--
--  Post Success :
--    Processing continues if the position is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    position is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_position_id
  (p_position_id            in hr_person_deployments.position_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_position_id';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_position is
  select 1
  from   hr_positions_f hp,
         per_shared_types ps
  where  hp.position_id = p_position_id
  and    hp.business_group_id = p_to_business_group_id
  and    p_start_date between
         hp.effective_start_date and hp.effective_end_date
  and    p_start_date between
         hp.date_effective and nvl(hp.date_end,hr_api.g_eot)
  and    ps.shared_type_id = hp.availability_status_id
  and    ps.system_type_cd = 'ACTIVE';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (nvl(hr_pdt_shd.g_old_rec.position_id,hr_api.g_number)
              <> nvl(p_position_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_position_id is not null then
        open csr_check_position;
        fetch csr_check_position into l_dummy;
        if csr_check_position%notfound then
           close csr_check_position;
	   fnd_message.set_name('PER','HR_51000_ASG_INVALID_POS');
	   fnd_message.raise_error;
        else
           close csr_check_position;
        end if;
      end if;  --position not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.POSITION_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_position_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_grade_id >---------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that grade exists in the host BG as of the
--   start date of deployment
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_grade_id
--    p_to_business_group_id
--    p_start_date
--
--  Post Success :
--    Processing continues if the grade is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    grade is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_grade_id
  (p_grade_id               in hr_person_deployments.grade_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_grade_id';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_grade is
  select 1
  from   per_grades grade
  where  grade.grade_id = p_grade_id
  and    grade.business_group_id = p_to_business_group_id
  and    p_start_date between
         grade.date_from and nvl(grade.date_to,hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (nvl(hr_pdt_shd.g_old_rec.grade_id,hr_api.g_number)
              <> nvl(p_grade_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_grade_id is not null then
        open csr_check_grade;
        fetch csr_check_grade into l_dummy;
        if csr_check_grade%notfound then
           close csr_check_grade;
	   fnd_message.set_name('PER','HR_7393_ASG_INVALID_GRADE');
	   fnd_message.raise_error;
        else
           close csr_check_grade;
        end if;
      end if;  --grade not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.GRADE_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_grade_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_position_id_job_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the position and job combination is valid
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_position_id
--    p_job_id
--    p_start_date
--
--  Post Success :
--    Processing continues if the position and job combo is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    position and job combo is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_position_id_job_id
  (p_position_id            in hr_person_deployments.position_id%type
  ,p_job_id                 in hr_person_deployments.job_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_position_id_job_id';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_pos_job is
  select null
  from   hr_positions_f hp,
         per_shared_types ps
  where  hp.position_id = p_position_id
  and    p_start_date between
         hp.effective_start_date and hp.effective_end_date
  and    hp.job_id = p_job_id
  and    p_start_date between
         hp.date_effective and nvl(hp.date_end,hr_api.g_eot)
  and    ps.shared_type_id = hp.availability_status_id
  and    ps.system_type_cd = 'ACTIVE' ;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.JOB_ID'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.POSITION_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (   nvl(hr_pdt_shd.g_old_rec.position_id,hr_api.g_number)
                 <> nvl(p_position_id,hr_api.g_number)
           or nvl(hr_pdt_shd.g_old_rec.job_id,hr_api.g_number)
                 <> nvl(p_job_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_position_id is not null and p_job_id is not null then
	open csr_check_pos_job;
	fetch csr_check_pos_job into l_dummy;
	if csr_check_pos_job%notfound then
	   close csr_check_pos_job;
	   fnd_message.set_name('PER','HR_51056_ASG_INV_POS_JOB_COMB');
	   fnd_message.raise_error;
	else
	   close csr_check_pos_job;
	end if;
      end if;  --pos and job not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.POSITION_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.JOB_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_position_id_job_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_position_id_grade_id >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that position and grade combination is valid
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--
--
--  Post Success :
--    Processing continues if the position and grade combo is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    position and grade combo is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_position_id_grade_id
  (p_position_id            in hr_person_deployments.position_id%type
  ,p_grade_id               in hr_person_deployments.grade_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ,p_inv_pos_grade_warning  out nocopy boolean
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_position_id_grade_id';
  l_api_updating             boolean;
  l_dummy                    number;
  l_inv_pos_grade_warning    boolean := false;
  --
  cursor csr_any_valid_grades is
  select 1
  from   per_valid_grades
  where  position_id = p_position_id
  and    p_start_date between
         date_from and nvl(date_to,hr_api.g_eot);
  --
  cursor csr_valid_grade is
  select 1
  from   per_valid_grades
  where  position_id = p_position_id
  and    grade_id = p_grade_id
  and    p_start_date between
         date_from and nvl(date_to,hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.GRADE_ID'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.POSITION_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (   nvl(hr_pdt_shd.g_old_rec.position_id,hr_api.g_number)
                 <> nvl(p_position_id,hr_api.g_number)
           or nvl(hr_pdt_shd.g_old_rec.grade_id,hr_api.g_number)
                 <> nvl(p_grade_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_position_id is not null and p_grade_id is not null then
        open csr_any_valid_grades;
        fetch csr_any_valid_grades into l_dummy;
        if csr_any_valid_grades%found then
           close csr_any_valid_grades;
           --
           open csr_valid_grade;
           fetch csr_valid_grade into l_dummy;
           if csr_valid_grade%notfound then
              close csr_valid_grade;
              p_inv_pos_grade_warning := l_inv_pos_grade_warning;
           else
              close csr_valid_grade;
           end if;
        else
           close csr_any_valid_grades;
        end if;  --csr_any_valid_grades
      end if;  --pos and grade not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.POSITION_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.GRADE_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_position_id_grade_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_job_id_grade_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that job and grade combination is valid
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--
--
--  Post Success :
--    Processing continues if the job and grade combo is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    job and grade combo is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_job_id_grade_id
  (p_job_id                 in hr_person_deployments.job_id%type
  ,p_grade_id               in hr_person_deployments.grade_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ,p_inv_job_grade_warning  out nocopy boolean
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_job_id_grade_id';
  l_api_updating             boolean;
  l_dummy                    number;
  l_inv_job_grade_warning    boolean := false;
  --
  cursor csr_any_valid_grades is
  select 1
  from   per_valid_grades
  where  job_id = p_job_id
  and    p_start_date between
         date_from and nvl(date_to,hr_api.g_eot);
  --
  cursor csr_valid_grade is
  select 1
  from   per_valid_grades
  where  job_id = p_job_id
  and    grade_id = p_grade_id
  and    p_start_date between
         date_from and nvl(date_to,hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.GRADE_ID'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.JOB_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (   nvl(hr_pdt_shd.g_old_rec.job_id,hr_api.g_number)
                 <> nvl(p_job_id,hr_api.g_number)
           or nvl(hr_pdt_shd.g_old_rec.grade_id,hr_api.g_number)
                 <> nvl(p_grade_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_job_id is not null and p_grade_id is not null then
        open csr_any_valid_grades;
        fetch csr_any_valid_grades into l_dummy;
        if csr_any_valid_grades%found then
           close csr_any_valid_grades;
           --
           open csr_valid_grade;
           fetch csr_valid_grade into l_dummy;
           if csr_valid_grade%notfound then
              close csr_valid_grade;
              p_inv_job_grade_warning := l_inv_job_grade_warning;
           else
              close csr_valid_grade;
           end if;
        else
           close csr_any_valid_grades;
        end if;  --csr_any_valid_grades
      end if;  --job and grade not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.JOB_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.GRADE_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_job_id_grade_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_position_id_org_id >------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the position and org combination is valid
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_position_id
--    p_organization_id
--    p_start_date
--
--  Post Success :
--    Processing continues if the position and org combo is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    position and org combo is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_position_id_org_id
  (p_position_id            in hr_person_deployments.position_id%type
  ,p_organization_id        in hr_person_deployments.organization_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_position_id_org_id';
  l_api_updating     boolean;
  l_dummy            number;
  --
  cursor csr_check_pos_org is
  select null
  from   hr_positions_f hp,
         per_shared_types ps
  where  hp.position_id = p_position_id
  and    p_start_date between
         hp.effective_start_date and hp.effective_end_date
  and    hp.organization_id = p_organization_id
  and    p_start_date between
         hp.date_effective and nvl(hp.date_end,hr_api.g_eot)
  and    ps.shared_type_id = hp.availability_status_id
  and    ps.system_type_cd = 'ACTIVE' ;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_exclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.ORGANIZATION_ID'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.POSITION_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (   nvl(hr_pdt_shd.g_old_rec.position_id,hr_api.g_number)
                 <> nvl(p_position_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.organization_id <> p_organization_id
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_position_id is not null and p_organization_id is not null then
	open csr_check_pos_org;
	fetch csr_check_pos_org into l_dummy;
	if csr_check_pos_org%notfound then
	   close csr_check_pos_org;
	   fnd_message.set_name('PER','HR_51056_ASG_INV_POS_ORG_COMB');
	   fnd_message.raise_error;
	else
	   close csr_check_pos_org;
	end if;
      end if;  --pos and org not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.POSITION_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.ORGANIZATION_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_position_id_org_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_payroll_id >-------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that payroll is valid for the host BG.
--    If the legislation is US or CA, then it must be null since there can bo no address
--    entered against a deployment proposal.
--
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_payroll_id
--    p_start_date
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the payroll is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    payroll is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_payroll_id
  (p_payroll_id             in hr_person_deployments.payroll_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_payroll_id';
  l_api_updating     boolean;
  l_dummy            number;
  l_legislation_code per_business_groups.legislation_code%type;
  --
  cursor csr_get_leg_code is
  select legislation_code
  from per_business_groups_perf
  where business_group_id = p_to_business_group_id;
  --
  cursor csr_check_payroll is
  select 1
  from   pay_all_payrolls_f
  where  p_start_date between
         effective_start_date and effective_end_date
  and    payroll_id = p_payroll_id
  and    business_group_id = p_to_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (nvl(hr_pdt_shd.g_old_rec.payroll_id,hr_api.g_number)
              <> nvl(p_payroll_id,hr_api.g_number)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_payroll_id is not null then
        open csr_check_payroll;
        fetch csr_check_payroll into l_dummy;
        if csr_check_payroll%notfound then
           close csr_check_payroll;
	   fnd_message.set_name('PER','HR_7370_ASG_INVALID_PAYROLL');
	   fnd_message.raise_error;
        else
           close csr_check_payroll;
        end if;
        --
	open csr_get_leg_code;
	fetch csr_get_leg_code into l_legislation_code;
	close csr_get_leg_code;
        --
	if hr_general.chk_geocodes_installed = 'Y'
	and ( ( l_legislation_code = 'CA'
		and hr_utility.chk_product_install(p_product => 'Oracle Payroll',
						   p_legislation => 'CA'))
	      OR ( l_legislation_code = 'US'
		and hr_utility.chk_product_install(p_product => 'Oracle Payroll',
						   p_legislation => 'US')))
	then
           fnd_message.set_name('PER','HR_449646_PDT_NO_PAYROLL');
	   fnd_message.raise_error;
        end if;  -- leg code check
      end if; --payroll not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.PAYROLL_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_payroll_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_assignment_status_type_id >----------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:--    This procedures validates that assignment_status_type_id exists in the Host BG
--    and is of ACTIVE_ASG
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_assignment_status_type_id
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the assignment_status_type_id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    assignment_status_type_id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_assignment_status_type_id
  (p_assignment_status_type_id in hr_person_deployments.assignment_status_type_id%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_assignment_status_type_id';
  l_api_updating     boolean;
  l_active_flag        per_assignment_status_types.active_flag%type;
  l_per_system_status  per_assignment_status_types.per_system_status%type;
  l_legislation_code per_business_groups.legislation_code%type;
  --
  cursor csr_get_leg_code is
  select legislation_code
  from per_business_groups_perf
  where business_group_id = p_to_business_group_id;
  --
  cursor csr_check_asg_status_amend is
  select active_flag, per_system_status
  from   per_ass_status_type_amends
  where  assignment_status_type_id = p_assignment_status_type_id
  and    business_group_id = p_to_business_group_id;
  --
  cursor csr_check_asg_status(p_legislation_code per_business_groups.legislation_code%TYPE) is
  select active_flag, per_system_status
  from   per_assignment_status_types
  where  assignment_status_type_id = p_assignment_status_type_id
  and    nvl(business_group_id,p_to_business_group_id) = p_to_business_group_id
  and    nvl(legislation_code,p_legislation_code) = p_legislation_code;
/*
  and    (business_group_id is not null
          and business_group_id = p_to_business_group_id)
  or     (business_group_id is null
          and (legislation_code is not null
               and legislation_code= p_legislation_code));
*/
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (nvl(hr_pdt_shd.g_old_rec.assignment_status_type_id,hr_api.g_number)
              <> nvl(p_assignment_status_type_id,hr_api.g_number)))
        or not l_api_updating) then
      --
      if p_assignment_status_type_id is not null then
         open csr_check_asg_status_amend;
         fetch csr_check_asg_status_amend into l_active_flag,l_per_system_status;
         if csr_check_asg_status_amend%notfound then
            close csr_check_asg_status_amend;
            --
	    open csr_get_leg_code;
	    fetch csr_get_leg_code into l_legislation_code;
	    close csr_get_leg_code;
	    --
            open csr_check_asg_status(l_legislation_code);
            fetch csr_check_asg_status into l_active_flag,l_per_system_status;
            if csr_check_asg_status%notfound then
               close csr_check_asg_status;
               fnd_message.set_name('PER','HR_7940_ASG_INV_ASG_STAT_TYPE');
               fnd_message.raise_error;
            else
               close csr_check_asg_status;
               if l_active_flag <> 'Y' then
                 fnd_message.set_name('PER','HR_51206_ASG_INV_AST_ACT_FLG');
                 fnd_message.raise_error;
               end if;
               --
               if l_per_system_status <> 'ACTIVE_ASSIGN' then
                 fnd_message.set_name('PER','HR_7941_ASG_INV_STAT_NOT_ACT');
                 fnd_message.raise_error;
               end if;
            end if;
         else
            close csr_check_asg_status_amend;
         end if;
      end if;
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.ASSIGNMENT_STATUS_TYPE_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_assignment_status_type_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_supervisor_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that supervisor_id is valid for range of assignment
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_supervisor_id
--    p_start_date
--    p_from_person_id
--    p_to_person_id
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--     is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_supervisor_id
  (p_supervisor_id in hr_person_deployments.supervisor_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_from_person_id         in hr_person_deployments.from_person_id%type
  ,p_to_person_id           in hr_person_deployments.to_person_id%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_supervisor_id';
  l_api_updating     boolean;
  l_per_party_id number;
  l_sup_party_id number;
  l_sup_bg_id    number;
  --
  cursor csr_party_id(p_per_id number)  IS
  select party_id
  from   per_all_people_f
  where  person_id = p_per_id
  and    p_start_date
     between  effective_start_date
       and    effective_end_date;
  --
  cursor csr_check_sup is
  select 1
  from   per_all_people_f
  where  person_id = p_supervisor_id
  and    p_start_date between
         effective_start_date and effective_end_date
  and    nvl(current_employee_flag,'N') = 'Y';
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          ((nvl(hr_pdt_shd.g_old_rec.supervisor_id,hr_api.g_number)
              <> nvl(p_supervisor_id,hr_api.g_number))
          or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_supervisor_id is not null then
         --
         if p_supervisor_id = nvl(p_to_person_id,-1)
         or p_supervisor_id = p_from_person_id then
            fnd_message.set_name('PER','HR_51143_ASG_EMP_EQUAL_SUP');
            fnd_message.raise_error;
         end if;
         --
	 open csr_party_id(p_from_person_id);
	 fetch csr_party_id into l_per_party_id;
	 close csr_party_id;
	 --
	 open csr_party_id(p_supervisor_id);
	 fetch csr_party_id into l_sup_party_id;
	 close csr_party_id;
         --
         if l_per_party_id = l_sup_party_id then
            fnd_message.set_name('PER','HR_449603_ASG_SUP_DUP_PER');
            fnd_message.raise_error;
         end if;
         --
         open csr_check_sup;
         fetch csr_check_sup into l_sup_bg_id;
         if csr_check_sup%notfound then
            close csr_check_sup;
            fnd_message.set_name('PER','PAY_7599_SYS_SUP_DT_OUTDATE');
            fnd_message.raise_error;
         else
            close csr_check_sup;
            if (p_to_business_group_id <> l_sup_bg_id  AND
               nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='N') then
              fnd_message.set_name('PER','HR_51145_ASG_SUP_BG_NE_EMP_BG');
              fnd_message.raise_error;
            end if;
         end if;
      end if;  --supervisor id not null
    end if;  --api updating
  end if; -- muti message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.SUPERVISOR_ID'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_supervisor_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_supervisor_assignment_id >-----------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that supervisor_assignment_id is an existing employee
--    assignment of the given supervisor.
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_supervisor_id
--    p_supervisor_assignment_id
--    p_start_date
--
--  Post Success :
--    Processing continues if the supervisor_assignment_id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    supervisor_assignment_id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_supervisor_assignment_id
  (p_supervisor_assignment_id in out nocopy hr_person_deployments.supervisor_assignment_id%type
  ,p_supervisor_id          in hr_person_deployments.supervisor_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_supervisor_assignment_id';
  l_api_updating     boolean;
  l_sup_asg_type     per_all_assignments_f.assignment_type%type;
  --
  cursor csr_check_sup_asg is
  select assignment_type
  from   per_all_assignments_f
  where  person_id = p_supervisor_id
  and    p_start_date between
         effective_start_date and effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
           (p_person_deployment_id   => p_person_deployment_id
           ,p_object_version_number  => p_object_version_number);
    --
    if ((l_api_updating and
         (   (nvl(hr_pdt_shd.g_old_rec.supervisor_id,hr_api.g_number)
                <> nvl(p_supervisor_id,hr_api.g_number))
           or (nvl(hr_pdt_shd.g_old_rec.supervisor_assignment_id,hr_api.g_number)
                <> nvl(p_supervisor_assignment_id,hr_api.g_number))
           or (hr_pdt_shd.g_old_rec.start_date <> p_start_date)
          )
         )
        or not l_api_updating
        ) then
      --
      if p_supervisor_id is null and p_supervisor_assignment_id is not null then
         p_supervisor_assignment_id := null;
      elsif p_supervisor_assignment_id is not null then
         open csr_check_sup_asg;
         fetch csr_check_sup_asg into l_sup_asg_type;
         if csr_check_sup_asg%notfound then
            close csr_check_sup_asg;
            fnd_message.set_name('PER','HR_50146_SUP_ASG_INVALID');
            fnd_message.raise_error;
         else
            close csr_check_sup_asg;
            if (l_sup_asg_type = 'E'
            or   (l_sup_asg_type = 'C' and
                  nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y')) then
              null;
            else
              fnd_message.set_name('PER','HR_50147_SUP_ASG_WRONG_TYPE');
              fnd_message.raise_error;
            end if;
         end if;

      end if;
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.SUPERVISOR_ASSIGNMENT_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_supervisor_assignment_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_pay_basis_id >-----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that pay_basis_id exists in host BG
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_pay_basis_id
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if thepay_basis_id  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    pay_basis_id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_pay_basis_id
  (p_pay_basis_id in hr_person_deployments.pay_basis_id%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc               varchar2(72) := g_package||'chk_pay_basis_id';
  l_api_updating       boolean;
  l_business_group_id  per_business_groups.business_group_id%TYPE;
  --
  cursor csr_check_pay_basis is
  select business_group_id
  from   per_pay_bases
  where  pay_basis_id = p_pay_basis_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  l_api_updating := hr_pdt_shd.api_updating
         (p_person_deployment_id   => p_person_deployment_id
         ,p_object_version_number  => p_object_version_number);
  --
  if ( (l_api_updating and
        (nvl(hr_pdt_shd.g_old_rec.pay_basis_id,hr_api.g_number)
            <> nvl(p_pay_basis_id,hr_api.g_number)))
      or not l_api_updating) then
      --
      if p_pay_basis_id is not null then
	open csr_check_pay_basis;
	fetch csr_check_pay_basis into l_business_group_id;
	if csr_check_pay_basis%notfound then
	   close csr_check_pay_basis;
	   fnd_message.set_name('PER','HR_51168_ASG_INV_PAY_BASIS_ID');
	   fnd_message.raise_error;
	else
	   close csr_check_pay_basis;
	   if p_to_business_group_id <> l_business_group_id then
	     fnd_message.set_name('PER','HR_51169_ASG_INV_PAY_BAS_BG');
	     fnd_message.raise_error;
           end if;
	end if;
    end if;  -- pay basis not null
  end if;  --api updating
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.PAY_BASIS_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_pay_basis_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_people_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that people group id exists on pay_people_groups
--    and that the structure of the provided combination is valid for the Host BG
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_people_group_id
--    p_start_date
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the people_group_id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    people_group_id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_people_group_id
  (p_people_group_id        in hr_person_deployments.people_group_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc                 varchar2(72) := g_package||'chk_people_group_id';
  l_api_updating         boolean;
  l_id_flex_num          pay_people_groups.id_flex_num%type;
  l_enabled_flag         pay_people_groups.enabled_flag%TYPE;
  l_bg_id_flex_num       per_business_groups_perf.people_group_structure%type;
  --
  cursor csr_check_grp is
  select enabled_flag,id_flex_num
  from   pay_people_groups
  where  people_group_id = p_people_group_id
  and    p_start_date between
         nvl(start_date_active,hr_api.g_sot) and nvl(end_date_active,hr_api.g_eot);
  --
  cursor csr_get_bg_flex is
  select people_group_structure
  from   per_business_groups_perf
  where  business_group_id = p_to_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
	   (p_person_deployment_id   => p_person_deployment_id
	   ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
	  (nvl(hr_pdt_shd.g_old_rec.people_group_id,hr_api.g_number)
	      <> nvl(p_people_group_id,hr_api.g_number)
	   or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
	or not l_api_updating) then
	--
        if p_people_group_id is not null then
           open csr_check_grp;
           fetch csr_check_grp into l_enabled_flag,l_id_flex_num;
           if csr_check_grp%notfound then
              close csr_check_grp;
	      fnd_message.set_name('PER','HR_7385_ASG_INV_PEOPLE_GROUP');
	      fnd_message.raise_error;
           else
              close csr_check_grp;
              if l_enabled_flag <> 'Y' then
	        fnd_message.set_name('PER','HR_51252_ASG_INV_PGP_ENBD_FLAG');
	        fnd_message.raise_error;
              end if;
              --
              open csr_get_bg_flex;
              fetch csr_get_bg_flex into l_bg_id_flex_num;
              close csr_get_bg_flex;
              --
              if to_number(l_bg_id_flex_num) <> l_id_flex_num then
	        fnd_message.set_name('PER','HR_7386_ASG_INV_PEOP_GRP_LINK');
	        fnd_message.raise_error;
              end if;
              --
           end if;  --csr_check_grp not found
        end if;  --people group not null
    end if; --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.PEOPLE_GROUP_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_people_group_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_soft_coding_keyflex_id >-------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that people group id exists on
--    and that the structure of the provided combination is valid for the Host BG
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_soft_coding_keyflex_id
--    p_start_date
--    p_to_business_group_id
--
--  Post Success :
--    Processing continues if the soft_coding_keyflex_id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    soft_coding_keyflex_id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_soft_coding_keyflex_id
  (p_soft_coding_keyflex_id in hr_person_deployments.soft_coding_keyflex_id%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_to_business_group_id   in hr_person_deployments.to_business_group_id%type
  ,p_payroll_id             in hr_person_deployments.payroll_id%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc                 varchar2(72) := g_package||'chk_soft_coding_keyflex_id';
  l_api_updating         boolean;
  l_dummy                number;
  l_legislation_code     per_business_groups_perf.legislation_code%type;
  --
  cursor csr_check_scl is
  select 1
  from   hr_soft_coding_keyflex
  where  soft_coding_keyflex_id = p_soft_coding_keyflex_id
  and    enabled_flag = 'Y'
  and    p_start_date between
         nvl(start_date_active,hr_api.g_sot) and nvl(end_date_active,hr_api.g_eot);
  --
  cursor csr_bg_leg is
  select legislation_code
  from   per_business_groups_perf
  where  business_group_id = p_to_business_group_id;
  --
  cursor csr_pay_legislation_rules(p_legislation_code per_business_groups_perf.legislation_code%type) is
  select 1
  from   pay_legislation_rules
  where  legislation_code = p_legislation_code
  and    rule_type = 'TAX_UNIT'
  and    rule_mode = 'Y';
  --
  cursor csr_tax_unit_message(p_message_name varchar2) is
  select 1
  from   fnd_new_messages
  where  message_name = p_message_name
  and    application_id = 801;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'to_business_group_id'
    ,p_argument_value => p_to_business_group_id
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ,p_check_column2      =>  'HR_PERSON_DEPLOYMENTS.TO_BUSINESS_GROUP_ID'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
	   (p_person_deployment_id   => p_person_deployment_id
	   ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
	  (nvl(hr_pdt_shd.g_old_rec.soft_coding_keyflex_id,hr_api.g_number)
	      <> nvl(p_soft_coding_keyflex_id,hr_api.g_number)
	   or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or (l_api_updating and
            p_soft_coding_keyflex_id is null and p_payroll_id is not null)
	or not l_api_updating) then
	--
        if p_soft_coding_keyflex_id is not null then
           open csr_check_scl;
           fetch csr_check_scl into l_dummy;
           if csr_check_scl%notfound then
              close csr_check_scl;
	      fnd_message.set_name('PER','HR_7383_ASG_INV_KEYFLEX');
              hr_multi_message.add
                  (p_associated_column1 => 'HR_PERSON_DEPLOYMENTS.SOFT_CODING_KEYFLEX_ID'                  ,p_associated_column2 => 'HR_PERSON_DEPLOYMENTS.START_DATE');
           else
              close csr_check_scl;
              --
	      end if;
	 else  -- bug fix 6956927
	 -- Check that for relevant legislations SCL is mandatory,
      --  when payroll_id is populated
              if p_payroll_id is not null then
		open csr_bg_leg;
		fetch csr_bg_leg into l_legislation_code;
		close csr_bg_leg;
		--
                open csr_pay_legislation_rules(l_legislation_code);
                fetch csr_pay_legislation_rules into l_dummy;
                if csr_pay_legislation_rules%found then
                   close csr_pay_legislation_rules;
                   if l_legislation_code = 'US' then
	              fnd_message.set_name('PER','HR_50001_EMP_ASS_NO_GRE');
                      hr_multi_message.add
                       (p_associated_column1 => 'HR_PERSON_DEPLOYMENTS.PAYROLL_ID');
                   else
                      open csr_tax_unit_message('HR_INV_LEG_ENT_'||l_legislation_code);
                      fetch csr_tax_unit_message into l_dummy;
                      if csr_tax_unit_message%found then
                         close csr_tax_unit_message;
                         fnd_message.set_name('PER','HR_INV_LEG_ENT_'||l_legislation_code);
                      else
                         close csr_tax_unit_message;
                         fnd_message.set_name('PER','HR_34024_IP_INV_LEG_ENT');
                      end if;
                      hr_multi_message.add
                       (p_associated_column1 => 'HR_PERSON_DEPLOYMENTS.PAYROLL_ID');
                   end if;  --legislation code
                end if;  --csr_pay_legislation_rules found
              end if; --payroll_id not null
          -- end if;  --csr_check_scl not found
        end if;  --soft coding keyflex not null
    end if; --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.SOFT_CODING_KEYFLEX_ID'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_soft_coding_keyflex_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_assignment_category >----------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that assignment category is valid from lookup EMP_CAT
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_assignment_category
--    p_start_date
--
--  Post Success :
--    Processing continues if the  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--     is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_assignment_category
  (p_assignment_category in hr_person_deployments.assignment_category%type
  ,p_start_date             in hr_person_deployments.start_date%type
  ,p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ,p_object_version_number  in hr_person_deployments.object_version_number%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_assignment_category';
  l_api_updating     boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'start_date'
    ,p_argument_value => p_start_date
    );
  --
  if hr_multi_message.no_all_inclusive_error
     (p_check_column1      =>  'HR_PERSON_DEPLOYMENTS.START_DATE'
     ) then
    --
    l_api_updating := hr_pdt_shd.api_updating
	   (p_person_deployment_id   => p_person_deployment_id
	   ,p_object_version_number  => p_object_version_number);
    --
    if ( (l_api_updating and
          (nvl(hr_pdt_shd.g_old_rec.assignment_category,hr_api.g_varchar2)
              <> nvl(p_assignment_category,hr_api.g_varchar2)
           or hr_pdt_shd.g_old_rec.start_date <> p_start_date))
        or not l_api_updating) then
      --
      if p_assignment_category is not null
      and hr_api.not_exists_in_leg_lookups
          (p_effective_date        => p_start_date
          ,p_lookup_type           => 'EMP_CAT'
          ,p_lookup_code           => p_assignment_category
          ) then
          fnd_message.set_name('PER','HR_51028_ASG_INV_EMP_CATEGORY');
          fnd_message.raise_error;
      end if;  --assignment category not null
    end if;  --api updating
  end if;  --multi message
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
      (p_associated_column1      => 'HR_PERSON_DEPLOYMENTS.ASSIGNMENT_CATEGORY'
      ,p_associated_column2      => 'HR_PERSON_DEPLOYMENTS.START_DATE'
      ) then
        hr_utility.set_location(' Leaving:'||l_proc, 50);
        raise;
      end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_assignment_category;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_delete >-----------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--
--
--  Post Success :
--    Processing continues if the  is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--     is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_delete
  (p_person_deployment_id   in hr_person_deployments.person_deployment_id%type
  ) is
  --
  l_proc        varchar2(72) := g_package||'chk_delete';
  l_api_updating     boolean;
  l_start_date       date;
  l_status           hr_person_deployments.status%type;
  --
  cursor csr_deployment is
  select start_date,status
  from   hr_person_deployments
  where  person_deployment_id = p_person_deployment_id;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_deployment;
  fetch csr_deployment into l_start_date,l_status;
  if csr_deployment%notfound then
     close csr_deployment;
     fnd_message.set_name('PER','HR_449647_PDT_DPL_DEL_PK');
     fnd_message.raise_error;
  else
     close csr_deployment;
     if l_status = 'ACTIVE' then
        fnd_message.set_name('PER','HR_449648_PDT_DPL_DEL_STATUS');
        fnd_message.raise_error;
     end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
  --
end chk_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in out nocopy hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_inv_pos_grade_warning  boolean;
  l_inv_job_grade_warning  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Set security Group context based on the TO_BUSINESS_GROUP_ID since the data
  -- in this table is being held specifically to be copied to an assignment there
  --
  hr_oru_bus.set_security_group_id(p_rec.to_business_group_id);
  --
  -- Validate Dependent Attributes
  --
  if g_debug then
     hr_utility.set_location(l_proc, 10);
  end if;
  --
  hr_pdt_bus.chk_business_groups
    (p_from_business_group_id => p_rec.from_business_group_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 15);
  end if;
  --
  hr_pdt_bus.chk_from_person_id
    (p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_from_person_id         => p_rec.from_person_id
    ,p_from_business_group_id => p_rec.from_business_group_id
    ,p_start_date             => p_rec.start_date
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  hr_pdt_bus.chk_to_person_id
    (p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_to_person_id           => p_rec.to_person_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_start_date             => p_rec.start_date
    ,p_status                 => p_rec.status
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 25);
  end if;
  --
  hr_pdt_bus.chk_person_type_id
    (p_person_type_id         => p_rec.person_type_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,30 );
  end if;
  --
  hr_pdt_bus.chk_start_end_date
    (p_start_date             => p_rec.start_date
    ,p_end_date               => p_rec.end_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_status                 => p_rec.status
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 35);
  end if;
  --
  hr_pdt_bus.chk_permanent
    (p_permanent              => p_rec.permanent
    ,p_from_person_id         => p_rec.from_person_id
    ,p_end_date               => p_rec.end_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 40);
  end if;
  --
  hr_pdt_bus.chk_deployment_reason
    (p_deployment_reason      => p_rec.deployment_reason
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 45);
  end if;
  --
  hr_pdt_bus.chk_employee_number
    (p_employee_number        => p_rec.employee_number
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_to_person_id           => p_rec.to_person_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,50 );
  end if;
  --
  hr_pdt_bus.chk_leaving_reason
    (p_leaving_reason         => p_rec.leaving_reason
    ,p_start_date             => p_rec.start_date
    ,p_permanent              => p_rec.permanent
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 55);
  end if;
  --
  hr_pdt_bus.chk_leaving_person_type_id
    (p_leaving_person_type_id => p_rec.leaving_person_type_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_permanent              => p_rec.permanent
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  hr_pdt_bus.chk_status
    (p_status                 => p_rec.status
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,65 );
  end if;
  --
  hr_pdt_bus.chk_deplymt_policy_id
    (p_deplymt_policy_id      => p_rec.deplymt_policy_id
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 70);
  end if;
  --
  hr_pdt_bus.chk_retain_direct_reports
    (p_retain_direct_reports  => p_rec.retain_direct_reports
    ,p_from_person_id         => p_rec.from_person_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_from_business_group_id => p_rec.from_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 75);
  end if;
  --
  hr_pdt_bus.chk_organization_id
    (p_organization_id        => p_rec.organization_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 80);
  end if;
  --
  hr_pdt_bus.chk_location_id
    (p_location_id            => p_rec.location_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
     );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 85);
  end if;
  --
  hr_pdt_bus.chk_job_id
    (p_job_id                 => p_rec.job_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,90 );
  end if;
  --
  hr_pdt_bus.chk_position_id
    (p_position_id            => p_rec.position_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 95);
  end if;
  --
  hr_pdt_bus.chk_grade_id
    (p_grade_id               => p_rec.grade_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 100);
  end if;
  --
  hr_pdt_bus.chk_position_id_job_id
    (p_position_id            => p_rec.position_id
    ,p_job_id                 => p_rec.job_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 105);
  end if;
  --
  hr_pdt_bus.chk_position_id_grade_id
    (p_position_id            => p_rec.position_id
    ,p_grade_id               => p_rec.grade_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_inv_pos_grade_warning  => l_inv_pos_grade_warning
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 110);
  end if;
  --
  hr_pdt_bus.chk_job_id_grade_id
    (p_job_id                 => p_rec.job_id
    ,p_grade_id               => p_rec.grade_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_inv_job_grade_warning  => l_inv_job_grade_warning
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 115);
  end if;
  --
  hr_pdt_bus.chk_position_id_org_id
    (p_position_id            => p_rec.position_id
    ,p_organization_id        => p_rec.organization_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 120);
  end if;
  --
  hr_pdt_bus.chk_payroll_id
    (p_payroll_id             => p_rec.payroll_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 125);
  end if;
  --
  hr_pdt_bus.chk_assignment_status_type_id
    (p_assignment_status_type_id => p_rec.assignment_status_type_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 130);
  end if;
  --
  hr_pdt_bus.chk_supervisor_id
    (p_supervisor_id          => p_rec.supervisor_id
    ,p_start_date             => p_rec.start_date
    ,p_from_person_id         => p_rec.from_person_id
    ,p_to_person_id           => p_rec.to_person_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 140);
  end if;
  --
  hr_pdt_bus.chk_supervisor_assignment_id
    (p_supervisor_assignment_id => p_rec.supervisor_assignment_id
    ,p_supervisor_id          => p_rec.supervisor_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 145);
  end if;
  --
  hr_pdt_bus.chk_pay_basis_id
    (p_pay_basis_id           => p_rec.pay_basis_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 150);
  end if;
  --
  hr_pdt_bus.chk_people_group_id
    (p_people_group_id        => p_rec.people_group_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 155);
  end if;
  --
  hr_pdt_bus.chk_soft_coding_keyflex_id
    (p_soft_coding_keyflex_id => p_rec.soft_coding_keyflex_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_payroll_id             => p_rec.payroll_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 160);
  end if;
  --
  hr_pdt_bus.chk_assignment_category
    (p_assignment_category    => p_rec.assignment_category
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_pdt_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in out nocopy hr_pdt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_inv_pos_grade_warning  boolean;
  l_inv_job_grade_warning  boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Set security Group context based on the TO_BUSINESS_GROUP_ID since the data
  -- in this table is being held specifically to be copied to an assignment there
  --
  hr_oru_bus.set_security_group_id(p_rec.to_business_group_id);
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 20);
  end if;
  --
  hr_pdt_bus.chk_to_person_id
    (p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_to_person_id           => p_rec.to_person_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_start_date             => p_rec.start_date
    ,p_status                 => p_rec.status
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 25);
  end if;
  --
  hr_pdt_bus.chk_person_type_id
    (p_person_type_id         => p_rec.person_type_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,30 );
  end if;
  --
  hr_pdt_bus.chk_start_end_date
    (p_start_date             => p_rec.start_date
    ,p_end_date               => p_rec.end_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_status                 => p_rec.status
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 35);
  end if;
  --
  hr_pdt_bus.chk_deployment_reason
    (p_deployment_reason      => p_rec.deployment_reason
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 45);
  end if;
  --
  hr_pdt_bus.chk_employee_number
    (p_employee_number        => p_rec.employee_number
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_to_person_id           => p_rec.to_person_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,50 );
  end if;
  --
  hr_pdt_bus.chk_leaving_reason
    (p_leaving_reason         => p_rec.leaving_reason
    ,p_start_date             => p_rec.start_date
    ,p_permanent              => p_rec.permanent
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 55);
  end if;
  --
  hr_pdt_bus.chk_leaving_person_type_id
    (p_leaving_person_type_id => p_rec.leaving_person_type_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_permanent              => p_rec.permanent
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 60);
  end if;
  --
  hr_pdt_bus.chk_status
    (p_status                 => p_rec.status
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,65 );
  end if;
  --
  hr_pdt_bus.chk_deplymt_policy_id
    (p_deplymt_policy_id      => p_rec.deplymt_policy_id
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 70);
  end if;
  --
  hr_pdt_bus.chk_retain_direct_reports
    (p_retain_direct_reports  => p_rec.retain_direct_reports
    ,p_from_person_id         => p_rec.from_person_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_from_business_group_id => p_rec.from_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 75);
  end if;
  --
  hr_pdt_bus.chk_organization_id
    (p_organization_id        => p_rec.organization_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 80);
  end if;
  --
  hr_pdt_bus.chk_location_id
    (p_location_id            => p_rec.location_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
     );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 85);
  end if;
  --
  hr_pdt_bus.chk_job_id
    (p_job_id                 => p_rec.job_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc,90 );
  end if;
  --
  hr_pdt_bus.chk_position_id
    (p_position_id            => p_rec.position_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 95);
  end if;
  --
  hr_pdt_bus.chk_grade_id
    (p_grade_id               => p_rec.grade_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 100);
  end if;
  --
  hr_pdt_bus.chk_position_id_job_id
    (p_position_id            => p_rec.position_id
    ,p_job_id                 => p_rec.job_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 105);
  end if;
  --
  hr_pdt_bus.chk_position_id_grade_id
    (p_position_id            => p_rec.position_id
    ,p_grade_id               => p_rec.grade_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_inv_pos_grade_warning  => l_inv_pos_grade_warning
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 110);
  end if;
  --
  hr_pdt_bus.chk_job_id_grade_id
    (p_job_id                 => p_rec.job_id
    ,p_grade_id               => p_rec.grade_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    ,p_inv_job_grade_warning  => l_inv_job_grade_warning
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 115);
  end if;
  --
  hr_pdt_bus.chk_position_id_org_id
    (p_position_id            => p_rec.position_id
    ,p_organization_id        => p_rec.organization_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 120);
  end if;
  --
  hr_pdt_bus.chk_payroll_id
    (p_payroll_id             => p_rec.payroll_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 125);
  end if;
  --
  hr_pdt_bus.chk_assignment_status_type_id
    (p_assignment_status_type_id => p_rec.assignment_status_type_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 130);
  end if;
  --
  hr_pdt_bus.chk_supervisor_id
    (p_supervisor_id          => p_rec.supervisor_id
    ,p_start_date             => p_rec.start_date
    ,p_from_person_id         => p_rec.from_person_id
    ,p_to_person_id           => p_rec.to_person_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 140);
  end if;
  --
  hr_pdt_bus.chk_supervisor_assignment_id
    (p_supervisor_assignment_id => p_rec.supervisor_assignment_id
    ,p_supervisor_id          => p_rec.supervisor_id
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 145);
  end if;
  --
  hr_pdt_bus.chk_pay_basis_id
    (p_pay_basis_id           => p_rec.pay_basis_id
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 150);
  end if;
  --
  hr_pdt_bus.chk_people_group_id
    (p_people_group_id        => p_rec.people_group_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 155);
  end if;
  --
  hr_pdt_bus.chk_soft_coding_keyflex_id
    (p_soft_coding_keyflex_id => p_rec.soft_coding_keyflex_id
    ,p_start_date             => p_rec.start_date
    ,p_to_business_group_id   => p_rec.to_business_group_id
    ,p_payroll_id             => p_rec.payroll_id
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  if g_debug then
     hr_utility.set_location(l_proc, 160);
  end if;
  --
  hr_pdt_bus.chk_assignment_category
    (p_assignment_category    => p_rec.assignment_category
    ,p_start_date             => p_rec.start_date
    ,p_person_deployment_id   => p_rec.person_deployment_id
    ,p_object_version_number  => p_rec.object_version_number
    );
  --
  hr_pdt_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in hr_pdt_shd.g_rec_type
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
end hr_pdt_bus;

/
