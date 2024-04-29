--------------------------------------------------------
--  DDL for Package Body PER_PJI_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PJI_BUS" as
/* $Header: pepjirhi.pkb 115.8 2002/12/03 15:41:52 eumenyio ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  per_pji_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_previous_job_extra_info_id  number         default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_previous_job_id >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that previous_job_id is valid.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_id
--
-- Post Success:
--   Processing continues if previous_job_id is valid
--
--
-- Post Failure:
--   An application error is raised if previous_job_id is not valid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_previous_job_id
  (p_previous_job_id
   in  per_previous_jobs.previous_job_id%type
  ,p_previous_job_extra_info_id
   in  per_prev_job_extra_info.previous_job_extra_info_id%type
  ,p_object_version_number
   in  per_prev_job_extra_info.object_version_number%type) is
	cursor csr_previous_job_id is
		select 	previous_job_id
		from   	per_previous_jobs
		where 	previous_job_id = p_previous_job_id;
	l_previous_job_id 	per_previous_jobs.previous_job_id%type;
	--
	l_proc          varchar2(72) := g_package||'chk_previous_job_id';
  l_api_updating  boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    hr_utility.set_location(l_proc, 10);
    l_api_updating
          := per_pji_shd.api_updating(p_previous_job_extra_info_id
                                      =>  p_previous_job_extra_info_id
                                     ,p_object_version_number
                                      =>  p_object_version_number
                                     );
    if  ((l_api_updating
        and nvl(per_pji_shd.g_old_rec.previous_job_id, hr_api.g_number)
            <> nvl(p_previous_job_id,hr_api.g_number))
        or
        (not l_api_updating)) then
        hr_utility.set_location(l_proc, 15);
	      open  csr_previous_job_id;
	      fetch csr_previous_job_id into	l_previous_job_id;
	      if csr_previous_job_id%notfound then
          hr_utility.set_location(l_proc, 20);
		      close csr_previous_job_id;
          fnd_message.set_name('PER','HR_289540_PJI_INV_PREV_JOB_ID');
          fnd_message.raise_error;
        end if;
	      if csr_previous_job_id%isopen then
	        close csr_previous_job_id;
	      end if;
    end if;
	--
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
	when others then
		raise;
end chk_previous_job_id;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_information_type >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure ensures that information_type is valid
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--  p_previous_job_extra_info_id
--  p_object_version_number
--  p_information_type
--
-- Post Success:
--   Processing continues if information_type is valid.
--
--
-- Post Failure:
--   An application error is raised if information_type is invalid.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
procedure chk_information_type
	(p_previous_job_extra_info_id
  in  per_prev_job_extra_info.previous_job_extra_info_id%type
  ,p_object_version_number
  in  per_prev_job_extra_info.object_version_number%type
  ,p_information_type
  in  per_prev_job_extra_info.information_type%type) is
	cursor csr_information_type is
		select 	information_type
		from   	per_prev_job_info_types
		where 	information_type = p_information_type
		and     active_inactive_flag = 'Y';
	l_information_type per_prev_job_extra_info.information_type%type;
	--
	l_proc            varchar2(72) := g_package||'chk_information_type';
  l_api_updating    boolean;
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
	--
    hr_utility.set_location(l_proc, 10);
    l_api_updating
          := per_pji_shd.api_updating(p_previous_job_extra_info_id
                                      =>  p_previous_job_extra_info_id
                                      ,p_object_version_number
                                      =>  p_object_version_number
                                     );
    if  ((l_api_updating
        and nvl(per_pji_shd.g_old_rec.information_type, hr_api.g_varchar2)
            <> nvl(p_information_type,hr_api.g_varchar2))
        or
        (not l_api_updating)) then
          hr_utility.set_location(l_proc, 15);
          open csr_information_type;
          fetch csr_information_type into l_information_type;
          if  csr_information_type%notfound then
            hr_utility.set_location(l_proc, 20);
            close csr_information_type;
            fnd_message.set_name('PER','HR_289539_PJI_INV_INFO_TYPE');
            fnd_message.raise_error;
          end if;
          if csr_information_type%isopen then
            close csr_information_type;
	        end if;
	  end if;
	--
  hr_utility.set_location('Leaving:'||l_proc, 25);
exception
	when others then
		raise;
end chk_information_type;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_previous_job_extra_info_id           in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups     pbg
         , per_prev_job_extra_info pji
      	 , per_previous_jobs       pjo
      	 , per_previous_employers  pem
     where pji.previous_job_extra_info_id 	= p_previous_job_extra_info_id
     and   pji.previous_job_id 				      = pjo.previous_job_id
     and   pjo.previous_employer_id 	      = pem.previous_employer_id
     and   pbg.business_group_id 			      = pem.business_group_id;
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
    ,p_argument           => 'previous_job_extra_info_id'
    ,p_argument_value     => p_previous_job_extra_info_id
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
  (p_previous_job_extra_info_id           in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  cursor csr_leg_code is
     select pbg.legislation_code
     from  per_business_groups     pbg
         , per_prev_job_extra_info pji
         , per_previous_jobs       pjo
         , per_previous_employers  pem
     where pji.previous_job_extra_info_id 	= p_previous_job_extra_info_id
     and   pji.previous_job_id 				      = pjo.previous_job_id
     and   pjo.previous_employer_id 		    = pem.previous_employer_id(+)
     and   pem.business_group_id            = pbg.business_group_id(+);
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
    ,p_argument           => 'previous_job_extra_info_id'
    ,p_argument_value     => p_previous_job_extra_info_id
    );
  --
  if ( nvl(per_pji_bus.g_previous_job_extra_info_id, hr_api.g_number)
       = p_previous_job_extra_info_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := per_pji_bus.g_legislation_code;
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
    per_pji_bus.g_previous_job_extra_info_id  := p_previous_job_extra_info_id;
    per_pji_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in per_pji_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_job_extra_info_id is not null)  and (
    nvl(per_pji_shd.g_old_rec.information_type, hr_api.g_varchar2) <>
    nvl(p_rec.information_type, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information_category, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information1, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information1, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information2, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information2, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information3, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information3, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information4, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information4, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information5, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information5, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information6, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information6, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information7, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information7, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information8, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information8, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information9, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information9, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information10, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information10, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information11, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information11, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information12, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information12, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information13, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information13, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information14, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information14, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information15, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information15, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information16, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information16, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information17, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information17, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information18, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information18, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information19, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information19, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information20, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information20, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information21, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information21, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information22, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information22, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information23, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information23, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information24, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information24, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information25, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information25, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information26, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information26, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information27, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information27, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information28, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information28, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information29, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information29, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_information30, hr_api.g_varchar2) <>
    nvl(p_rec.pji_information30, hr_api.g_varchar2) ))
    or (p_rec.previous_job_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'Extra Previous Job DDF'
      ,p_attribute_category              => p_rec.pji_information_category
      ,p_attribute1_name                 => 'PJI_INFORMATION1'
      ,p_attribute1_value                => p_rec.pji_information1
      ,p_attribute2_name                 => 'PJI_INFORMATION2'
      ,p_attribute2_value                => p_rec.pji_information2
      ,p_attribute3_name                 => 'PJI_INFORMATION3'
      ,p_attribute3_value                => p_rec.pji_information3
      ,p_attribute4_name                 => 'PJI_INFORMATION4'
      ,p_attribute4_value                => p_rec.pji_information4
      ,p_attribute5_name                 => 'PJI_INFORMATION5'
      ,p_attribute5_value                => p_rec.pji_information5
      ,p_attribute6_name                 => 'PJI_INFORMATION6'
      ,p_attribute6_value                => p_rec.pji_information6
      ,p_attribute7_name                 => 'PJI_INFORMATION7'
      ,p_attribute7_value                => p_rec.pji_information7
      ,p_attribute8_name                 => 'PJI_INFORMATION8'
      ,p_attribute8_value                => p_rec.pji_information8
      ,p_attribute9_name                 => 'PJI_INFORMATION9'
      ,p_attribute9_value                => p_rec.pji_information9
      ,p_attribute10_name                => 'PJI_INFORMATION10'
      ,p_attribute10_value               => p_rec.pji_information10
      ,p_attribute11_name                => 'PJI_INFORMATION11'
      ,p_attribute11_value               => p_rec.pji_information11
      ,p_attribute12_name                => 'PJI_INFORMATION12'
      ,p_attribute12_value               => p_rec.pji_information12
      ,p_attribute13_name                => 'PJI_INFORMATION13'
      ,p_attribute13_value               => p_rec.pji_information13
      ,p_attribute14_name                => 'PJI_INFORMATION14'
      ,p_attribute14_value               => p_rec.pji_information14
      ,p_attribute15_name                => 'PJI_INFORMATION15'
      ,p_attribute15_value               => p_rec.pji_information15
      ,p_attribute16_name                => 'PJI_INFORMATION16'
      ,p_attribute16_value               => p_rec.pji_information16
      ,p_attribute17_name                => 'PJI_INFORMATION17'
      ,p_attribute17_value               => p_rec.pji_information17
      ,p_attribute18_name                => 'PJI_INFORMATION18'
      ,p_attribute18_value               => p_rec.pji_information18
      ,p_attribute19_name                => 'PJI_INFORMATION19'
      ,p_attribute19_value               => p_rec.pji_information20
      ,p_attribute20_name                => 'PJI_INFORMATION20'
      ,p_attribute20_value               => p_rec.pji_information20
      ,p_attribute21_name                => 'PJI_INFORMATION21'
      ,p_attribute21_value               => p_rec.pji_information21
      ,p_attribute22_name                => 'PJI_INFORMATION22'
      ,p_attribute22_value               => p_rec.pji_information22
      ,p_attribute23_name                => 'PJI_INFORMATION23'
      ,p_attribute23_value               => p_rec.pji_information23
      ,p_attribute24_name                => 'PJI_INFORMATION24'
      ,p_attribute24_value               => p_rec.pji_information24
      ,p_attribute25_name                => 'PJI_INFORMATION25'
      ,p_attribute25_value               => p_rec.pji_information25
      ,p_attribute26_name                => 'PJI_INFORMATION26'
      ,p_attribute26_value               => p_rec.pji_information26
      ,p_attribute27_name                => 'PJI_INFORMATION27'
      ,p_attribute27_value               => p_rec.pji_information27
      ,p_attribute28_name                => 'PJI_INFORMATION28'
      ,p_attribute28_value               => p_rec.pji_information28
      ,p_attribute29_name                => 'PJI_INFORMATION29'
      ,p_attribute29_value               => p_rec.pji_information29
      ,p_attribute30_name                => 'PJI_INFORMATION30'
      ,p_attribute30_value               => p_rec.pji_information30
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
  (p_rec in per_pji_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_df';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.previous_job_extra_info_id is not null)  and (
    nvl(per_pji_shd.g_old_rec.pji_attribute_category, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute_category, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute1, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute1, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute2, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute2, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute3, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute3, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute4, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute4, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute5, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute5, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute6, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute6, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute7, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute7, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute8, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute8, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute9, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute9, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute10, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute10, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute11, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute11, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute12, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute12, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute13, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute13, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute14, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute14, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute15, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute15, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute16, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute16, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute17, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute17, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute18, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute18, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute19, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute19, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute20, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute20, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute21, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute21, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute22, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute22, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute23, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute23, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute24, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute24, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute25, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute25, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute26, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute26, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute27, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute27, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute28, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute28, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute29, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute29, hr_api.g_varchar2)  or
    nvl(per_pji_shd.g_old_rec.pji_attribute30, hr_api.g_varchar2) <>
    nvl(p_rec.pji_attribute30, hr_api.g_varchar2) ))
    or (p_rec.previous_job_extra_info_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'PER'
      ,p_descflex_name                   => 'PER_PREV_JOB_EXTRA_INFO'
      ,p_attribute_category              => p_rec.pji_attribute_category
      ,p_attribute1_name                 => 'PJI_ATTRIBUTE1'
      ,p_attribute1_value                => p_rec.pji_attribute1
      ,p_attribute2_name                 => 'PJI_ATTRIBUTE2'
      ,p_attribute2_value                => p_rec.pji_attribute2
      ,p_attribute3_name                 => 'PJI_ATTRIBUTE3'
      ,p_attribute3_value                => p_rec.pji_attribute3
      ,p_attribute4_name                 => 'PJI_ATTRIBUTE4'
      ,p_attribute4_value                => p_rec.pji_attribute4
      ,p_attribute5_name                 => 'PJI_ATTRIBUTE5'
      ,p_attribute5_value                => p_rec.pji_attribute5
      ,p_attribute6_name                 => 'PJI_ATTRIBUTE6'
      ,p_attribute6_value                => p_rec.pji_attribute6
      ,p_attribute7_name                 => 'PJI_ATTRIBUTE7'
      ,p_attribute7_value                => p_rec.pji_attribute7
      ,p_attribute8_name                 => 'PJI_ATTRIBUTE8'
      ,p_attribute8_value                => p_rec.pji_attribute8
      ,p_attribute9_name                 => 'PJI_ATTRIBUTE9'
      ,p_attribute9_value                => p_rec.pji_attribute9
      ,p_attribute10_name                => 'PJI_ATTRIBUTE10'
      ,p_attribute10_value               => p_rec.pji_attribute10
      ,p_attribute11_name                => 'PJI_ATTRIBUTE11'
      ,p_attribute11_value               => p_rec.pji_attribute11
      ,p_attribute12_name                => 'PJI_ATTRIBUTE12'
      ,p_attribute12_value               => p_rec.pji_attribute12
      ,p_attribute13_name                => 'PJI_ATTRIBUTE13'
      ,p_attribute13_value               => p_rec.pji_attribute13
      ,p_attribute14_name                => 'PJI_ATTRIBUTE14'
      ,p_attribute14_value               => p_rec.pji_attribute14
      ,p_attribute15_name                => 'PJI_ATTRIBUTE15'
      ,p_attribute15_value               => p_rec.pji_attribute15
      ,p_attribute16_name                => 'PJI_ATTRIBUTE16'
      ,p_attribute16_value               => p_rec.pji_attribute16
      ,p_attribute17_name                => 'PJI_ATTRIBUTE17'
      ,p_attribute17_value               => p_rec.pji_attribute17
      ,p_attribute18_name                => 'PJI_ATTRIBUTE18'
      ,p_attribute18_value               => p_rec.pji_attribute18
      ,p_attribute19_name                => 'PJI_ATTRIBUTE19'
      ,p_attribute19_value               => p_rec.pji_attribute19
      ,p_attribute20_name                => 'PJI_ATTRIBUTE20'
      ,p_attribute20_value               => p_rec.pji_attribute20
      ,p_attribute21_name                => 'PJI_ATTRIBUTE21'
      ,p_attribute21_value               => p_rec.pji_attribute21
      ,p_attribute22_name                => 'PJI_ATTRIBUTE22'
      ,p_attribute22_value               => p_rec.pji_attribute22
      ,p_attribute23_name                => 'PJI_ATTRIBUTE23'
      ,p_attribute23_value               => p_rec.pji_attribute23
      ,p_attribute24_name                => 'PJI_ATTRIBUTE24'
      ,p_attribute24_value               => p_rec.pji_attribute24
      ,p_attribute25_name                => 'PJI_ATTRIBUTE25'
      ,p_attribute25_value               => p_rec.pji_attribute25
      ,p_attribute26_name                => 'PJI_ATTRIBUTE26'
      ,p_attribute26_value               => p_rec.pji_attribute26
      ,p_attribute27_name                => 'PJI_ATTRIBUTE27'
      ,p_attribute27_value               => p_rec.pji_attribute27
      ,p_attribute28_name                => 'PJI_ATTRIBUTE28'
      ,p_attribute28_value               => p_rec.pji_attribute28
      ,p_attribute29_name                => 'PJI_ATTRIBUTE29'
      ,p_attribute29_value               => p_rec.pji_attribute29
      ,p_attribute30_name                => 'PJI_ATTRIBUTE30'
      ,p_attribute30_value               => p_rec.pji_attribute30
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
  (p_rec in per_pji_shd.g_rec_type
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
  IF NOT per_pji_shd.api_updating
    (p_previous_job_extra_info_id           => p_rec.previous_job_extra_info_id
    ,p_object_version_number                => p_rec.object_version_number
    ) THEN
     fnd_message.set_name('PER', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  -- Check for non updateable args
  if per_pji_shd.g_old_rec.previous_job_extra_info_id
     <> p_rec.previous_job_extra_info_id
     then
     hr_api.argument_changed_error
       (p_api_name => l_proc
       ,p_argument => 'previous_job_extra_info_id'
       );
  end if;
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
  (p_rec                          in per_pji_shd.g_rec_type) is
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Check whether the Previous Job Id is Valid
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'previous_job_id'
    ,p_argument_value     => p_rec.previous_job_id
    );
  --
    hr_api.mandatory_arg_error
      (p_api_name           => l_proc
      ,p_argument           => 'information_type'
      ,p_argument_value     => p_rec.information_type
      );
  --
  hr_utility.set_location(l_proc, 10);
  chk_previous_job_id(p_previous_job_id
                      =>  p_rec.previous_job_id
                     ,p_previous_job_extra_info_id
                      =>  p_rec.previous_job_extra_info_id
                     ,p_object_version_number
                      =>  p_rec.object_version_number);
  -- Check for valid Information Types for selected Previous Job
  hr_utility.set_location(l_proc, 15);
  chk_information_type(p_previous_job_extra_info_id
                       =>  p_rec.previous_job_extra_info_id
                      ,p_object_version_number
                       =>  p_rec.object_version_number
                      ,p_information_type
                       =>  p_rec.information_type);
  -- Call all supporting business operations
  hr_utility.set_location(l_proc, 20);
 	per_pji_bus.chk_ddf(p_rec);
  --
  hr_utility.set_location(l_proc, 25);
	per_pji_bus.chk_df(p_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_rec                          in per_pji_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'previous_job_id'
    ,p_argument_value     => p_rec.previous_job_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'information_type'
    ,p_argument_value     => p_rec.information_type
    );
  --
    hr_utility.set_location(l_proc, 10);
    chk_non_updateable_args(p_rec              => p_rec);
  -- Check for valid Information Types for selected Previous Job
    hr_utility.set_location(l_proc, 20);
    chk_information_type(p_previous_job_extra_info_id
                         =>  p_rec.previous_job_extra_info_id
                        ,p_object_version_number
                         =>  p_rec.object_version_number
                        ,p_information_type
                         =>  p_rec.information_type);
  	--
    hr_utility.set_location(l_proc, 25);
  	per_pji_bus.chk_ddf(p_rec);
  	--
    hr_utility.set_location(l_proc, 30);
  	per_pji_bus.chk_df(p_rec);
  	--
  	hr_utility.set_location(' Leaving:'||l_proc, 35);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in per_pji_shd.g_rec_type
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
end per_pji_bus;

/
