--------------------------------------------------------
--  DDL for Package Body PER_ROL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ROL_BUS" as
/* $Header: perolrhi.pkb 120.0 2005/05/31 18:34:51 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_rol_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_role_id                     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_role_id                              in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select null
     from hr_organization_information hoi
         , per_roles rol
         , per_people_f per
     where rol.role_id = p_role_id
     and per.person_id = rol.person_id
     and hoi.organization_id = per.business_group_id
     and hoi.org_information_context||'' = 'Business Group Information';
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
    ,p_argument           => 'role_id'
    ,p_argument_value     => p_role_id
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
  (p_role_id                              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , per_roles rol
         , per_people_f per
     where rol.role_id = p_role_id
     and rol.person_id = per.person_id
     and per.business_group_id = pbg.business_group_id;
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
    ,p_argument           => 'role_id'
    ,p_argument_value     => p_role_id
    );
  --
  if ( nvl(per_rol_bus.g_role_id, hr_api.g_number)
       = p_role_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_rol_bus.g_legislation_code;
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
    per_rol_bus.g_role_id           := p_role_id;
    per_rol_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_person_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert PERSON_ID is not null and that
--    it exists in per_all_people_f on the effective_date.
--
--
--  Pre-conditions : None
--
--  In Arguments :
--    p_role_id
--    p_person_id
--    p_effective_date
--
--  Post Success :
--    Processing continues if person_id is not null and exists in
--    per_all_people_f on the effective_date.
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated.
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_person_id
  (p_role_id             in    per_roles.person_id%TYPE
  ,p_person_id           in    per_roles.person_id%TYPE
   ,p_effective_date      in    date
    ) is
--
 l_proc  varchar2(72) := g_package||'chk_person_id';
 l_dummy number;
--
 cursor csr_person_id is
 select null
 from per_people_f per
 where per.person_id = p_person_id
 and p_effective_date between per.effective_start_date
 and per.effective_end_date;
--
begin
hr_utility.set_location('Entering:'||l_proc, 1);
--
--      Check mandatory person_id is set
--
 if p_person_id is null then
   hr_utility.set_message(800, 'HR_52891_INC_PERSON_ID_NULL');
   hr_utility.raise_error;
 end if;
--
 hr_utility.set_location(l_proc, 5);
--  --
 if (p_role_id is null) then
   hr_utility.set_location(l_proc, 10);
   --
-- Check that the person_id is in the per_people_f view on the effective_date
--
   open csr_person_id;
   fetch csr_person_id into l_dummy;
   if csr_person_id%notfound then
     close csr_person_id;
     hr_utility.set_message(800, 'HR_52896_INC_FK_NOT_FOUND');
     hr_utility.raise_error;
   end if;
   close csr_person_id;
 end if;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
--
end chk_person_id;

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_dates >--------------------------------|
-- ----------------------------------------------------------------------------
procedure chk_dates
  (p_start_date    in  date
  ,p_end_date      in  date
  ) is
--
l_proc varchar2(72) := g_package||'chk_dates';
--
begin
 --
 hr_utility.set_location('Entering: '||l_proc,5);
 --
   if p_end_date is NOT NULL then
     if p_start_date > p_end_date then
     hr_utility.set_message(800,'PER_52675_END_START_DATE');
     hr_utility.raise_error;
     end if;
   end if;
 --
 hr_utility.set_location('Leaving: '||l_proc,10);
--
end chk_dates;

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_emp_rights>----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--     Validates that the end_of_rights_date is null when emp_rights_flag is
--     set to 'N' and that the end_of_rights_date is the same or later than
--     the end date.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_emp_rights_flag
--    p_end_of_rights_date
--    p_end_date
--    p_role_id
--
-- Post Success:
--    Processing continues if end_of_rights_date is null or end_of_rights_date
--    is not null and emp_rights_flag = 'Y'. Also continues if end_date is
--    the same or earlier than the end of rights date.
--
-- Post Failure:
--    An application error is raised and processing is terminated if
--    end_of_rights_date is not null and emp_rights_flag = 'N'.
--    Also terminates if end_of_rights_date is earlier than the end date.
--
-- Access Status:
--    Internal Development use only.
--
-- -------------------------------------------------------------------
procedure chk_emp_rights(p_emp_rights_flag varchar2
             ,p_end_of_rights_date date
             ,p_end_date date) is
--
l_proc varchar2(72) := g_package||'chk_emp_rights';
--
begin
 --
 hr_utility.set_location('Entering: '||l_proc,5);
 --
   if p_end_of_rights_date is NOT NULL then
     if p_emp_rights_flag = 'N' then
     hr_utility.set_message(800,'PER_52676_EMP_RIGHTS_NO');
     hr_utility.raise_error;
     elsif p_end_date is NOT NULL then
     if p_end_of_rights_date < p_end_date then
       hr_utility.set_message(800,'PER_52677_EMP_RIGHTS_DATE');
       hr_utility.raise_error;
       end if;
     end if;
   end if;
 --
 hr_utility.set_location('Leaving: '||l_proc,10);
--
end chk_emp_rights;

-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_job_group>-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--     Validates that the job group exists in the person's business group.
--     Also validates that the role exists in the job group and that the job
--     group is not the default HR job group.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_job_id
--    p_job_group_id
--    p_person_id
--
-- Post Success:
--    Processing continues if the role entered exists in the job group
--    and the job group is not the default HR job group. Also, that the
--    job group has the same business group as the person.
--
-- Post Failure:
--    An application error is raised and processing is terminated if
--    the role does not exist in the job group or the job group is the
--    default HR job group or the job group's business group is not the
--    same as the person's.
--
-- Access Status:
--    Internal Development use only.
--
-- -------------------------------------------------------------------
procedure chk_job_group(p_job_id number
                 ,p_job_group_id number
               ,p_person_id number
               ) is
--
l_proc varchar2(72) := g_package||'chk_job_group';
l_job_group varchar2(30);
l_job_in_jgr varchar2(30);
l_person_bgid number;
l_jgr_bgid number;
--
cursor csr_bg is
select p.business_group_id
,j.business_group_id
from per_all_people_f p
,per_job_groups j
where p.person_id = p_person_id
and j.job_group_id = p_job_group_id;
--
cursor csr_valid_job_group is
select 'X'
from per_job_groups
where job_group_id = p_job_group_id
and internal_name <> 'HR_'||business_group_id;
--
cursor csr_job_in_jgr is
select 'X'
from per_jobs
where job_group_id = p_job_group_id
and job_id = p_job_id;
--
begin
 --
 hr_utility.set_location('Entering: '||l_proc,5);
 --
  if fnd_profile.value('HR_CROSS_BUSINESS_GROUP') = 'N' then
   open csr_bg;
   fetch csr_bg into l_person_bgid, l_jgr_bgid;
   if l_jgr_bgid <> l_person_bgid then
   hr_utility.set_message(800,'PER_52678_INV_BG');
   hr_utility.raise_error;
   end if;
   close csr_bg;
  end if;
   --
   open csr_valid_job_group;
   fetch csr_valid_job_group into l_job_group;
   if csr_valid_job_group%notfound then
   hr_utility.set_message(800,'PER_52679_INV_JOB_GROUP');
   hr_utility.raise_error;
   else
     open csr_job_in_jgr;
     fetch csr_job_in_jgr into l_job_in_jgr;
       if csr_job_in_jgr%notfound then
       hr_utility.set_message(800,'PER_52680_ROLE_NOT_JGR');
       hr_utility.raise_error;
       end if;
     close csr_job_in_jgr;
   end if;
   close csr_valid_job_group;
 --
 hr_utility.set_location('Leaving: '||l_proc,10);
--
end chk_job_group;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_rep_body>------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--     Validates that the representative body is linked to the job group.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_organization_id
--    p_job_group_id
--
-- Post Success:
--    Processing continues if the rep body is linked to the job group.
--
-- Post Failure:
--    An application error is raised and processing is terminated if
--    the rep body is not linked to the job group.
--
-- Access Status:
--    Internal Development use only.
--
-- -------------------------------------------------------------------
procedure chk_rep_body(p_organization_id number
                 ,p_job_group_id number) is
--
l_proc varchar2(72) := g_package||'chk_rep_body';
l_rep_jgr varchar2(30);
--
cursor csr_rep_jgr is
select 'X'
from hr_organization_information hoi
where org_information1 = to_char(p_job_group_id)
and organization_id = p_organization_id;
--
begin
 --
 hr_utility.set_location('Entering: '||l_proc,5);
 --
   if p_organization_id is NOT NULL then
     open csr_rep_jgr;
     fetch csr_rep_jgr into l_rep_jgr;
     if csr_rep_jgr%notfound then
     hr_utility.set_message(800,'PER_52681_INV_REP_BODY');
     hr_utility.raise_error;
     end if;
     close csr_rep_jgr;
   end if;
  --
  hr_utility.set_location('Entering: '||l_proc,10);
--
end chk_rep_body;
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_flags >--------------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--     Validates that the primary_contact_flag and the emp_rights_flag
--     only have values of 'Y','N' or null.
--
-- Pre-Requisites:
--    None.
--
-- In Parameters:
--    p_primary_contact_flag
--    p_emp_rights_flag
--
-- Post Success:
--    Processing continues if primary contact flag and emp_rights_flag
--    have values of 'Y', 'N' or null.
--
-- Post Failure:
--    An application error is raised and processing is terminated.
--
-- Access Status:
--    Internal Development use only.
--
-- -------------------------------------------------------------------
procedure chk_flags(p_primary_contact_flag varchar2
             ,p_emp_rights_flag      varchar2) is
--
l_proc varchar2(72) := g_package||'chk_flags';
--
begin
 --
 hr_utility.set_location('Entering: '||l_proc,5);
 --
   if p_primary_contact_flag is NOT NULL then
     if p_primary_contact_flag not in ('Y','N') then
     hr_utility.set_message(800,'PER_52682_PRIM_CON_FLAG');
     hr_utility.raise_error;
     end if;
   end if;
   if p_emp_rights_flag is NOT NULL then
   if p_emp_rights_flag not in('Y','N') then
     hr_utility.set_message(800,'PER_52683_EMP_RIGHTS_FLAG');
     hr_utility.raise_error;
     end if;
   end if;
  --
  hr_utility.set_location('Entering: '||l_proc,10);
--
end chk_flags;
-- ----------------------------------------------------------------------------
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
  (p_rec in per_rol_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.role_id is not null)  and (
    nvl(per_rol_shd.g_old_rec.role_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.role_information_category, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information1, hr_api.g_varchar2) <>
    nvl(p_rec.role_information1, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information2, hr_api.g_varchar2) <>
    nvl(p_rec.role_information2, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information3, hr_api.g_varchar2) <>
    nvl(p_rec.role_information3, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information4, hr_api.g_varchar2) <>
    nvl(p_rec.role_information4, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information5, hr_api.g_varchar2) <>
    nvl(p_rec.role_information5, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information6, hr_api.g_varchar2) <>
    nvl(p_rec.role_information6, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information7, hr_api.g_varchar2) <>
    nvl(p_rec.role_information7, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information8, hr_api.g_varchar2) <>
    nvl(p_rec.role_information8, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information9, hr_api.g_varchar2) <>
    nvl(p_rec.role_information9, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information10, hr_api.g_varchar2) <>
    nvl(p_rec.role_information10, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information11, hr_api.g_varchar2) <>
    nvl(p_rec.role_information11, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information12, hr_api.g_varchar2) <>
    nvl(p_rec.role_information12, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information13, hr_api.g_varchar2) <>
    nvl(p_rec.role_information13, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information14, hr_api.g_varchar2) <>
    nvl(p_rec.role_information14, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information15, hr_api.g_varchar2) <>
    nvl(p_rec.role_information15, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information16, hr_api.g_varchar2) <>
    nvl(p_rec.role_information16, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information17, hr_api.g_varchar2) <>
    nvl(p_rec.role_information17, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information18, hr_api.g_varchar2) <>
    nvl(p_rec.role_information18, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information19, hr_api.g_varchar2) <>
    nvl(p_rec.role_information19, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.role_information20, hr_api.g_varchar2) <>
    nvl(p_rec.role_information20, hr_api.g_varchar2) ))
    or (p_rec.role_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Roles Developer DF'
      ,p_attribute_category              => p_rec.ROLE_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'ROLE_INFORMATION1'
      ,p_attribute1_value                => p_rec.role_information1
      ,p_attribute2_name                 => 'ROLE_INFORMATION2'
      ,p_attribute2_value                => p_rec.role_information2
      ,p_attribute3_name                 => 'ROLE_INFORMATION3'
      ,p_attribute3_value                => p_rec.role_information3
      ,p_attribute4_name                 => 'ROLE_INFORMATION4'
      ,p_attribute4_value                => p_rec.role_information4
      ,p_attribute5_name                 => 'ROLE_INFORMATION5'
      ,p_attribute5_value                => p_rec.role_information5
      ,p_attribute6_name                 => 'ROLE_INFORMATION6'
      ,p_attribute6_value                => p_rec.role_information6
      ,p_attribute7_name                 => 'ROLE_INFORMATION7'
      ,p_attribute7_value                => p_rec.role_information7
      ,p_attribute8_name                 => 'ROLE_INFORMATION8'
      ,p_attribute8_value                => p_rec.role_information8
      ,p_attribute9_name                 => 'ROLE_INFORMATION9'
      ,p_attribute9_value                => p_rec.role_information9
      ,p_attribute10_name                => 'ROLE_INFORMATION10'
      ,p_attribute10_value               => p_rec.role_information10
      ,p_attribute11_name                => 'ROLE_INFORMATION11'
      ,p_attribute11_value               => p_rec.role_information11
      ,p_attribute12_name                => 'ROLE_INFORMATION12'
      ,p_attribute12_value               => p_rec.role_information12
      ,p_attribute13_name                => 'ROLE_INFORMATION13'
      ,p_attribute13_value               => p_rec.role_information13
      ,p_attribute14_name                => 'ROLE_INFORMATION14'
      ,p_attribute14_value               => p_rec.role_information14
      ,p_attribute15_name                => 'ROLE_INFORMATION15'
      ,p_attribute15_value               => p_rec.role_information15
      ,p_attribute16_name                => 'ROLE_INFORMATION16'
      ,p_attribute16_value               => p_rec.role_information16
      ,p_attribute17_name                => 'ROLE_INFORMATION17'
      ,p_attribute17_value               => p_rec.role_information17
      ,p_attribute18_name                => 'ROLE_INFORMATION18'
      ,p_attribute18_value               => p_rec.role_information18
      ,p_attribute19_name                => 'ROLE_INFORMATION19'
      ,p_attribute19_value               => p_rec.role_information19
      ,p_attribute20_name                => 'ROLE_INFORMATION20'
      ,p_attribute20_value               => p_rec.role_information20
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
  (p_rec in per_rol_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.role_id is not null)  and (
    nvl(per_rol_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_rol_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.role_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_ROLES'
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
  (p_effective_date               in date
  ,p_rec in per_rol_shd.g_rec_type
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
  IF NOT per_rol_shd.api_updating
      (p_role_id                              => p_rec.role_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  IF nvl(p_rec.person_id, hr_api.g_number) <>
     nvl(per_rol_shd.g_old_rec.person_id, hr_api.g_number) then
     l_argument := 'person_id';
     raise l_error;
  END IF;
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
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_rol_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Call parent person table's set security group id function.
  --
  per_per_bus.set_security_group_id(p_person_id => to_number(p_rec.person_id));
  --
  per_rol_bus.chk_job_group(p_job_id       => p_rec.job_id
                 ,p_job_group_id => p_rec.job_group_id
                 ,p_person_id    => p_rec.person_id);
  --
  per_rol_bus.chk_rep_body(p_job_group_id => p_rec.job_group_id
                ,p_organization_id => p_rec.organization_id);
  --
  per_rol_bus.chk_dates(p_start_date => p_rec.start_date
               ,p_end_date => p_rec.end_date);
  --
  per_rol_bus.chk_person_id
  (p_role_id     => p_rec.role_id
  ,p_person_id   => p_rec.person_id
  ,p_effective_date  => p_effective_date);
  --
  per_rol_bus.chk_emp_rights
  (p_emp_rights_flag    => p_rec.emp_rights_flag
  ,p_end_of_rights_date => p_rec.end_of_rights_date
  ,p_end_date           => p_rec.end_date);
  --
  per_rol_bus.chk_ddf(p_rec);
  --
  per_rol_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_rol_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  per_rol_bus.chk_job_group(p_job_id       => p_rec.job_id
                 ,p_job_group_id => p_rec.job_group_id
                 ,p_person_id    => p_rec.person_id);
  --
  per_rol_bus.chk_rep_body(p_job_group_id => p_rec.job_group_id
                ,p_organization_id => p_rec.organization_id);
  --
  per_rol_bus.chk_dates(p_start_date => p_rec.start_date
               ,p_end_date => p_rec.end_date);
  --
  per_rol_bus.chk_person_id
  (p_role_id     => p_rec.role_id
  ,p_person_id   => p_rec.person_id
  ,p_effective_date  => p_effective_date);
  --
  per_rol_bus.chk_emp_rights
  (p_emp_rights_flag    => p_rec.emp_rights_flag
  ,p_end_of_rights_date => p_rec.end_of_rights_date
  ,p_end_date           => p_rec.end_date);
  --
  -- Call parent person table's set security group id function.
  --
  per_per_bus.set_security_group_id(p_person_id => to_number(p_rec.person_id));
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  per_rol_bus.chk_ddf(p_rec);
  --
  per_rol_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_rol_shd.g_rec_type
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
-- Start of fix 2497485
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_dup_roles >-------------------------------|
-- ----------------------------------------------------------------------------
function chk_dup_roles
         (p_person_id        in    per_roles.person_id%Type
         ,p_job_group_id     in    per_roles.job_group_id%Type
         ,p_job_id           in    per_roles.job_id%Type
         ) return boolean is
--
   --
   cursor csr_dup_roles is
          select 'X'
          from per_roles
          where person_id = p_person_id
          and job_group_id = p_job_group_id
          and job_id = p_job_id;
   --
   l_exist boolean := false;
   l_dummy varchar2(1);
   --
--
begin
--
   open csr_dup_roles;
   fetch csr_dup_roles into l_dummy;
   if csr_dup_roles%found then
      l_exist := true;
   end if;
   --
   close csr_dup_roles;
   --
   return l_exist;
   --
--
end chk_dup_roles;
-- End of 2497485
--
end per_rol_bus;

/
