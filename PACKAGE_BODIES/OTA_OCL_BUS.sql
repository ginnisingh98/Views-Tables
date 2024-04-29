--------------------------------------------------------
--  DDL for Package Body OTA_OCL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OCL_BUS" as
/* $Header: otoclrhi.pkb 120.1.12000000.2 2007/02/07 09:19:37 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_ocl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_competence_language_id      number         default null;
--

procedure check_lang_code(p_rec                          in ota_ocl_shd.g_rec_type)
is
begin
 If p_rec.language_code IS NULL THEN
       fnd_message.set_name      ( 'OTA','OTA_467063_MAND_LANGUAGE_CODE');
       fnd_message.raise_error;
  END IF;

end;
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_competence_language_id               in number
  ) is
  --
  -- Declare cursor
  --
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , ota_competence_languages ocl
     where ocl.competence_language_id = p_competence_language_id
       and pbg.business_group_id = ocl.business_group_id;
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
    ,p_argument           => 'competence_language_id'
    ,p_argument_value     => p_competence_language_id
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
  (p_competence_language_id               in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups pbg
         , ota_competence_languages ocl
     where ocl.competence_language_id = p_competence_language_id
       and pbg.business_group_id = ocl.business_group_id;
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
    ,p_argument           => 'competence_language_id'
    ,p_argument_value     => p_competence_language_id
    );
  --
  if ( nvl(ota_ocl_bus.g_competence_language_id, hr_api.g_number)
       = p_competence_language_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := ota_ocl_bus.g_legislation_code;
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
    ota_ocl_bus.g_competence_language_id:= p_competence_language_id;
    ota_ocl_bus.g_legislation_code  := l_legislation_code;
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
  (p_rec in ota_ocl_shd.g_rec_type
  ) is
--
  l_proc   varchar2(72) := g_package || 'chk_ddf';
--
begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  if ((p_rec.competence_language_id is not null)  and (
    nvl(ota_ocl_shd.g_old_rec.ocl_information_category, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information_category, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information1, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information1, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information2, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information2, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information3, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information3, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information4, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information4, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information5, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information5, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information6, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information6, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information7, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information7, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information8, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information8, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information9, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information9, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information10, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information10, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information11, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information11, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information12, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information12, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information13, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information13, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information14, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information14, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information15, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information15, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information16, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information16, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information17, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information17, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information18, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information18, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information19, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information19, hr_api.g_varchar2)  or
    nvl(ota_ocl_shd.g_old_rec.ocl_information20, hr_api.g_varchar2) <>
    nvl(p_rec.ocl_information20, hr_api.g_varchar2) ))
    or (p_rec.competence_language_id is null)  then
    --
    -- Only execute the validation if absolutely necessary:
    -- a) During update, the structure column value or any
    --    of the attribute values have actually changed.
    -- b) During insert.
    --
    hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name                 => 'OTA'
      ,p_descflex_name                   => 'OTA_COMPETENCE_LANGUAGES'
    --  ,p_attribute20_name                => 'OCL_INFORMATION20'
    --  ,p_attribute20_value               => p_rec.ocl_information20
      ,p_attribute_category              => p_rec.OCL_INFORMATION_CATEGORY
      ,p_attribute1_name                 => 'OCL_INFORMATION1'
      ,p_attribute1_value                => p_rec.ocl_information1
      ,p_attribute2_name                 => 'OCL_INFORMATION2'
      ,p_attribute2_value                => p_rec.ocl_information2
      ,p_attribute3_name                 => 'OCL_INFORMATION3'
      ,p_attribute3_value                => p_rec.ocl_information3
      ,p_attribute4_name                 => 'OCL_INFORMATION4'
      ,p_attribute4_value                => p_rec.ocl_information4
      ,p_attribute5_name                 => 'OCL_INFORMATION5'
      ,p_attribute5_value                => p_rec.ocl_information5
      ,p_attribute6_name                 => 'OCL_INFORMATION6'
      ,p_attribute6_value                => p_rec.ocl_information6
      ,p_attribute7_name                 => 'OCL_INFORMATION7'
      ,p_attribute7_value                => p_rec.ocl_information7
      ,p_attribute8_name                 => 'OCL_INFORMATION8'
      ,p_attribute8_value                => p_rec.ocl_information8
      ,p_attribute9_name                 => 'OCL_INFORMATION9'
      ,p_attribute9_value                => p_rec.ocl_information9
      ,p_attribute10_name                => 'OCL_INFORMATION10'
      ,p_attribute10_value               => p_rec.ocl_information10
      ,p_attribute11_name                => 'OCL_INFORMATION11'
      ,p_attribute11_value               => p_rec.ocl_information11
      ,p_attribute12_name                => 'OCL_INFORMATION12'
      ,p_attribute12_value               => p_rec.ocl_information12
      ,p_attribute13_name                => 'OCL_INFORMATION13'
      ,p_attribute13_value               => p_rec.ocl_information13
      ,p_attribute14_name                => 'OCL_INFORMATION14'
      ,p_attribute14_value               => p_rec.ocl_information14
      ,p_attribute15_name                => 'OCL_INFORMATION15'
      ,p_attribute15_value               => p_rec.ocl_information15
      ,p_attribute16_name                => 'OCL_INFORMATION16'
      ,p_attribute16_value               => p_rec.ocl_information16
      ,p_attribute17_name                => 'OCL_INFORMATION17'
      ,p_attribute17_value               => p_rec.ocl_information17
      ,p_attribute18_name                => 'OCL_INFORMATION18'
      ,p_attribute18_value               => p_rec.ocl_information18
      ,p_attribute19_name                => 'OCL_INFORMATION19'
      ,p_attribute19_value               => p_rec.ocl_information19
      ,p_attribute20_name                => 'OCL_INFORMATION20'
      ,p_attribute20_value               => p_rec.ocl_information20
      );
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc,20);
end chk_ddf;
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
  ,p_rec in ota_ocl_shd.g_rec_type
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
  IF NOT ota_ocl_shd.api_updating
      (p_competence_language_id               => p_rec.competence_language_id
      ,p_object_version_number                => p_rec.object_version_number
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
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_competence>----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_competence
  (p_competence_language_id 	    in number
  ,p_effective_date               in date
  ,p_competence_id                in number
  ,p_business_group_id            in number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_competence';
  l_exists	varchar2(1);

  l_business_group_id  number := fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID');
  l_hr_cross		 	varchar2(2) := fnd_profile.value('HR_CROSS_BUSINESS_GROUP');

--
 CURSOR csr_competence
 IS
 SELECT null
 FROM PER_COMPETENCES
 WHERE COMPETENCE_ID = p_competence_id and
 Business_group_id = l_business_group_id ;

CURSOR csr_competence_cross
IS
 SELECT null
FROM per_competences
WHERE COMPETENCE_ID = p_competence_id and
(business_group_id = l_business_group_id OR
 business_group_id is null);

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
   if l_business_group_id is null then
      l_business_group_id := p_business_group_id;
   end if;



  -- Call all supporting business operations
  if (((p_competence_language_id is not null) and
      nvl(ota_ocl_shd.g_old_rec.competence_id,hr_api.g_number) <>
         nvl(p_competence_id,hr_api.g_number))
   or (p_competence_language_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_competence_id is not null) then
         hr_utility.set_location('Entering:'||l_proc, 15);
         if ( fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID') is null and
		 l_hr_cross ='N') or
               (fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID') is not null and
		 l_hr_cross = 'N' )then
            open csr_competence;
            fetch csr_competence into l_exists;
            if csr_competence%notfound then
               close csr_competence;
               fnd_message.set_name('OTA','OTA_OCL_COMP_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close csr_competence;
            hr_utility.set_location('Entering:'||l_proc, 20);
          elsif ( fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID') is not null and
		 l_hr_cross ='Y') or
               (fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID') is null and
		 l_hr_cross ='Y' )then
            hr_utility.set_location('Entering:'||l_proc, 25);
            open csr_competence_cross;
            fetch csr_competence_cross into l_exists;
            if csr_competence_cross%notfound then
               close csr_competence_cross;
               fnd_message.set_name('OTA','OTA_OCL_COMP_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close csr_competence_cross;
            hr_utility.set_location('Entering:'||l_proc, 30);

          end if;
      end if;
end if;

  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 35);
End chk_competence;

-- ----------------------------------------------------------------------------
-- |---------------------------< chk_proficiency>----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_proficiency
  (p_competence_language_id 	    in number
  ,p_effective_date               in date
  ,p_competence_id                in number
  ,p_min_proficiency_level_id     in number
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_proficiency';
  l_exists	varchar2(1);

--
 CURSOR csr_proficiency
 IS
 /*  Modified for bug#4905777
 SELECT null
 FROM PER_COMPETENCE_LEVELS_V
 WHERE COMPETENCE_ID = p_competence_id AND
 RATING_LEVEL_ID = p_min_proficiency_level_id
 ;
 */
  select null
 from
   per_rating_levels prl
  ,per_competences pce
