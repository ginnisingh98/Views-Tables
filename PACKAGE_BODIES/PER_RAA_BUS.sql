--------------------------------------------------------
--  DDL for Package Body PER_RAA_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RAA_BUS" as
/* $Header: peraarhi.pkb 115.20 2003/11/21 02:05:11 vvayanip ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_raa_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_recruitment_activity_id     number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_recruitment_activity_id              in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_recruitment_activities raa
     where raa.recruitment_activity_id = p_recruitment_activity_id
       and pbg.business_group_id = raa.business_group_id;
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
    ,p_argument           => 'recruitment_activity_id'
    ,p_argument_value     => p_recruitment_activity_id
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
     hr_multi_message.add
       (p_associated_column1
        => nvl(p_associated_column1,'RECRUITMENT_ACTIVITY_ID')
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
  (p_recruitment_activity_id              in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_recruitment_activities raa
     where raa.recruitment_activity_id = p_recruitment_activity_id
       and pbg.business_group_id = raa.business_group_id;
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
    ,p_argument           => 'recruitment_activity_id'
    ,p_argument_value     => p_recruitment_activity_id
    );
  --
  if ( nvl(per_raa_bus.g_recruitment_activity_id, hr_api.g_number)
       = p_recruitment_activity_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_raa_bus.g_legislation_code;
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
    per_raa_bus.g_recruitment_activity_id     := p_recruitment_activity_id;
    per_raa_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
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
  (p_rec in per_raa_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.recruitment_activity_id is not null)  and (
    nvl(per_raa_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_raa_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.recruitment_activity_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_RECRUITMENT_ACTIVITIES'
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
  (p_rec in per_raa_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  if NOT per_raa_shd.api_updating
      (p_recruitment_activity_id              => p_rec.recruitment_activity_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END if;
  --
  --  Add checks to ensure non-updateable args have
  --  not been updated.
  if p_rec.business_group_id <> per_raa_shd.g_old_rec.business_group_id then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'BUSINESS_GROUP_ID'
     ,p_base_table => per_raa_shd.g_tab_nam
     );
  end if;

  if p_rec.recruitment_activity_id <> per_raa_shd.g_old_rec.recruitment_activity_id then
     hr_api.argument_changed_error
     (p_api_name   => l_proc
     ,p_argument   => 'RECRUITMENT_ACTIVITY_ID'
     ,p_base_table => per_raa_shd.g_tab_nam
     );
  end if;
  --
End chk_non_updateable_args;
--
-- -----------------------------------------------------------------------------
-- |-------------------------------< chk_name >--------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that name is mandatory
--
-- Prerequisites:
--
--
-- In Arguments:
--   p_name
--
-- Post Success:
--   If name is valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   If authorising person id is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_name
  (p_name in per_recruitment_activities.name%TYPE
  ,p_recruitment_activity_id in
       per_recruitment_activities.recruitment_activity_id%TYPE
  ,p_object_version_number in
       per_recruitment_activities.object_version_number%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_name';
  l_name     varchar2(1);
  l_api_updating boolean;
  cursor csr_name is
         select null
           from per_recruitment_activities
          where name     = p_name;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
   (p_api_name           => l_proc
   ,p_argument           => 'NAME'
   ,p_argument_value     => p_name
   );
  --
  l_api_updating := per_raa_shd.api_updating
                    (p_recruitment_activity_id => p_recruitment_activity_id
                    ,p_object_version_number   => p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if(l_api_updating  and
       p_name <>
       NVL(per_raa_shd.g_old_rec.name,hr_api.g_varchar2)
     ) or (NOT l_api_updating) then
     hr_utility.set_location(l_proc,30);
    open csr_name;
    fetch csr_name into l_name;
  --
    if(csr_name%found) then
      hr_utility.set_location(l_proc,40);
      close csr_name;
      fnd_message.set_name('PER','IRC_412123_DUPLICATE_REC_ACTIV');
      fnd_message.raise_error;
    end if;
    close csr_name;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PER_RECRUITMENT_ACTIVITIES.NAME'
       ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
end chk_name;
--
-- -----------------------------------------------------------------------------
-- |----------------------< chk_authorising_person_id >------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that Authorising person id exists in
--   PER_ALL_PEOPLE_F and system person type is EMP or CWK.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_authorising_person_id
--   p_date_start
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If authorising_person_id is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If authorising person id is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_authorising_person_id
  (p_authorising_person_id   in
                         per_recruitment_activities.authorising_person_id%TYPE
  ,p_date_start              in
                         per_recruitment_activities.date_start%TYPE
  ,p_recruitment_activity_id in
                         per_recruitment_activities.recruitment_activity_id%TYPE
  ,p_object_version_number   in
                         per_recruitment_activities.object_version_number%TYPE
 ) is
--
  l_proc   varchar2(72) := g_package || 'chk_authorising_person_id';
  l_authorising_person_id varchar2(1);
  l_system_person_type    varchar2(1);
  l_api_updating          boolean;

  cursor csr_authorising_person_id is
  select null from PER_ALL_PEOPLE_F pap
  where pap.person_id = p_authorising_person_id
  and
  (p_date_start between pap.effective_start_date and pap.effective_end_date);

  cursor csr_system_person_type is
  select null from per_person_types ppt, per_person_type_usages_f ptu
  where ptu.person_id = p_authorising_person_id
  and p_date_start between ptu.effective_start_date and ptu.effective_end_date
  and ptu.person_type_id = ppt.person_type_id
  and (ppt.system_person_type = 'EMP'
   or (ppt.system_person_type = 'CWK' and
       nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'));
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_authorising_person_id is not null then
    if (l_api_updating  and
        p_authorising_person_id <>
        NVL(per_raa_shd.g_old_rec.authorising_person_id,hr_api.g_number)
       ) or (NOT l_api_updating) then

    -- check that authorising_person_id exists in per_all_people_f.
      hr_utility.set_location(l_proc,30);
      open csr_authorising_person_id;
      fetch csr_authorising_person_id into l_authorising_person_id;
      if csr_authorising_person_id%NOTFOUND then
        close csr_authorising_person_id;
        fnd_message.set_name('PER','PER_289429_RAA_INV_AUTH_PERSON');
        fnd_message.raise_error;
      end if;
      close csr_authorising_person_id;
    -- check that system person type is EMP or CWK.
      hr_utility.set_location(l_proc,40);
      open csr_system_person_type;
      fetch csr_system_person_type into l_system_person_type;
      if csr_system_person_type%NOTFOUND then
        close csr_system_person_type;
        fnd_message.set_name('PER','PER_289430_RAA_INV_PERSON_TYPE');
        fnd_message.raise_error;
      end if;
      close csr_system_person_type;
    --
    end if;
   end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
    if hr_multi_message.exception_add
     (p_associated_column1 => 'PER_RECRUITMENT_ACTIVITIES.AUTHORISING_PERSON_ID'
     ) then
      hr_utility.set_location(' Leaving:'||l_proc,60);
      raise;
    end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
--
end chk_authorising_person_id;
--
-- -----------------------------------------------------------------------------
-- |--------------------< chk_run_by_organization_id >-------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that run_by_organization_id exists in HR_ALL_ORGANIZATION_UNITS
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_run_by_organization_id
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If run_by_organization_id is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If run_by_organization_id is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_run_by_organization_id
  (p_run_by_organization_id  in
                         per_recruitment_activities.run_by_organization_id%TYPE
  ,p_recruitment_activity_id in
                         per_recruitment_activities.recruitment_activity_id%TYPE
  ,p_object_version_number   in
                         per_recruitment_activities.object_version_number%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_run_by_organization_id';
  l_run_by_organization_id varchar2(1);
  l_api_updating           boolean;

  cursor csr_run_by_organization_id is
  select null from HR_ALL_ORGANIZATION_UNITS hao
  where hao.organization_id = p_run_by_organization_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_run_by_organization_id is not null then
    if (l_api_updating and
        p_run_by_organization_id <>
        NVL(per_raa_shd.g_old_rec.run_by_organization_id,hr_api.g_number))
       or (NOT l_api_updating) then

    -- check that run_by_organization_id exists in per_all_people_f.
      hr_utility.set_location(l_proc,30);
      open csr_run_by_organization_id;
      fetch csr_run_by_organization_id into l_run_by_organization_id;
      if csr_run_by_organization_id%NOTFOUND then
        close csr_run_by_organization_id;
        fnd_message.set_name('PER','PER_289431_RAA_INV_RUN_BY_ORG');
        fnd_message.raise_error;
      end if;
      close csr_run_by_organization_id;
    --
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1=> 'PER_RECRUITMENT_ACTIVITIES.RUN_BY_ORGANIZATION_ID'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
--
end chk_run_by_organization_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_internal_contact_person_id >---------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that internal contact person id exists in
--   PER_ALL_PEOPLE_F and system person type is EMP or CWK.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_internal_contact_person_id
--   p_date_start
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If internal_contact_person_id is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If internal contact person id is invalid then an application error is
--   raised as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_internal_contact_person_id
  (p_internal_contact_person_id in
                     per_recruitment_activities.internal_contact_person_id%TYPE
  ,p_date_start                 in
                     per_recruitment_activities.date_start%TYPE
  ,p_recruitment_activity_id    in
                     per_recruitment_activities.recruitment_activity_id%TYPE
  ,p_object_version_number      in
                     per_recruitment_activities.object_version_number%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_internal_contact_person_id';
  l_internal_contact_person_id     varchar2(1);
  l_system_person_type             varchar2(1);
  l_api_updating                   boolean;

  cursor csr_internal_contact_person_id is
  select null from PER_ALL_PEOPLE_F  pap
  where pap.person_id = p_internal_contact_person_id
  and
  (p_date_start between pap.effective_start_date and pap.effective_end_date);

  cursor csr_system_person_type is
  select null from per_person_types ppt, per_person_type_usages_f ptu
  where ptu.person_id = p_internal_contact_person_id
  and p_date_start between ptu.effective_start_date and ptu.effective_end_date
  and ptu.person_type_id = ppt.person_type_id
  and (ppt.system_person_type = 'EMP'
   or (ppt.system_person_type = 'CWK' and
       nvl(fnd_profile.value('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'));

  --
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_internal_contact_person_id is not null then
    if (l_api_updating and
        p_internal_contact_person_id <>
        NVL(per_raa_shd.g_old_rec.internal_contact_person_id,hr_api.g_number))
        or (NOT l_api_updating) then

    -- check that internal_contact_person_id exists in per_all_people_f.
      hr_utility.set_location(l_proc,30);
      open csr_internal_contact_person_id;
      fetch csr_internal_contact_person_id into l_internal_contact_person_id;
      if csr_internal_contact_person_id%NOTFOUND then
        close csr_internal_contact_person_id;
        fnd_message.set_name('PER','PER_289432_RAA_INV_CONT_PERSON');
        fnd_message.raise_error;
      end if;
      close csr_internal_contact_person_id;

    -- check that system person type is EMP or CWK.
      hr_utility.set_location(l_proc,40);
      open csr_system_person_type;
      fetch csr_system_person_type into l_system_person_type;
      if csr_system_person_type%NOTFOUND then
        close csr_system_person_type;
        fnd_message.set_name('PER','PER_289430_RAA_INV_PERSON_TYPE');
        fnd_message.raise_error;
      end if;
      close csr_system_person_type;
    --
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.INTERNAL_CONTACT_PERSON_ID'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,60);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,70);
--
end chk_internal_contact_person_id;
--
-- -----------------------------------------------------------------------------
-- |-------------------< chk_parent_recruitment_activit >----------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that parent recruitment activity id exists in
--   PER_RECRUITMENT_ACTIVITIES.
--   Checks that parent_recruitment_activity_id is not equal to
--   recruitment_activity_id of current row.
--   Checks that parent_recruitment_activity_id is not equal to
--   recruiment_activity_id of any row for which parent_recruitment_activity_id
--   is equal to recruitment_id of current row.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_parent_recruitment_activity
--   p_date_start
--   p_business_group_id
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If parent_recruitment_activity_id is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If parent_recruitment_acitivity_id is invalid then an application error is
--   raised as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_parent_recruitment_activit
  (p_parent_recruitment_activity in
                  per_recruitment_activities.parent_recruitment_activity_id%TYPE
  ,p_date_start                  in
                  per_recruitment_activities.date_start%TYPE
  ,p_business_group_id           in
                  per_recruitment_activities.business_group_id%TYPE
  ,p_recruitment_activity_id     in
                  per_recruitment_activities.recruitment_activity_id%TYPE
  ,p_object_version_number       in
                  per_recruitment_activities.object_version_number%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_parent_recruitment_activit';
  l_parent_recruitment_activity_  varchar2(1);
  l_recruitment_activity_id       varchar2(1);
  l_api_updating                  boolean;
--
  cursor csr_parent_recruitment_activit is
   select null from PER_RECRUITMENT_ACTIVITIES pra
   where pra.recruitment_activity_id = p_parent_recruitment_activity;

  cursor csr_recruitment_activity_id is
  select null from PER_RECRUITMENT_ACTIVITIES r1
  where r1.business_group_id = p_business_group_id and
  p_recruitment_activity_id <> r1.recruitment_activity_id
  and r1.recruitment_activity_id=p_parent_recruitment_activity
  and p_date_start between r1.date_start and nvl(r1.date_end, hr_api.g_eot)
  and r1.recruitment_activity_id not in (select r2.recruitment_activity_id
  from per_recruitment_activities r2 connect by
  r2.parent_recruitment_activity_id = prior r2.recruitment_activity_id
  start with r2.parent_recruitment_activity_id = p_recruitment_activity_id);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);

  if p_parent_recruitment_activity is not null then
    if (l_api_updating and
       (p_parent_recruitment_activity <>
       NVL(per_raa_shd.g_old_rec.parent_recruitment_activity_id,hr_api.g_number)
       or
       p_recruitment_activity_id <>
       per_raa_shd.g_old_rec.recruitment_activity_id))
       or (NOT l_api_updating) then

    -- Checks that parent recruitment activity id exists in
    -- PER_RECRUITMENT_ACTIVITIES.
      hr_utility.set_location(l_proc,30);
      open csr_parent_recruitment_activit;
      fetch csr_parent_recruitment_activit into l_parent_recruitment_activity_;
      if csr_parent_recruitment_activit%NOTFOUND then
        close csr_parent_recruitment_activit;
        fnd_message.set_name('PER','PER_289433_RAA_INV_PARENT_ACTI');
        fnd_message.raise_error;
      end if;
      close csr_parent_recruitment_activit;

      hr_utility.set_location(l_proc,35);
      if p_recruitment_activity_id is not null then
        -- Checks that parent_recruitment_activity_id is not equal to
        -- recruitment_activity_id of current row.
        hr_utility.set_location(l_proc,40);
        if  p_parent_recruitment_activity = p_recruitment_activity_id then
          fnd_message.set_name('PER','PER_289434_RAA_INV_PARENT_ACTI');
          fnd_message.raise_error;
        end if;
        -- Checks that parent_recruitment_activity_id is not equal to
        -- recruiment_activity_id of any row for which
        -- parent_recruitment_activity_id
        -- is equal to recruitment_id of current row.
        hr_utility.set_location(l_proc,50);
        open csr_recruitment_activity_id;
        fetch csr_recruitment_activity_id into l_recruitment_activity_id;
        if csr_recruitment_activity_id%NOTFOUND then
          close csr_recruitment_activity_id;
          fnd_message.set_name('PER','PER_289434_RAA_INV_PARENT_ACTI');
          fnd_message.raise_error;
        end if;
        close csr_recruitment_activity_id;
      end if;
    --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,60);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.PARENT_RECRUITMENT_ACTIVITY_ID'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,70);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,80);
--
end chk_parent_recruitment_activit;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< chk_currency_code >----------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that currency_code exists in FND_CURRENCIES
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_currency_code
--   p_date_start
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If currency_code is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If currency_code is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_currency_code
  (p_currency_code           in
                  per_recruitment_activities.currency_code%TYPE
  ,p_date_start              in
                  per_recruitment_activities.date_start%TYPE
  ,p_recruitment_activity_id in
                  per_recruitment_activities.recruitment_activity_id%TYPE
  ,p_object_version_number   in
                  per_recruitment_activities.object_version_number%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_currency_code';
  l_currency_code varchar2(1);
  l_api_updating  boolean;

  cursor csr_currency_code is
  select null from FND_CURRENCIES fc
  where fc.currency_code = p_currency_code
  and
  (p_date_start between fc.start_date_active and fc.end_date_active);
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_currency_code is not null then
    if (l_api_updating and
        p_currency_code <>
        NVL(per_raa_shd.g_old_rec.currency_code,hr_api.g_number))
       or (NOT l_api_updating) then

      -- check that currency_code exists in FND_CURRENCIES.
      hr_utility.set_location(l_proc,30);
      open csr_currency_code;
      fetch csr_currency_code into l_currency_code;
      if csr_currency_code%NOTFOUND then
        close csr_currency_code;
        fnd_message.set_name('PER','PER_289435_RAA_INV_CURRENCY_CO');
        fnd_message.raise_error;
      end if;
      close csr_currency_code;
    --
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.CURRENCY_CODE'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_currency_code;
--
-- -----------------------------------------------------------------------------
-- |-------------------< chk_recruiting_site_id >------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that posting_content_id exists in IRC_ALL_RECRUITING_SITES
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_recruiting_site_id
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If recruiting_site_id is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If posting_content_id is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_recruiting_site_id
  (p_recruiting_site_id       in
                  per_recruitment_activities.recruiting_site_id%TYPE
  ,p_recruitment_activity_id  in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number    in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_recruiting_site_id';
  l_recruiting_site_id varchar2(1);
  l_api_updating       boolean;

  cursor csr_recruiting_site_id is
   select null from IRC_ALL_RECRUITING_SITES irs
   where irs.recruiting_site_id = p_recruiting_site_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_recruiting_site_id is not null then
    if (l_api_updating  and
        p_recruiting_site_id <>
        NVL(per_raa_shd.g_old_rec.recruiting_site_id,hr_api.g_number)
       ) or (NOT l_api_updating) then

    -- check that recruiting_site_id exists in IRC_ALL_RECRUITING_SITES.
      hr_utility.set_location(l_proc,30);
      open csr_recruiting_site_id;
      fetch csr_recruiting_site_id into l_recruiting_site_id;
      if csr_recruiting_site_id%NOTFOUND then
        close csr_recruiting_site_id;
        fnd_message.set_name('PER','PER_289880_BAD_REC_SITE_ID');
        fnd_message.raise_error;
      end if;
      close csr_recruiting_site_id;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.RECRUITING_SITE_ID'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_recruiting_site_id;
--
-- -----------------------------------------------------------------------------
-- |-------------------< chk_posting_content_id >------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that posting_content_id exists in IRC_POSTING_CONTENTS
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_posting_content_id
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If posting_content_id is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If posting_content_id is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_posting_content_id
  (p_posting_content_id       in
                  per_recruitment_activities.POSTING_CONTENT_ID%TYPE
  ,p_recruitment_activity_id  in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number    in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_posting_content_id';
  l_posting_content_id varchar2(1);
  l_api_updating       boolean;

  cursor csr_posting_content_id is
   select null from IRC_POSTING_CONTENTS ipc
   where ipc.posting_content_id = p_posting_content_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_posting_content_id is not null then
    if (l_api_updating  and
        p_posting_content_id <>
        NVL(per_raa_shd.g_old_rec.posting_content_id,hr_api.g_number)
       ) or (NOT l_api_updating) then

    -- check that posting_content_id exists in IRC_POSTING_CONTENTS.
      hr_utility.set_location(l_proc,30);
      open csr_posting_content_id;
      fetch csr_posting_content_id into l_posting_content_id;
      if csr_posting_content_id%NOTFOUND then
        close csr_posting_content_id;
        fnd_message.set_name('PER','PER_289436_RAA_INV_PERSON_TYPE');
        fnd_message.raise_error;
      end if;
      close csr_posting_content_id;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.POSTING_CONTENT_ID'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_posting_content_id;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< chk_dates >--------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that date_start is not later then corresponding date_end
--   Checks that date_start is not null.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_date_start
--   p_date_end
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If date_start and date_end are valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If date_start and date_end invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_dates
  (p_date_start              in
                  per_recruitment_activities.DATE_START%TYPE
  ,p_date_end                in
                  per_recruitment_activities.DATE_END%TYPE
  ,p_recruitment_activity_id in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number   in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc            varchar2(72) := g_package || 'chk_date_start';
  l_api_updating    boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if  (l_api_updating and
       (NVL(p_date_start,hr_api.g_eot) <> per_raa_shd.g_old_rec.date_start
       or NVL(p_date_end,hr_api.g_eot) <>
       NVL(per_raa_shd.g_old_rec.date_end,hr_api.g_eot))
      ) or (NOT l_api_updating) then
    --  Checks that date_start is not null.
    hr_utility.set_location(l_proc,30);
    if p_date_start is null then
      fnd_message.set_name('PER','PER_289438_RAA_START_DATE_REQ');
      hr_multi_message.add
      (p_associated_column1 => 'PER_RECRUITMENT_ACTIVITIES.DATE_START'
      );
    -- Call to raise any errors on multi-message list
    hr_multi_message.end_validation_set;
    else
      --  Checks that date_start is not later then corresponding date_end
      hr_utility.set_location(l_proc,40);
      if p_date_start > p_date_end then
        fnd_message.set_name('PER','HR_6021_ALL_START_END_DATE');
        hr_multi_message.add
        (p_associated_column1 => 'PER_RECRUITMENT_ACTIVITIES.DATE_START'
        ,p_associated_column2 => 'PER_RECRUITMENT_ACTIVITIES.DATE_END'
        );
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
end chk_dates;
--
-- -----------------------------------------------------------------------------
-- |-----------------------------< chk_type >----------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that type is validated against hr_lookups.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_type
--   p_effective_date
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If type is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If type is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_type
  (p_type                     in
                  per_recruitment_activities.TYPE%TYPE
  ,p_effective_date           in
                  per_recruitment_activities.DATE_START%TYPE
  ,p_recruitment_activity_id  in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number    in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc          varchar2(72) := g_package || 'chk_date_end';
  l_api_updating  boolean;
  l_ret           boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_type is not null then
    if (l_api_updating and
        p_type <> NVL(per_raa_shd.g_old_rec.type,hr_api.g_varchar2))
       or (NOT l_api_updating) then

      --  Checks that type is validated against hr_lookups.
       hr_utility.set_location(l_proc,30);
      l_ret := hr_api.not_exists_in_hr_lookups(
                              p_effective_date => p_effective_date
                             ,p_lookup_type    => 'REC_TYPE'
                             ,p_lookup_code    => p_type);
      if l_ret = true then
        fnd_message.set_name('PER','PER_289439_RAA_INV_CHECK_TYPE');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.TYPE'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_type;
--
-- -----------------------------------------------------------------------------
-- |---------------------------< chk_date_closing >----------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that date_closing is not earlier then corresponding date_start
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_date_closing
--   p_date_start
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If date_closing is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If date_closing is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_date_closing
  (p_date_closing            in
                  per_recruitment_activities.DATE_CLOSING%TYPE
  ,p_date_start              in
                  per_recruitment_activities.DATE_START%TYPE
  ,p_recruitment_activity_id in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number   in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc            varchar2(72) := g_package || 'chk_date_closing';
  l_api_updating    boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_date_closing is not null then
    if (l_api_updating and
        (NVL(p_date_closing,hr_api.g_eot) <>
        NVL(per_raa_shd.g_old_rec.date_closing,hr_api.g_eot)
        or p_date_start <> per_raa_shd.g_old_rec.date_start))
        or (NOT l_api_updating) then

    --  Checks that date_start is not later then corresponding date_closing
      hr_utility.set_location(l_proc,30);
      if p_date_start > p_date_closing then
        fnd_message.set_name('PER','HR_6114_RAC_CLOSE_DATE');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.DATE_CLOSING'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_date_closing;
--
-- -----------------------------------------------------------------------------
-- |------------------------------< chk_status >-------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that status is validated against hr_lookups.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_status
--   p_effective_date
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If status is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If status is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_status
  (p_status                  in
                  per_recruitment_activities.STATUS%TYPE
  ,p_effective_date          in
                  per_recruitment_activities.DATE_START%TYPE
  ,p_recruitment_activity_id in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number   in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc              varchar2(72) := g_package || 'chk_date_end';
  l_status            varchar2(1);
  l_api_updating      boolean;
  l_ret               boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_status  is not null then
    if (l_api_updating and
        p_status <> NVL(per_raa_shd.g_old_rec.status,hr_api.g_varchar2))
        or (NOT l_api_updating) then

    --  Checks that status is validated against hr_lookups.
      hr_utility.set_location(l_proc,30);
      l_ret := hr_api.not_exists_in_hr_lookups(
                                p_effective_date => p_effective_date
                               ,p_lookup_type    => 'REC_STATUS'
                               ,p_lookup_code    => p_status);
      if l_ret = true then
        fnd_message.set_name('PER','PER_289440_RAA_INV_CHECK_STATU');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.STATUS'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
end chk_status;
--
-- -----------------------------------------------------------------------------
-- |--------------------------< chk_actual_cost >------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that actual_cost should be greater then zero.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_actual_cost
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If actual_cost is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If actual_cost is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_actual_cost
  (p_actual_cost             in
                  per_recruitment_activities.ACTUAL_COST%TYPE
  ,p_recruitment_activity_id in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number   in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_actual_cost';
  l_api_updating    boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_actual_cost is not null then
    if (l_api_updating and
        p_actual_cost <>
        NVL(per_raa_shd.g_old_rec.actual_cost,hr_api.g_number))
       or (NOT l_api_updating) then

    -- Checks that actual_cost is greater then zero
      hr_utility.set_location(l_proc,30);
      if p_actual_cost < 0  then
        fnd_message.set_name( 'PER','PAY_6779_DEF_CURR_UNIT_ZERO');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.ACTUAL_COST'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
--
end chk_actual_cost;
--
-- -----------------------------------------------------------------------------
-- |-------------------------< chk_planned_cost >------------------------------|
-- -----------------------------------------------------------------------------
--
-- Description:
--   Checks that planned_cost should be greater then zero.
--
-- Prerequisites:
--  g_old_rec has been populated with details of the values currently in
--  the database.
--
-- In Arguments:
--   p_planned_cost
--   p_recruitment_activity_id
--   p_object_version_number
--
-- Post Success:
--   If planned_cost is valid this procedure will
--   end normally and processing will continue.
--
-- Post Failure:
--   If planned_cost is invalid then an application error is raised
--   as a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_planned_cost
  (p_planned_cost            in
                  per_recruitment_activities.PLANNED_COST%TYPE
  ,p_recruitment_activity_id in
                  per_recruitment_activities.RECRUITMENT_ACTIVITY_ID%TYPE
  ,p_object_version_number   in
                  per_recruitment_activities.OBJECT_VERSION_NUMBER%TYPE
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_planned_cost';
  l_api_updating    boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  l_api_updating  :=
  per_raa_shd.api_updating(p_recruitment_activity_id,p_object_version_number);
  hr_utility.set_location(l_proc,20);
  if p_planned_cost is not null then
    if (l_api_updating and
        p_planned_cost <>
        NVL(per_raa_shd.g_old_rec.planned_cost,hr_api.g_number))
       or (NOT l_api_updating) then

    -- Checks that planned_cost is greater then zero
      hr_utility.set_location(l_proc,30);
      if p_planned_cost < 0  then
        fnd_message.set_name( 'PER','PAY_6779_DEF_CURR_UNIT_ZERO');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,40);
  exception
   when app_exception.application_exception then
     if hr_multi_message.exception_add
     (p_associated_column1 =>
     'PER_RECRUITMENT_ACTIVITIES.PLANNED_COST'
     ) then
       hr_utility.set_location(' Leaving:'||l_proc,50);
       raise;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,60);
--
end chk_planned_cost;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in per_raa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate Important Attributes
  --
  -- Call all supporting business operations
  --
  -- Validate Bus Grp
  hr_api.validate_bus_grp_id
     (p_business_group_id  => p_rec.business_group_id
     ,p_associated_column1 => per_raa_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
      );
  --
  -- After validating the set of important attributes,
  -- if Mulitple message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_utility.set_location(l_proc,6);
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc,10);
  per_raa_bus.CHK_NAME(p_name => p_rec.name
                    ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                    ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,12);
  hr_utility.set_location(l_proc,15);
  per_raa_bus.CHK_POSTING_CONTENT_ID(
                    p_posting_content_id      => p_rec.posting_content_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,16);
  per_raa_bus.CHK_recruiting_site_id(
                    p_recruiting_site_id      => p_rec.recruiting_site_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  per_raa_bus.CHK_DATES(
                    p_date_start              => p_rec.date_start
                   ,p_date_end                => p_rec.date_end
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,25);
  per_raa_bus.CHK_TYPE(
                    p_type                    => p_rec.type
                   ,p_effective_date          => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,40);
  per_raa_bus.CHK_DATE_CLOSING(
                    p_date_closing            => p_rec.date_closing
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,45);
  per_raa_bus.CHK_STATUS(
                    p_status                  => p_rec.status
                   ,p_effective_date          => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,50);
  per_raa_bus.CHK_AUTHORISING_PERSON_ID(
                    p_authorising_person_id   => p_rec.authorising_person_id
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,55);
  per_raa_bus.CHK_RUN_BY_ORGANIZATION_ID(
                    p_run_by_organization_id  => p_rec.run_by_organization_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,60);
  per_raa_bus.CHK_INTERNAL_CONTACT_PERSON_ID(
                    p_internal_contact_person_id =>
                                               p_rec.internal_contact_person_id
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,65);
  per_raa_bus.CHK_PARENT_RECRUITMENT_ACTIVIT(
                    p_parent_recruitment_activity
                                         => p_rec.parent_recruitment_activity_id
                   ,p_date_start              => p_rec.date_start
                   ,p_business_group_id       => p_rec.business_group_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,70);
  per_raa_bus.CHK_CURRENCY_CODE(
                    p_currency_code           => p_rec.currency_code
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,75);
  per_raa_bus.CHK_ACTUAL_COST(
                    p_actual_cost             => p_rec.actual_cost
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,80);
  per_raa_bus.CHK_PLANNED_COST(
                    p_planned_cost            => p_rec.planned_cost
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,85);
  per_raa_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_raa_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
  -- Validate Important Attributes
  --
  -- Call all supporting business operations
  --
  -- Validate Bus Grp
  hr_api.validate_bus_grp_id(
      p_business_group_id  => p_rec.business_group_id
     ,p_associated_column1 => per_raa_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
      );
  --
  -- After validating the set of important attributes,
  -- if Mulitple message detection is enabled and at least
  -- one error has been found then abort further validation.
  --
  hr_utility.set_location(l_proc,6);
  hr_multi_message.end_validation_set;
  --
  -- Validate Dependent Attributes
  --
  hr_utility.set_location(l_proc,7);
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(l_proc,10);
  per_raa_bus.CHK_NAME(p_name => p_rec.name
                    ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                    ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,12);
  --
  hr_utility.set_location(l_proc,15);
  per_raa_bus.CHK_POSTING_CONTENT_ID(
                    p_posting_content_id      => p_rec.posting_content_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,16);
  per_raa_bus.CHK_recruiting_site_id(
                    p_recruiting_site_id      => p_rec.recruiting_site_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  hr_utility.set_location(l_proc,20);
  per_raa_bus.CHK_DATES(
                    p_date_start              => p_rec.date_start
                   ,p_date_end                => p_rec.date_end
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,25);
  per_raa_bus.CHK_TYPE(
                    p_type                    => p_rec.type
                   ,p_effective_date          => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,40);
  per_raa_bus.CHK_DATE_CLOSING(
                    p_date_closing            => p_rec.date_closing
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,45);
  per_raa_bus.CHK_STATUS(
                    p_status                  => p_rec.status
                   ,p_effective_date          => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,50);
  per_raa_bus.CHK_AUTHORISING_PERSON_ID(
                    p_authorising_person_id   => p_rec.authorising_person_id
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,55);
  per_raa_bus.CHK_RUN_BY_ORGANIZATION_ID(
                    p_run_by_organization_id  => p_rec.run_by_organization_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,60);
  per_raa_bus.CHK_INTERNAL_CONTACT_PERSON_ID(
                    p_internal_contact_person_id =>
                                               p_rec.internal_contact_person_id
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,65);
  per_raa_bus.CHK_PARENT_RECRUITMENT_ACTIVIT(
                    p_parent_recruitment_activity
                                              =>
                                            p_rec.parent_recruitment_activity_id
                   ,p_date_start              => p_rec.date_start
                   ,p_business_group_id       =>
                                         per_raa_shd.g_old_rec.business_group_id
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,70);
  per_raa_bus.CHK_CURRENCY_CODE(
                    p_currency_code           => p_rec.currency_code
                   ,p_date_start              => p_rec.date_start
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,75);
  per_raa_bus.CHK_ACTUAL_COST(
                    p_actual_cost             => p_rec.actual_cost
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,80);
  per_raa_bus.CHK_PLANNED_COST(
                    p_planned_cost            => p_rec.planned_cost
                   ,p_recruitment_activity_id => p_rec.recruitment_activity_id
                   ,p_object_version_number   => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc,85);
  per_raa_bus.chk_df(p_rec => p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_raa_shd.g_rec_type
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
end per_raa_bus;

/
