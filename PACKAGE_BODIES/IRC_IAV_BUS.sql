--------------------------------------------------------
--  DDL for Package Body IRC_IAV_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_IAV_BUS" as
/* $Header: iriavrhi.pkb 120.1 2005/12/22 21:07:08 gganesan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_iav_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_vacancy_id           number         default null;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_vacancy_id                    in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id,
           pbg.legislation_code
      from per_business_groups_perf pbg
         , per_all_vacancies pav
     where pav.vacancy_id = p_vacancy_id
       and pbg.business_group_id = pav.business_group_id;
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
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
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
        => nvl(p_associated_column1,'VACANCY_ID')
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
  (p_vacancy_id                    in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups_perf pbg
         , per_all_vacancies pav
     where pav.vacancy_id = p_vacancy_id
       and pbg.business_group_id = pav.business_group_id;
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
  if ( nvl(irc_iav_bus.g_vacancy_id, hr_api.g_number)
       = p_vacancy_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := irc_iav_bus.g_legislation_code;
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
    irc_iav_bus.g_vacancy_id           := p_vacancy_id;
    irc_iav_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in irc_iav_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.agency_vacancy_id is not null)  and (
    nvl(irc_iav_shd.g_old_rec.attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.attribute_category, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.attribute1, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.attribute2, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.attribute3, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.attribute4, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.attribute5, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.attribute6, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.attribute7, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.attribute8, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.attribute9, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.attribute10, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.attribute11, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.attribute12, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.attribute13, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.attribute14, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.attribute15, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.attribute16, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.attribute17, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.attribute18, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.attribute19, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.attribute20, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.attribute21, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.attribute22, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.attribute23, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.attribute24, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.attribute25, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.attribute26, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.attribute27, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.attribute28, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.attribute29, hr_api.g_varchar2)  or
    nvl(irc_iav_shd.g_old_rec.attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.attribute30, hr_api.g_varchar2) ))
    or (p_rec.agency_vacancy_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
/*    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'IRC'
      ,p_descflex_name                   => 'EDIT_HERE: Enter descflex name'
      ,p_attribute_category              => 'ATTRIBUTE_CATEGORY'
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
      ,p_attribute21_name                => 'ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.attribute21
      ,p_attribute22_name                => 'ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.attribute22
      ,p_attribute23_name                => 'ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.attribute23
      ,p_attribute24_name                => 'ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.attribute24
      ,p_attribute25_name                => 'ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.attribute25
      ,p_attribute26_name                => 'ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.attribute26
      ,p_attribute27_name                => 'ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.attribute27
      ,p_attribute28_name                => 'ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.attribute28
      ,p_attribute29_name                => 'ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.attribute29
      ,p_attribute30_name                => 'ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.attribute30
      ); */
      null;
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
  (p_rec in irc_iav_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT irc_iav_shd.api_updating
      (p_agency_vacancy_id                 => p_rec.agency_vacancy_id
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_agency_id >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Validates if the agency id exists in the PO_VENDORS table
--
-- Prerequisites:
--   Must be called as the first step in insert_validate.
--
-- In Arguments:
--   p_agency_id
--
-- Post Success:
--   If the agency_id is existing in PO_VENDORS (vendor_id)
--   then continue.
--
-- Post Failure:
--   If the agency_id is not present in PO_VENDORS (vendor_id)
--   then throw an error indicating the same.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- ----------------------------------------------------------------------------
Procedure chk_agency_id
  (p_agency_id
    in irc_agency_vacancies.agency_id%type
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_agency_id';
  l_agency_id irc_agency_vacancies.agency_id%type;
  cursor csr_agency_id is
    select 1
      from po_vendors
     where vendor_id = p_agency_id
       and vendor_type_lookup_code = 'IRC_JOB_AGENCY';
--
Begin
  --
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  open csr_agency_id;
  fetch csr_agency_id into l_agency_id;
  --
  hr_utility.set_location(l_proc,20);
  --
  if csr_agency_id%notfound then
    close csr_agency_id;
    fnd_message.set_name('PER','IRC_BAD_AGENCY_ID');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,30);
  --
  close csr_agency_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  --
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1 => 'IRC_AGENCY_VACANCIES.AGENCY_ID'
      ) then
      --
      hr_utility.set_location(' Leaving:'||l_proc,60);
      --
      raise;
    end if;
    --
    hr_utility.set_location(' Leaving:'||l_proc,70);
    --
End chk_agency_id;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_vacancy_id >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if the vacancy_id exists in per_all_vacancies
--
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_start_date.
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified vacancy id exists.
--
-- Post Failure:
--   An application error is raised if the vacancy id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_vacancy_id
  (p_vacancy_id in irc_agency_vacancies.vacancy_id%type
  ,p_start_date in irc_agency_vacancies.start_date%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_vacancy_id';
  l_vacancy_id  irc_agency_vacancies.vacancy_id%type;
--
--
--   Cursor to check that the vacancy_id exists in PER_ALL_VACANCIES
--   and is current at the p_start_date.
--
cursor csr_vacancy_id is
  select vacancy_id
    from per_all_vacancies
  where vacancy_id = p_vacancy_id
  and p_start_date between date_from and nvl(date_to,hr_api.g_eot);
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
    );
  --
  -- Check if the vacancy_id exists in PER_ALL_VACANCIES
  -- and is current at the p_start_date.
  --
  open csr_vacancy_id;
  fetch csr_vacancy_id into l_vacancy_id;
  hr_utility.set_location(l_proc, 30);
  if csr_vacancy_id%notfound then
    close csr_vacancy_id;
    fnd_message.set_name('PER','IRC_IAV_INV_VACANCY_ID');
    fnd_message.raise_error;
  end if;
  close csr_vacancy_id;
  hr_utility.set_location(' Leaving:'||l_proc,35);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
           (p_associated_column1      => 'IRC_AGENCY_VACANCIES.VACANCY_ID'
           ) then
        hr_utility.set_location(' Leaving:'||l_proc, 40);
        raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,50);
