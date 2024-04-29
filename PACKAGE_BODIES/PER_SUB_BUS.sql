--------------------------------------------------------
--  DDL for Package Body PER_SUB_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SUB_BUS" as
/* $Header: pesubrhi.pkb 115.14 2004/02/23 01:47:08 smparame ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_sub_bus.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_subjects_taken_id >----------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that a subjects_taken_id is unique. This column
--   is the primary key for the entity and so must be null on insert and
--   non-updateable on update.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_subjects_taken_id        PK
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_subjects_taken_id (p_subjects_taken_id     in number,
				 p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_subjects_taken_id';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_sub_shd.api_updating
    (p_subjects_taken_id        => p_subjects_taken_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_subjects_taken_id,hr_api.g_number)
      <> per_sub_shd.g_old_rec.subjects_taken_id) then
    --
    -- raise error as PK has changed
    --
    per_sub_shd.constraint_error('PER_SUBJECTS_TAKEN_PK');
    --
  elsif not l_api_updating then
    --
    -- check if PK is null
    --
    if p_subjects_taken_id is not null then
      --
      -- raise error as PK is not null
      --
      per_sub_shd.constraint_error('PER_SUBJECTS_TAKEN_PK');
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_subjects_taken_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_qualification_id >-----------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that the qualification_id is not null. This is
--   a foreign key to the PER_QUALIFICATIONS table and so must be populated
--   on insert and on update.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_subjects_taken_id        PK
--   p_qualification_id         ID of referenced qualification record.
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_qualification_id (p_subjects_taken_id     in number,
				p_qualification_id      in number,
				p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_qualification_id';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  cursor c1 is
    select null
    from   per_qualifications per
    where  per.qualification_id = p_qualification_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_sub_shd.api_updating
    (p_subjects_taken_id        => p_subjects_taken_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_qualification_id,hr_api.g_number)
      <> per_sub_shd.g_old_rec.qualification_id
      or not l_api_updating) then
    --
    -- check if qualification id exists in per_qualifications table.
    -- it must also be a not null value.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      if c1%notfound then
	--
	close c1;
        per_sub_shd.constraint_error('PER_SUBJECTS_TAKEN_FK1');
        --
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,10);
  --
End chk_qualification_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_start_date >-----------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that the start date for the subject is valid. This
--   includes checking that the start date of the subject is before the end
--   date of the subject. This procedure also ensures that the start
--   dates of the subject are within the start and end dates of the
--   qualification.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_subjects_taken_id        PK
--   p_qualification_id         ID of referenced qualification record.
--   p_start_date               start date of subject
--   p_end_date                 end date of subject
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_start_date (p_subjects_taken_id     in number,
                          p_qualification_id      in number,
			  p_start_date            in date,
			  p_end_date              in date,
			  p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_start_date';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_start_date         date; --  part of bug fix 1854046
  l_end_date           date;

  --
  -- If a qualification has not got a start date then subjects can not be
  -- assigned to that qualification as subjects must have a start date.
  --
  --
  -- Bug Fix 3267372.
  -- Validation of qualification end date against subject
  -- start date and end date is relaxed.
  cursor c1 is
    select  null
    from    per_qualifications per
    where   per.qualification_id = p_qualification_id
    and     p_start_date between nvl(per.start_date,hr_api.g_sot)
        	and     nvl(per.end_date,p_start_date)
    and     (p_start_date <= nvl(per.end_date,hr_api.g_eot));

  --
Begin
  --
  select start_date,end_date
  into l_start_date,l_end_date
  from per_qualifications per
  where per.qualification_id = p_qualification_id;
--
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_sub_shd.api_updating
    (p_subjects_taken_id        => p_subjects_taken_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
/*
WWBUG 2502284 backport drove this.
      and (nvl(p_start_date,hr_api.g_date)
           <> per_sub_shd.g_old_rec.start_date
           or nvl(p_end_date,hr_api.g_date)
	   <> per_sub_shd.g_old_rec.end_date)
*/
      or not l_api_updating) then
    --
    -- check if start_date and end date fall within the dates of the
    -- qualification that they are linked to.
    --
    open c1;
      --
      fetch c1 into l_dummy;
  if l_start_date is not null then
      if c1%notfound then
	--
	close c1;
        hr_utility.set_message(801,'HR_51817_SUB_START_DATE_QUAL');
	hr_utility.raise_error;
	--
      end if;
