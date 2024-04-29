--------------------------------------------------------
--  DDL for Package Body PER_SHA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SHA_BUS" as
/* $Header: pesharhi.pkb 115.6 2002/12/06 16:54:11 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_sha_bus.';  -- Global package name
--
--
-- The following two global variables are only to be used by the
-- return_legislation_code function.
--
g_std_holiday_absences_id number default null;
g_legislation_code        varchar2(150) default null;
--
--  -----------------------------------------------------------------
--  |-----------------------< chk_non_updateable_args >--------------|
--  -----------------------------------------------------------------
--
Procedure chk_non_updateable_args
  (p_rec            in per_sha_shd.g_rec_type
  ) is
--
  l_proc     varchar2(72) := g_package||'chk_non_updateable_args';
  l_error    exception;
  l_argument varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Only proceed with validation if a row exists for
  -- the current record in the HR Schema
  --
  if not per_sha_shd.api_updating
      (p_std_holiday_absences_id  => p_rec.std_holiday_absences_id,
       p_object_version_number    => p_rec.object_version_number)
  then
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP', '20');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  if nvl(p_rec.person_id, hr_api.g_number) <>
     nvl(per_sha_shd.g_old_rec.person_id
        ,hr_api.g_number
        ) then
     l_argument := 'person_id';
     raise l_error;
  end if;
  --
 hr_utility.set_location(l_proc, 40);
exception
    when l_error then
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument
         );
    when others then
       raise;
  hr_utility.set_location(' Leaving:'||l_proc, 50);
end chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_date_not_taken >---------------------------|
-- ----------------------------------------------------------------------------
--
-- Descriiption :
--
--   DATE_NOT_TAKEN is mandatory and cannot be updated if the ACTUAL_DATE_TAKEN
--   is not NULL or the expired flag is set.
--
--  Pre-conditions :
--    Format for date_not_taken  must be correct
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_date_not_taken
--    p_actual_date_taken
--    p_expired
--    p_object_version_number
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
procedure chk_date_not_taken
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_date_not_taken          in per_std_holiday_absences.date_not_taken%TYPE
  ,p_actual_date_taken       in per_std_holiday_absences.actual_date_taken%TYPE
  ,p_expired                 in per_std_holiday_absences.expired%TYPE
  ,p_object_version_number   in per_std_holiday_absences.object_version_number%TYPE
    )   is
--
 l_proc  varchar2(72) := g_package||'chk_date_not_taken';
 l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  BEGIN
    hr_api.mandatory_arg_error
      (p_api_name         => l_proc
      ,p_argument         => 'date_not_taken'
      ,p_argument_value   => p_date_not_taken
      );
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_message(800,'PER_50042_DATE_NOT_TAKEN_NULL');
      hr_utility.raise_error;
  END;
  --
  -- Check whether field is being updated
  --
  l_api_updating := per_sha_shd.api_updating
    (p_std_holiday_absences_id => p_std_holiday_absences_id,
     p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating AND
       per_sha_shd.g_old_rec.date_not_taken <> p_date_not_taken) then
    --
    -- Check whether the ACTUAL_DATE_TAKEN is NULL
    --
    if (p_actual_date_taken IS NOT NULL) then
      hr_utility.set_message(800,'PER_50029_SHA_HOL_UPDATE');
      hr_utility.raise_error;
    elsif (p_expired = 'Y') then
      hr_utility.set_message(800,'PER_50040_SHA_HOL_UPDATE_EXPD');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_date_not_taken;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_person_id >-----------------------------|
-- ----------------------------------------------------------------------------
--
--  Descriiption :
--    PERSON_ID is mandatory and must exist in PER_PEOPLE_F for the date
--    of the holiday, DATE_NOT_TAKEN.
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_person_id
--    p_date_not_taken
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
procedure chk_person_id
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_person_id               in per_std_holiday_absences.person_id%TYPE
  ,p_date_not_taken          in per_std_holiday_absences.date_not_taken%TYPE
    )   is
--
 l_proc  varchar2(72) := g_package||'chk_person_id';
 l_dummy number;
--
  CURSOR csr_valid_person_id IS
    SELECT per.person_id
    FROM   per_people_f per
    WHERE  per.person_id = p_person_id
    AND    p_date_not_taken BETWEEN per.effective_start_date
                                AND per.effective_end_date;
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'person_id'
    ,p_argument_value   => p_person_id
    );
  --
  -- Check that the PERSON_ID exists in PER_PEOPLE_F
  --
  open csr_valid_person_id;
  fetch csr_valid_person_id into l_dummy;
  if (csr_valid_person_id%NOTFOUND) then
    close csr_valid_person_id;
    hr_utility.set_message(800,'HR_52361_PTU_INVALID_PERSON_ID');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_standard_holiday_id >-------------------------|
-- ----------------------------------------------------------------------------
--
--  Descriiption :
--    STANDARD_HOLIDAY_ID is mandatory and must exist in
--    PER_STANDARD_HOLIDAYS
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_standard_holiday_id
--    p_actual_date_taken
--    p_expired
--    p_object_version_number
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
procedure chk_standard_holiday_id
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_standard_holiday_id     in per_std_holiday_absences.standard_holiday_id%TYPE
  ,p_actual_date_taken       in per_std_holiday_absences.actual_date_taken%TYPE
  ,p_expired                 in per_std_holiday_absences.expired%TYPE
  ,p_object_version_number   in per_std_holiday_absences.object_version_number%TYPE
    )   is
--
 l_proc  varchar2(72) := g_package||'chk_standard_holiday_id';
 l_dummy number;
 l_api_updating boolean;
--
  CURSOR csr_valid_std_hol_id IS
    SELECT sth.standard_holiday_id
    FROM   per_standard_holidays sth
    WHERE  sth.standard_holiday_id = p_standard_holiday_id;
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  --    Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'standard_holiday_id'
    ,p_argument_value   => p_standard_holiday_id
    );
  --
  -- Check that the STANDARD_HOLIDAY_ID exists in PER_STANDARD_HOLIDAYS
  --
  open csr_valid_std_hol_id;
  fetch csr_valid_std_hol_id into l_dummy;
  if (csr_valid_std_hol_id%NOTFOUND) then
    close csr_valid_std_hol_id;
    hr_utility.set_message(800,'PER_50038_SHA_INVALID_HOL_ID');
    hr_utility.raise_error;
  end if;
  --
  -- Update is not allowed if the ACTUAL_DATE_TAKEN is not NULL or the
  -- EXPIRED flag is 'checked'
  --
  l_api_updating := per_sha_shd.api_updating
    (p_std_holiday_absences_id => p_std_holiday_absences_id,
     p_object_version_number   => p_object_version_number);
  --
  if (l_api_updating AND
       per_sha_shd.g_old_rec.standard_holiday_id <> p_standard_holiday_id) then
    if (p_actual_date_taken is not NULL) then
      hr_utility.set_message(800,'PER_50028_SHA_HOL_UPDATE_ID');
      hr_utility.raise_error;
    elsif (p_expired = 'Y') then
      hr_utility.set_message(800,'PER_50039_SHA_EXPIRED_POP');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_standard_holiday_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_actual_date_taken >--------------------------|
-- ----------------------------------------------------------------------------
--
--  Descriiption :
--    This check procedure ensures that
--    a) the ACTUAL_DATE_TAKEN does not overlap with the Standard Holidays
--       defined for the Legislation/Sub-Legislation.
--    b) the ACTUAL_DATE_TAKEN cannot be updated if the expired flag is set.
--
--  Pre-conditions :
--    None
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_actual_date_taken
--    p_person_id
--    p_expired
--    p_object_version_number
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
procedure chk_actual_date_taken
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_actual_date_taken     in per_std_holiday_absences.actual_date_taken%TYPE
  ,p_person_id             in per_std_holiday_absences.person_id%TYPE
  ,p_expired               in per_std_holiday_absences.expired%TYPE
  ,p_object_version_number in per_std_holiday_absences.object_version_number%TYPE
    )   is
--
 l_proc   varchar2(72) := g_package||'chk_actual_date_taken';
 l_dummy  number(15);
 l_api_updating boolean;
--
  CURSOR csr_valid_actual_date_taken IS
    SELECT NVL(sth.standard_holiday_id,99)
    FROM   per_standard_holidays    sth,
           per_people_f             per,
           per_business_groups      bus
    WHERE  per.person_id               = p_person_id
    AND    p_actual_date_taken BETWEEN per.effective_start_date
           AND per.effective_end_date
    AND    bus.business_group_id       = per.business_group_id
    AND    sth.legislation_code        = bus.legislation_code
    AND    p_actual_date_taken BETWEEN sth.holiday_date
           AND NVL(sth.holiday_date_end, sth.holiday_date);
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check whether field is being updated
  --
  l_api_updating := per_sha_shd.api_updating
    (p_std_holiday_absences_id => p_std_holiday_absences_id,
     p_object_version_number   => p_object_version_number);
  --
  if ((l_api_updating AND
       nvl(per_sha_shd.g_old_rec.actual_date_taken, hr_api.g_date) <>
       nvl(p_actual_date_taken, hr_api.g_date))
      OR
       (NOT l_api_updating  AND p_actual_date_taken IS NOT NULL)) then
    --
    -- Check that the EXPIRED flag is not checked
    --
    if (p_expired = 'Y') then
      hr_utility.set_message(801,'PER_50026_SHA_EXPIRED_CHKD');
      hr_utility.raise_error;
    end if;
    --
    -- Check that the ACTUAL_DATE_TAKEN does not overlap with any of the
    -- Standard Holidays
    --
    open csr_valid_actual_date_taken;
    fetch csr_valid_actual_date_taken into l_dummy;
    if (csr_valid_actual_date_taken%FOUND) then
      close csr_valid_actual_date_taken;
      hr_utility.set_message(800,'PER_50025_SHA_DATE_NO_OVERLAP');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_actual_date_taken;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_expired >--------------------------------|
-- ----------------------------------------------------------------------------
--
--  Descriiption :
--    This check procedure ensures that the EXPIRED flag is not checked if
--    the ACTUAL_DATE_TAKEN is not NULL
--
--  Pre-conditions :
--    This must be either 'Y' or 'N'
--
--  In Arguments :
--    p_std_holiday_absences_id
--    p_expired
--    p_actual_date_taken
--    p_object_version_number
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
procedure chk_expired
  (p_std_holiday_absences_id in per_std_holiday_absences.std_holiday_absences_id%TYPE
  ,p_expired                 in per_std_holiday_absences.expired%TYPE
  ,p_actual_date_taken       in per_std_holiday_absences.actual_date_taken%TYPE
  ,p_object_version_number   in per_std_holiday_absences.object_version_number%TYPE
    )   is
--
 l_proc   varchar2(72) := g_package||'chk_expired';
 l_api_updating boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Check whether field is being updated
  --
  l_api_updating := per_sha_shd.api_updating
    (p_std_holiday_absences_id => p_std_holiday_absences_id,
     p_object_version_number   => p_object_version_number);

  if ((l_api_updating AND
       nvl(per_sha_shd.g_old_rec.expired, hr_api.g_varchar2) <>
       nvl(p_expired, hr_api.g_varchar2))
      OR
       NOT l_api_updating) then
    --
    -- The EXPIRED flag can only be set if the ACTUAL_DATE_TAKEN is NULL
    --
    if (p_actual_date_taken is not NULL AND
        p_expired = 'Y') then
      hr_utility.set_message(800,'PER_50027_SHA_EXPIRED_UPD');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 3);
  --
end chk_expired;
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
  (p_rec in per_sha_shd.g_rec_type) is
--
  l_proc     varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.std_holiday_absences_id is not null) and (
    nvl(per_sha_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2) or
    nvl(per_sha_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)))
    or
    (p_rec.std_holiday_absences_id is null) then
   --
   -- Only execute the validation if absolutely necessary:
   -- a) During update, the structure column value or any
   --    of the attribute values have actually changed.
   -- b) During insert.
   --
   hr_dflex_utility.ins_or_upd_descflex_attribs
     (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_STD_HOLIDAY_ABSENCES'
      ,p_attribute_category => p_rec.attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => p_rec.attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => p_rec.attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => p_rec.attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => p_rec.attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => p_rec.attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => p_rec.attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => p_rec.attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => p_rec.attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => p_rec.attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => p_rec.attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => p_rec.attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => p_rec.attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => p_rec.attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => p_rec.attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => p_rec.attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => p_rec.attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => p_rec.attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => p_rec.attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => p_rec.attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => p_rec.attribute20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
end chk_df;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_sha_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  hr_api.set_security_group_id(p_security_group_id => 0);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Validate Standard Holiday Dates not taken
  --
  chk_date_not_taken
        (p_rec.std_holiday_absences_id,
         p_rec.date_not_taken,
         p_rec.actual_date_taken,
         p_rec.expired,
         p_rec.object_version_number);
  --
  -- Validate Person
  --
  chk_person_id
        (p_rec.std_holiday_absences_id,
         p_rec.person_id,
         p_rec.date_not_taken);
  --
  -- Validate Standard Holiday Id
  --
  chk_standard_holiday_id
        (p_rec.std_holiday_absences_id,
         p_rec.standard_holiday_id,
         p_rec.actual_date_taken,
         p_rec.expired,
         p_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- Validate Actual Date Taken
  --
  chk_actual_date_taken
        (p_rec.std_holiday_absences_id,
         p_rec.actual_date_taken,
         p_rec.person_id,
         p_rec.expired,
         p_rec.object_version_number);
  --
  -- Validate Expire Flag
  --
  chk_expired
        (p_rec.std_holiday_absences_id,
         p_rec.expired,
         p_rec.actual_date_taken,
         p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  -- call descriptive flexfield validation routines
  --
  per_sha_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location (l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_sha_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As this data is not within the context of a business group
  -- the set_security_group_id procedure has zero passed
  -- to it as the default security_group_id.
  --
  hr_api.set_security_group_id(p_security_group_id => 0);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Check no non-updateable arguments have been updated
  --
  chk_non_updateable_args (p_rec => p_rec);
  --
  -- Validate Standard Holiday Dates not taken
  --
  chk_date_not_taken
        (p_rec.std_holiday_absences_id,
         p_rec.date_not_taken,
         p_rec.actual_date_taken,
         p_rec.expired,
         p_rec.object_version_number);
  --
  -- Validate Standard Holiday Id
  --
  chk_standard_holiday_id
        (p_rec.std_holiday_absences_id,
         p_rec.standard_holiday_id,
         p_rec.actual_date_taken,
         p_rec.expired,
         p_rec.object_version_number);
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  -- Validate Actual Date Taken
  --
  chk_actual_date_taken
        (p_rec.std_holiday_absences_id,
         p_rec.actual_date_taken,
         p_rec.person_id,
         p_rec.expired,
         p_rec.object_version_number);
  --
  -- Validate Expire Flag
  --
  chk_expired
        (p_rec.std_holiday_absences_id,
         p_rec.expired,
         p_rec.actual_date_taken,
         p_rec.object_version_number);
  --
  --
  hr_utility.set_location (l_proc, 15);
  --
  -- call descriptive flexfield validation routines
  --
  per_sha_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_sha_shd.g_rec_type) is
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
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_std_holiday_absences_id              in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_people_f         per
         , per_std_holiday_absences sha
     where sha.std_holiday_absences_id   = p_std_holiday_absences_id
       and per.person_id = sha.person_id
       and pbg.business_group_id = per.business_group_id
  order by per.effective_start_date;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'std_holiday_absences_id',
                             p_argument_value => p_std_holiday_absences_id);
  --
  if nvl(g_std_holiday_absences_id, hr_api.g_number) = p_std_holiday_absences_id then
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
    g_std_holiday_absences_id := p_std_holiday_absences_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 25);
  --
  return l_legislation_code;
end return_legislation_code;
--
end per_sha_bus;

/
