--------------------------------------------------------
--  DDL for Package Body PER_PEM_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PEM_BUS" as
/* $Header: pepemrhi.pkb 120.1.12010000.3 2009/01/12 08:21:02 skura ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pem_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_previous_employer_id        number         default null;
--
-- -----------------------------------------------------------------------
-- |---------------------------< get_period_values >---------------------|
-- -----------------------------------------------------------------------
procedure get_period_values
          (p_start_date     in  per_previous_employers.start_date%type
          ,p_end_date       in  per_previous_employers.end_date%type
          ,p_period_years   out nocopy per_previous_employers.period_years%type
          ,p_period_months  out nocopy per_previous_employers.period_months%type
          ,p_period_days    out nocopy per_previous_employers.period_days%type
          ) is
  l_proc            varchar2(72) := g_package||'get_period_values';
  l_period_years    number; -- Don't change the datatype
  l_start_date      per_previous_employers.start_date%type;
  l_end_date        per_previous_employers.end_date%type;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Truncate all date datatypes
  l_start_date  := trunc(p_start_date);
  l_end_date    := trunc(p_end_date+1);
  --
  if l_start_date is not null and l_end_date is not null then
    hr_utility.set_location(l_proc, 10);
    l_period_years   := trunc(trunc(months_between(l_end_date,l_start_date))/12);
    if l_period_years between 0 and 99 then
      hr_utility.set_location(l_proc, 15);
      p_period_years := trunc(trunc(months_between(l_end_date
                                                  ,l_start_date))/12);
      hr_utility.set_location(l_proc, 20);
      p_period_months:= mod(trunc(months_between(l_end_date
                                                ,l_start_date)),12);
      hr_utility.set_location(l_proc, 25);
      --
      -- 3635308: Added the if - else condition.
      --
      -- 3635308 start here
      if (add_months(l_start_date,trunc(months_between(l_end_date,l_start_date)))
         <= l_end_date) then
         p_period_days  := trunc(l_end_date
                                 - add_months(l_start_date
                                              ,trunc(months_between(l_end_date
                                                                   ,l_start_date))));
       hr_utility.set_location(l_proc, 26);
      else
       p_period_days  := trunc(l_end_date
                                - add_months(l_start_date
                                             ,trunc(months_between(l_end_date
                                                                  ,l_start_date)-1)));
       p_period_months := p_period_months - 1;
        if p_period_months < 0 and p_period_years > 0 then
            p_period_months:=11;
            p_period_years:=p_period_years - 1;
        end if;

       hr_utility.set_location(l_proc, 28);
      end if;
      --
      -- 3635308  end here
      --
      hr_utility.set_location(l_proc, 30);
    else
        /*Error message changed for the bug 5686794*/
       hr_utility.set_location(l_proc, 35);
       fnd_message.set_name('PER','HR_289530_PEM_STRT_END_DATES');
       fnd_message.set_token('START_DATE',TO_CHAR(p_start_date,'DD-MON-YYYY'),true);
       fnd_message.set_token('END_DATE',TO_CHAR(p_end_date,'DD-MON-YYYY'),true);
       fnd_message.raise_error;

      /*hr_utility.set_location(l_proc, 35);
      fnd_message.set_name('PER','HR_289552_NOVALD_DATES_DIFF');
      fnd_message.raise_error;*/-- Error msg changed & Commented for bug 5686794

    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
