--------------------------------------------------------
--  DDL for Package Body PE_PEI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PE_PEI_BUS" as
/* $Header: pepeirhi.pkb 120.1 2005/07/25 05:01:42 jpthomas noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pe_pei_bus.';  -- Global package name
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_person_extra_info_id number        default null;
g_legislation_code     varchar2(150) default null;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_person_extra_info_id in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups   pbg
          ,per_people_extra_info pei
          ,per_all_people_f      per
     where pei.person_extra_info_id = p_person_extra_info_id
       and per.person_id            = pei.person_id
       and pbg.business_group_id    = per.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameters are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc
    ,p_argument       => 'person_extra_info_id'
    ,p_argument_value => p_person_extra_info_id);
  --
  if nvl(g_person_extra_info_id, hr_api.g_number) = p_person_extra_info_id then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    if csr_leg_code%notfound then
      close csr_leg_code;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;
    --
    close csr_leg_code;
    hr_utility.set_location(' Leaving:'|| l_proc, 20);
    --
    g_person_extra_info_id := p_person_extra_info_id;
    g_legislation_code     := l_legislation_code;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 25);
  --
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Verify that the non updateable arguments not changed.
--   For the PERSON_EXTRA_INFO table neither of the FK's can be updated
--   i.e. PERSON_ID and INFORMATION_TYPE
--
-- Pre Conditions:
--   None
--
-- In Parameters:
--   p_rec
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
Procedure chk_non_updateable_args(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc        varchar2(72) := g_package||'chk_non_updateable_args';
  l_error       exception;
  l_argument    varchar2(30);
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc,10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema.
  if not pe_pei_shd.api_updating
   (p_person_extra_info_id  => p_rec.person_extra_info_id
   ,p_object_version_number => p_rec.object_version_number
   ) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
  end if;
  --
  hr_utility.set_location (l_proc, 30);
  --
  if nvl(p_rec.person_id,hr_api.g_number)
        <> nvl(pe_pei_shd.g_old_rec.person_id,hr_api.g_number) then
     l_argument := 'person_id';
     raise l_error;
  end if;
  --
  if nvl(p_rec.information_type,hr_api.g_varchar2)
        <> nvl(pe_pei_shd.g_old_rec.information_type,hr_api.g_varchar2) then
     l_argument := 'information_type';
     raise l_error;
  end if;
  --
  hr_utility.set_location(' Leaving : '|| l_proc, 40);
  --
  exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    when others then
       raise;
end chk_non_updateable_args;
--
--  ---------------------------------------------------------------------------
--  |------------------------------< chk_person_id >---------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the person id exists on the PER_PERSON_F
--    table. Note: It does not check if they exists at a given time such as
--    p_effective_date
--
--  Pre-conditions :
--    None
--
--  In Parameters :
--    p_person_id
--
--  Post Success :
--    Processing continues if the person id is valid
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    person id is invalid
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_person_id
  (p_person_id    in  per_people_extra_info.person_id%TYPE
  --  ,p_effective_date  in  date
    )	is
  --
  l_proc         varchar2(72) := g_package||'chk_person_id';
  l_person_found boolean := false;
  --
  cursor csr_person_id is
    SELECT 1
    FROM   per_all_people_f per                    -- Bug 4508101
    WHERE  per.person_id = p_person_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'person_id',
     p_argument_value   => p_person_id
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Now check to see if the person exists
  --
  for csr_person_id_rec in csr_person_id loop
    --
    hr_utility.set_location(l_proc, 30);
    --
    l_person_found := true;
    exit;
  end loop;
  --
  hr_utility.set_location(l_proc, 40);
  --
  if not l_person_found then
    --
    hr_utility.set_location(l_proc, 50);
    --
    hr_utility.set_message(800, 'HR_INV_PERSON');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_information_type >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption:
--    This procedures validates that the information type is active on the
--    PER_PEOPLE_INFO_TYPE table
--
--  Pre-conditions :
--    p_person_id is valid
--
--  In Parameters :
--    p_information_type
--    p_person_id
--
--  Post Success :
--    Processing continues if the information type is active. It will also
--    continue if the information type does not allow multiple occurrences and
--    there doesn't a record for the given information type and person.
--
--  Post Failure :
--    An application error will be raised and processing is terminated if the
--    information type is not active.
--    An application error will also be raised and processing is terminated if
--    the information type doe not allow multiple occurrences and there already
--    exists a record for that information type and person.
--
--  Access Status :
--    Internal Row Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_information_type
 (p_information_type in  per_people_extra_info.information_type%TYPE
 ,p_person_id        in  per_people_extra_info.person_id%TYPE) is
  --
  -- Declare local variables
  --
  l_proc                   varchar2(72) := g_package||'chk_information_type';
  --
  CURSOR csr_info_type IS
    SELECT pit.multiple_occurences_flag
          ,pit.active_inactive_flag
    FROM   per_people_info_types  pit
    WHERE  pit.information_type = p_information_type;
  --
  CURSOR csr_extra_info IS
    SELECT 1
    FROM   per_people_extra_info pei
    WHERE  pei.information_type = p_information_type
    AND    pei.person_id        = p_person_id ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (
     p_api_name         => l_proc,
     p_argument         => 'information_type',
     p_argument_value   => p_information_type
    );
  --
  hr_utility.set_location(l_proc, 7);
  --
  for csr_info_type_rec in csr_info_type loop
    --
    hr_utility.set_location(l_proc, 10);
    --
    -- We would only come here if the information type was valid if it is not
    -- valid then we do not want to do the following checks. We will leave the FK
    -- to be checked by the constraint PER_PEOPLE_EXTRA_INFO_FK1 at DML time
    -- Also leave the check it is mandatory to the database
    --
    -- Check to see the info type is still active
    --
    if csr_info_type_rec.active_inactive_flag = 'N' then
      --
      hr_utility.set_location(l_proc, 15);
      --
      hr_utility.set_message(800, 'HR_INACTIVE_INFO_TYPE');
      hr_utility.raise_error;
    end if;
    --
    -- If multiple ocurrences flag says N(o) then there is not allowed to be a
    -- record already on the EXTRA_INFO table
    --
    hr_utility.set_location(l_proc, 20);
    --
    if csr_info_type_rec.multiple_occurences_flag = 'N' THEN
      --
      hr_utility.set_location(l_proc, 25);
      --
      for csr_extra_info_rec in csr_extra_info loop
        --
        hr_utility.set_location(l_proc, 30);
        --
        -- If we are here the multiple ocurrences flag is N and there
        -- already exists a record on the EXTRA_INFO table for the given
        -- person and info type
        --
        -- Fix for WWBUG 1621849. Provide a better error message.
        --
        if p_information_type = 'PER_US_ADDITIONAL_DETAILS' then
          --
          fnd_message.set_name('PER','HR_289377_VISA_ADD_DETAILS');
          fnd_message.raise_error;
          --
        end if;
        --
        -- Otherwise let the generic message be raised.
        --
        hr_utility.set_message(800, 'HR_PEI_MORE_THAN_1_RECORD');
        hr_utility.raise_error;
        --
      end loop;
      --
    end if;
    --
  end loop;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End chk_information_type;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_df >-----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
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
procedure chk_df
  (p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.person_extra_info_id is not null) and (
     nvl(pe_pei_shd.g_old_rec.pei_attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute_category, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute1, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute2, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute3, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute4, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute5, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute6, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute7, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute8, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute9, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute10, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute11, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute12, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute13, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute14, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute15, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute16, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute17, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute18, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute19, hr_api.g_varchar2) or
     nvl(pe_pei_shd.g_old_rec.pei_attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.pei_attribute20, hr_api.g_varchar2)))
     or
     (p_rec.person_extra_info_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_PEOPLE_EXTRA_INFO'
      ,p_attribute_category => p_rec.pei_attribute_category
      ,p_attribute1_name    => 'PEI_ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.pei_attribute1
      ,p_attribute2_name    => 'PEI_ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.pei_attribute2
      ,p_attribute3_name    => 'PEI_ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.pei_attribute3
      ,p_attribute4_name    => 'PEI_ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.pei_attribute4
      ,p_attribute5_name    => 'PEI_ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.pei_attribute5
      ,p_attribute6_name    => 'PEI_ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.pei_attribute6
      ,p_attribute7_name    => 'PEI_ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.pei_attribute7
      ,p_attribute8_name    => 'PEI_ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.pei_attribute8
      ,p_attribute9_name    => 'PEI_ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.pei_attribute9
      ,p_attribute10_name   => 'PEI_ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.pei_attribute10
      ,p_attribute11_name   => 'PEI_ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.pei_attribute11
      ,p_attribute12_name   => 'PEI_ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.pei_attribute12
      ,p_attribute13_name   => 'PEI_ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.pei_attribute13
      ,p_attribute14_name   => 'PEI_ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.pei_attribute14
      ,p_attribute15_name   => 'PEI_ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.pei_attribute15
      ,p_attribute16_name   => 'PEI_ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.pei_attribute16
      ,p_attribute17_name   => 'PEI_ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.pei_attribute17
      ,p_attribute18_name   => 'PEI_ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.pei_attribute18
      ,p_attribute19_name   => 'PEI_ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.pei_attribute19
      ,p_attribute20_name   => 'PEI_ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.pei_attribute20);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
--
-- -----------------------------------------------------------------------
-- |------------------------------< chk_ddf >----------------------------|
-- -----------------------------------------------------------------------
--
-- Description:
--   Validates the all Developer Descriptive Flexfield values.
--
-- Pre-conditions:
--   All other columns have been validated. Must be called as the
--   second last step from insert_validate and update_validate.
--   Before any Descriptive Flexfield (chk_df) calls.
--
-- In Arguments:
--   p_rec
--
-- Post Success:
--   If the Developer Descriptive Flexfield structure column and data
--   values are all valid this procedure will end normally and
--   processing will continue.
--
-- Post Failure:
--   If the DDF structure column value or any of the data values
--   are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_ddf
  (p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc       varchar2(72) := g_package||'chk_ddf';
  l_error      exception;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check if the row is being inserted or updated and a
  -- value has changed
  --
  if (p_rec.person_extra_info_id is null)
    or ((p_rec.person_extra_info_id is not null)
    and
    nvl(pe_pei_shd.g_old_rec.pei_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information_category, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information1, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information2, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information3, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information4, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information5, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information6, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information7, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information8, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information9, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information10, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information11, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information12, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information13, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information14, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information15, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information16, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information17, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information18, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information19, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information20, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information21, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information21, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information22, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information22, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information23, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information23, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information24, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information24, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information25, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information25, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information26, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information26, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information27, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information27, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information28, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information28, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information29, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information29, hr_api.g_varchar2) or
    nvl(pe_pei_shd.g_old_rec.pei_information30, hr_api.g_varchar2) <>
    nvl(p_rec.pei_information30, hr_api.g_varchar2))
  then
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Extra Person Info DDF'
      ,p_attribute_category => p_rec.pei_information_category
      ,p_attribute1_name    => 'PEI_INFORMATION1'
      ,p_attribute1_value   => p_rec.pei_information1
      ,p_attribute2_name    => 'PEI_INFORMATION2'
      ,p_attribute2_value   => p_rec.pei_information2
      ,p_attribute3_name    => 'PEI_INFORMATION3'
      ,p_attribute3_value   => p_rec.pei_information3
      ,p_attribute4_name    => 'PEI_INFORMATION4'
      ,p_attribute4_value   => p_rec.pei_information4
      ,p_attribute5_name    => 'PEI_INFORMATION5'
      ,p_attribute5_value   => p_rec.pei_information5
      ,p_attribute6_name    => 'PEI_INFORMATION6'
      ,p_attribute6_value   => p_rec.pei_information6
      ,p_attribute7_name    => 'PEI_INFORMATION7'
      ,p_attribute7_value   => p_rec.pei_information7
      ,p_attribute8_name    => 'PEI_INFORMATION8'
      ,p_attribute8_value   => p_rec.pei_information8
      ,p_attribute9_name    => 'PEI_INFORMATION9'
      ,p_attribute9_value   => p_rec.pei_information9
      ,p_attribute10_name   => 'PEI_INFORMATION10'
      ,p_attribute10_value  => p_rec.pei_information10
      ,p_attribute11_name   => 'PEI_INFORMATION11'
      ,p_attribute11_value  => p_rec.pei_information11
      ,p_attribute12_name   => 'PEI_INFORMATION12'
      ,p_attribute12_value  => p_rec.pei_information12
      ,p_attribute13_name   => 'PEI_INFORMATION13'
      ,p_attribute13_value  => p_rec.pei_information13
      ,p_attribute14_name   => 'PEI_INFORMATION14'
      ,p_attribute14_value  => p_rec.pei_information14
      ,p_attribute15_name   => 'PEI_INFORMATION15'
      ,p_attribute15_value  => p_rec.pei_information15
      ,p_attribute16_name   => 'PEI_INFORMATION16'
      ,p_attribute16_value  => p_rec.pei_information16
      ,p_attribute17_name   => 'PEI_INFORMATION17'
      ,p_attribute17_value  => p_rec.pei_information17
      ,p_attribute18_name   => 'PEI_INFORMATION18'
      ,p_attribute18_value  => p_rec.pei_information18
      ,p_attribute19_name   => 'PEI_INFORMATION19'
      ,p_attribute19_value  => p_rec.pei_information19
      ,p_attribute20_name   => 'PEI_INFORMATION20'
      ,p_attribute20_value  => p_rec.pei_information20
      ,p_attribute21_name   => 'PEI_INFORMATION21'
      ,p_attribute21_value  => p_rec.pei_information21
      ,p_attribute22_name   => 'PEI_INFORMATION22'
      ,p_attribute22_value  => p_rec.pei_information22
      ,p_attribute23_name   => 'PEI_INFORMATION23'
      ,p_attribute23_value  => p_rec.pei_information23
      ,p_attribute24_name   => 'PEI_INFORMATION24'
      ,p_attribute24_value  => p_rec.pei_information24
      ,p_attribute25_name   => 'PEI_INFORMATION25'
      ,p_attribute25_value  => p_rec.pei_information25
      ,p_attribute26_name   => 'PEI_INFORMATION26'
      ,p_attribute26_value  => p_rec.pei_information26
      ,p_attribute27_name   => 'PEI_INFORMATION27'
      ,p_attribute27_value  => p_rec.pei_information27
      ,p_attribute28_name   => 'PEI_INFORMATION28'
      ,p_attribute28_value  => p_rec.pei_information28
      ,p_attribute29_name   => 'PEI_INFORMATION29'
      ,p_attribute29_value  => p_rec.pei_information29
      ,p_attribute30_name   => 'PEI_INFORMATION30'
      ,p_attribute30_value  => p_rec.pei_information30
      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end chk_ddf;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_per_bus.set_security_group_id
   (
    p_person_id => p_rec.person_id
   );
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- 1) Check person id
  --
  pe_pei_bus.chk_person_id
    (p_person_id => p_rec.person_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- 2) Check information type
  --
  pe_pei_bus.chk_information_type
    (p_information_type => p_rec.information_type
    ,p_person_id        => p_rec.person_id);
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- 3) Call ddf procedure to validation Developer Descriptive Flexfields
  --
  pe_pei_bus.chk_ddf(p_rec => p_rec);
  --
  -- Call df procedure to validation Descriptive Flexfields
  --
  pe_pei_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in pe_pei_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_per_bus.set_security_group_id
   (
    p_person_id => p_rec.person_id
   );
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- 1) Check those columns which cannot be updated have not changed.
  --
  hr_utility.set_location(l_proc, 10);
  --
  pe_pei_bus.chk_non_updateable_args (p_rec => p_rec);
  --
  -- 2) Call ddf procedure to validation Developer Descriptive Flexfields
  --
  pe_pei_bus.chk_ddf(p_rec => p_rec);
  --
  -- Call df procedure to validation Descriptive Flexfields
  --
  pe_pei_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in pe_pei_shd.g_rec_type) is
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
end pe_pei_bus;

/
