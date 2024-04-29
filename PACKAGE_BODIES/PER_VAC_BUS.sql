--------------------------------------------------------
--  DDL for Package Body PER_VAC_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VAC_BUS" as
/* $Header: pevacrhi.pkb 120.0.12010000.2 2010/04/08 10:24:32 karthmoh ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_vac_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_vacancy_id                  number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_vacancy_id                           in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_all_vacancies vac
     where vac.vacancy_id = p_vacancy_id
       and pbg.business_group_id = vac.business_group_id;
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
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
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
     (p_associated_column1 => nvl(p_associated_column1,'VACANCY_ID'));
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
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_vacancy_id                           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
 cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_all_vacancies vac
     where vac.vacancy_id = p_vacancy_id
       and pbg.business_group_id = vac.business_group_id;
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
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
    );
  --
  if ( nvl(per_vac_bus.g_vacancy_id, hr_api.g_number)
       = p_vacancy_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_vac_bus.g_legislation_code;
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
    per_vac_bus.g_vacancy_id                  := p_vacancy_id;
    per_vac_bus.g_legislation_code  := l_legislation_code;
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
--   if the Descriptive Flexfield structure column and data values are
--   all valid this procedure will end normally and processing will
--   continue.
--
-- Post Failure:
--   if the Descriptive Flexfield structure column value or any of
--   the data values are invalid then an application error is raised as
--   a PL/SQL exception.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
procedure chk_df
  (p_rec in per_vac_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.vacancy_id is not null)  and (
    nvl(per_vac_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(per_vac_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2) ))
    or (p_rec.vacancy_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_VACANCIES'
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
--   not been updated. if an attribute has been updated an error is generated.
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
  (p_rec in per_vac_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  if not per_vac_shd.api_updating
      (p_vacancy_id                           => p_rec.vacancy_id
      ,p_object_version_number                => p_rec.object_version_number
      ) then
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  end if;


  if per_vac_shd.g_old_rec.business_group_id <> p_rec.business_group_id
    then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'business_group_id'
         ,p_base_table => per_vac_shd.g_tab_name
         );
    end if;

    if per_vac_shd.g_old_rec.vacancy_id <> p_rec.vacancy_id then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'vacancy_id'
         ,p_base_table => per_vac_shd.g_tab_name
         );
    end if;

    if per_vac_shd.g_old_rec.name <> p_rec.name then
        hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => 'name'
         ,p_base_table => per_vac_shd.g_tab_name
         );
    end if;
  --
End chk_non_updateable_args;

--
-- ----------------------------------------------------------------------------
-- |-------------------------------< chk_name>--------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid vacancy name
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_name
--   p_business_group_id
-- Post Success:
--   Processing continues if vacancy name is not null and unique
--
-- Post Failure:
--   An application error is raised if vacacny name is null or exists already
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_name
  (p_name in per_all_vacancies.name%TYPE
  ,p_business_group_id in per_all_vacancies.business_group_id%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_name';
  l_name     varchar2(1);
  cursor csr_name is
         select null
           from per_all_vacancies
          where name = p_name
            and business_group_id = p_business_group_id;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  if (p_name is null)
  then
    hr_api.mandatory_arg_error
    (p_api_name         => l_proc
    ,p_argument         => 'NAME'
    ,p_argument_value   => p_name
    );
  end if;
--
  open csr_name;
  fetch csr_name into l_name;
--
  hr_utility.set_location(l_proc,20);
  if (csr_name%found)
  then
    close csr_name;
    fnd_message.set_name('PER','IRC_412115_DUPLICATE_VAC_NAME');
    fnd_message.set_token('INFORMATION_TYPE','VACANCY');
    fnd_message.raise_error;
  end if;
  close csr_name;
--
  hr_utility.set_location(' Leaving:'||l_proc,30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.NAME'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
End chk_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_vacancy_dates>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures valid dates are entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_date_from
--   p_date_to
-- Post Success:
--   Processing continues if from and to dates are valid and from date is lesser
--     to date
--
-- Post Failure:
--   An application error is raised if dates entered are not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_dates
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_date_from in per_all_vacancies.date_from%TYPE
  ,p_date_to in per_all_vacancies.date_to%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_vacancy_dates';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating := per_vac_shd.api_updating
          (p_vacancy_id             => p_vacancy_id
           ,p_object_version_number => p_object_version_number);
    --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
    and
       (nvl(per_vac_shd.g_old_rec.date_from, hr_api.g_date) <>
       nvl(p_date_from, hr_api.g_date) or
       nvl(per_vac_shd.g_old_rec.date_to, hr_api.g_date) <>
       nvl(p_date_to, hr_api.g_date)))
    or
       (NOT l_api_updating)) then
  --
    hr_utility.set_location(l_proc,30);
    if (p_date_from is null)
    then
      fnd_message.set_name('PER','PER_289443_VAC_DATE_FROM_MND');
      hr_multi_message.add
           (p_associated_column1      => 'PER_ALL_VACANCIES.DATE_FROM'
           );
      hr_multi_message.end_validation_set();
    end if;
    hr_utility.set_location(l_proc,40);
  --
    if (p_date_from > nvl(p_date_to,hr_api.g_eot))
    then
      fnd_message.set_name('PER','IRC_ALL_DATE_START_END');
      hr_multi_message.add
           (p_associated_column1      => 'PER_ALL_VACANCIES.DATE_FROM'
           ,p_associated_column2      => 'PER_ALL_VACANCIES.DATE_TO'
           );
    end if;
  end if;
--
  hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_vacancy_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_status >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid vacancy status
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_status
--   p_effective_date
-- Post Success:
--   Processing continues if status is valid

--
-- Post Failure:
--   An application error is raised if status code is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_status
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_status in per_all_vacancies.status%TYPE
  ,p_effective_date in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_status';
  l_api_updating boolean;
  l_exists boolean;
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc,10);
  l_api_updating := per_vac_shd.api_updating
          (p_vacancy_id             => p_vacancy_id
           ,p_object_version_number => p_object_version_number);
    --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
           and
         nvl(per_vac_shd.g_old_rec.status, hr_api.g_varchar2) <>
         nvl(p_status, hr_api.g_varchar2))
      or
     (NOT l_api_updating)) then
    if (p_status is not null)
    then
    l_exists := hr_api.not_exists_in_hr_lookups(p_effective_date
                                            ,'VACANCY_STATUS'
                                            ,p_status);
     hr_utility.set_location(l_proc,30);
      if (l_exists = true)
      then
        fnd_message.set_name('PER','PER_289444_VAC_INV_STATUS_CODE');
        fnd_message.raise_error;
      end if;
     hr_utility.set_location(l_proc,30);
     end if;
  end if;
--
 hr_utility.set_location(' Leaving:'||l_proc,40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.STATUS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
--
End chk_status;
--
-- ----------------------------------------------------------------------------
-- |----------------------<chk_budget_measurement_type>-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid budget measurement type
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_budget_measurement_type
--   p_effective_date
-- Post Success:
--   Processing continues if budget measurement code is valid

--
-- Post Failure:
--   An application error is raised if budget measurement code is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_budget_measurement_type
  (
   p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_budget_measurement_type in per_all_vacancies.budget_measurement_type%TYPE
  ,p_effective_date in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_budget_measurement_type';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  l_api_updating := per_vac_shd.api_updating
            (p_vacancy_id             => p_vacancy_id
             ,p_object_version_number => p_object_version_number);
--
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
             and
          nvl(per_vac_shd.g_old_rec.budget_measurement_type,hr_api.g_varchar2) <>
          nvl(p_budget_measurement_type, hr_api.g_varchar2))
        or
  (NOT l_api_updating)) then
--
    if (p_budget_measurement_type is not null)
    then
      l_api_updating := hr_api.not_exists_in_hr_lookups(p_effective_date
                                           ,'BUDGET_MEASUREMENT_TYPE'
                                           ,p_budget_measurement_type);
      hr_utility.set_location(l_proc,30);
      if (l_api_updating = true)
      then
        fnd_message.set_name('PER','PER_289445_VAC_INV_BUD_MST_TYP');
        fnd_message.raise_error;
      end if;
      hr_utility.set_location(l_proc,40);
    end if;
   end if;
--
hr_utility.set_location(' Leaving:'||l_proc,50);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.BUDGET_MEASUREMENT_TYPE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
End chk_budget_measurement_type;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_security_method>--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid security method
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_security_method
--   p_effective_date
-- Post Success:
--   Processing continues if security method is valid
--
-- Post Failure:
--   An application error is raised if budget measurement code is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_security_method
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_security_method in per_all_vacancies.security_method%TYPE
  ,p_effective_date in date
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_security_method';
  l_api_updating boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
--
  l_api_updating := per_vac_shd.api_updating
              (p_vacancy_id             => p_vacancy_id
               ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
               and
            nvl(per_vac_shd.g_old_rec.security_method,hr_api.g_varchar2) <>
            nvl(p_security_method, hr_api.g_varchar2))
          or
   (NOT l_api_updating)) then
--
    hr_utility.set_location(l_proc,30);
    if(p_security_method is not null)
    then
     l_api_updating := hr_api.not_exists_in_hr_lookups(p_effective_date
                                           ,'IRC_SECURITY_METHOD'
                                           ,p_security_method);
     hr_utility.set_location(l_proc,40);
     if (l_api_updating = true)
     then
       fnd_message.set_name('PER','PER_289446_VAC_INV_SEC_METHOD');
       fnd_message.raise_error;
     end if;
     hr_utility.set_location(l_proc,50);
   end if;
 end if;
hr_utility.set_location(' Leaving:'||l_proc,60);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.SECURITY_METHOD'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 70);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 80);
End chk_security_method;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_requisition_id>----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures requisition column exsits in per_requisitions table
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_requisition_id
--   p_date_from
--   p_business_group_id
-- Post Success:
--   Processing continues if requisition id exists
--
-- Post Failure:
--   An application error is raised if requisition id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_requisition_id
  (p_requisition_id in per_all_vacancies.requisition_id%TYPE
  ,p_date_from      in per_all_vacancies.date_from%TYPE
  ,p_business_group_id in per_all_vacancies.business_group_id%TYPE
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_requisition_id';
  l_date_from per_all_vacancies.date_from%TYPE;
  l_date_to per_all_vacancies.date_to%TYPE;
  cursor csr_requisition is
         select date_from,date_to
         from  per_requisitions
         where  requisition_id = p_requisition_id
           and  business_group_id = p_business_group_id;
--
Begin
--
   hr_utility.set_location('Entering:'||l_proc,10);
   open csr_requisition;
   fetch csr_requisition into l_date_from,l_date_to;
   if (csr_requisition%NOTFOUND) then
        close csr_requisition;
        fnd_message.set_name('PER','PER_289447_VAC_INV_REQ_ID');
        hr_multi_message.add
         (p_associated_column1      => 'PER_ALL_VACANCIES.REQUISITION_ID'
         );
   else
        close csr_requisition;
        hr_utility.set_location(l_proc,20);
        if(p_date_from not between l_date_from and nvl(l_date_to,hr_api.g_eot)) then
           fnd_message.set_name('PER','PER_289448_VAC_REQ_ID_INV_DATE');
           hr_multi_message.add
             (p_associated_column1      => 'PER_ALL_VACANCIES.REQUISITION_ID'
             ,p_associated_column2      => 'PER_ALL_VACANCIES.DATE_FROM'
             ,p_associated_column3      => 'PER_ALL_VACANCIES.DATE_TO'
             );
        end if;
   end if;
    --
   hr_utility.set_location(' Leaving:'||l_proc,30);
   End chk_requisition_id;
--
--  ---------------------------------------------------------------------------
--  |------------------------< chk_position_id >------------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_position_id
  (p_vacancy_id            in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_position_id           in per_all_vacancies.position_id%TYPE
  ,p_business_group_id     in per_all_vacancies.business_group_id%TYPE
  ,p_effective_date        in date
  )
is
  --
  l_proc             varchar2(72)  :=  g_package||'chk_position_id';
  l_exists           varchar2(1);
  l_api_updating     boolean;
  l_position_id      per_all_vacancies.position_id%TYPE;
  l_pos_bus_group_id per_all_vacancies.business_group_id%TYPE;
  --
  cursor csr_valid_pos is
    select   hp.business_group_id
    from     hr_all_positions_f hp
           , per_shared_types ps
    where    hp.position_id    = p_position_id
    and      p_effective_date
    between  hp.effective_start_date
    and      hp.effective_end_date
    and      p_effective_date
    between  hp.date_effective
    and      nvl(hp.date_end, hr_api.g_eot)
    and      ps.shared_type_id = hp.availability_status_id
    and      ps.system_type_cd = 'ACTIVE' ;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position_id has changed
  --
  l_api_updating := per_vac_shd.api_updating
        (p_vacancy_id             => p_vacancy_id
         ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
         and
       nvl(per_vac_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
    or
       (NOT l_api_updating)) then
    hr_utility.set_location(l_proc, 30);
    --
    -- Check that if the value for position_id is not null
    -- then it exists date effective in HR_POSITIONS
    --
    if p_position_id is not null then
      --
      -- Check if the position_id exists date effectively
      --
      open csr_valid_pos;
      fetch csr_valid_pos into l_pos_bus_group_id;
      if csr_valid_pos%notfound then
        close csr_valid_pos;
        fnd_message.set_name('PER','PER_289449_VAC_INV_POS_ID');
        fnd_message.raise_error;
      end if;
      close csr_valid_pos;
      hr_utility.set_location(l_proc, 40);
      --
      -- Check if the business_group_id for the assignment matches
      -- the business_group_id in HR_POSITIONS date effectively.
      --
      if l_pos_bus_group_id <> p_business_group_id then
        --
        fnd_message.set_name('PAY', 'HR_51009_ASG_INVALID_BG_POS');
        fnd_message.raise_error;
        --
      end if;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving'||l_proc, 80);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.POSITION_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 40);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 50);
end chk_position_id;
------------------------------------------------------------------------------
-------------------< chk_position_id_grade_id >-------------------------------
------------------------------------------------------------------------------
--
procedure chk_position_id_grade_id
  (p_vacancy_id           in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_position_id           in per_all_vacancies.position_id%TYPE
  ,p_grade_id              in per_all_vacancies.grade_id%TYPE
  ,p_effective_date        in date
  ,p_inv_pos_grade_warning out nocopy boolean
  )
as
  l_proc             varchar2(72)  :=  g_package||'chk_position_id_grade_id';
  l_exists           varchar2(1);
  l_api_updating     boolean;
  l_inv_pos_grade_warning    boolean := false;
  --
  cursor csr_valid_pos_val_grd is
    select   null
    from     per_valid_grades
    where    position_id = p_position_id
    and      grade_id = p_grade_id
    and      p_effective_date
    between  date_from
    and      nvl(date_to, hr_api.g_eot);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  if hr_multi_message.no_exclusive_error
         (p_check_column1      => 'PER_ALL_VACANCIES.POSITION_ID'
         ,p_check_column2      => 'PER_ALL_VACANCIES.GRADE_ID'
         ,p_check_column3      => 'PER_ALL_VACANCIES.DATE_FROM'
         ) then
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position_id or grade_id has changed
  --
  l_api_updating := per_vac_shd.api_updating
        (p_vacancy_id            => p_vacancy_id
        ,p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and
       ((nvl(per_vac_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
         or
       (nvl(per_vac_shd.g_old_rec.grade_id, hr_api.g_number) <>
       nvl(p_grade_id, hr_api.g_number))
      ))
    or
       (NOT l_api_updating) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check that position_id and grade_id both contain not null values
    --
    if p_position_id is not null and p_grade_id is not null then
      --
      -- Check if the position_id and grade_id exist date effectively
      --
      open csr_valid_pos_val_grd;
      fetch csr_valid_pos_val_grd into l_exists;
      if csr_valid_pos_val_grd%notfound then
        l_inv_pos_grade_warning := true;
      end if;
      close csr_valid_pos_val_grd;
      hr_utility.set_location(l_proc, 3);
      --
    end if;
    --
  end if;
  --
  p_inv_pos_grade_warning := l_inv_pos_grade_warning;
  end if;
  hr_utility.set_location('Leaving'||l_proc, 4);

end chk_position_id_grade_id;
--
-- ----------------------------------------------------------------------------
-- ------------------------< chk_position_id_org_id >--------------------------
-- ----------------------------------------------------------------------------
--
procedure chk_position_id_org_id
   (p_vacancy_id            in per_all_vacancies.vacancy_id%TYPE
   ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
   ,p_position_id           in per_all_vacancies.position_id%TYPE
   ,p_organization_id       in per_all_vacancies.organization_id%TYPE
   ,p_effective_date        in date
   )
  as
    l_proc             varchar2(72)  :=  g_package||'chk_position_id_org_id';
    l_exists           varchar2(1);
    l_api_updating     boolean;
--
--

  cursor csr_valid_pos_org_comb is
    select   null
    from     hr_all_positions_f hp
    where    hp.position_id     = p_position_id
    and      p_effective_date
    between  hp.effective_start_date
    and      hp.effective_end_date
    and      hp.organization_id = p_organization_id;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 1);
  if hr_multi_message.no_exclusive_error
         (p_check_column1      => 'PER_ALL_VACANCIES.POSITION_ID'
         ,p_check_column2      => 'PER_ALL_VACANCIES.ORGANIZATION_ID'
         ,p_check_column3      => 'PER_ALL_VACANCIES.DATE_FROM'
         ) then
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position_id or grade_id has changed
  --
  l_api_updating := per_vac_shd.api_updating
         (p_vacancy_id            => p_vacancy_id
         ,p_object_version_number => p_object_version_number);
  --
  if (l_api_updating and
       ((nvl(per_vac_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
         or
       (nvl(per_vac_shd.g_old_rec.organization_id, hr_api.g_number) <>
       nvl(p_organization_id, hr_api.g_number))
      ))
    or
       (NOT l_api_updating) then
    --
    hr_utility.set_location(l_proc, 2);
    --
    -- Check if the position is null
    --
    If p_position_id is not null then
      --
      -- Check if assignment position_id and organization_id combination
      -- matches the combination in HR_POSITIONS.
      --
      hr_utility.set_location(l_proc, 3);
      open csr_valid_pos_org_comb;
      fetch csr_valid_pos_org_comb into l_exists;
      if csr_valid_pos_org_comb%notfound then
        close csr_valid_pos_org_comb;
        fnd_message.set_name('PAY', 'HR_51055_ASG_INV_POS_ORG_COMB');
        fnd_message.raise_error;
      end if;
      close csr_valid_pos_org_comb;
      --
    end if;
  end if;
  --
  end if;
  hr_utility.set_location('Leaving'||l_proc, 4);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.POSITION_ID'
         ,p_associated_column2      => 'PER_ALL_VACANCIES.ORGANIZATION_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_position_id_org_id;
--
------------------------------------------------------------------------------
-------------------------< chk_position_id_job_id >---------------------------
------------------------------------------------------------------------------
--
procedure chk_position_id_job_id
  (p_vacancy_id            in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_position_id           in per_all_vacancies.position_id%TYPE
  ,p_job_id                in per_all_vacancies.job_id%TYPE
  ,p_effective_date        in date
  )
  as
    l_proc             varchar2(72)  :=  g_package||'chk_position_id_job_id';
    l_exists           varchar2(1);
    l_api_updating     boolean;
  --
  --
  cursor csr_valid_pos_job_comb is
    select   null
    from     hr_all_positions_f hp
    where    hp.position_id = p_position_id
    and      p_effective_date
    between  hp.effective_start_date
    and      hp.effective_end_date
    and      hp.job_id = p_job_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if hr_multi_message.no_exclusive_error
         (p_check_column1      => 'PER_ALL_VACANCIES.POSITION_ID'
         ,p_check_column2      => 'PER_ALL_VACANCIES.JOB_ID'
         ,p_check_column3      => 'PER_ALL_VACANCIES.DATE_FROM'
         ) then
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for position or job has changed
  --
  l_api_updating := per_vac_shd.api_updating
         (p_vacancy_id            => p_vacancy_id
         ,p_object_version_number => p_object_version_number);
  hr_utility.set_location(l_proc, 30);
  --
  if (l_api_updating and
       ((nvl(per_vac_shd.g_old_rec.position_id, hr_api.g_number) <>
       nvl(p_position_id, hr_api.g_number))
         or
       (nvl(per_vac_shd.g_old_rec.job_id, hr_api.g_number) <>
       nvl(p_job_id, hr_api.g_number))
    ))
    or
       (NOT l_api_updating)
    then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check if the assignment job and position are not null
    --
    if p_position_id is not null and p_job_id is not null then
      --
      -- Check if assignment position and job combination matches
      -- the combination in HR_POSITIONS
      --
      open csr_valid_pos_job_comb;
      fetch csr_valid_pos_job_comb into l_exists;
      if csr_valid_pos_job_comb%notfound then
        close csr_valid_pos_job_comb;
        fnd_message.set_name('PAY', 'HR_51056_ASG_INV_POS_JOB_COMB');
        fnd_message.raise_error;
      end if;
      close csr_valid_pos_job_comb;
      --
    elsif p_job_id is null and p_position_id is not null then
      --
      -- Position is not null but job is null
      --
      fnd_message.set_name('PAY', 'HR_51057_ASG_JOB_NULL_VALUE');
      fnd_message.raise_error;
      --
    end if;
    --
  end if;
  end if;
  --
  hr_utility.set_location('Leaving'||l_proc, 3);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.POSITION_ID'
         ,p_associated_column2      => 'PER_ALL_VACANCIES.JOB_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_position_id_job_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_job_id>-----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Job Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_job_id
--   p_effective_date
--   p_business_group_id
-- Post Success:
--   Processing continues if Job id is valid

--
-- Post Failure:
--   An application error is raised if Job id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_job_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_job_id in per_all_vacancies.job_id%TYPE
  ,p_effective_date in date
  ,p_business_group_id in per_all_vacancies.business_group_id%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_job_id';
  l_api_updating boolean;
  l_date_from per_all_vacancies.date_from%TYPE;
  l_date_to per_all_vacancies.date_to%TYPE;
  cursor csr_job is
        select date_from,date_to
          from per_jobs
         where job_id = p_job_id
           and business_group_id = p_business_group_id;
--
Begin
--
   hr_utility.set_location('Entering:'||l_proc,10);
--
  l_api_updating := per_vac_shd.api_updating
              (p_vacancy_id             => p_vacancy_id
               ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
 if ((l_api_updating
               and
            nvl(per_vac_shd.g_old_rec.job_id,hr_api.g_number) <>
            nvl(p_job_id, hr_api.g_number))
          or
   (NOT l_api_updating)) then
--
   if (p_job_id is not null) then
     open csr_job;
     fetch csr_job into l_date_from,l_date_to;
     hr_utility.set_location(l_proc,30);
     if (csr_job%notfound) then
       close csr_job;
       fnd_message.set_name('PER','PER_289451_VAC_INV_JOB_ID');
       hr_multi_message.add
         (p_associated_column1      => 'PER_ALL_VACANCIES.JOB_ID'
         );
     else
       close csr_job;
       hr_utility.set_location(l_proc,40);
       if (p_effective_date not between l_date_from and nvl(l_date_to,hr_api.g_eot))
       then
         fnd_message.set_name('PER','PER_289452_VAC_JOB_ID_INV_DATE');
         hr_multi_message.add
           (p_associated_column1      => 'PER_ALL_VACANCIES.JOB_ID'
           ,p_associated_column2      => 'PER_ALL_VACANCIES.DATE_FROM'
           );
       end if;
     end if;
   end if;
 end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_job_id;
--
--  ---------------------------------------------------------------------------
--  |----------------------< chk_job_id_grade_id >----------------------------|
--  ---------------------------------------------------------------------------
--
procedure chk_job_id_grade_id
  (p_vacancy_id             in     per_all_vacancies.vacancy_id%TYPE
  ,p_job_id                 in     per_all_vacancies.job_id%TYPE
  ,p_grade_id               in     per_all_vacancies.grade_id%TYPE
  ,p_effective_date         in     date
  ,p_object_version_number  in     per_all_assignments_f.object_version_number%TYPE
  ,p_inv_job_grade_warning     out nocopy boolean
  )
  is
  --
   l_proc                   varchar2(72)  :=  g_package||'chk_job_id_grade_id';
   l_api_updating           boolean;
   l_exists                 varchar2(1);
   l_inv_job_grade_warning  boolean := false;
  --
  cursor csr_val_job_grade is
    select   null
    from     per_valid_grades
    where    job_id = p_job_id
    and      grade_id = p_grade_id
    and      p_effective_date
      between  date_from
      and      nvl(date_to, hr_api.g_eot);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  if hr_multi_message.no_exclusive_error
         (p_check_column1      => 'PER_ALL_VACANCIES.JOB_ID'
         ,p_check_column2      => 'PER_ALL_VACANCIES.GRADE_ID'
         ) then
  --
  --  Check if the vacancy is being updated.
  --
  l_api_updating := per_vac_shd.api_updating
        (p_vacancy_id             => p_vacancy_id
        ,p_object_version_number  => p_object_version_number
        );
  hr_utility.set_location(l_proc, 30);
  --
  -- Only proceed with validation if :
  -- a) The current g_old_rec is current and
  -- b) The value for job or grade has changed.
  --
  if (l_api_updating
    and
      ((nvl(per_vac_shd.g_old_rec.job_id, hr_api.g_number)
      <> nvl(p_job_id, hr_api.g_number))
      or
      (nvl(per_vac_shd.g_old_rec.grade_id, hr_api.g_number)
      <> nvl(p_grade_id, hr_api.g_number))))
    or
      NOT l_api_updating then
    hr_utility.set_location(l_proc, 40);
    --
    -- Check that both job and grade are set.
    --
    if p_job_id is not null and p_grade_id is not null then
      --
      -- Check if the job and grade exists date effectively in
      -- PER_VALID_GRADES.
      --
      open csr_val_job_grade;
      fetch csr_val_job_grade into l_exists;
      if csr_val_job_grade%notfound then
        p_inv_job_grade_warning := true;
      end if;
      close csr_val_job_grade;
      hr_utility.set_location(l_proc, 50);
      --
    end if;
    hr_utility.set_location(l_proc, 60);
    --
  end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 70);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.JOB_ID'
         ,p_associated_column2      => 'PER_ALL_VACANCIES.GRADE_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
end chk_job_id_grade_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------<chk_grade_id>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid grade Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_business_group_id
--   p_grade_id
--   p_effective_date
-- Post Success:
--   Processing continues if Grade id is valid
--
-- Post Failure:
--   An application error is raised if Grade id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_grade_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_grade_id in per_all_vacancies.grade_id%TYPE
  ,p_effective_date in date
  ,p_business_group_id in per_all_vacancies.business_group_id%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_grade_id';
  l_api_updating boolean;
  l_date_from per_all_vacancies.date_from%TYPE;
  l_date_to per_all_vacancies.date_to%TYPE;
  cursor csr_grade is
        select date_from,date_to
          from per_grades
         where grade_id = p_grade_id
           and business_group_id = p_business_group_id;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
  l_api_updating := per_vac_shd.api_updating
              (p_vacancy_id             => p_vacancy_id
               ,p_object_version_number => p_object_version_number);
  --
 hr_utility.set_location(l_proc,20);
 if ((l_api_updating
               and
            nvl(per_vac_shd.g_old_rec.grade_id,hr_api.g_number) <>
            nvl(p_grade_id, hr_api.g_number))
          or
   (NOT l_api_updating)) then
-- --
   hr_utility.set_location(l_proc,30);
   if (p_grade_id is not null)
   then
     open csr_grade;
     fetch csr_grade into l_date_from,l_date_to;
     hr_utility.set_location(l_proc,40);
     if (csr_grade%notfound)
     then
       close csr_grade;
       fnd_message.set_name('PER','PER_289453_VAC_INV_GRD_ID');
        hr_multi_message.add
         (p_associated_column1     => 'PER_ALL_VACANCIES.GRADE_ID'
         );
     else
       close csr_grade;
       hr_utility.set_location(l_proc,50);
       if (p_effective_date not between l_date_from and nvl(l_date_to,hr_api.g_eot))
       then
         fnd_message.set_name('PER','PER_289454_VAC_GRD_ID_INV_DATE');
         hr_multi_message.add
           (p_associated_column1      => 'PER_ALL_VACANCIES.GRADE_ID'
           ,p_associated_column2      => 'PER_ALL_VACANCIES.DATE_FROM'
           );
       end if;
     end if;
   end if;
 end if;
--
  hr_utility.set_location(' Leaving:'||l_proc,60);
End chk_grade_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_organization_id>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Organization Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_organization_id
--   p_effective_date
--   p_business_group_id
-- Post Success:
--   Processing continues if Organization id is valid
--
-- Post Failure:
--   An application error is raised if Organization id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_organization_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_organization_id in per_all_vacancies.organization_id%TYPE
  ,p_effective_date in date
  ,p_business_group_id in per_all_vacancies.business_group_id%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_organization_id';
  l_api_updating boolean;
  l_date_from per_all_vacancies.date_from%TYPE;
  l_date_to per_all_vacancies.date_to%TYPE;
  cursor csr_organization is
        select date_from,date_to
          from hr_all_organization_units
         where organization_id = p_organization_id
           and business_group_id = p_business_group_id;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
 --
   l_api_updating := per_vac_shd.api_updating
                (p_vacancy_id             => p_vacancy_id
                 ,p_object_version_number => p_object_version_number);
    --
   hr_utility.set_location(l_proc,20);
   if ((l_api_updating
                 and
              nvl(per_vac_shd.g_old_rec.organization_id,hr_api.g_number) <>
              nvl(p_organization_id, hr_api.g_number))
            or
   (NOT l_api_updating)) then
 --
     if (p_organization_id is not null)
     then
       open csr_organization;
       fetch csr_organization into l_date_from,l_date_to;
       hr_utility.set_location(l_proc,30);
       if (csr_organization%notfound)
       then
         close csr_organization;
         fnd_message.set_name('PER','PER_289455_VAC_INV_ORG_ID');
         hr_multi_message.add
           (p_associated_column1      => 'PER_ALL_VACANCIES.ORGANIZATION_ID'
           );
       else
         close csr_organization;
         hr_utility.set_location(l_proc,40);
         if (p_effective_date not between l_date_from and nvl(l_date_to,hr_api.g_eot))
         then
           fnd_message.set_name('PER','PER_289456_VAC_ORG_ID_INV_DATE');
           hr_multi_message.add
             (p_associated_column1      => 'PER_ALL_VACANCIES.ORGANIZATION_ID'
             ,p_associated_column2      => 'PER_ALL_VACANCIES.DATE_FROM'
             );
         end if;
       end if;
     end if;
   end if;
   hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_organization_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_people_group_id>---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid People Group Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_people_group_id
--   p_effective_date
--   p_vacancy_id
--   p_object_version_number
-- Post Success:
--   Processing continues if People group id is valid
--
-- Post Failure:
--   An application error is raised if People Group Id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_people_group_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_people_group_id in per_all_vacancies.people_group_id%TYPE
  ,p_effective_date in date
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_people_group_id';
  l_date_from date;
  l_date_to date;
  l_api_updating boolean;
  cursor csr_peoplegrp is
        select start_date_active,end_date_active
          from pay_people_groups
         where people_group_id = p_people_group_id;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
   l_api_updating := per_vac_shd.api_updating
                   (p_vacancy_id             => p_vacancy_id
                    ,p_object_version_number => p_object_version_number);
       --
      hr_utility.set_location(l_proc,20);
   if ((l_api_updating
                    and
                 nvl(per_vac_shd.g_old_rec.people_group_id,hr_api.g_number) <>
                 nvl(p_people_group_id, hr_api.g_number))
               or
     (NOT l_api_updating)) then
 --
     if(p_people_group_id is not null)
     then
       open csr_peoplegrp;
       fetch csr_peoplegrp into l_date_from,l_date_to;
--
       hr_utility.set_location(l_proc,20);
       if (csr_peoplegrp%notfound)
       then
         close csr_peoplegrp;
         fnd_message.set_name('PER','PER_289457_VAC_INV_GRP_ID');
         hr_multi_message.add
           (p_associated_column1      => 'PER_ALL_VACANCIES.PEOPLE_GROUP_ID'
           );
       else
         close csr_peoplegrp;
         hr_utility.set_location(l_proc,30);
         if (p_effective_date not between l_date_from and nvl(l_date_to,hr_api.g_eot))
         then
           fnd_message.set_name('PER','PER_289458_VAC_GRP_ID_INV_DATE');
           hr_multi_message.add
             (p_associated_column1      => 'PER_ALL_VACANCIES.PEOPLE_GROUP_ID'
             ,p_associated_column2      => 'PER_ALL_VACANCIES.DATE_FROM'
             );
         end if;
       end if;
     end if;
   end if;
     hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_people_group_id;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<chk_location_id>-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Location Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_location_id
-- Post Success:
--   Processing continues if Location id is valid
--
-- Post Failure:
--   An application error is raised if Location Id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_location_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_location_id in per_all_vacancies.location_id%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_location_id';
  l_location_id   varchar2(1);
  l_api_updating boolean;
  cursor csr_location is
        select null
          from hr_locations_all
         where location_id = p_location_id;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
   l_api_updating := per_vac_shd.api_updating
                      (p_vacancy_id             => p_vacancy_id
                       ,p_object_version_number => p_object_version_number);
          --
   hr_utility.set_location(l_proc,20);
   if ((l_api_updating
                       and
                    nvl(per_vac_shd.g_old_rec.location_id,hr_api.g_number) <>
                    nvl(p_location_id, hr_api.g_number))
                  or
   (NOT l_api_updating)) then
   --
     if (p_location_id is not null)
     then
       open csr_location;
       fetch csr_location into l_location_id;
       hr_utility.set_location(l_proc,30);
       if (csr_location%notfound)
       then
         close csr_location;
         fnd_message.set_name('PER','PER_289459_VAC_INV_LOCATION_ID');
         fnd_message.raise_error;
       end if;
       close csr_location;
     end if;
   end if;
  hr_utility.set_location(' Leaving:'||l_proc,40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.LOCATION_ID'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
End chk_location_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------<chk_recruiter_id>-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Recruiter Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_recruiter_id
--   p_effective_date
--   p_business_group_id
-- Post Success:
--   Processing continues if Recruiter id is valid
--
-- Post Failure:
--   An application error is raised if Recruiter Id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_recruiter_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_recruiter_id in per_all_vacancies.recruiter_id%TYPE
  ,p_effective_date in date
  ,p_business_group_id in per_all_vacancies.business_group_id%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_recruiter_id';
  l_recruiter_id varchar2(1);
  l_api_updating boolean;
--
  cursor csr_recruiter1 is
        select null
          from per_all_people_f
         where person_id = p_recruiter_id
           and (p_business_group_id = business_group_id
            or (p_business_group_id <> business_group_id
           and nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y'));

--
  cursor csr_recruiter2 is
        select null
          from per_all_people_f
         where person_id = p_recruiter_id
           and p_effective_date between effective_start_date and effective_end_date;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
   l_api_updating := per_vac_shd.api_updating
                         (p_vacancy_id             => p_vacancy_id
                          ,p_object_version_number => p_object_version_number);
             --
   hr_utility.set_location(l_proc,20);
   if ((l_api_updating
                        and
                     nvl(per_vac_shd.g_old_rec.recruiter_id,hr_api.g_number) <>
                     nvl(p_recruiter_id, hr_api.g_number))
                     or
   (NOT l_api_updating)) then
   --
     if (p_recruiter_id is not null)
     then
       open csr_recruiter1;
       fetch csr_recruiter1 into l_recruiter_id;
       hr_utility.set_location(l_proc,30);
       if (csr_recruiter1%notfound)
       then
         close csr_recruiter1;
         fnd_message.set_name('PER','PER_289460_VAC_INV_REC_ID');
         hr_multi_message.add
         (p_associated_column1      => 'PER_ALL_VACANCIES.RECRUITER_ID'
         );
       else
         close csr_recruiter1;
--
         open csr_recruiter2;
         fetch csr_recruiter2 into l_recruiter_id;
--
         hr_utility.set_location(l_proc,40);
         if (csr_recruiter2%notfound)
         then
           close csr_recruiter2;
           fnd_message.set_name('PER','PER_289461_VAC_REC_ID_INV_DATE');
           hr_multi_message.add
             (p_associated_column1      => 'PER_ALL_VACANCIES.RECRUITER_ID'
             );
         else
           close csr_recruiter2;
         end if;
       end if;
     end if;
   end if;
--
hr_utility.set_location(' Leaving:'||l_proc,50);
End chk_recruiter_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------<chk_number_of_openings>------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures positive number is entered for openings
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_num_open
-- Post Success:
--   Processing continues if openings is positive
--
-- Post Failure:
--   An application error is raised if openings is not positive
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_number_of_openings
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_num_open in per_all_vacancies.number_of_openings%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_number_of_openings';
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
   --
     hr_utility.set_location(l_proc,30);
     if (p_num_open <= 0)
     then
      fnd_message.set_name('PER','PER_289462_VAC_INV_NO_OF_OPEN');
      fnd_message.raise_error;
     end if;
--
hr_utility.set_location(' Leaving:'||l_proc,40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.NUMBER_OF_OPENINGS'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 50);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 60);
End chk_number_of_openings;
--
-- ----------------------------------------------------------------------------
-- |-----------------------<chk_budget_measurement_value>---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures positive number is entered for budget measurement value
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_bud_mea_val
-- Post Success:
--   Processing continues if budget measurement value is positive

--
-- Post Failure:
--   An application error is raised if budget measurement value is not positive
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_budget_measurement_value
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_bud_mea_val in per_all_vacancies.budget_measurement_value%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_budget_measurement_value';
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
                   --
   hr_utility.set_location(l_proc,20);
   --
     hr_utility.set_location(l_proc,20);
     if (p_bud_mea_val <= 0)
     then
       fnd_message.set_name('PER','PER_289462_VAC_INV_NO_OF_OPEN');
       fnd_message.raise_error;
     end if;
   hr_utility.set_location(' Leaving:'||l_proc,30);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
         (p_associated_column1      => 'PER_ALL_VACANCIES.BUDGET_MEASUREMENT_VALUE'
         ) then
      hr_utility.set_location(' Leaving:'|| l_proc, 60);
      raise;
    end if;
    hr_utility.set_location(' Leaving:'|| l_proc, 70);
End chk_budget_measurement_value;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_manager_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Manager Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_manager_id
--   p_effective_date
--   p_business_group_id
-- Post Success:
--   Processing continues if Manager id is valid
--
-- Post Failure:
--   An application error is raised if Manager Id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_manager_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_manager_id in per_all_vacancies.manager_id%TYPE
  ,p_effective_date in date
  ,p_business_group_id in per_all_vacancies.business_group_id%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_manager_id';
  l_manager_id varchar2(1);
  l_api_updating boolean;
--
  cursor csr_manager1 is
       select null
         from per_all_people_f
         where person_id = p_manager_id
           and(p_business_group_id = business_group_id
           or (p_business_group_id <> business_group_id
           and nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y'));
--
  cursor csr_manager2 is
        select null
          from per_all_people_f
         where person_id = p_manager_id
           and p_effective_date between effective_start_date and effective_end_date;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
  l_api_updating := per_vac_shd.api_updating
                    (p_vacancy_id            => p_vacancy_id
                    ,p_object_version_number => p_object_version_number);
                     --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
                 and
            nvl(per_vac_shd.g_old_rec.manager_id,hr_api.g_number) <>
            nvl(p_manager_id, hr_api.g_number))
                             or
  (NOT l_api_updating)) then
   --
    if (p_manager_id is not null)
    then
      open csr_manager1;
      fetch csr_manager1 into l_manager_id;
      hr_utility.set_location(l_proc,20);
      if (csr_manager1%notfound)
      then
        close csr_manager1;
        fnd_message.set_name('PER','PER_289464_VAC_INV_MGR_ID');
        hr_multi_message.add
           (p_associated_column1      => 'PER_ALL_VACANCIES.MANAGER_ID'
           );
      else
        close csr_manager1;
--
        open csr_manager2;
        fetch csr_manager2 into l_manager_id;
        hr_utility.set_location(l_proc,30);
        if (csr_manager2%notfound)
        then
          close csr_manager2;
          fnd_message.set_name('PER','PER_289465_VAC_MGR_ID_INV_DATE');
          hr_multi_message.add
             (p_associated_column1      => 'PER_ALL_VACANCIES.MANAGER_ID'
             );
        else
          close csr_manager2;
        end if;
      end if;
    end if;
  end if;
--
hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_manager_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_manager_assignment_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that manager is not an applicant while updating the vacancy
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_manager_id
--   p_effective_date
-- Post Success:
--   Processing continues if Manager id is valid
--
-- Post Failure:
--   An application error is raised if manager is an existing applicant for the same vacancy
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_manager_assignment_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_manager_id in per_all_vacancies.manager_id%TYPE
  ,p_effective_date in date
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_manager_assignment_id';
  l_exists varchar2(1);
  l_api_updating boolean;
--
  cursor csr_manager is
	select null
	from per_all_assignments_f paf,per_all_people_f ppf
	where paf.vacancy_id = p_vacancy_id
	and ppf.person_id = paf.person_id
	and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
	and ppf.party_id = (select ppf.party_id
	from per_all_people_f ppf
	where ppf.person_id = p_manager_id
	and p_effective_date between ppf.effective_start_date and ppf.effective_end_date);
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
  l_api_updating := per_vac_shd.api_updating
                    (p_vacancy_id            => p_vacancy_id
                    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(l_proc,20);
  if ((l_api_updating
                 and
            nvl(per_vac_shd.g_old_rec.manager_id,hr_api.g_number) <>
            nvl(p_manager_id, hr_api.g_number))
                             or
  (NOT l_api_updating)) then
   --
    if (p_manager_id is not null)
    then
      --
      -- Check that the manager is not existing applicant for the same vacancy.
      --
      open csr_manager;
      fetch csr_manager into l_exists;
      hr_utility.set_location(l_proc,30);
      if (csr_manager%found)
      then
	close csr_manager;
	fnd_message.set_name('PER','IRC_VAC_MGR_EQUAL_APPL');
	hr_multi_message.add
	 (p_associated_column1      => 'PER_ALL_VACANCIES.MANAGER_ID'
	  );
      else
	close csr_manager;
      end if;
    end if;
  end if;
--
hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_manager_assignment_id;

--
-- ----------------------------------------------------------------------------
-- |-------------------------<chk_primary_posting_id>-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Posting Content Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_primary_posting_id
--
-- Post Success:
--   Processing continues if Posting Content id is valid
--
-- Post Failure:
--   An application error is raised if Posting Content id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_primary_posting_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_primary_posting_id in per_all_vacancies. primary_posting_id %TYPE
  )
    IS
--
  l_proc    varchar2(72) := g_package || 'chk_primary_posting_id ';
  l_primary_posting varchar2(1);
  l_api_updating boolean;
--
  cursor csr_posting_contents is
        select null
          from irc_posting_contents
         where posting_content_id = p_primary_posting_id;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
   l_api_updating := per_vac_shd.api_updating
                     (p_vacancy_id            => p_vacancy_id
                     ,p_object_version_number => p_object_version_number);
   --
   hr_utility.set_location(l_proc,20);
   if ((l_api_updating
                       and
           nvl(per_vac_shd.g_old_rec.primary_posting_id,hr_api.g_number) <>
           nvl(p_primary_posting_id, hr_api.g_number))
                               or
   (NOT l_api_updating)) then
   --
     if (p_primary_posting_id is not null)
     then
       open csr_posting_contents;
       fetch csr_posting_contents into l_primary_posting;
       hr_utility.set_location(l_proc,30);
       if (csr_posting_contents%notfound)
       then
         close csr_posting_contents;
         fnd_message.set_name('PER','PER_449565_VAC_INV_POSTING_ID');
         hr_multi_message.add
             (p_associated_column1  => 'PER_ALL_VACANCIES.PRIMARY_POSTING_ID'
             );
       else
         close csr_posting_contents;
       end if;
     end if;
   end if;
--
hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_primary_posting_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------<chk_assessment_id>------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures a valid Assessment Id is entered
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_object_version_number
--   p_assessment_id
--
-- Post Success:
--   Processing continues if Assessment id is valid
--
-- Post Failure:
--   An application error is raised if Assessment id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_assessment_id
  (p_vacancy_id in per_all_vacancies.vacancy_id%TYPE
  ,p_object_version_number in per_all_vacancies.object_version_number%TYPE
  ,p_assessment_id in per_all_vacancies.assessment_id%TYPE
  )
    IS
--
  l_proc     varchar2(72) := g_package || 'chk_assessment_id ';
  l_assessment varchar2(1);
  l_api_updating boolean;
--
  cursor csr_assessments is
        select null
          from ota_learning_objects
         where data_source='OIR'
           and test_id = p_assessment_id;
--
Begin
   hr_utility.set_location('Entering:'||l_proc,10);
   --
   l_api_updating := per_vac_shd.api_updating
                     (p_vacancy_id            => p_vacancy_id
                     ,p_object_version_number => p_object_version_number);
   --
   hr_utility.set_location(l_proc,20);
   if ((l_api_updating
                  and
              nvl(per_vac_shd.g_old_rec.assessment_id,hr_api.g_number) <>
              nvl(p_assessment_id, hr_api.g_number))
                         or
   (NOT l_api_updating)) then
   --
     if (p_assessment_id is not null)
     then
       open csr_assessments;
       fetch csr_assessments into l_assessment;
       hr_utility.set_location(l_proc,30);
       if (csr_assessments%notfound)
       then
         close csr_assessments;
         fnd_message.set_name('PER','PER_449566_VAC_INV_ASSESS_ID');
         hr_multi_message.add
            (p_associated_column1  => 'PER_ALL_VACANCIES.ASSESSMENT_ID'
            );
       else
         close csr_assessments;
       end if;
     end if;
   end if;
--
hr_utility.set_location(' Leaving:'||l_proc,40);
End chk_assessment_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in         per_vac_shd.g_rec_type
  ,p_effective_date               in         date
  ,p_inv_pos_grade_warning        out nocopy boolean
  ,p_inv_job_grade_warning        out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
  l_inv_job_grade_warning boolean;
  l_inv_pos_grade_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_vac_shd.g_tab_name||'.BUSINESS_GROUP_ID');
  --
  hr_utility.set_location(l_proc, 10);
   --
  chk_vacancy_dates
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  );
  --
      hr_multi_message.end_validation_set();
  --
 hr_utility.set_location(l_proc, 20);
  --
  chk_name
  (p_name              => p_rec.name
  ,p_business_group_id => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_status
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_status                => p_rec.status
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_budget_measurement_type
  (p_vacancy_id              => p_rec.vacancy_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_budget_measurement_type => p_rec.budget_measurement_type
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 50);
  --
  chk_security_method
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_security_method       => p_rec.security_method
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 60);
  --
  chk_requisition_id
  (p_requisition_id        => p_rec.requisition_id
  ,p_date_from             => p_rec.date_from
  ,p_business_group_id     => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 70);
  --
  chk_organization_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_organization_id       => p_rec.organization_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 80);
  --
  chk_job_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_job_id                => p_rec.job_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 90);
  --
  chk_position_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 100);
  --
  chk_position_id_org_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_organization_id       => p_rec.organization_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 110);
  --
  chk_position_id_job_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_job_id                => p_rec.job_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 120);
  --
  chk_grade_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_grade_id              => p_rec.grade_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => p_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 130);
  --
  chk_position_id_grade_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_grade_id              => p_rec.grade_id
  ,p_effective_date        => p_effective_date
  ,p_inv_pos_grade_warning => l_inv_pos_grade_warning
  );
  --
  hr_utility.set_location(l_proc, 140);
  --
  per_vac_bus.chk_job_id_grade_id
  (p_vacancy_id             =>  p_rec.vacancy_id
  ,p_job_id                 =>  p_rec.job_id
  ,p_grade_id               =>  p_rec.grade_id
  ,p_effective_date        => p_effective_date
  ,p_object_version_number  =>  p_rec.object_version_number
  ,p_inv_job_grade_warning  =>  l_inv_job_grade_warning
  );
  --
  hr_utility.set_location(l_proc, 150);
  --
  chk_people_group_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_people_group_id       => p_rec.people_group_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 160);
  --
  chk_location_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_location_id           => p_rec.location_id
  );
  --
  hr_utility.set_location(l_proc, 170);
  --
  chk_recruiter_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_recruiter_id          => p_rec.recruiter_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 180);
  --
  chk_number_of_openings
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_num_open              => p_rec.number_of_openings
  );
  --
  hr_utility.set_location(l_proc, 190);
  --
 chk_budget_measurement_value
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_bud_mea_val           => p_rec.budget_measurement_value
  );
  --
  hr_utility.set_location(l_proc, 200);
  --
  chk_manager_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_manager_id            => p_rec.manager_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => p_rec.business_group_id
  );
  --
    hr_utility.set_location(l_proc, 210);
  --
  chk_primary_posting_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_primary_posting_id    => p_rec.primary_posting_id
  );
  --
    hr_utility.set_location(l_proc, 220);
  --
  chk_assessment_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_assessment_id         => p_rec.assessment_id
  );
  --
  -- ER#8530112 starts here
 per_vacancies_pkg.
 CHK_POS_BUDGET_VAL( p_rec.Position_Id,p_effective_date,p_rec.Organization_Id,p_rec.Number_Of_Openings,p_rec.Vacancy_Id);

-- ER#8530112 ends here
    hr_utility.set_location(l_proc, 230);
  --
  per_vac_bus.chk_df(p_rec);
  --
  hr_utility.set_location(l_proc, 240);
  --
  p_inv_job_grade_warning:=l_inv_job_grade_warning;
  p_inv_pos_grade_warning:=l_inv_pos_grade_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 250);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in            per_vac_shd.g_rec_type
  ,p_effective_date               in            date
  ,p_inv_pos_grade_warning           out nocopy boolean
  ,p_inv_job_grade_warning           out nocopy boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
  l_inv_job_grade_warning boolean;
  l_inv_pos_grade_warning boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  -- Call all supporting business operations
  --
  --
    hr_utility.set_location(l_proc, 190);
  --
  chk_non_updateable_args
  (p_rec              => p_rec
  );
  --
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id
  ,p_associated_column1 => per_vac_shd.g_tab_name||'.BUSINESS_GROUP_ID');
  --
    hr_utility.set_location(l_proc, 20);
  --
  chk_vacancy_dates
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_date_from             => p_rec.date_from
  ,p_date_to               => p_rec.date_to
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_status
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_status                => p_rec.status
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 40);
  --
  chk_budget_measurement_type
  (p_vacancy_id              => p_rec.vacancy_id
  ,p_object_version_number   => p_rec.object_version_number
  ,p_budget_measurement_type => p_rec.budget_measurement_type
  ,p_effective_date          => p_effective_date
  );
  --
    hr_utility.set_location(l_proc, 50);
  --
  chk_organization_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_organization_id       => p_rec.organization_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => per_vac_shd.g_old_rec.business_group_id
  );
  --
    hr_utility.set_location(l_proc, 60);
  --
  chk_job_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_job_id                => p_rec.job_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => per_vac_shd.g_old_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 70);
  --
  chk_position_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_business_group_id     => p_rec.business_group_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 80);
  --
  chk_position_id_org_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_organization_id       => p_rec.organization_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 90);
  --
  chk_position_id_job_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_job_id                => p_rec.job_id
  ,p_effective_date        => p_effective_date
  );
  --
  hr_utility.set_location(l_proc, 100);
  --
  chk_grade_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_grade_id              => p_rec.grade_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => per_vac_shd.g_old_rec.business_group_id
  );
  --
  hr_utility.set_location(l_proc, 110);
  --
  chk_position_id_grade_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_position_id           => p_rec.position_id
  ,p_grade_id              => p_rec.grade_id
  ,p_effective_date        => p_effective_date
  ,p_inv_pos_grade_warning => l_inv_pos_grade_warning
  );
  --
  hr_utility.set_location(l_proc, 120);
  --
  per_vac_bus.chk_job_id_grade_id
  (p_vacancy_id             =>  p_rec.vacancy_id
  ,p_job_id                 =>  p_rec.job_id
  ,p_grade_id               =>  p_rec.grade_id
  ,p_effective_date        => p_effective_date
  ,p_object_version_number  =>  p_rec.object_version_number
  ,p_inv_job_grade_warning  =>  l_inv_job_grade_warning
  );
  --
    hr_utility.set_location(l_proc, 130);
  --
  chk_people_group_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_people_group_id       => p_rec.people_group_id
  ,p_effective_date        => p_effective_date
  );
  --
    hr_utility.set_location(l_proc, 140);
  --
  chk_location_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_location_id           => p_rec.location_id
  );
  --
    hr_utility.set_location(l_proc, 150);
  --
  chk_recruiter_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_recruiter_id          => p_rec.recruiter_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => per_vac_shd.g_old_rec.business_group_id
  );
  --
    hr_utility.set_location(l_proc, 160);
  --
  chk_number_of_openings
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_num_open              => p_rec.number_of_openings
  );
  --
    hr_utility.set_location(l_proc, 170);
  --
  chk_budget_measurement_value
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_bud_mea_val           => p_rec.budget_measurement_value
  );
  --
    hr_utility.set_location(l_proc, 180);
  --
  chk_manager_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_manager_id            => p_rec.manager_id
  ,p_effective_date        => p_effective_date
  ,p_business_group_id     => per_vac_shd.g_old_rec.business_group_id
  );
  --
    hr_utility.set_location(l_proc, 190);
  --
  chk_manager_assignment_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_manager_id            => p_rec.manager_id
  ,p_effective_date        => p_effective_date
  );
  --
    hr_utility.set_location(l_proc, 200);
  --
  chk_primary_posting_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_primary_posting_id    => p_rec.primary_posting_id
  );
  --
    hr_utility.set_location(l_proc, 210);
  --
  chk_assessment_id
  (p_vacancy_id            => p_rec.vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  ,p_assessment_id         => p_rec.assessment_id
  );
  --
  -- ER#8530112 starts here
 per_vacancies_pkg.
 CHK_POS_BUDGET_VAL( p_rec.Position_Id,p_effective_date,p_rec.Organization_Id,p_rec.Number_Of_Openings,p_rec.Vacancy_Id);
-- ER#8530112 ends here
    hr_utility.set_location(l_proc, 220);
  --
  per_vac_bus.chk_df(p_rec);
  --
  p_inv_job_grade_warning:=l_inv_job_grade_warning;
  p_inv_pos_grade_warning:=l_inv_pos_grade_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 230);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_vac_shd.g_rec_type
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
end per_vac_bus;

/
