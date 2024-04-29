--------------------------------------------------------
--  DDL for Package Body PER_CKL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CKL_BUS" as
/* $Header: pecklrhi.pkb 120.2 2005/11/15 09:02 lsilveir noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_ckl_bus.';  -- Global package name
g_debug boolean         := hr_utility.debug_enabled;
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_checklist_id                number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_checklist_id                         in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_checklists ckl
     where ckl.checklist_id = p_checklist_id
       and pbg.business_group_id (+) = ckl.business_group_id;
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
    ,p_argument           => 'checklist_id'
    ,p_argument_value     => p_checklist_id
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
        => nvl(p_associated_column1,'CHECKLIST_ID')
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
  (p_checklist_id                         in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_checklists ckl
     where ckl.checklist_id = p_checklist_id
       and pbg.business_group_id (+) = ckl.business_group_id;
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
    ,p_argument           => 'checklist_id'
    ,p_argument_value     => p_checklist_id
    );
  --
  if ( nvl(per_ckl_bus.g_checklist_id, hr_api.g_number)
       = p_checklist_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_ckl_bus.g_legislation_code;
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
    per_ckl_bus.g_checklist_id                := p_checklist_id;
    per_ckl_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- --------------------------------------------------------------------------
-- |------------------------< chk_name >------------------------------------|
-- --------------------------------------------------------------------------
--
Procedure chk_name
  (p_name                   in   per_checklists.name%TYPE
  ,p_category               IN   per_checklists.checklist_category%TYPE
  ,p_business_group_id      in   per_checklists.business_group_id%TYPE
  ,p_checklist_id           in   per_checklists.checklist_id%type
  ,p_object_version_number  in   per_checklists.object_version_number%type
  )
  is
  --
  -- Declare cursor to check name is unique.
  --
  cursor csr_unique_name is
    select null
    from per_checklists
    where name = p_name
    AND checklist_category = p_category
    and business_group_id = p_business_group_id;
  --
  -- Declare local variables
  --
  l_exists            varchar2(1);
  l_proc              varchar2(72)  :=  g_package||'chk_name';
  l_api_updating      boolean;
  --
begin
  if g_debug then  hr_utility.set_location('Entering:'||l_proc, 1);  end if;
  --
  --  Only proceed with validation if:
  --  a) The current g_old_rec is current and
  --  b) The checklist name value has changed
  --  c) a record is being inserted
  --
  l_api_updating := per_ckl_shd.api_updating
    (p_checklist_id          => p_checklist_id
    ,p_object_version_number => p_object_version_number
    );

  IF (l_api_updating
      and nvl(per_ckl_shd.g_old_rec.name, hr_api.g_varchar2) = nvl(p_name,hr_api.g_varchar2)
     )
  THEN
      RETURN;
  END IF;
  --
    if g_debug then  hr_utility.set_location(l_proc, 40);  end if;
    --
    hr_utility.set_location('Entering: '||l_proc,10);
    --
    if p_name is not null then
       -- Check that name is unique
       open csr_unique_name;
       fetch csr_unique_name into l_exists;
       --
       if csr_unique_name%FOUND then
          -- Name is not unique - raise error by calling constraint error
          close csr_unique_name;
          --
          fnd_message.set_name('PER', 'PER_449664_CKL_CKL_NAME_UNQ');
          fnd_message.set_token('CHECKLIST_NAME', p_name);
          fnd_message.raise_error;
          --
       end if;
       --
       close csr_unique_name;
    else
       -- Name is null - raise error
       fnd_message.set_name('PER','PER_449678_CKL_NAME_REQD');
       fnd_message.raise_error;
    end if;
    --

    if g_debug then hr_utility.set_location('Entering:'||l_proc, 50);  end if;
    --
  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'PER_CHECKLISTS.NAME'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_name;
--
--  ---------------------------------------------------------------------------
--  |-------------------------------< chk_ler_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that LIFE_EVENT_REASON_ID exists in ben_ler_f on the
--    effective_date.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_ler_id
--    p_person_id
--    p_effective_date
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
procedure chk_ler_id
  (p_ler_id              in    per_checklists.event_reason_id%TYPE
  ,p_business_group_id   in    per_checklists.business_group_id%TYPE
  ,p_effective_date      in    date
   ) is
  --
  -- Declare local variables
  --
  l_proc  varchar2(72) := g_package||'chk_ler_id';
  l_dummy number;
  --
  -- Declare cursor to check name is unique.
  --
  cursor csr_ler_id is
    select null
    from ben_ler_f ler
    where ler.ler_id = p_ler_id
    and ler.business_group_id = p_business_group_id
    and p_effective_date between ler.effective_start_date
                         and ler.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  -- 	Check mandatory ler_id exists if not null
  --
  if p_ler_id is not null then
       open csr_ler_id;
       fetch csr_ler_id into l_dummy;
       if csr_ler_id%notfound then
          close csr_ler_id;
          fnd_message.set_name('PER','PER_449681_CKL_INV_LIFE_EV_RSN');
          fnd_message.raise_error;
       end if;
       close csr_ler_id;

  end if;
  --
  hr_utility.set_location(l_proc, 5);
  --
  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'PER_CHECKLISTS.EVENT_REASON_ID'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_ler_id;
--
--
--  ---------------------------------------------------------------------------
--  |--------------------------<  chk_ckl_category >--------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_ckl_category
  (p_checklist_id           in per_checklists.checklist_id%TYPE,
   p_ckl_category           in per_checklists.checklist_category%TYPE,
   p_effective_date         in date) is
  --
  -- Declare local variables
  --
   l_proc           varchar2(72)  :=  g_package||'chk_ckl_category';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  --
  if p_ckl_category is not null then
    --
    hr_utility.set_location(l_proc, 5);
    --
    -- Only proceed with validation if :
    -- a) Inserting or
    -- b) The value for category has changed
    --
    if ((p_checklist_id is null) or
       ((p_checklist_id is not null) and
         (nvl(per_ckl_shd.g_old_rec.checklist_category,hr_api.g_varchar2) <> nvl(p_ckl_category,hr_api.g_varchar2)))) then
       --
      if hr_api.not_exists_in_leg_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'CHECKLIST_CATEGORY'
        ,p_lookup_code           => p_ckl_category
        )
      then
      --
        fnd_message.set_name('PER','PER_449673_CKL_INV_CKL_CATGRY');
        fnd_message.raise_error;
      --
      end if;
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'|| l_proc, 20);

  exception when app_exception.application_exception then
        if hr_multi_message.exception_add
                 (p_associated_column1      => 'PER_CHECKLISTS.CHECKLIST_CATEGORY'
                 ) then
              hr_utility.set_location(' Leaving:'|| l_proc, 60);
              raise;
            end if;
            hr_utility.set_location(' Leaving:'|| l_proc, 70);
--
end chk_ckl_category;
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
  (p_rec in per_ckl_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.checklist_id is not null)  and (
    nvl(per_ckl_shd.g_old_rec.information_category, hr_api.g_varchar2) <>
    nvl(p_rec.information_category, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information1, hr_api.g_varchar2) <>
    nvl(p_rec.information1, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information2, hr_api.g_varchar2) <>
    nvl(p_rec.information2, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information3, hr_api.g_varchar2) <>
    nvl(p_rec.information3, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information4, hr_api.g_varchar2) <>
    nvl(p_rec.information4, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information5, hr_api.g_varchar2) <>
    nvl(p_rec.information5, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information6, hr_api.g_varchar2) <>
    nvl(p_rec.information6, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information7, hr_api.g_varchar2) <>
    nvl(p_rec.information7, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information8, hr_api.g_varchar2) <>
    nvl(p_rec.information8, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information9, hr_api.g_varchar2) <>
    nvl(p_rec.information9, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information10, hr_api.g_varchar2) <>
    nvl(p_rec.information10, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information11, hr_api.g_varchar2) <>
    nvl(p_rec.information11, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information12, hr_api.g_varchar2) <>
    nvl(p_rec.information12, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information13, hr_api.g_varchar2) <>
    nvl(p_rec.information13, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information14, hr_api.g_varchar2) <>
    nvl(p_rec.information14, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information15, hr_api.g_varchar2) <>
    nvl(p_rec.information15, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information16, hr_api.g_varchar2) <>
    nvl(p_rec.information16, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information17, hr_api.g_varchar2) <>
    nvl(p_rec.information17, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information18, hr_api.g_varchar2) <>
    nvl(p_rec.information18, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information19, hr_api.g_varchar2) <>
    nvl(p_rec.information19, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.information20, hr_api.g_varchar2) <>
    nvl(p_rec.information20, hr_api.g_varchar2) ))
    or (p_rec.checklist_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => p_rec.information_category
      ,p_attribute1_name                 => 'INFORMATION1'
      ,p_attribute1_value                => p_rec.information1
      ,p_attribute2_name                 => 'INFORMATION2'
      ,p_attribute2_value                => p_rec.information2
      ,p_attribute3_name                 => 'INFORMATION3'
      ,p_attribute3_value                => p_rec.information3
      ,p_attribute4_name                 => 'INFORMATION4'
      ,p_attribute4_value                => p_rec.information4
      ,p_attribute5_name                 => 'INFORMATION5'
      ,p_attribute5_value                => p_rec.information5
      ,p_attribute6_name                 => 'INFORMATION6'
      ,p_attribute6_value                => p_rec.information6
      ,p_attribute7_name                 => 'INFORMATION7'
      ,p_attribute7_value                => p_rec.information7
      ,p_attribute8_name                 => 'INFORMATION8'
      ,p_attribute8_value                => p_rec.information8
      ,p_attribute9_name                 => 'INFORMATION9'
      ,p_attribute9_value                => p_rec.information9
      ,p_attribute10_name                => 'INFORMATION10'
      ,p_attribute10_value               => p_rec.information10
      ,p_attribute11_name                => 'INFORMATION11'
      ,p_attribute11_value               => p_rec.information11
      ,p_attribute12_name                => 'INFORMATION12'
      ,p_attribute12_value               => p_rec.information12
      ,p_attribute13_name                => 'INFORMATION13'
      ,p_attribute13_value               => p_rec.information13
      ,p_attribute14_name                => 'INFORMATION14'
      ,p_attribute14_value               => p_rec.information14
      ,p_attribute15_name                => 'INFORMATION15'
      ,p_attribute15_value               => p_rec.information15
      ,p_attribute16_name                => 'INFORMATION16'
      ,p_attribute16_value               => p_rec.information16
      ,p_attribute17_name                => 'INFORMATION17'
      ,p_attribute17_value               => p_rec.information17
      ,p_attribute18_name                => 'INFORMATION18'
      ,p_attribute18_value               => p_rec.information18
      ,p_attribute19_name                => 'INFORMATION19'
      ,p_attribute19_value               => p_rec.information19
      ,p_attribute20_name                => 'INFORMATION20'
      ,p_attribute20_value               => p_rec.information20
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
  (p_rec in per_ckl_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.checklist_id is not null)  and (
    nvl(per_ckl_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_ckl_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.checklist_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
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
  (p_effective_date               in date
  ,p_rec in per_ckl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_ckl_shd.api_updating
      (p_checklist_id                      => p_rec.checklist_id
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
  (p_effective_date               in date
  ,p_rec                          in per_ckl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_ckl_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  per_ckl_bus.chk_name
  (p_name                   => p_rec.name
  ,p_category               => p_rec.checklist_category
  ,p_business_group_id      => p_rec.business_group_id
  ,p_checklist_id           => p_rec.checklist_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  per_ckl_bus.chk_ler_id
  (p_ler_id             => p_rec.event_reason_id
  ,p_business_group_id  => p_rec.business_group_id
  ,p_effective_date     => p_effective_date
   );
  --
  per_ckl_bus.chk_ckl_category
  (p_checklist_id     => p_rec.checklist_id,
   p_ckl_category     => p_rec.checklist_category,
   p_effective_date   => p_effective_date
  );
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
/*  per_ckl_bus.chk_ddf(p_rec);
  --
  per_ckl_bus.chk_df(p_rec);
*/  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_ckl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id
    (p_business_group_id => p_rec.business_group_id
    ,p_associated_column1 => per_ckl_shd.g_tab_nam
                              || '.BUSINESS_GROUP_ID');
  --
  --
  per_ckl_bus.chk_name
  (p_name                   => p_rec.name
  ,p_category               => p_rec.checklist_category
  ,p_business_group_id      => p_rec.business_group_id
  ,p_checklist_id           => p_rec.checklist_id
  ,p_object_version_number  => p_rec.object_version_number
  );
  --
  per_ckl_bus.chk_ler_id
  (p_ler_id             => p_rec.event_reason_id
  ,p_business_group_id  => p_rec.business_group_id
  ,p_effective_date     => p_effective_date
   );
  --
  per_ckl_bus.chk_ckl_category
  (p_checklist_id     => p_rec.checklist_id,
   p_ckl_category     => p_rec.checklist_category,
   p_effective_date   => p_effective_date
  );
  --
  -- After validating the set of important attributes,
  -- if Multiple Message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
/*
  per_ckl_bus.chk_ddf(p_rec);
  --
  per_ckl_bus.chk_df(p_rec);
*/
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_ckl_shd.g_rec_type
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
end per_ckl_bus;

/