end get_period_values;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_previous_employer_id                 in number
  ,p_associated_column1                   in varchar2 default null
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , per_previous_employers pem
     where pem.previous_employer_id = p_previous_employer_id
       and pbg.business_group_id = pem.business_group_id;
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
    ,p_argument           => 'previous_employer_id'
    ,p_argument_value     => p_previous_employer_id
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
       (p_associated_column1 => nvl(p_associated_column1,'PREVIOUS_EMPLOYER_ID')
       );
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
  (p_previous_employer_id                 in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , per_previous_employers pem
     where pem.previous_employer_id = p_previous_employer_id
       and pbg.business_group_id (+) = pem.business_group_id;
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
    ,p_argument           => 'previous_employer_id'
    ,p_argument_value     => p_previous_employer_id
    );
  --
  if ( nvl(per_pem_bus.g_previous_employer_id, hr_api.g_number)
       = p_previous_employer_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pem_bus.g_legislation_code;
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
    per_pem_bus.g_previous_employer_id        := p_previous_employer_id;
    per_pem_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_pem_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_employer_id is not null)  and (
    nvl(per_pem_shd.g_old_rec.pem_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information_category, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information1, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information2, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information3, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information4, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information5, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information6, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information7, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information8, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information9, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information10, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information11, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information12, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information13, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information14, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information15, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information16, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information17, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information18, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information19, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information20, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information21, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information21, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information22, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information22, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information23, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information23, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information24, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information24, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information25, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information25, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information26, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information26, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information27, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information27, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information28, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information28, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information29, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information29, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_information30, hr_api.g_varchar2) <>
    nvl(p_rec.pem_information30, hr_api.g_varchar2) ))
    or (p_rec.previous_employer_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Previous Employer Developer DF'
      ,p_attribute_category              => p_rec.pem_information_category
      ,p_attribute1_name                 => 'PEM_INFORMATION1'
      ,p_attribute1_value                => p_rec.pem_information1
      ,p_attribute2_name                 => 'PEM_INFORMATION2'
      ,p_attribute2_value                => p_rec.pem_information2
      ,p_attribute3_name                 => 'PEM_INFORMATION3'
      ,p_attribute3_value                => p_rec.pem_information3
      ,p_attribute4_name                 => 'PEM_INFORMATION4'
      ,p_attribute4_value                => p_rec.pem_information4
      ,p_attribute5_name                 => 'PEM_INFORMATION5'
      ,p_attribute5_value                => p_rec.pem_information5
      ,p_attribute6_name                 => 'PEM_INFORMATION6'
      ,p_attribute6_value                => p_rec.pem_information6
      ,p_attribute7_name                 => 'PEM_INFORMATION7'
      ,p_attribute7_value                => p_rec.pem_information7
      ,p_attribute8_name                 => 'PEM_INFORMATION8'
      ,p_attribute8_value                => p_rec.pem_information8
      ,p_attribute9_name                 => 'PEM_INFORMATION9'
      ,p_attribute9_value                => p_rec.pem_information9
      ,p_attribute10_name                => 'PEM_INFORMATION10'
      ,p_attribute10_value               => p_rec.pem_information10
      ,p_attribute11_name                => 'PEM_INFORMATION11'
      ,p_attribute11_value               => p_rec.pem_information11
      ,p_attribute12_name                => 'PEM_INFORMATION12'
      ,p_attribute12_value               => p_rec.pem_information12
      ,p_attribute13_name                => 'PEM_INFORMATION13'
      ,p_attribute13_value               => p_rec.pem_information13
      ,p_attribute14_name                => 'PEM_INFORMATION14'
      ,p_attribute14_value               => p_rec.pem_information14
      ,p_attribute15_name                => 'PEM_INFORMATION15'
      ,p_attribute15_value               => p_rec.pem_information15
      ,p_attribute16_name                => 'PEM_INFORMATION16'
      ,p_attribute16_value               => p_rec.pem_information16
      ,p_attribute17_name                => 'PEM_INFORMATION17'
      ,p_attribute17_value               => p_rec.pem_information17
      ,p_attribute18_name                => 'PEM_INFORMATION18'
      ,p_attribute18_value               => p_rec.pem_information18
      ,p_attribute19_name                => 'PEM_INFORMATION19'
      ,p_attribute19_value               => p_rec.pem_information19
      ,p_attribute20_name                => 'PEM_INFORMATION20'
      ,p_attribute20_value               => p_rec.pem_information20
      ,p_attribute21_name                => 'PEM_INFORMATION21'
      ,p_attribute21_value               => p_rec.pem_information21
      ,p_attribute22_name                => 'PEM_INFORMATION22'
      ,p_attribute22_value               => p_rec.pem_information22
      ,p_attribute23_name                => 'PEM_INFORMATION23'
      ,p_attribute23_value               => p_rec.pem_information23
      ,p_attribute24_name                => 'PEM_INFORMATION24'
      ,p_attribute24_value               => p_rec.pem_information24
      ,p_attribute25_name                => 'PEM_INFORMATION25'
      ,p_attribute25_value               => p_rec.pem_information25
      ,p_attribute26_name                => 'PEM_INFORMATION26'
      ,p_attribute26_value               => p_rec.pem_information26
      ,p_attribute27_name                => 'PEM_INFORMATION27'
      ,p_attribute27_value               => p_rec.pem_information27
      ,p_attribute28_name                => 'PEM_INFORMATION28'
      ,p_attribute28_value               => p_rec.pem_information28
      ,p_attribute29_name                => 'PEM_INFORMATION29'
      ,p_attribute29_value               => p_rec.pem_information29
      ,p_attribute30_name                => 'PEM_INFORMATION30'
      ,p_attribute30_value               => p_rec.pem_information30
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
  (p_rec in per_pem_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_employer_id is not null)  and (
    nvl(per_pem_shd.g_old_rec.pem_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute_category, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute1, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute2, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute3, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute4, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute5, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute6, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute7, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute8, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute9, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute10, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute11, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute12, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute13, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute14, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute15, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute16, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute17, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute18, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute19, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute20, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute21, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute22, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute23, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute24, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute25, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute26, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute27, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute28, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute29, hr_api.g_varchar2)  or
    nvl(per_pem_shd.g_old_rec.pem_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.pem_attribute30, hr_api.g_varchar2) ))
    or (p_rec.previous_employer_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PREVIOUS_EMPLOYERS'
      ,p_attribute_category              => p_rec.pem_attribute_category
      ,p_attribute1_name                 => 'PEM_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pem_attribute1
      ,p_attribute2_name                 => 'PEM_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pem_attribute2
      ,p_attribute3_name                 => 'PEM_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pem_attribute3
      ,p_attribute4_name                 => 'PEM_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pem_attribute4
      ,p_attribute5_name                 => 'PEM_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pem_attribute5
      ,p_attribute6_name                 => 'PEM_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pem_attribute6
      ,p_attribute7_name                 => 'PEM_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pem_attribute7
      ,p_attribute8_name                 => 'PEM_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pem_attribute8
      ,p_attribute9_name                 => 'PEM_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pem_attribute9
      ,p_attribute10_name                => 'PEM_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pem_attribute10
      ,p_attribute11_name                => 'PEM_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pem_attribute11
      ,p_attribute12_name                => 'PEM_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pem_attribute12
      ,p_attribute13_name                => 'PEM_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pem_attribute13
      ,p_attribute14_name                => 'PEM_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pem_attribute14
      ,p_attribute15_name                => 'PEM_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pem_attribute15
      ,p_attribute16_name                => 'PEM_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pem_attribute16
      ,p_attribute17_name                => 'PEM_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pem_attribute17
      ,p_attribute18_name                => 'PEM_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pem_attribute18
      ,p_attribute19_name                => 'PEM_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pem_attribute19
      ,p_attribute20_name                => 'PEM_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pem_attribute20
      ,p_attribute21_name                => 'PEM_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.pem_attribute21
      ,p_attribute22_name                => 'PEM_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.pem_attribute22
      ,p_attribute23_name                => 'PEM_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.pem_attribute23
      ,p_attribute24_name                => 'PEM_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.pem_attribute24
      ,p_attribute25_name                => 'PEM_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.pem_attribute25
      ,p_attribute26_name                => 'PEM_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.pem_attribute26
      ,p_attribute27_name                => 'PEM_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.pem_attribute27
      ,p_attribute28_name                => 'PEM_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.pem_attribute28
      ,p_attribute29_name                => 'PEM_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.pem_attribute29
      ,p_attribute30_name                => 'PEM_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.pem_attribute30
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
  ,p_rec                          in per_pem_shd.g_rec_type
  ) IS
  --
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  --
Begin
  hr_utility.set_location('Entering : '||l_proc,5);
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT per_pem_shd.api_updating
      (p_previous_employer_id                 => p_rec.previous_employer_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  -- Add checks to ensure non-updateable args have
  -- not been updated.
  hr_utility.set_location(l_proc,10);
  if per_pem_shd.g_old_rec.previous_employer_id <> p_rec.previous_employer_id
     then
     hr_api.argument_changed_error
       (p_api_name   => l_proc
       ,p_argument   => 'previous_employer_id'
       ,p_base_table => per_pem_shd.g_tab_nam
       );
  end if;
  --
  hr_utility.set_location(l_proc,15);
  if per_pem_shd.g_old_rec.person_id <> p_rec.person_id
     then
     hr_api.argument_changed_error
       (p_api_name    =>  l_proc
       ,p_argument    =>  'person_id'
       ,p_base_table  =>  per_pem_shd.g_tab_nam
       );
  end if;
  --
  hr_utility.set_location(l_proc,20);
  if nvl(per_pem_shd.g_old_rec.party_id,p_rec.party_id) <>
                 nvl(p_rec.party_id,per_pem_shd.g_old_rec.party_id)
     then
     hr_api.argument_changed_error
       (p_api_name    =>  l_proc
       ,p_argument    =>  'party_id'
       ,p_base_table  =>  per_pem_shd.g_tab_nam
       );
  end if;
  hr_utility.set_location(l_proc,25);
  --
  -- start commented code  for business_group_id is
  -- updateable if previously null.
  --
/*
  if per_pem_shd.g_old_rec.business_group_id <> p_rec.business_group_id
     then
     hr_api.argument_changed_error
       (p_api_name    =>  l_proc
       ,p_argument    =>  'business_group_id'
       ,p_base_table  =>  per_pem_shd.g_tab_nam
       );
  end if;
  --
*/
  --
  -- end commented code
  --
  hr_utility.set_location('Leaving : '||l_proc,30);
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_person_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that person_id value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_person_id
--  p_previous_employer_id
--  p_object_version_number
--  p_effective_date
--
-- Post Success:
--   Processing continues if person_id is valid employee
--
-- Post Failure:
--   An application error is raised person_id is not valid
--   or person is not an employee or if the person is not valid
--   for the current period.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_person_id(p_person_id
                        in  per_previous_employers.person_id%type
                       ,p_previous_employer_id
                        in  per_previous_employers.previous_employer_id%type
                       ,p_object_version_number
                        in  per_previous_employers.object_version_number%type
                       ,p_effective_date
                        in date)
      is
  -- Define the cursor for the person_id
  cursor csr_person_id is
    select  person_id
    from    per_all_people_f
    where   person_id = p_person_id;
  --
  cursor csr_effective_person_id is
    select  person_id
    from    per_all_people_f
    where   person_id = p_person_id
    and     p_effective_date
            between effective_start_date and effective_end_date;
  --
  --
  l_person_id     per_all_people_f.person_id%type;
  --
  l_proc          varchar2(72) := g_package||'chk_person_id';
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_person_id is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating    := per_pem_shd.api_updating(p_previous_employer_id
                                                  =>  p_previous_employer_id
                                                  ,p_object_version_number
                                                  =>  p_object_version_number
                                                  );
    if  ((l_api_updating
          and nvl(per_pem_shd.g_old_rec.person_id, hr_api.g_number)
              <> nvl(p_person_id,hr_api.g_number))
        or
        (not l_api_updating))
    then
      -- Check for invalid person_id
      hr_utility.set_location(l_proc, 15);
      open  csr_person_id;
      fetch csr_person_id into l_person_id;
      if csr_person_id%notfound then
        hr_utility.set_location(l_proc, 20);
        close csr_person_id;
        fnd_message.set_name('PER','HR_289535_PEM_VALID_PERSON_ID');
        fnd_message.raise_error;
      end if;
      if csr_person_id%isopen then
        close csr_person_id;
      end if;
      -- Check for person_id with effective dates
      hr_utility.set_location(l_proc, 25);
      open  csr_effective_person_id;
      fetch csr_effective_person_id into l_person_id;
      if csr_effective_person_id%notfound then
         hr_utility.set_location(l_proc, 30);
         close csr_effective_person_id;
         fnd_message.set_name('PER','HR_289547_PEM_DATE_PERSON_ID');
         fnd_message.raise_error;
      end if;
      if csr_effective_person_id%isopen then
        close csr_effective_person_id;
      end if;
    --
    end if;
  end if;
  hr_utility.set_location('Leaving:'||l_proc, 40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.PERSON_ID'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_person_id;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_party_id >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that party_id value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_party_id
--  p_previous_employer_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if party_id is valid.
--
-- Post Failure:
--   An application error is raised party_id is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_party_id(p_party_id
                      in  per_previous_employers.party_id%type
                      ,p_previous_employer_id
                      in  per_previous_employers.previous_employer_id%type
                      ,p_object_version_number
                      in  per_previous_employers.object_version_number%type) is
  --Define the cursor for party_id
  cursor csr_party_id is
    select  party_id
    from    hz_parties
    where   party_id = p_party_id;
  l_party_id  hz_parties.party_id%type;
  --
  l_proc          varchar2(72) := g_package||'chk_party_id';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_party_id is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating    := per_pem_shd.api_updating(p_previous_employer_id
                                                  =>  p_previous_employer_id
                                                  ,p_object_version_number
                                                  =>  p_object_version_number
                                                  );
    if  ((l_api_updating
          and nvl(per_pem_shd.g_old_rec.party_id, hr_api.g_number)
              <> nvl(p_party_id,hr_api.g_number))
        or
        (not l_api_updating))
    then
      hr_utility.set_location(l_proc, 15);
      open  csr_party_id;
      fetch csr_party_id into l_party_id;
      if  csr_party_id%notfound then
        hr_utility.set_location(l_proc, 20);
        close csr_party_id;
        fnd_message.set_name('PER','HR_289536_PEM_VALID_PARTY_ID');
        fnd_message.raise_error;
      end if;
      if  csr_party_id%isopen then
        close csr_party_id;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.PARTY_ID'
      ) then
      hr_utility.set_location('Leaving:'||l_proc,30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end chk_party_id;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_employer_country >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that employer_country has valid lookup
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_employer_id
--  p_object_version_number
--  p_employer_country
--
-- Post Success:
--   Processing continues if employer_country has valid value
--   in fnd_territories
--
-- Post Failure:
--   An application error is raised if employer country is not valid
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_employer_country
          (p_previous_employer_id
          in per_previous_employers.previous_employer_id%type
          ,p_object_version_number
          in per_previous_employers.object_version_number%type
          ,p_employer_country
          in per_previous_employers.employer_country%type) is
  cursor csr_employer_country is
    select  territory_code
    from    fnd_territories_vl
    where   territory_code = p_employer_country;
  l_employer_country  per_previous_employers.employer_country%type;
  --
  l_proc            varchar2(72) := g_package||'chk_employer_country';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_employer_country is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating    := per_pem_shd.api_updating(p_previous_employer_id
                                                  =>  p_previous_employer_id
                                                  ,p_object_version_number
                                                  =>  p_object_version_number
                                                  );
    if  ((l_api_updating
          and nvl(per_pem_shd.g_old_rec.employer_country, hr_api.g_varchar2)
              <> nvl(p_employer_country,hr_api.g_varchar2))
        or
        (not l_api_updating))
    then
      hr_utility.set_location(l_proc, 15);
      open  csr_employer_country;
      fetch csr_employer_country into l_employer_country;
      if  csr_employer_country%notfound then
        hr_utility.set_location(l_proc, 20);
        close csr_employer_country;
        fnd_message.set_name('PER','HR_289531_PEM_VALD_EMPR_CNTRY');
        fnd_message.raise_error;
      end if;
      if  csr_employer_country%isopen then
        close csr_employer_country;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.EMPLOYER_COUNTRY'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end chk_employer_country;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_employer_type >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that employer_type has valid lookup
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_employer_id
--  p_object_version_number
--  p_employer_type
--  p_effective_date
--
-- Post Success:
--   Processing continues if employer_type has valid lookup
--
-- Post Failure:
--   An application error is raised if employer_type has no valid lookup
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_employer_type
          (p_previous_employer_id
          in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
          in  per_previous_employers.object_version_number%type
          ,p_employer_type
          in  per_previous_employers.employer_type%type
          ,p_effective_date in  date) is
  l_proc              varchar2(72) := g_package||'chk_employer_type';
  l_no_lookup         boolean;
  l_effective_date    date := p_effective_date;
  l_lookup_type       fnd_lookups.lookup_type%type := 'PREV_EMP_TYPE';
  l_lookup_code       per_previous_employers.employer_type%type
                      := p_employer_type;
  l_api_updating      boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_employer_type is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating    := per_pem_shd.api_updating(p_previous_employer_id
                                                 =>  p_previous_employer_id
                                                 ,p_object_version_number
                                                 =>  p_object_version_number
                                                 );
    if ((l_api_updating and
               nvl(p_employer_type,hr_api.g_varchar2)
               <> nvl(per_pem_shd.g_old_rec.employer_type, hr_api.g_varchar2))
       or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 15);
      l_no_lookup := hr_api.not_exists_in_leg_lookups
                      (p_effective_date =>  l_effective_date
                      ,p_lookup_type    =>  l_lookup_type
                      ,p_lookup_code    =>  l_lookup_code
                      );
      if l_no_lookup = true then
        hr_utility.set_location(l_proc, 20);
        fnd_message.set_name('PER','HR_289532_PEM_VALID_EMPR_TYPE');
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.EMPLOYER_TYPE'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end chk_employer_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_employer_subtype >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that employer_subtype has valid lookup
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_employer_id
--  p_object_version_number
--  p_employer_type
--  p_employer_subtype
--  p_effective_date
--
-- Post Success:
--   Processing continues if employer_subtype has valid lookup
--
-- Post Failure:
--   An application error is raised if employer_subtype has no valid lookup
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_employer_subtype
          (p_previous_employer_id
          in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
          in  per_previous_employers.object_version_number%type
          ,p_employer_type
          in per_previous_employers.employer_type%type
          ,p_employer_subtype
          in  per_previous_employers.employer_subtype%type
          ,p_effective_date in  date) is
  --
  cursor csr_employer_subtype is
         select lookup_code
         from   hr_leg_lookups
         where  lookup_type = 'PREV_EMP_SUBTYPE'
         and    lookup_code like p_employer_type||'_%'
         and    lookup_code = p_employer_subtype;
  --
  l_proc            varchar2(72) := g_package||'chk_employer_subtype';
  l_no_lookup       boolean;
  l_effective_date  date := p_effective_date;
  l_lookup_type     fnd_lookups.lookup_type%type := 'PREV_EMP_SUBTYPE';
  l_lookup_code     fnd_lookups.lookup_code%type := p_employer_subtype;
  l_employer_subtype  hr_leg_lookups.lookup_code%type;
  --
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --Only proceed with employer_subtype validation when multiple message list
  --does not already contain an error associated with employer type column.
  --
  if hr_multi_message.no_exclusive_error
    (p_check_column1    => 'PER_PREVIOUS_EMPLOYERS.EMPLOYER_TYPE'
    ) then
    if p_employer_subtype is not null then
      hr_utility.set_location(l_proc, 10);
      l_api_updating := per_pem_shd.api_updating(p_previous_employer_id
                                              =>  p_previous_employer_id
                                              ,p_object_version_number
                                              =>  p_object_version_number
                                              );
      if ((l_api_updating and
                 nvl(p_employer_subtype,hr_api.g_varchar2)
                 <> nvl(per_pem_shd.g_old_rec.employer_subtype
                        , hr_api.g_varchar2))
       or
       (not l_api_updating)) then
        hr_utility.set_location(l_proc, 15);
        -- Check for standard lookup
        l_no_lookup :=  hr_api.not_exists_in_leg_lookups
                              (p_effective_date =>  l_effective_date
                              ,p_lookup_type    =>  l_lookup_type
                              ,p_lookup_code    =>  l_lookup_code
                              );
        if l_no_lookup = true then
          hr_utility.set_location(l_proc, 20);
          fnd_message.set_name('PER','HR_289533_PEM_VALID_EMPR_SBTP');
          fnd_message.raise_error;
        end if;
        -- Check for the dependency on employer type
        hr_utility.set_location(l_proc, 25);
        open csr_employer_subtype;
        fetch csr_employer_subtype into l_employer_subtype;
        if csr_employer_subtype%notfound then
          hr_utility.set_location(l_proc, 30);
          close csr_employer_subtype;
          fnd_message.set_name('PER','HR_289533_PEM_VALID_EMPR_SBTP');
          fnd_message.raise_error;
        end if;
        if csr_employer_subtype%isopen then
          close csr_employer_subtype;
        end if;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 35);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.EMPLOYER_TYPE'
      ,p_associated_column2  => 'PER_PREVIOUS_EMPLOYERS.EMPLOYER_SUBTYPE'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 40);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,50);