--
End chk_vacancy_id;


-- ----------------------------------------------------------------------------
-- |-----------------------< chk_end_date >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that valid dates have been entered.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_start_date
--   p_end_date
--   p_object_version_number.
--
-- Post Success:
--   Processing continues if valid dates are entered.
--
-- Post Failure:
--   An application error is raised if valid dates are not entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_end_date
  (p_start_date in irc_agency_vacancies.start_date%type
  ,p_end_date in irc_agency_vacancies.end_date%type
  ,p_agency_vacancy_id in irc_agency_vacancies.agency_vacancy_id%type
  ,p_object_version_number in irc_agency_vacancies.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_end_date';
  l_api_updating boolean;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  if (p_start_date is not NULL or p_end_date is not NULL) then
  --
    l_api_updating := irc_iav_shd.api_updating(p_agency_vacancy_id
      ,p_object_version_number);
    --
    --  Check to see if start_date or end_date values have changed.
    --
    hr_utility.set_location(l_proc, 30);
    if ((l_api_updating
      and ((nvl(irc_iav_shd.g_old_rec.start_date,hr_api.g_sot)
            <> p_start_date)
      or (nvl(irc_iav_shd.g_old_rec.end_date,hr_api.g_eot) <> p_end_date)))
      or (NOT l_api_updating)) then
      --
      -- Check that the end date is not before the start date.
      --
      hr_utility.set_location(l_proc, 40);
      if(nvl(p_start_date,hr_api.g_sot) > nvl(p_end_date,hr_api.g_eot)) then
        fnd_message.set_name('PER','IRC_IAV_INV_ST_END_DATE');
        fnd_message.raise_error;
      end if;
      --
    end if;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
               (p_associated_column1      => 'IRC_AGENCY_VACANCIES.START_DATE'
               ,p_associated_column2      => 'IRC_AGENCY_VACANCIES.END_DATE'
               ) then
            hr_utility.set_location(' Leaving:'||l_proc, 50);
            raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
--
End chk_end_date;


--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_agency_vac_comb_id >--------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if the agency_id and vacancy_id combination is
--   unique .
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_vacancy_id
--   p_start_date.
--
-- Post Success:
--   Processing continues if the mandatory parameters have been set and the
--   specified vacancy id and vacancy id is unique.
--
-- Post Failure:
--   An application error is raised if the vacancy id does not exist.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_agency_vac_comb_id
  (p_agency_id in irc_agency_vacancies.agency_id%type
  ,p_vacancy_id in irc_agency_vacancies.vacancy_id%type
  ,p_agency_vacancy_id in irc_agency_vacancies.agency_vacancy_id%type
  ,p_object_version_number in irc_agency_vacancies.object_version_number%type
  ) IS
--
  l_proc  varchar2(72) := g_package || 'chk_agency_vacancy_combination_id';
  l_agency_vacancy_id  irc_agency_vacancies.agency_vacancy_id%type;
--
--
--
--
--
cursor csr_agency_vacancy_id is
  select agency_vacancy_id
    from irc_agency_vacancies
   where agency_id = p_agency_id
     and vacancy_id = p_vacancy_id;
--
cursor csr_agency_vacancy_upd is
  select agency_vacancy_id
    from irc_agency_vacancies
   where agency_id = p_agency_id
     and vacancy_id = p_vacancy_id
     and agency_vacancy_id <> p_agency_vacancy_id;
--
  l_api_updating boolean;

Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'agency_id'
    ,p_argument_value     => p_agency_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'vacancy_id'
    ,p_argument_value     => p_vacancy_id
    );
  --
  --
  --
  --
  --
  l_api_updating := irc_iav_shd.api_updating(p_agency_vacancy_id
      ,p_object_version_number);
  --
  if l_api_updating then
    open csr_agency_vacancy_upd ;
    fetch csr_agency_vacancy_upd into l_agency_vacancy_id;
    hr_utility.set_location(l_proc, 30);
    if csr_agency_vacancy_upd%found then
      close csr_agency_vacancy_upd ;
      fnd_message.set_name('PER','IRC_IAV_INV_AGENCY_VAC_COMB');
      fnd_message.raise_error;
    end if;
    close csr_agency_vacancy_upd ;
  else
    open csr_agency_vacancy_id;
    fetch csr_agency_vacancy_id into l_agency_vacancy_id;
    hr_utility.set_location(l_proc, 40);
    if csr_agency_vacancy_id%found then
      close csr_agency_vacancy_id;
      fnd_message.set_name('PER','IRC_IAV_INV_AGENCY_VAC_COMB');
      fnd_message.raise_error;
    end if;
    close csr_agency_vacancy_id;
  --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,50);
  --
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
           (p_associated_column1      => 'IRC_AGENCY_VACANCIES.AGENCY_ID'
           ,p_associated_column2      => 'IRC_AGENCY_VACANCIES.VACANCY_ID'
           ) then
        hr_utility.set_location(' Leaving:'||l_proc, 60);
        raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,70);
