--------------------------------------------------------
--  DDL for Package Body PER_JOB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JOB_BUS" as
/* $Header: pejobrhi.pkb 120.0.12010000.2 2009/05/12 06:16:11 varanjan ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_job_bus.';  -- Global package name
--
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code         varchar2(150) default null;
g_job_id                   number        default null;
--
--  ---------------------------------------------------------------------------
--  |--------------------<  chk_job_definition_id  >---------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates that JOB_DEFINITION_ID is not null
--
--    Validates that JOB_DEFINITION_ID in the PER_JOB_DEFINITIONS table
--    exists for the record specified by JOB_DEFINITION_ID.
--    Validate that JOB_DEFINITION_ID is unique for each business group.
--
--  Pre-conditions:
--    None.
--
--  In Arguments :
--    p_job_definition_id
--    p_business_group_id
--    p_job_id
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- -----------------------------------------------------------------------
procedure chk_job_definition_id
  (p_job_definition_id     in number,
   p_business_group_id          in      number,
   p_job_id                     in      number default null,
   p_object_version_number      in      number default null
  )   is
--
   l_proc   varchar2(72)   := g_package||'chk_job_definition_id';
   l_exists    varchar2(1);
   l_api_updating  boolean;
--
cursor csr_job_def is
  select 'x'
  from per_job_definitions
  where job_definition_id = p_job_definition_id;
--
cursor csr_unique_job_def is
  select 'x'
    from per_jobs
   where job_definition_id     = p_job_definition_id
     and business_group_id + 0 = p_business_group_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --  Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'job_definition_id'
    ,p_argument_value   => p_job_definition_id
    );
  --
  hr_utility.set_location(l_proc, 2);
  --
  l_api_updating := per_job_shd.api_updating
    (p_job_id               => p_job_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 3);
  --
  if ((l_api_updating and
       (per_job_shd.g_old_rec.job_definition_id <>
          p_job_definition_id)) or (NOT l_api_updating)) then
    --
    hr_utility.set_location(l_proc, 4);
    --
    open csr_job_def;
    fetch csr_job_def into l_exists;
    if csr_job_def%notfound then
      close csr_job_def;
      per_job_shd.constraint_error(p_constraint_name => 'PER_JOBS_FK2');
    end if;
    close csr_job_def;
    --
    hr_utility.set_location(l_proc, 5);
    --
    open csr_unique_job_def;
    fetch csr_unique_job_def into l_exists;
    if csr_unique_job_def%found then
      close csr_unique_job_def;
      hr_utility.set_message(801,'PER_7810_DEF_JOB_EXISTS');
      hr_utility.raise_error;
    end if;
    close csr_unique_job_def;
    --
  end if;
  hr_utility.set_location('Leaving '||l_proc, 6);
  --
end chk_job_definition_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------------<  chk_dates >--------------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validates DATE_FROM is not null
--
--    Validates that DATE_FROM is less than or equal to the value for
--    DATE_TO on the same JOB record
--
--  Pre-conditions:
--    Format of p_date_effective must be correct
--
--  In Arguments :
--    p_job_id
--    p_date_from
--    p_date_to
--    p_object_version_number
--
--  Post Success :
--    If the above business rules are satisfied, processing continues
--
--  Post Failure :
--    If the above business rules are violated, an application error
--    is raised and processing terminates
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_dates
  (p_job_id          in number default null
  ,p_date_from          in date
  ,p_date_to         in date
  ,p_object_version_number in number default null) is
--
   l_proc          varchar2(72)  := g_package||'chk_dates';
   l_api_updating  boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --  Check mandatory parameters have been set
  --

  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'date_from'
    ,p_argument_value   => p_date_from
    );
  hr_utility.set_location(l_proc, 2);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The date_end value has changed
  --
  l_api_updating := per_job_shd.api_updating
    (p_job_id          => p_job_id
    ,p_object_version_number => p_object_version_number);
  --
  if (((l_api_updating and
       (nvl(per_job_shd.g_old_rec.date_to,hr_api.g_eot) <>
                      nvl(p_date_to,hr_api.g_eot)) or
       (per_job_shd.g_old_rec.date_from <> p_date_from)) or
       (NOT l_api_updating))) then
    --
    --   Check that date_from <= date_to
    --
    hr_utility.set_location(l_proc, 3);
    --
    if p_date_from > nvl(p_date_to,hr_api.g_eot) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE', l_proc);
      hr_utility.set_message_token('STEP', '3');
      hr_utility.raise_error;
    end if;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 4);
end chk_dates;
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
  (p_rec in per_job_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.job_id is not null) and (
     nvl(per_job_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.job_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_JOBS'
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
procedure chk_ddf
  (p_rec in per_job_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.job_id is not null) and (
     nvl(per_job_shd.g_old_rec.job_information_category, hr_api.g_varchar2) <>
     nvl(p_rec.job_information_category, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information1, hr_api.g_varchar2) <>
     nvl(p_rec.job_information1, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information2, hr_api.g_varchar2) <>
     nvl(p_rec.job_information2, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information3, hr_api.g_varchar2) <>
     nvl(p_rec.job_information3, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information4, hr_api.g_varchar2) <>
     nvl(p_rec.job_information4, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information5, hr_api.g_varchar2) <>
     nvl(p_rec.job_information5, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information6, hr_api.g_varchar2) <>
     nvl(p_rec.job_information6, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information7, hr_api.g_varchar2) <>
     nvl(p_rec.job_information7, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information8, hr_api.g_varchar2) <>
     nvl(p_rec.job_information8, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information9, hr_api.g_varchar2) <>
     nvl(p_rec.job_information9, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information10, hr_api.g_varchar2) <>
     nvl(p_rec.job_information10, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information11, hr_api.g_varchar2) <>
     nvl(p_rec.job_information11, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information12, hr_api.g_varchar2) <>
     nvl(p_rec.job_information12, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information13, hr_api.g_varchar2) <>
     nvl(p_rec.job_information13, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information14, hr_api.g_varchar2) <>
     nvl(p_rec.job_information14, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information15, hr_api.g_varchar2) <>
     nvl(p_rec.job_information15, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information16, hr_api.g_varchar2) <>
     nvl(p_rec.job_information16, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information17, hr_api.g_varchar2) <>
     nvl(p_rec.job_information17, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information18, hr_api.g_varchar2) <>
     nvl(p_rec.job_information18, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information19, hr_api.g_varchar2) <>
     nvl(p_rec.job_information19, hr_api.g_varchar2) or
     nvl(per_job_shd.g_old_rec.job_information20, hr_api.g_varchar2) <>
     nvl(p_rec.job_information20, hr_api.g_varchar2)))
     or
     (p_rec.job_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the job_information values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Job Developer DF'
      ,p_attribute_category => p_rec.job_information_category
      ,p_attribute1_name    => 'JOB_INFORMATION1'
      ,p_attribute1_value   => p_rec.job_information1
      ,p_attribute2_name    => 'JOB_INFORMATION2'
      ,p_attribute2_value   => p_rec.job_information2
      ,p_attribute3_name    => 'JOB_INFORMATION3'
      ,p_attribute3_value   => p_rec.job_information3
      ,p_attribute4_name    => 'JOB_INFORMATION4'
      ,p_attribute4_value   => p_rec.job_information4
      ,p_attribute5_name    => 'JOB_INFORMATION5'
      ,p_attribute5_value   => p_rec.job_information5
      ,p_attribute6_name    => 'JOB_INFORMATION6'
      ,p_attribute6_value   => p_rec.job_information6
      ,p_attribute7_name    => 'JOB_INFORMATION7'
      ,p_attribute7_value   => p_rec.job_information7
      ,p_attribute8_name    => 'JOB_INFORMATION8'
      ,p_attribute8_value   => p_rec.job_information8
      ,p_attribute9_name    => 'JOB_INFORMATION9'
      ,p_attribute9_value   => p_rec.job_information9
      ,p_attribute10_name   => 'JOB_INFORMATION10'
      ,p_attribute10_value  => p_rec.job_information10
      ,p_attribute11_name   => 'JOB_INFORMATION11'
      ,p_attribute11_value  => p_rec.job_information11
      ,p_attribute12_name   => 'JOB_INFORMATION12'
      ,p_attribute12_value  => p_rec.job_information12
      ,p_attribute13_name   => 'JOB_INFORMATION13'
      ,p_attribute13_value  => p_rec.job_information13
      ,p_attribute14_name   => 'JOB_INFORMATION14'
      ,p_attribute14_value  => p_rec.job_information14
      ,p_attribute15_name   => 'JOB_INFORMATION15'
      ,p_attribute15_value  => p_rec.job_information15
      ,p_attribute16_name   => 'JOB_INFORMATION16'
      ,p_attribute16_value  => p_rec.job_information16
      ,p_attribute17_name   => 'JOB_INFORMATION17'
      ,p_attribute17_value  => p_rec.job_information17
      ,p_attribute18_name   => 'JOB_INFORMATION18'
      ,p_attribute18_value  => p_rec.job_information18
      ,p_attribute19_name   => 'JOB_INFORMATION19'
      ,p_attribute19_value  => p_rec.job_information19
      ,p_attribute20_name   => 'JOB_INFORMATION20'
      ,p_attribute20_value  => p_rec.job_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_ddf;
--
--  ---------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec in per_job_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Business Group
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 6);
  --
  -- Validate date from and date_to
  --
  chk_dates
  (p_date_from             => p_rec.date_from,
   p_date_to               => p_rec.date_to
  );
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Validate job definition id
  --
  chk_job_definition_id
  (p_job_definition_id     => p_rec.job_definition_id,
   p_business_group_id     =>   p_rec.business_group_id
  );
  --
  -- chk_emp_rights_flag
  --
  hr_utility.set_location(l_proc, 8);
  --
  chk_emp_rights_flag
  (p_emp_rights_flag => p_rec.emp_rights_flag
  ,p_rec             => p_rec);
  --
  -- chk_job_group_id
  --
  hr_utility.set_location(l_proc, 9);
  --
  chk_job_group_id
  (p_job_group_id       => p_rec.job_group_id
  ,p_business_group_id  => p_rec.business_group_id);
  --
  -- chk_approval_authority
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_approval_authority
  (p_approval_authority => p_rec.approval_authority
  ,p_rec                => p_rec);
  --
  -- chk_benchmark_job_flag
  --
  hr_utility.set_location(l_proc, 11);
  --
  chk_benchmark_job_flag
  (p_benchmark_job_flag => p_rec.benchmark_job_flag
  ,p_benchmark_job_id   => p_rec.benchmark_job_id
  ,p_rec                => p_rec);
  --
  -- chk_benchmark_job_id
  --
  hr_utility.set_location(l_proc, 12);
  --
  chk_benchmark_job_id
  (p_benchmark_job_id   => p_rec.benchmark_job_id
  ,p_job_id             => p_rec.job_id
  ,p_business_group_id  => p_rec.business_group_id
  ,p_rec                => p_rec);
  --
  --  Flexfield Validation
  --
  hr_utility.set_location(l_proc, 13);
  --
  chk_ddf(p_rec => p_rec);
  --
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location('Leaving:'||l_proc, 14);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec in per_job_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Validate Business Group
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- chk_non_updateable_args
  --
   chk_non_updateable_args
     (p_date_from  => p_rec.date_from
     ,p_rec        => p_rec);
  --
  hr_utility.set_location(l_proc, 15);
  --
  -- Validate date effective
  --
  chk_dates
  (p_job_id            => p_rec.job_id,
   p_date_from       => p_rec.date_from,
   p_date_to              => p_rec.date_to,
   p_object_version_number => p_rec.object_version_number
   );
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate job definition id
  --
  chk_job_definition_id
  (p_job_definition_id     => p_rec.job_definition_id,
   p_business_group_id     => p_rec.business_group_id,
   p_job_id                => p_rec.job_id,
   p_object_version_number => p_rec.object_version_number
  );
  --
  -- check that the emp_rights_flag is set to Y or N
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_emp_rights_flag
  (p_emp_rights_flag => p_rec.emp_rights_flag
  ,p_rec             => p_rec);
  --
  -- chk_approval_authority
  --
  hr_utility.set_location(l_proc, 35);
  --
  chk_approval_authority
  (p_approval_authority => p_rec.approval_authority
  ,p_rec                => p_rec);
  --
  -- check that both the benchmark_job_flag and benchmark_job_id are not
  -- populated
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_benchmark_job_flag
  (p_benchmark_job_flag => p_rec.benchmark_job_flag
  ,p_benchmark_job_id   => p_rec.benchmark_job_id
  ,p_rec                => p_rec);
  --
  -- chk_benchmark_job_id
  --
  hr_utility.set_location(l_proc, 45);
  --
  chk_benchmark_job_id
  (p_benchmark_job_id   => p_rec.benchmark_job_id
  ,p_job_id             => p_rec.job_id
  ,p_business_group_id  => p_rec.business_group_id
  ,p_rec                => p_rec);
  --
  hr_utility.set_location(l_proc, 50);
  --
  --  Flexfield Validation
  --
  chk_ddf(p_rec => p_rec);
  --
  chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 55);
--
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_job_shd.g_rec_type) is
--
  cursor csr_bg is select business_group_id from per_jobs
                     where job_id = p_rec.job_id;
  l_business_group_id  number;
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  open csr_bg;
  fetch csr_bg into l_business_group_id;
  close csr_bg;
per_job_bus.check_delete_record
     (p_job_id              =>  p_rec.job_id
     ,p_business_group_id   =>  l_business_group_id);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
function return_legislation_code
  (p_job_id           in number
  ) return varchar2 is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups  pbg
         , per_jobs             job
     where job.job_id     = p_job_id
       and pbg.business_group_id = job.business_group_id;
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
                             p_argument       => 'job_id',
                             p_argument_value => p_job_id);
 --
  if nvl(g_job_id, hr_api.g_number) = p_job_id then
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
    g_job_id    := p_job_id;
    g_legislation_code := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_date_from  in date
  ,p_rec in per_job_shd.g_rec_type
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
  IF NOT per_job_shd.api_updating
       (p_job_id                      => p_rec.job_id,
        p_object_version_number       => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF (nvl(p_rec.business_group_id,hr_api.g_number) <>
      nvl(per_job_shd.g_old_rec.business_group_id,hr_api.g_number)
     ) THEN
     l_argument := 'business_group_id';
     RAISE l_error;
  END IF;

  IF (nvl(p_rec.job_group_id,hr_api.g_number) <>
      nvl(per_job_shd.g_old_rec.job_group_id,hr_api.g_number)
     ) THEN
     l_argument := 'job_group_id';
     RAISE l_error;
  END IF;

  IF (nvl(p_rec.job_id,hr_api.g_number) <>
      nvl(per_job_shd.g_old_rec.job_id,hr_api.g_number)
     ) THEN
     l_argument := 'job_id';
     RAISE l_error;
  END IF;

EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- -------------------------------------------------------------------------+
-- |------------------------< chk_emp_rights_flag >-------------------------|
-- -------------------------------------------------------------------------+
procedure chk_emp_rights_flag
  (p_emp_rights_flag in per_jobs.emp_rights_flag%TYPE
  ,p_rec in per_job_shd.g_rec_type) is

  l_proc          varchar2(72) := g_package||'chk_emp_rights_flag';
  l_api_updating  boolean;

begin
   hr_utility.set_location('Entering:'|| l_proc, 10);

  l_api_updating := per_job_shd.api_updating
    (p_job_id                => p_rec.job_id
    ,p_object_version_number => p_rec.object_version_number);

  if  (l_api_updating and
       (nvl(per_job_shd.g_old_rec.emp_rights_flag,hr_api.g_varchar2) <>
        nvl(p_emp_rights_flag,hr_api.g_varchar2)) or NOT l_api_updating) then

     if (p_emp_rights_flag <> 'Y' and p_emp_rights_flag <> 'N' and
         p_emp_rights_flag is not null) then
       hr_utility.set_message(801,'HR_289476_EMP_RIGHTS_FLAG');
       hr_utility.raise_error;
     end if;

  end if;

   hr_utility.set_location('Leaving:'|| l_proc, 20);

end chk_emp_rights_flag;
--
-- -------------------------------------------------------------------------+
-- |--------------------------< chk_job_group_id >--------------------------|
-- -------------------------------------------------------------------------+
procedure chk_job_group_id
  (p_job_group_id       in per_jobs.job_group_id%TYPE
  ,p_business_group_id  in per_jobs.business_group_id%TYPE
  ) is
  -- Bug 3177195 Changed the where clause for the cursor
  cursor csr_job_group_id is
   select job_group_id
   from per_job_groups
   where job_group_id = p_job_group_id
   and (business_group_id is null
     or business_group_id = p_business_group_id);

   l_job_group_id   per_jobs.job_group_id%TYPE;
   l_proc  varchar2(72) := g_package||'chk_job_group_id';

begin
   hr_utility.set_location('Entering:'|| l_proc, 10);

   open csr_job_group_id;
   fetch csr_job_group_id into l_job_group_id;
   close csr_job_group_id;

   if l_job_group_id is null then
    hr_utility.set_message(801, 'HR_289477_JOB_GROUP_ID');
    hr_utility.raise_error;
   end if;

    hr_utility.set_location('Leaving:'|| l_proc, 20);

end chk_job_group_id;
--
-- -------------------------------------------------------------------------+
-- |-----------------------< chk_approval_authority >-----------------------|
-- -------------------------------------------------------------------------+
procedure chk_approval_authority
  (p_approval_authority in per_jobs.approval_authority%TYPE
  ,p_rec in per_job_shd.g_rec_type) is

  l_proc                varchar2(72) := g_package||'chk_approval_authority';
  l_approval_authority  number       := p_approval_authority;
  l_api_updating  boolean;

begin

   hr_utility.set_location('Entering:'|| l_proc, 10);

   l_api_updating := per_job_shd.api_updating
    (p_job_id                => p_rec.job_id
    ,p_object_version_number => p_rec.object_version_number);

   if (l_api_updating and
       (nvl(per_job_shd.g_old_rec.approval_authority,hr_api.g_number) <>
                           nvl(p_approval_authority,hr_api.g_number)) or
       NOT l_api_updating) then

   if (l_approval_authority < 0) then
      hr_utility.set_message(801, 'HR_289991_APPROVAL_AUTHORITY');
      hr_utility.raise_error;
   end if;

   end if;

   hr_utility.set_location('Leaving:'|| l_proc, 20);

end chk_approval_authority;
--
-- -------------------------------------------------------------------------+
-- |-----------------------< chk_benchmark_job_flag >-----------------------|
-- -------------------------------------------------------------------------+
procedure chk_benchmark_job_flag
  (p_benchmark_job_flag in per_jobs.benchmark_job_flag%TYPE
  ,p_benchmark_job_id in per_jobs.benchmark_job_id%TYPE
  ,p_rec in per_job_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'chk_benchmark_job_flag';
  l_api_updating  boolean;
begin

   hr_utility.set_location('Entering:'|| l_proc, 10);

   l_api_updating := per_job_shd.api_updating
    (p_job_id                => p_rec.job_id
    ,p_object_version_number => p_rec.object_version_number);

  if (l_api_updating and
       (nvl(per_job_shd.g_old_rec.benchmark_job_flag,'N') <>
                           nvl(p_benchmark_job_flag, 'N')) or
       (nvl(per_job_shd.g_old_rec.benchmark_job_id, hr_api.g_number) <>
                           nvl(p_benchmark_job_id, hr_api.g_number)) or
       NOT l_api_updating) then

    if (p_benchmark_job_flag = 'Y' and p_benchmark_job_id is not null) then
       hr_utility.set_message(801, 'HR_289474_BENCHMARK_JOB_FLAG');
       hr_utility.raise_error;
    end if;

  end if;

    hr_utility.set_location('Leaving:'|| l_proc, 20);

end chk_benchmark_job_flag;
--
-- --------------------------------------------------------------------------+
-- |------------------------< chk_benchmark_job_id >-------------------------|
-- --------------------------------------------------------------------------+
procedure chk_benchmark_job_id
  (p_benchmark_job_id    in  per_jobs.benchmark_job_id%TYPE
  ,p_job_id              in  per_jobs.job_id%TYPE
  ,p_business_group_id   in  per_jobs.business_group_id%TYPE
  ,p_rec                 in  per_job_shd.g_rec_type) is

  cursor csr_benchmark_job_id is
  select 1
  from per_jobs
--
-- Bug 3213738
-- Changed where clause to filter based on benchmark_job_id
-- and relaxed check on business group.
--
  where job_id = p_benchmark_job_id
  and p_benchmark_job_id <> nvl(p_job_id,hr_api.g_number)
  and benchmark_job_flag = 'Y';

  l_benchmark_job_id  per_jobs.benchmark_job_id%TYPE;
  l_proc  varchar2(72) := g_package||'chk_benchmark_job_id';
  l_api_updating  boolean;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_api_updating := per_job_shd.api_updating
     (p_job_id                => p_rec.job_id
     ,p_object_version_number => p_rec.object_version_number);

  if  (l_api_updating and
            (nvl(per_job_shd.g_old_rec.benchmark_job_id,hr_api.g_number) <>
             nvl(p_benchmark_job_id,hr_api.g_number)) or NOT l_api_updating) then

   if (p_benchmark_job_id is not null) then

    open csr_benchmark_job_id;
    fetch csr_benchmark_job_id into l_benchmark_job_id;
    close csr_benchmark_job_id;

     if l_benchmark_job_id is null then
      hr_utility.set_message(801, 'HR_289475_BENCHMARK_JOB_ID');
      hr_utility.raise_error;
     end if;

   end if;

  end if;

   hr_utility.set_location('Leaving:'|| l_proc, 20);

end chk_benchmark_job_id ;
--

-- --------------------------------------------------------------------------+
-- |------------------------< check_unique_name >-------------------------|
-- --------------------------------------------------------------------------+
procedure check_unique_name(p_job_id               in number,
             p_business_group_id    in number,
                      p_name                 in varchar2) is
--
cursor csr_name is select null
         from per_jobs j
         where ((p_job_id is not null
          and j.job_id <> p_job_id)
                   or    p_job_id is null)
         and   j.business_group_id + 0 = p_business_group_id
         and   j.name = p_name;
--
g_dummy_number number;
v_not_unique boolean := FALSE;
l_proc  varchar2(72) := g_package||'check_unique_name';
--
-- Check the job name is unique
--
begin
  --
  open csr_name;
  fetch csr_name into g_dummy_number;
  v_not_unique := csr_name%FOUND;
  close csr_name;
  --
  if v_not_unique then
     hr_utility.set_message(801,'PER_7810_DEF_JOB_EXISTS');
     hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
end check_unique_name;
--
-- --------------------------------------------------------------------------+
-- |------------------------< check_date_from >-------------------------|
-- --------------------------------------------------------------------------+
procedure check_date_from(p_job_id       in number,
           p_date_from    in date) is
--
cursor csr_date_from is select null
         from per_valid_grades vg
         where vg.job_id    = p_job_id
         and   p_date_from  > vg.date_from;
--
g_dummy_number number;
v_job_date_greater boolean := FALSE;
l_proc  varchar2(72) := g_package||'check_date_from';
--
begin
hr_utility.set_location('check date',99);
  --
  -- If the date from item in the jobs block is greater than
  -- the date from item in the grades block then raise an error
  --
  open csr_date_from;
  fetch csr_date_from into g_dummy_number;
  v_job_date_greater := csr_date_from%FOUND;
  close csr_date_from;
  --
  if v_job_date_greater then
    hr_utility.set_message(801,'PER_7825_DEF_GRD_JOB_START_JOB');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
end check_date_from;
--
-- --------------------------------------------------------------------------+
-- |------------------------< check_altered_end_date >-----------------------|
-- --------------------------------------------------------------------------+
procedure check_altered_end_date(p_business_group_id      number,
             p_job_id                 number,
             p_end_of_time            date,
                      p_date_to                date,
             p_early_date_to   in out nocopy boolean,
                      p_early_date_from in out nocopy boolean) is
--
cursor csr_date_to is select null
          from   per_valid_grades vg
          where  vg.business_group_id + 0 = p_business_group_id
          and    vg.job_id            = p_job_id
          and    nvl(vg.date_to, p_end_of_time) > p_date_to;
--
cursor csr_date_from is select null
           from per_valid_grades vg
           where  vg.business_group_id + 0 = p_business_group_id
           and     vg.job_id            = p_job_id
           and    vg.date_from > p_date_to;
--
g_dummy_number number;
l_proc  varchar2(72) := g_package||'check_altered_end_date';
--
begin
   --
   open csr_date_to;
   fetch csr_date_to into g_dummy_number;
   p_early_date_to := csr_date_to%FOUND;
   close csr_date_to;
   --
   hr_utility.set_location(l_proc, 10);
   --
   open csr_date_from;
   fetch csr_date_from into g_dummy_number;
   p_early_date_from := csr_date_from%FOUND;
   close csr_date_from;
   --
   hr_utility.set_location(l_proc, 20);
   --
end check_altered_end_date;
--
--  ---------------------------------------------------------------------------
--  |-----------------------<  check_delete_record >--------------------------|
--  ---------------------------------------------------------------------------
procedure check_delete_record(p_job_id            number,
                              p_business_group_id number) is
--
-- Changed 01-Oct-99 SCNair (per_all_positions to hr_all_positions_f) date track
-- requirement
--
cursor csr_position    is select null
                          from   hr_all_positions_f pst1
                          where  pst1.job_id = p_job_id;
--
cursor csr_assignment  is select null
                          from   per_all_assignments_f a
                          where  a.job_id = p_job_id
                          and    a.job_id is not null;
--
cursor csr_grade       is select null
                          from   per_valid_grades vg1
                          where  vg1.business_group_id + 0 = p_business_group_id
                          and    vg1.job_id            = p_job_id;
--
cursor csr_requirement is select null
                          from   per_job_requirements jre1
                          where  jre1.job_id = p_job_id;
--
cursor csr_evaluation  is select null
                          from   per_job_evaluations jev1
                          where  jev1.job_id = p_job_id;
--
cursor csr_elementp    is select null
                          from   per_career_path_elements cpe1
                          where  cpe1.parent_job_id = p_job_id;
--
cursor csr_elements    is select null
                          from per_career_path_elements cpe1
                          where cpe1.subordinate_job_id = p_job_id;
--
cursor csr_budget     is select null
                          from   per_budget_elements bde1
                          where  bde1.job_id = p_job_id
                          and    bde1.job_id is not null;
--
cursor csr_vacancy     is select null
                          from per_vacancies vac
                          where vac.job_id = p_job_id
                          and   vac.job_id is not null;
--
cursor csr_link        is select null
                          from pay_element_links_f eln
                          where eln.job_id = p_job_id
                          and   eln.job_id is not null;
--
cursor csr_role        is select null
                          from per_roles rol
                          where rol.job_id = p_job_id
                          and   rol.job_id is not null;
--
g_dummy_number  number;
v_record_exists boolean := FALSE;
v_dummy boolean := FALSE;
l_sql_text VARCHAR2(2000);
l_status VARCHAR2(1);
l_industry VARCHAR2(1);
l_oci_out VARCHAR2(1);
l_sql_cursor NUMBER;
l_rows_fetched NUMBER;
l_proc  varchar2(72) := g_package||'check_delete_record';
--
begin
  --
  --  Check there are no values in per_valid_grades, per_job_requirements,
  --  per_job_evaluations, per_career_path_elements (check on parent and
  --  subordinate id), hr_all_positions_f, per_budget_elements,
  --  PER_all_assignments, per_vacancies_f, per_element_links_f
  --
  --
  --
  open csr_position;
  fetch csr_position into g_dummy_number;
  v_record_exists := csr_position%FOUND;
  close csr_position;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7813_DEF_JOB_DEL_POS');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
  --
  --
  open csr_assignment;
  fetch csr_assignment into g_dummy_number;
  v_record_exists := csr_assignment%FOUND;
  close csr_assignment;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7817_DEF_JOB_DEL_EMP');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  --
  open csr_grade;
  fetch csr_grade into g_dummy_number;
  v_record_exists := csr_grade%FOUND;
  close csr_grade;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7812_DEF_JOB_DEL_GRADE');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  --
  open csr_requirement;
  fetch csr_requirement into g_dummy_number;
  v_record_exists := csr_requirement%FOUND;
  close csr_requirement;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7814_DEF_JOB_DEL_REQ');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  --
  --
  --
  open csr_evaluation;
  fetch csr_evaluation into g_dummy_number;
  v_record_exists := csr_evaluation%FOUND;
  close csr_evaluation;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7815_DEF_JOB_DEL_EVAL');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  --
  open csr_elementp;
  fetch csr_elementp into g_dummy_number;
  v_record_exists := csr_elementp%FOUND;
  close csr_elementp;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7811_DEF_JOB_DEL_PATH');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 60);
  --
  --
  --
  open csr_elements;
  fetch csr_elements into g_dummy_number;
  v_record_exists := csr_elements%FOUND;
  close csr_elements;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7811_DEF_JOB_DEL_PATH');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 70);
  --
  --
  open csr_budget;
  fetch csr_budget into g_dummy_number;
  v_record_exists := csr_budget%FOUND;
  close csr_budget;
  --
  if v_record_exists then
      hr_utility.set_message(801,'PER_7816_DEF_JOB_DEL_BUD');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  --
  open csr_vacancy;
  fetch csr_vacancy into g_dummy_number;
  v_record_exists := csr_vacancy%FOUND;
  close csr_vacancy;
  --
  if v_record_exists then
      hr_utility.set_message(801,'HR_6945_JOB_DEL_RAC');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 90);
  --
  --
  open csr_link;
  fetch csr_link into g_dummy_number;
  v_record_exists := csr_link%FOUND;
  close csr_link;
  --
  if v_record_exists then
      hr_utility.set_message(801,'HR_6946_JOB_DEL_LINK');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_Proc, 100);
  --
  --
  open csr_role;
  fetch csr_role into g_dummy_number;
  v_record_exists := csr_role%FOUND;
  close csr_role;
  --
  if v_record_exists then
        hr_utility.set_message(800,'PER_52684_JOB_DEL_ROLE');
        hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 110);
  --
  -- is po installed?
  --
  if (fnd_installation.get(appl_id => 201
                          ,dep_appl_id => 201
                          ,status => l_status
                          ,industry => l_industry))
  then
    --
    -- If fully installed (l_status = 'I')
    --
    if l_status = 'I'
    then
  -- Dynamic SQL cursor to get round the problem of Table not existing.
  -- Shouldn't be a problem after 10.6, but better safe than sorry.
  -- This uses a similar method to OCI but Via PL/SQL instead.
  --
  -- #358988 removed the table alias 'pcc' which didn't match the column
  -- alias ppc. RMF 17-Apr-96.
  --
    begin
     l_sql_text := 'select null '
     ||'from sys.dual '
     ||'where exists( select null '
     ||'    from   po_position_controls_all '
     ||'    where  job_id = '
     ||to_char(p_job_id)
     ||' ) ';
      --
      -- Open Cursor for Processing Sql statment.
      --
      l_sql_cursor := dbms_sql.open_cursor;
      --
      --
      -- Parse SQL statement.
      --
      dbms_sql.parse(l_sql_cursor, l_sql_text, dbms_sql.v7);
      --
      -- Map the local variables to each returned Column
      --
      dbms_sql.define_column(l_sql_cursor, 1,l_oci_out,1);
      --
      -- Execute the SQL statement.
      --
      l_rows_fetched := dbms_sql.execute(l_sql_cursor);
      --
      if (dbms_sql.fetch_rows(l_sql_cursor) > 0)
      then
         fnd_message.set_name('PAY','HR_6048_PO_POS_DEL_POS_CONT');
         fnd_message.raise_error;
      end if;
      --
      -- Close cursor used for processing SQL statement.
      --
      dbms_sql.close_cursor(l_sql_cursor);
     end;
   end if;
  end if;
  --
  hr_utility.set_location(l_proc, 120);
  --
  per_ota_predel_validation.ota_predel_job_validation(p_job_id);
  --
  hr_utility.set_location(l_proc, 130);
  --
  pa_job.pa_predel_validation(p_job_id);
  --
end check_delete_record;
--
--  ---------------------------------------------------------------------------
--  |-----------------------< check_evaluation_dates >-----------------------|
--  ---------------------------------------------------------------------------
procedure check_evaluation_dates(p_jobid in number,
                                 p_job_date_from in date,
                                 p_job_date_to in date) is


cursor csr_job_evaluations(p_job_id in number) is
       select jbe.job_evaluation_id,
              jbe.date_evaluated
       from per_job_evaluations jbe
       where jbe.job_id = csr_job_evaluations.p_job_id;

--
begin
--

   if p_jobid is not null then
     for l_job_evaluation in csr_job_evaluations(
        p_job_id => p_jobid) loop
        if l_job_evaluation.date_evaluated not between
          nvl(p_job_date_from, hr_api.g_sot) and
          nvl(p_job_date_to, hr_api.g_eot) then
          fnd_message.set_name('PER', 'HR_52603_JOB_JBE_OUT_PERIOD');
          hr_utility.raise_error;
        end if;
     end loop;
   end if;

--
exception
--

when others then
  if csr_job_evaluations%isopen then
    close csr_job_evaluations;
  end if;
  raise;

--
end check_evaluation_dates;
--
end per_job_bus;

/