end chk_employer_subtype;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_start_end_dates >-------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that end_date is greater than start_date
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_employer_id
--  p_object_version_number
--  p_start_date
--  p_end_date
--
-- Post Success:
--   Processing continues if end_date is greater than start_date
--
-- Post Failure:
--   An application error is raised if start_date is greater than end_date
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_start_end_dates
          (p_previous_employer_id
          in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
          in  per_previous_employers.object_version_number%type
          ,p_start_date
          in  per_previous_employers.start_date%type
          ,p_end_date
          in  per_previous_employers.end_date%TYPE
	  ,p_effective_date
	  IN  per_previous_employers.start_date%type) is
l_proc            varchar2(72) := g_package||'chk_start_end_dates';
l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    -- This If condition added for bug 7112425

    IF p_start_date is not null  AND p_start_date > p_effective_date THEN
          fnd_message.set_name('PER','HR_INVAL_ST_DT_PEM');
          fnd_message.raise_error;
    END IF ;
  hr_utility.set_location('Entering:'||l_proc, 6);

  if p_start_date is not null and p_end_date is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pem_shd.api_updating(p_previous_employer_id
                                              =>  p_previous_employer_id
                                              ,p_object_version_number
                                              =>  p_object_version_number
                                              );
    if ((l_api_updating and
        ( nvl(p_start_date,hr_api.g_sot)
          <> nvl(per_pem_shd.g_old_rec.start_date, hr_api.g_sot)
             or
             nvl(p_end_date,hr_api.g_eot)
             <> nvl(per_pem_shd.g_old_rec.end_date, hr_api.g_eot)
        ))
        or
        (not l_api_updating)) then
          hr_utility.set_location(l_proc, 15);
          if p_start_date > p_end_date then
            hr_utility.set_location(l_proc, 20);
            fnd_message.set_name('PER','HR_289530_PEM_STRT_END_DATES');
            fnd_message.set_token('START_DATE',TO_CHAR(p_start_date,'DD-MON-YYYY'),true);
            fnd_message.set_token('END_DATE',TO_CHAR(p_end_date,'DD-MON-YYYY'),true);
            fnd_message.raise_error;
          end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