--
End chk_agency_vac_comb_id;


--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_manage_appl_allowed >---------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if 'manage_applicants_allowed' value is valid .
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_update_allowed
--
-- Post Success:
--   Processing continues if a valid 'manage_applicants_allowed' value is
--   entered.
--
-- Post Failure:
--   An application error is raised if a valid 'manage_applicants_allowed' value
--   is not entered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_manage_appl_allowed
  (p_manage_applicants_allowed  in
          irc_agency_vacancies.manage_applicants_allowed%type
  ,p_start_date in irc_agency_vacancies.start_date%type
  ,p_agency_vacancy_id in irc_agency_vacancies.agency_vacancy_id%type
  ,p_object_version_number in irc_agency_vacancies.object_version_number%type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_manage_appl_allowed';
  l_var      boolean;
  l_api_updating boolean;
--
Begin
--
  hr_utility.set_location(' Entering:'||l_proc,10);
  if (p_manage_applicants_allowed is not NULL) then
  --
    l_api_updating := irc_iav_shd.api_updating(p_agency_vacancy_id
      ,p_object_version_number);
    --
    --  Check to see if the update_allowed value has changed.
    --
    hr_utility.set_location(l_proc, 30);
    if ((l_api_updating
      and (irc_iav_shd.g_old_rec.manage_applicants_allowed <> p_manage_applicants_allowed))
      or (NOT l_api_updating)) then
      --
      -- Check that a valid 'Update Allowed' value is entered.
      --
      l_var := hr_api.not_exists_in_hr_lookups
               (p_start_date
               ,'YES_NO'
               ,p_manage_applicants_allowed
               );
      hr_utility.set_location(l_proc, 40);
      if (l_var = true) then
        fnd_message.set_name('PER','IRC_IAV_INV_MNG_APL_ALLOWED');
        fnd_message.raise_error;
      end if;
    end if;
    --
  end if;
  hr_utility.set_location(' Leaving:'||l_proc,45);
  exception
    when app_exception.application_exception then
      if hr_multi_message.exception_add
                 (p_associated_column1      => 'IRC_AGENCY_VACANCIES.MANAGE_APPLICANTS_ALLOWED'
                 ) then
              hr_utility.set_location(' Leaving:'||l_proc, 50);
              raise;
      end if;
  hr_utility.set_location(' Leaving:'||l_proc,60);
--
End chk_manage_appl_allowed;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_rec                          in irc_iav_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 10);
  irc_iav_bus.set_security_group_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_associated_column1 => irc_iav_shd.g_tab_nam||'.VACANCY_ID'
  );
  --
  -- Validate Dependent Attributes
  --
  --
  irc_iav_bus.chk_df(p_rec);
  --
  chk_agency_id
  (p_agency_id             => p_rec.agency_id
  );
  --
  chk_vacancy_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_start_date => p_rec.start_date
  );
 --
 chk_agency_vac_comb_id
  (p_agency_id  => p_rec.agency_id
  ,p_vacancy_id => p_rec.vacancy_id
  ,p_agency_vacancy_id => p_rec.agency_vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  );
 --
  chk_end_date
  (p_start_date            => p_rec.start_date
  ,p_end_date              => p_rec.end_date
  ,p_agency_vacancy_id     => p_rec.agency_vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  );
 --
 chk_manage_appl_allowed
  (p_manage_applicants_allowed  => p_rec.manage_applicants_allowed
  ,p_start_date                 => p_rec.start_date
  ,p_agency_vacancy_id          => p_rec.agency_vacancy_id
  ,p_object_version_number      => p_rec.object_version_number
  );
 --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in irc_iav_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_utility.set_location(l_proc, 10);
  irc_iav_bus.set_security_group_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_associated_column1 => irc_iav_shd.g_tab_nam||'.VACANCY_ID'
  );
  --
  -- Validate Dependent Attributes
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  --
  irc_iav_bus.chk_df(p_rec);
    --
  chk_agency_id
  (p_agency_id             => p_rec.agency_id
  );
  --
  chk_vacancy_id
  (p_vacancy_id => p_rec.vacancy_id
  ,p_start_date => p_rec.start_date
  );
  --
  chk_agency_vac_comb_id
  (p_agency_id  => p_rec.agency_id
  ,p_vacancy_id => p_rec.vacancy_id
  ,p_agency_vacancy_id => p_rec.agency_vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_end_date
  (p_start_date            => p_rec.start_date
  ,p_end_date              => p_rec.end_date
  ,p_agency_vacancy_id     => p_rec.agency_vacancy_id
  ,p_object_version_number => p_rec.object_version_number
  );
  --
  chk_manage_appl_allowed
  (p_manage_applicants_allowed  => p_rec.manage_applicants_allowed
  ,p_start_date                 => p_rec.start_date
  ,p_agency_vacancy_id          => p_rec.agency_vacancy_id
  ,p_object_version_number      => p_rec.object_version_number
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in irc_iav_shd.g_rec_type
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
end irc_iav_bus;

/