where (prl.rating_scale_id = pce.rating_scale_id
     OR pce.competence_id = prl.competence_id)
     AND pce.competence_id = p_competence_id
     AND prl.rating_level_id = p_min_proficiency_level_id;


Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  if (((p_competence_language_id is not null) and
      nvl(ota_ocl_shd.g_old_rec.min_proficiency_level_id,hr_api.g_number) <>
         nvl(p_min_proficiency_level_id,hr_api.g_number))
   or (p_competence_language_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_min_proficiency_level_id is not null) then
          hr_utility.set_location('Entering:'||l_proc, 15);
            open csr_proficiency ;
            fetch csr_proficiency  into l_exists;
            if csr_proficiency %notfound then
               close csr_proficiency ;
               fnd_message.set_name('OTA','OTA_OCL_PROF_LEVEL_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close csr_proficiency;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;

  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_proficiency;


-- ----------------------------------------------------------------------------
-- |------------------------------< chk_language>----------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_language
  (p_competence_language_id 	    in number
  ,p_effective_date               in date
  ,p_language_code                 in varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'chk_language';
  l_exists	varchar2(1);

--
 CURSOR csr_language
 IS
 SELECT null
 FROM OTA_NATURAL_LANGUAGES_V
 WHERE LANGUAGE_code = p_language_code;

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  if (((p_competence_language_id is not null) and
      nvl(ota_ocl_shd.g_old_rec.language_code,hr_api.g_number) <>
         nvl(p_language_code,hr_api.g_varchar2))
   or (p_competence_language_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_language_code is not null) then
          hr_utility.set_location('Entering:'||l_proc, 15);
            open csr_language;
            fetch csr_language into l_exists;
            if csr_language%notfound then
               close csr_language;
               fnd_message.set_name('OTA','OTA_OCL_LANG_NOT_EXIST');
               fnd_message.raise_error;
            end if;
            close csr_language;
            hr_utility.set_location('Entering:'||l_proc, 20);
      end if;
end if;

  --
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End chk_language;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  --
  ota_ocl_bus.chk_ddf(p_rec);

   check_lang_code(p_rec);

  chk_competence
  (p_competence_language_id => p_rec.competence_language_id
  ,p_effective_date         => p_effective_date
  ,p_competence_id          => p_rec.competence_id
  ,p_business_group_id      => p_rec.business_group_id );

   chk_proficiency
  (p_competence_language_id 	    => p_rec.competence_language_id
  ,p_effective_date               => p_effective_date
  ,p_competence_id                => p_rec.competence_id
  ,p_min_proficiency_level_id     => p_rec.min_proficiency_level_id
  ) ;

  chk_language
  (p_competence_language_id 	    => p_rec.competence_language_id
  ,p_effective_date               => p_effective_date
  ,p_language_code                  => p_rec.language_code
  ) ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_effective_date               in date
  ,p_rec                          in ota_ocl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);  -- Validate Bus Grp
  --
  chk_non_updateable_args
    (p_effective_date              => p_effective_date
      ,p_rec              => p_rec
    );
  --
  --
   check_lang_code(p_rec);
  ota_ocl_bus.chk_ddf(p_rec);
 --
 chk_competence
  (p_competence_language_id => p_rec.competence_language_id
  ,p_effective_date         => p_effective_date
  ,p_competence_id          => p_rec.competence_id
  ,p_business_group_id      => p_rec.business_group_id );

   chk_proficiency
  (p_competence_language_id 	    => p_rec.competence_language_id
  ,p_effective_date               => p_effective_date
  ,p_competence_id                => p_rec.competence_id
  ,p_min_proficiency_level_id     => p_rec.min_proficiency_level_id
  ) ;

  chk_language
  (p_competence_language_id 	    => p_rec.competence_language_id
  ,p_effective_date               => p_effective_date
  ,p_language_code                 => p_rec.language_code
  ) ;


  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in ota_ocl_shd.g_rec_type
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
end ota_ocl_bus;

/