/*exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.START_DATE'
      ,p_associated_column2  => 'PER_PREVIOUS_EMPLOYERS.END_DATE'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);*/--commented for the bug 5686794
end chk_start_end_dates;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_years >----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_years is between 0 and 99
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_years
--  p_previous_employer_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 99
--
-- Post Failure:
--   An application error is raised if period_years value is not in range
--   of 0 and 99.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_years
          (p_period_years
           in  per_previous_employers.period_years%type
          ,p_previous_employer_id
           in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
           in  per_previous_employers.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_years';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_years is not null then
    l_api_updating := per_pem_shd.api_updating(p_previous_employer_id
                                              =>  p_previous_employer_id
                                              ,p_object_version_number
                                              =>  p_object_version_number);
    hr_utility.set_location(l_proc, 10);
    if ((l_api_updating and
        (   nvl(p_period_years,hr_api.g_number)
            <> nvl(per_pem_shd.g_old_rec.period_years, hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 15);
      if p_period_years not between 0 and 99 then
        hr_utility.set_location(l_proc, 20);
        fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
        fnd_message.set_token('RANGE_START','0',true);
        fnd_message.set_token('RANGE_END','99',true);
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.PERIOD_YEARS'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end chk_period_years;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_months >---------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_months is between 0 and 11
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_months
--  p_previous_employer_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_years is between 0 and 11
--
-- Post Failure:
--   An application error is raised if period_months value is not in range
--   of 0 and 11.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_months
          (p_period_months
           in  per_previous_employers.period_months%type
          ,p_previous_employer_id
           in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
           in  per_previous_employers.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_months';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_months is not null then
    l_api_updating := per_pem_shd.api_updating(p_previous_employer_id
                                              =>  p_previous_employer_id
                                              ,p_object_version_number
                                              =>  p_object_version_number);
    hr_utility.set_location(l_proc, 10);
    if ((l_api_updating and
        (   nvl(p_period_months,hr_api.g_number)
            <> nvl(per_pem_shd.g_old_rec.period_months,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 15);
      if p_period_months not between 0 and 11 then
        hr_utility.set_location(l_proc, 20);
        fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
        fnd_message.set_token('RANGE_START','0',true);
        fnd_message.set_token('RANGE_END','11',true);
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.PERIOD_MONTHS'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end chk_period_months;
--
-- -----------------------------------------------------------------------
-- |---------------------------< chk_period_days >-----------------------|
-- -----------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that period_days is between 0 and 365
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_period_days
--  p_previous_employer_id
--  p_object_version_number
--
-- Post Success:
--   Processing continues if period_days is between 0 and 365
--
-- Post Failure:
--   An application error is raised if period_days value is not in range
--   of 0 and 365.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_period_days
          (p_period_days
           in  per_previous_employers.period_days%type
          ,p_previous_employer_id
           in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
           in  per_previous_employers.object_version_number%type) is
  l_proc          varchar2(72) := g_package||'chk_period_days';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_period_days is not null then
    l_api_updating := per_pem_shd.api_updating(p_previous_employer_id
                                              =>  p_previous_employer_id
                                              ,p_object_version_number
                                              =>  p_object_version_number);
    hr_utility.set_location(l_proc, 10);
    if ((l_api_updating and
        (   nvl(p_period_days,hr_api.g_number)
            <> nvl(per_pem_shd.g_old_rec.period_days,hr_api.g_number)
        )
       ) or
       (not l_api_updating)) then
      hr_utility.set_location(l_proc, 15);
      if p_period_days not between 0 and 365 then
        hr_utility.set_location(l_proc, 20);
        fnd_message.set_name('PER','HR_289534_PEM_VALID_PRD_RANGE');
        fnd_message.set_token('RANGE_START','0',true);
        fnd_message.set_token('RANGE_END','365',true);
        fnd_message.raise_error;
      end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.PERIOD_DAYS'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 30);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,40);
end chk_period_days;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_all_assignments >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that all_assignments is valid value and
--   this previous employer is not associated with any assignments.
--   Valid values for all_assignments are 'Y' and 'N'
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_employer_id
--  p_object_version_number
--  p_all_assignments
--
-- Post Success:
--   Processing continues if all_assignments value is valid and
--   this previous employer is not mapped to any assignment
--
--
-- Post Failure:
--   An application error is raised if all_assignments value is not valid
--   if there are any assignments mapped to this previous employer
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_all_assignments
          (p_previous_employer_id
          in  per_previous_employers.previous_employer_id%type
          ,p_object_version_number
          in  per_previous_employers.object_version_number%type
          ,p_all_assignments
          in  per_previous_employers.all_assignments%type) is
  cursor csr_pem_assignments is
       select previous_job_usage_id
       from   per_previous_job_usages
       where  previous_employer_id = p_previous_employer_id;
  l_previous_job_usage_id   per_previous_job_usages.previous_job_usage_id%type;
  --
  l_proc                varchar2(72) := g_package||'chk_all_assignments';
  l_api_updating        boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  if p_all_assignments is not null then
    hr_utility.set_location(l_proc, 10);
    l_api_updating := per_pem_shd.api_updating(p_previous_employer_id
                                              =>  p_previous_employer_id
                                              ,p_object_version_number
                                              =>  p_object_version_number
                                              );

    if ((l_api_updating and
         nvl(p_all_assignments,hr_api.g_varchar2)
          <> nvl(per_pem_shd.g_old_rec.all_assignments, hr_api.g_varchar2))
          or
          (not l_api_updating)) then
        hr_utility.set_location(l_proc, 15);
        if p_all_assignments = 'Y' or p_all_assignments = 'N' then
          hr_utility.set_location(l_proc, 20);
          if p_all_assignments = 'Y' then
            hr_utility.set_location(l_proc, 25);
            open    csr_pem_assignments;
            fetch   csr_pem_assignments into l_previous_job_usage_id;
            if csr_pem_assignments%found then
              hr_utility.set_location(l_proc, 30);
              close   csr_pem_assignments;
              fnd_message.set_name('PER','HR_289546_PEM_ALL_ASG_MOD_NA');
              hr_multi_message.add
          (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.PREVIOUS_EMPLOYER_ID'
               );
            end if;
            if  csr_pem_assignments%isopen then
              close csr_pem_assignments;
            end if;
          end if;
        else
          hr_utility.set_location(l_proc, 35);
          fnd_message.set_name('PER','HR_289545_PEM_VALID_ASGMT_FLAG');
          hr_multi_message.add
       (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.ALL_ASSIGNMENTS'
            );
        end if;
    end if;
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
end chk_all_assignments;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_business_group_id >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that business_group_id value is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_business_group_id
--  p_previous_employer_id
--  p_object_version_number
--  p_effective_date
--
-- Post Success:
--   Processing continues if business_group_id is valid and if updating,
--   old_rec.business_group_id is null
--
-- Post Failure:
--   An application error is raised
--   if updating and old_rec.business_group_id is not null, or
--   business_group_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_business_group_id
            (p_business_group_id
               in  per_previous_employers.business_group_id%type
            ,p_previous_employer_id
               in  per_previous_employers.previous_employer_id%type
            ,p_object_version_number
               in  per_previous_employers.object_version_number%type
            ,p_effective_date        in date) is
  --
  l_proc          varchar2(72) := g_package||'chk_business_group_id';
  l_api_updating  boolean;
  --
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  if p_business_group_id is not null then
    hr_utility.set_location(l_proc, 10);
    --
    --validate business_group_id
    --
    hr_api.validate_bus_grp_id(p_business_group_id);
  --
  end if;
  --
  --
  --update only if null
  --
  l_api_updating    := per_pem_shd.api_updating
                              (p_previous_employer_id  =>  p_previous_employer_id
                              ,p_object_version_number =>  p_object_version_number );
  if  (l_api_updating
        and per_pem_shd.g_old_rec.business_group_id is not null
        and per_pem_shd.g_old_rec.business_group_id <> p_business_group_id ) then
      --
      hr_utility.set_message(800, 'HR_289947_INV_UPD_BG_ID');
      hr_utility.raise_error;
      --
  end if;
  --
  hr_utility.set_location('Leaving:'||l_proc, 40);
exception
  when app_exception.application_exception then
    if hr_multi_message.exception_add
      (p_associated_column1  => 'PER_PREVIOUS_EMPLOYERS.BUSINESS_GROUP_ID'
      ) then
      hr_utility.set_location('Leaving:'||l_proc, 50);
      raise;
    end if;
    hr_utility.set_location('Leaving:'||l_proc,60);
end chk_business_group_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in per_pem_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --Validate Important Attributes
  --
  hr_utility.set_location(l_proc, 10);
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'EFFECTIVE_DATE'
  ,p_argument_value     => p_effective_date
  );
  -- Call all supporting business operations
  hr_utility.set_location(l_proc, 15);
  --
  if p_rec.party_id is null and p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 =>per_pem_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
    );  -- Validate Bus Grp
  end if;
  --After validating the set of important attributes,
  --if multiple message detection is enabled and atleast
  --one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  --validate dependent attributes
  --
  hr_utility.set_location(l_proc, 18);
  chk_business_group_id(p_business_group_id     =>  p_rec.business_group_id
                       ,p_previous_employer_id  =>  p_rec.previous_employer_id
                       ,p_object_version_number =>  p_rec.object_version_number
                       ,p_effective_date        =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  chk_person_id(p_person_id             =>  p_rec.person_id
               ,p_effective_date        =>  p_effective_date
               ,p_previous_employer_id  =>  p_rec.previous_employer_id
               ,p_object_version_number =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 25);
  chk_party_id(p_party_id               =>  p_rec.party_id
              ,p_previous_employer_id   =>  p_rec.previous_employer_id
              ,p_object_version_number  =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  chk_employer_country(p_previous_employer_id   =>  p_rec.previous_employer_id
                      ,p_object_version_number  =>  p_rec.object_version_number
                      ,p_employer_country       =>  p_rec.employer_country);
  --
  hr_utility.set_location(l_proc, 35);
  chk_employer_type(p_previous_employer_id    =>  p_rec.previous_employer_id
                   ,p_object_version_number   =>  p_rec.object_version_number
                   ,p_employer_type           =>  p_rec.employer_type
                   ,p_effective_date          =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 40);
  chk_employer_subtype(p_previous_employer_id   =>  p_rec.previous_employer_id
                      ,p_object_version_number  =>  p_rec.object_version_number
                      ,p_employer_type          =>  p_rec.employer_type
                      ,p_employer_subtype       =>  p_rec.employer_subtype
                      ,p_effective_date         =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 50);
  chk_start_end_dates(p_previous_employer_id    =>  p_rec.previous_employer_id
                     ,p_object_version_number   =>  p_rec.object_version_number
                     ,p_start_date              =>  p_rec.start_date
                     ,p_end_date                =>  p_rec.end_date
		     ,p_effective_date    =>  p_effective_date);  -- bug 7112425
  --
  hr_utility.set_location(l_proc, 55);
  chk_period_years(p_period_years
                   =>  p_rec.period_years
                  ,p_previous_employer_id
                   =>  p_rec.previous_employer_id
                  ,p_object_version_number
                   =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  chk_period_months(p_period_months
                    =>  p_rec.period_months
                   ,p_previous_employer_id
                    =>  p_rec.previous_employer_id
                   ,p_object_version_number
                    =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 65);
  chk_period_days(p_period_days
                  =>  p_rec.period_days
                 ,p_previous_employer_id
                  =>  p_rec.previous_employer_id
                 ,p_object_version_number
                  =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 70);
  chk_all_assignments(p_previous_employer_id    =>  p_rec.previous_employer_id
                     ,p_object_version_number   =>  p_rec.object_version_number
                     ,p_all_assignments         =>  p_rec.all_assignments);
  --
  hr_utility.set_location(l_proc, 75);
  per_pem_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 80);
  per_pem_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 85);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in per_pem_shd.g_rec_type
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
  hr_api.mandatory_arg_error
  (p_api_name           => l_proc
  ,p_argument           => 'EFFECTIVE_DATE'
  ,p_argument_value     => p_effective_date
  );
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
    ,p_rec                         => p_rec
    );
  --
  hr_utility.set_location(l_proc, 15);
  if p_rec.party_id is null and p_rec.business_group_id is not null then
    hr_api.validate_bus_grp_id
    (p_business_group_id  => p_rec.business_group_id
    ,p_associated_column1 =>per_pem_shd.g_tab_nam || '.BUSINESS_GROUP_ID'
    );  -- Validate Bus Grp
  end if;
  --
  --After validating the set of important attributes,
  --if multiple message detection is enabled and atleast
  --one error has been found then abort further validation.
  --
  hr_multi_message.end_validation_set;
  --
  --validate dependent attributes
  --
  hr_utility.set_location(l_proc, 18);
  chk_business_group_id(p_business_group_id     =>  p_rec.business_group_id
                       ,p_previous_employer_id  =>  p_rec.previous_employer_id
                       ,p_object_version_number =>  p_rec.object_version_number
                       ,p_effective_date        =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 20);
  chk_employer_country(p_previous_employer_id   =>  p_rec.previous_employer_id
                      ,p_object_version_number  =>  p_rec.object_version_number
                      ,p_employer_country       =>  p_rec.employer_country);
  --
  hr_utility.set_location(l_proc, 25);
  chk_employer_type(p_previous_employer_id    =>  p_rec.previous_employer_id
                   ,p_object_version_number   =>  p_rec.object_version_number
                   ,p_employer_type           =>  p_rec.employer_type
                   ,p_effective_date          =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 30);
  chk_employer_subtype(p_previous_employer_id   =>  p_rec.previous_employer_id
                      ,p_object_version_number  =>  p_rec.object_version_number
                      ,p_employer_type          =>  p_rec.employer_type
                      ,p_employer_subtype       =>  p_rec.employer_subtype
                      ,p_effective_date         =>  p_effective_date);
  --
  hr_utility.set_location(l_proc, 40);
  chk_start_end_dates(p_previous_employer_id    =>  p_rec.previous_employer_id
                     ,p_object_version_number   =>  p_rec.object_version_number
                     ,p_start_date              =>  p_rec.start_date
                     ,p_end_date                =>  p_rec.end_date
		     ,p_effective_date    =>  p_effective_date);  -- bug 7112425
  --
  hr_utility.set_location(l_proc, 45);
  chk_period_years(p_period_years
                   =>  p_rec.period_years
                  ,p_previous_employer_id
                   =>  p_rec.previous_employer_id
                  ,p_object_version_number
                   =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 50);
  chk_period_months(p_period_months
                    =>  p_rec.period_months
                   ,p_previous_employer_id
                    =>  p_rec.previous_employer_id
                   ,p_object_version_number
                    =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 55);
  chk_period_days(p_period_days
                  =>  p_rec.period_days
                 ,p_previous_employer_id
                  =>  p_rec.previous_employer_id
                 ,p_object_version_number
                  =>  p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 60);
  chk_all_assignments(p_previous_employer_id    =>  p_rec.previous_employer_id
                     ,p_object_version_number   =>  p_rec.object_version_number
                     ,p_all_assignments         =>  p_rec.all_assignments);
  --
  hr_utility.set_location(l_proc, 65);
  per_pem_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 70);
  per_pem_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 75);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pem_shd.g_rec_type
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
end per_pem_bus;

/