end if;
      --
    close c1;
    --
    -- Check if end date is greater than start date
    --
    if p_end_date < p_start_date then
      --
      per_sub_shd.constraint_error('PER_SUB_START_DATES');
      --
    end if;
    --
     if p_start_date > nvl(l_end_date,p_start_date) then
 --
        hr_utility.set_message(801,'HR_51817_SUB_START_DATE_QUAL');
	hr_utility.raise_error;
 --
     end if;
--
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
End chk_start_date;
--
--

--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_end_date >-----------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that the end date for the subject is valid. This
--   includes checking that the end date of the subject is after the start
--   date of the subject. This procedure also ensures that the end
--   dates of the subject are within the start and end dates of the
--   qualification.
--
--This check procedure has been included to reslove the bug 1854046
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_subjects_taken_id        PK
--   p_qualification_id         ID of referenced qualification record.
--   p_start_date               start date of subject
--   p_end_date                 end date of subject
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_end_date (p_subjects_taken_id     in number,
                          p_qualification_id      in number,
			  p_start_date            in date,
			  p_end_date              in date,
			  p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_end_date';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  l_end_date         date; -- part of bug fix 1854046

  --
  -- If a qualification has got an end date then subjects can not be
  -- assigned to that qualification unless their dates lie within the
  -- qualification end/start dates.
  --
  -- Bug Fix 3267372.
  -- Validation of qualification end date against subject
  -- start date and end date is relaxed.

  cursor c1 is
    select  null
    from    per_qualifications per
    where   per.qualification_id = p_qualification_id
    and     nvl(p_end_date,nvl(per.end_date,hr_api.g_eot))
    between nvl(per.start_date,hr_api.g_sot)
    and     nvl(per.end_date,hr_api.g_eot);

  --
Begin
  --
  select end_date
  into l_end_date
  from per_qualifications per
  where per.qualification_id = p_qualification_id;
--
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_sub_shd.api_updating
    (p_subjects_taken_id        => p_subjects_taken_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      or not l_api_updating) then
    --
    -- check if end date fall within the dates of the
    -- qualification that they are linked to.
    -- It only checks the two if they are entered.
    open c1;
      --
      fetch c1 into l_dummy;
   if l_end_date is not null and p_end_date is not null then
     if c1%notfound then
	--
	close c1;
        hr_utility.set_message(801,'HR_289802_SUB_END_QUAL');
	hr_utility.raise_error;
	--
      end if;
  end if;
      --
    close c1;

    --
  end if;
  --
End chk_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_major >----------------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that the major value exists in the lookup YES_NO.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_subjects_taken_id        PK
--   p_major                    value of major column
--   p_effective_date           effective date of session
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_major (p_subjects_taken_id     in number,
		     p_major                 in varchar2,
		     p_effective_date        in date,
		     p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_major';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_sub_shd.api_updating
    (p_subjects_taken_id        => p_subjects_taken_id,
     p_object_version_number    => p_object_version_number);
  --
  if p_major is not null then --p_major is optional field.
    if (l_api_updating
      and nvl(p_major,hr_api.g_varchar2)
      <> per_sub_shd.g_old_rec.major
      or not l_api_updating) then
      --
      -- check if major exists in the lookup YES_NO.
      --
      if hr_api.not_exists_in_hr_lookups
	(p_effective_date => p_effective_date,
	 p_lookup_type    => 'YES_NO',
	 p_lookup_code    => p_major) then
        --
        hr_utility.set_message(801,'HR_51818_SUB_MAJOR_LKP_INV');
        hr_utility.raise_error;
        --
      end if;
      --
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
End chk_major;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_subject_status >-------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that the subject_status value exists in the lookup
--   PER_SUBJECT_STATUSES.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_subjects_taken_id        PK
--   p_subject_status           value of subject_status column
--   p_effective_date           effective date of session
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_subject_status (p_subjects_taken_id     in number,
		              p_subject_status        in varchar2,
		              p_effective_date        in date,
		              p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_subject_status';
  l_api_updating boolean;
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_sub_shd.api_updating
    (p_subjects_taken_id        => p_subjects_taken_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and nvl(p_subject_status,hr_api.g_varchar2)
      <> per_sub_shd.g_old_rec.subject_status
      or not l_api_updating) then
    --
    -- check if subject_status exists in the lookup PER_SUBJECT_STATUSES.
    --
    if hr_api.not_exists_in_hr_lookups
	(p_effective_date => p_effective_date,
	 p_lookup_type    => 'PER_SUBJECT_STATUSES',
	 p_lookup_code    => p_subject_status) then
      --
      hr_utility.set_message(801,'HR_51819_SUB_STATUS_LKP_INV');
      hr_utility.raise_error;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
End chk_subject_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_subject >--------------------------------|
-- ----------------------------------------------------------------------------
-- Description
--   This procedure checks that the subject value exists in the lookup
--   PER_SUBJECTS.
--
-- Pre-Conditions
--   None.
--
-- In Parameters
--   p_subjects_taken_id        PK
--   p_subject                  value of subject column
--   p_effective_date           effective date of session
--   p_object_version_number    object version number
--
-- Post Success
--   Processing continues
--
-- Post Failure
--   Error raised.
--
-- Access Status
--   Internal table handler use only.
--
Procedure chk_subject (p_subjects_taken_id     in number,
		       p_subject               in varchar2,
		       p_qualification_id      in number,
		       p_start_date            in date,
		       p_end_date              in date,
		       p_effective_date        in date,
		       p_object_version_number in number) is
  --
  l_proc         varchar2(72) := g_package||'chk_subject';
  l_api_updating boolean;
  l_dummy        varchar2(1);
  --
  -- This cursor checks that this subject has not been used for this
  -- qualification before. It checks for the boundaries of the existing
  -- identical subjects and whether these have been breached. As it is
  -- possible to take the same subject again in order to improve one's grade
  -- this option must be catered for.
  --
  cursor c1 is
    select  null
    from    per_subjects_taken per
    where   per.qualification_id = p_qualification_id
    and     per.subject = p_subject
    and     (p_start_date
    between per.start_date
    and     nvl(per.end_date,hr_api.g_eot)
    or      p_end_date
    between per.start_date
    and     nvl(per.end_date,hr_api.g_eot))
    and     per.subjects_taken_id <> nvl(p_subjects_taken_id,-1);
  --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,5);
  --
  l_api_updating := per_sub_shd.api_updating
    (p_subjects_taken_id        => p_subjects_taken_id,
     p_object_version_number    => p_object_version_number);
  --
  if (l_api_updating
      and (nvl(p_subject,hr_api.g_varchar2)
           <> per_sub_shd.g_old_rec.subject
	   or nvl(p_start_date,hr_api.g_date)
	   <> per_sub_shd.g_old_rec.start_date
	   or nvl(p_end_date,hr_api.g_date)
	   <> per_sub_shd.g_old_rec.end_date
	   or nvl(p_qualification_id,hr_api.g_number)
	   <> per_sub_shd.g_old_rec.qualification_id)
      or not l_api_updating) then
    --
    -- check if subject exists in the lookup PER_SUBJECTS.
    --
    if hr_api.not_exists_in_hr_lookups
	(p_effective_date => p_effective_date,
	 p_lookup_type    => 'PER_SUBJECTS',
	 p_lookup_code    => p_subject) then
      --
      hr_utility.set_message(801,'HR_51820_SUB_SUBJECT_LKP_INV');
      hr_utility.raise_error;
      --
    end if;
    --
    -- Check if subject conflicts with a previous subject for the same
    -- qualification that has an end date that is not before the start
    -- date of the current subject.
    --
    open c1;
      --
      fetch c1 into l_dummy;
      --
      if c1%found then
	--
	-- raise error as subject trying to be added twice
	--
	close c1;
	hr_utility.set_message(801,'HR_51821_SUB_SUB_DATE_OVLAP');
	hr_utility.raise_error;
	--
      end if;
      --
    close c1;
    --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc,5);
  --
End chk_subject;
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
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
procedure chk_df
  (p_rec in per_sub_shd.g_rec_type) is
--
  l_proc    varchar2(72) := g_package||'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  if ((p_rec.subjects_taken_id is not null) and (
     nvl(per_sub_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
     nvl(p_rec.attribute_category, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
     nvl(p_rec.attribute1, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
     nvl(p_rec.attribute2, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
     nvl(p_rec.attribute3, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
     nvl(p_rec.attribute4, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
     nvl(p_rec.attribute5, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
     nvl(p_rec.attribute6, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
     nvl(p_rec.attribute7, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
     nvl(p_rec.attribute8, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
     nvl(p_rec.attribute9, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
     nvl(p_rec.attribute10, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
     nvl(p_rec.attribute11, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
     nvl(p_rec.attribute12, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
     nvl(p_rec.attribute13, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
     nvl(p_rec.attribute14, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
     nvl(p_rec.attribute15, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
     nvl(p_rec.attribute16, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
     nvl(p_rec.attribute17, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
     nvl(p_rec.attribute18, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
     nvl(p_rec.attribute19, hr_api.g_varchar2) or
     nvl(per_sub_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
     nvl(p_rec.attribute20, hr_api.g_varchar2)))
     or
     (p_rec.subjects_taken_id is null) then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_SUBJECTS_TAKEN'
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
      ,p_attribute20_value  => p_rec.attribute20);
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
end chk_df;
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
  (p_rec in per_sub_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.subjects_taken_id is not null)  and (
    nvl(per_sub_shd.g_old_rec.sub_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information_category, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information1, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information1, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information2, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information2, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information3, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information3, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information4, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information4, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information5, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information5, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information6, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information6, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information7, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information7, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information8, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information8, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information9, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information9, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information10, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information10, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information11, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information11, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information12, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information12, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information13, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information13, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information14, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information14, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information15, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information15, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information16, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information16, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information17, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information17, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information18, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information18, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information19, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information19, hr_api.g_varchar2)  or
    nvl(per_sub_shd.g_old_rec.sub_information20, hr_api.g_varchar2) <>
    nvl(p_rec.sub_information20, hr_api.g_varchar2) ))
    or (p_rec.subjects_taken_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Subject Developer DF'
      ,p_attribute_category              => p_rec.sub_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'SUB_INFORMATION1'
      ,p_attribute1_value                => p_rec.sub_information1
      ,p_attribute2_name                 => 'SUB_INFORMATION2'
      ,p_attribute2_value                => p_rec.sub_information2
      ,p_attribute3_name                 => 'SUB_INFORMATION3'
      ,p_attribute3_value                => p_rec.sub_information3
      ,p_attribute4_name                 => 'SUB_INFORMATION4'
      ,p_attribute4_value                => p_rec.sub_information4
      ,p_attribute5_name                 => 'SUB_INFORMATION5'
      ,p_attribute5_value                => p_rec.sub_information5
      ,p_attribute6_name                 => 'SUB_INFORMATION6'
      ,p_attribute6_value                => p_rec.sub_information6
      ,p_attribute7_name                 => 'SUB_INFORMATION7'
      ,p_attribute7_value                => p_rec.sub_information7
      ,p_attribute8_name                 => 'SUB_INFORMATION8'
      ,p_attribute8_value                => p_rec.sub_information8
      ,p_attribute9_name                 => 'SUB_INFORMATION9'
      ,p_attribute9_value                => p_rec.sub_information9
      ,p_attribute10_name                => 'SUB_INFORMATION10'
      ,p_attribute10_value               => p_rec.sub_information10
      ,p_attribute11_name                => 'SUB_INFORMATION11'
      ,p_attribute11_value               => p_rec.sub_information11
      ,p_attribute12_name                => 'SUB_INFORMATION12'
      ,p_attribute12_value               => p_rec.sub_information12
      ,p_attribute13_name                => 'SUB_INFORMATION13'
      ,p_attribute13_value               => p_rec.sub_information13
      ,p_attribute14_name                => 'SUB_INFORMATION14'
      ,p_attribute14_value               => p_rec.sub_information14
      ,p_attribute15_name                => 'SUB_INFORMATION15'
      ,p_attribute15_value               => p_rec.sub_information15
      ,p_attribute16_name                => 'SUB_INFORMATION16'
      ,p_attribute16_value               => p_rec.sub_information16
      ,p_attribute17_name                => 'SUB_INFORMATION17'
      ,p_attribute17_value               => p_rec.sub_information17
      ,p_attribute18_name                => 'SUB_INFORMATION18'
      ,p_attribute18_value               => p_rec.sub_information18
      ,p_attribute19_name                => 'SUB_INFORMATION19'
      ,p_attribute19_value               => p_rec.sub_information19
      ,p_attribute20_name                => 'SUB_INFORMATION20'
      ,p_attribute20_value               => p_rec.sub_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate(p_rec            in per_sub_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_qua_bus.set_security_group_id
    (
     p_qualification_id => p_rec.qualification_id);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_SUBJECTS_TAKEN_ID
  chk_subjects_taken_id
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_QUALIFICATION_ID
  chk_qualification_id
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_qualification_id      => p_rec.qualification_id,
       p_object_version_number => p_rec.object_version_number);

 -- Bug Fix 3267372.
 -- Validation of subject start date and  end date against
 -- qyualification start date and end date is relaxed.
---
/*
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_START_DATE
     chk_start_date
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_qualification_id      => p_rec.qualification_id,
       p_start_date            => p_rec.start_date,
       p_end_date              => p_rec.end_date,
       p_object_version_number => p_rec.object_version_number);

  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_END_DATE
  chk_end_date
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_qualification_id      => p_rec.qualification_id,
       p_start_date            => p_rec.start_date,
       p_end_date              => p_rec.end_date,
       p_object_version_number => p_rec.object_version_number);

   */
 ---
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_MAJOR
  chk_major
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_major                 => p_rec.major,
       p_effective_date        => p_effective_date,
       p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_SUBJECT_STATUS
  chk_subject_status
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_subject_status        => p_rec.subject_status,
       p_effective_date        => p_effective_date,
       p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_SUBJECT
  chk_subject
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_subject               => p_rec.subject,
       p_start_date            => p_rec.start_date,
       p_end_date              => p_rec.end_date,
       p_qualification_id      => p_rec.qualification_id,
       p_effective_date        => p_effective_date,
       p_object_version_number => p_rec.object_version_number);
  --
/*
  -- Descriptive Flex Check
  -- ----------------------
  IF hr_general.get_calling_context <>FORMS' THEN
    per_sub_flex.df(p_rec => p_rec);
  END IF;
*/

  --
  -- call descriptive flexfield validation routines
  --
  per_sub_bus.chk_df(p_rec => p_rec);
  --
  per_sub_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate(p_rec            in per_sub_shd.g_rec_type,
			  p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  per_qua_bus.set_security_group_id
    (
     p_qualification_id => p_rec.qualification_id);
  --
  hr_utility.set_location('Entering:'||l_proc, 7);
  --
  -- Call all supporting business operations
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_SUBJECTS_TAKEN_ID
  chk_subjects_taken_id
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_QUALIFICATION_ID
  chk_qualification_id
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_qualification_id      => p_rec.qualification_id,
       p_object_version_number => p_rec.object_version_number);

  -- Bug Fix 3267372.
  -- Validation of  subject start date and end date against
  -- qualification start date and end date is relaxed is relaxed.
  /*

  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_START_DATE
    chk_start_date
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_qualification_id      => p_rec.qualification_id,
       p_start_date            => p_rec.start_date,
       p_end_date              => p_rec.end_date,
       p_object_version_number => p_rec.object_version_number);
  --
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_END_DATE
  chk_end_date
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_qualification_id      => p_rec.qualification_id,
       p_start_date            => p_rec.start_date,
       p_end_date              => p_rec.end_date,
       p_object_version_number => p_rec.object_version_number);*/
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_MAJOR
  chk_major
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_major                 => p_rec.major,
       p_effective_date        => p_effective_date,
       p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_SUBJECT_STATUS
  chk_subject_status
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_subject_status        => p_rec.subject_status,
       p_effective_date        => p_effective_date,
       p_object_version_number => p_rec.object_version_number);
  --
  -- Business Rule Mapping
  -- ---------------------
  -- CHK_SUBJECT
  chk_subject
      (p_subjects_taken_id     => p_rec.subjects_taken_id,
       p_subject               => p_rec.subject,
       p_start_date            => p_rec.start_date,
       p_end_date              => p_rec.end_date,
       p_qualification_id      => p_rec.qualification_id,
       p_effective_date        => p_effective_date,
       p_object_version_number => p_rec.object_version_number);
  --
/*
  -- Descriptive Flex Check
  -- ----------------------
  IF hr_general.get_calling_context <>FORMS' THEN
    per_sub_flex.df(p_rec => p_rec);
  END IF;
*/
  --
  --
  -- call descriptive flexfield validation routines
  --
  per_sub_bus.chk_df(p_rec => p_rec);
  --
  per_sub_bus.chk_ddf(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate(p_rec in per_sub_shd.g_rec_type) is
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
end per_sub_bus;

/
